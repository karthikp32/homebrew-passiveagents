#!/usr/bin/env bash
set -euo pipefail

PA_CLAUDE_PKG="${PA_CLAUDE_PKG:-@anthropic-ai/claude-code}"
PA_CODEX_PKG="${PA_CODEX_PKG:-@openai/codex}"
PA_GEMINI_PKG="${PA_GEMINI_PKG:-@google/gemini-cli}"
PA_OPENCODE_PKG="${PA_OPENCODE_PKG:-opencode-ai}"

say() {
  printf "%s\n" "$*"
}

confirm() {
  local prompt="$1"
  while true; do
    read -r -p "$prompt [y/N]: " ans
    case "${ans:-}" in
      y|Y|yes|YES) return 0 ;;
      n|N|no|NO|"") return 1 ;;
      *) say "Please answer y or n." ;;
    esac
  done
}

require_cmd() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    say "Missing required command: $name"
    return 1
  fi
}

is_root_or_has_sudo() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    return 0
  fi
  command -v sudo >/dev/null 2>&1
}

ensure_homebrew() {
    if command -v brew >/dev/null 2>&1; then
      say "Homebrew is already installed."
      return 0
    fi

    local os
    os="$(uname -s)"
    if [[ "$os" != "Darwin" && "$os" != "Linux" ]]; then
      say "Homebrew installation is not supported on ${os}."
      return 1
    fi

    say "Homebrew is required for PassiveAgents installation."
    if ! confirm "Install Homebrew now?"; then
      say "Homebrew is required. Please install from https://brew.sh and rerun this script."
      return 1
    fi

    say "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
      say "Installed Homebrew."

      # Ensure Homebrew is in PATH for this session and future sessions
      if [[ "$os" == "Linux" ]]; then
        local homebrew_init
        homebrew_init="$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        eval "$homebrew_init"

        # Add to shell profiles so it persists
        local profile
        for profile in ~/.bashrc ~/.zshrc ~/.bash_profile; do
          if [[ -f "$profile" ]]; then
            if ! grep -q "Homebrew initialization" "$profile" 2>/dev/null; then
              printf '\n# Homebrew initialization\neval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"\n' >>"$profile"
            fi
          fi
        done
      fi
      return 0
    else
      say "Homebrew installation failed. Visit https://brew.sh for manual installation."
      return 1
    fi
  }

install_passiveagents() {
  say "Installing PassiveAgents via Homebrew..."
  if brew tap karthikp32/passiveagents; then
    if brew install passiveagents; then
      say "Installed PassiveAgents."
      return 0
    else
      say "Failed to install passiveagents via brew. Check your internet connection and try again."
      return 1
    fi
  else
    say "Failed to tap the PassiveAgents Homebrew repository."
    return 1
  fi
}

run_with_optional_sudo() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    "$@"
    return
  fi
  sudo "$@"
}

ensure_nodejs() {
  if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    return 0
  fi

  say "At least one coding agent needs Node.js and npm."
  if ! confirm "Install Node.js now?"; then
    say "Skipping coding-agent downloads because Node.js was not approved."
    return 1
  fi

  local os
  os="$(uname -s)"
  case "$os" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        brew install node
      else
        say "Homebrew not found. Install Node.js manually from https://nodejs.org/ and rerun setup."
        return 1
      fi
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        if ! is_root_or_has_sudo; then
          say "Skipping Node.js install because elevated privileges are unavailable."
          return 1
        fi
        run_with_optional_sudo apt-get update
        run_with_optional_sudo apt-get install -y nodejs npm
      elif command -v dnf >/dev/null 2>&1; then
        if ! is_root_or_has_sudo; then
          say "Skipping Node.js install because elevated privileges are unavailable."
          return 1
        fi
        run_with_optional_sudo dnf install -y nodejs npm
      elif command -v pacman >/dev/null 2>&1; then
        if ! is_root_or_has_sudo; then
          say "Skipping Node.js install because elevated privileges are unavailable."
          return 1
        fi
        run_with_optional_sudo pacman -Sy --noconfirm nodejs npm
      else
        say "No supported package manager found. Install Node.js manually from https://nodejs.org/."
        return 1
      fi
      ;;
    *)
      say "Unsupported OS for automatic Node.js installation: ${os}."
      return 1
      ;;
  esac

  if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    say "Node.js installation did not complete successfully."
    return 1
  fi

  say "Installed Node.js and npm."
}

offer_agent_login() {
  local label="$1"
  local login_command="$2"
  local instructions="$3"

  say "${label} login command: ${login_command}"
  say "${instructions}"
  if ! confirm "Launch ${label} login now?"; then
    say "You can log in later with: ${login_command}"
    return
  fi

  if bash -lc "$login_command"; then
    say "${label} login flow finished."
  else
    say "${label} login command exited before completing. Retry later with: ${login_command}"
  fi
}

install_claude_code() {
  local label="Claude Code"
  local login_command="claude"
  local instructions="Claude Code opens its login/auth flow from the CLI session."

  say "Installing ${label}..."
  if bash -c "$(curl -fsSL https://claude.ai/install.sh)"; then
    say "Installed ${label}."
    offer_agent_login "$label" "$login_command" "$instructions"
  else
    say "Failed to install ${label}. You can install manually from https://code.claude.com/"
  fi
}

install_codex() {
  local label="Codex"
  local login_command="codex --login"
  local instructions="Codex starts the ChatGPT or API-key sign-in flow with the explicit login command."

  say "Installing ${label}..."
  if command -v brew >/dev/null 2>&1 && [[ "$(uname -s)" == "Darwin" ]]; then
    if brew install openai-codex; then
      say "Installed ${label}."
      offer_agent_login "$label" "$login_command" "$instructions"
      return 0
    fi
  fi

  # Fallback to npm
  if ensure_nodejs && npm install -g @openai/codex; then
    say "Installed ${label}."
    offer_agent_login "$label" "$login_command" "$instructions"
  else
    say "Failed to install ${label}. You can install manually from https://developers.openai.com/codex/cli"
  fi
}

install_gemini_cli() {
  local label="Gemini CLI"
  local login_command="gemini"
  local instructions="Gemini CLI lets you choose Google sign-in or API-key auth when it launches."

  say "Installing ${label}..."
  if command -v brew >/dev/null 2>&1; then
    if brew install gemini-cli; then
      say "Installed ${label}."
      offer_agent_login "$label" "$login_command" "$instructions"
      return 0
    fi
  fi

  # Fallback to npm
  if ensure_nodejs && npm install -g @google/gemini-cli; then
    say "Installed ${label}."
    offer_agent_login "$label" "$login_command" "$instructions"
  else
    say "Failed to install ${label}. You can install manually from https://github.com/google-gemini/gemini-cli"
  fi
}

install_opencode() {
  local label="OpenCode"
  local login_command="opencode auth login"
  local instructions="OpenCode starts its auth flow with the dedicated auth login command."

  say "Installing ${label}..."
  if bash -c "$(curl -fsSL https://opencode.ai/install)"; then
    say "Installed ${label}."
    offer_agent_login "$label" "$login_command" "$instructions"
  else
    # Fallback to npm
    if ensure_nodejs && npm install -g @opencode/cli; then
      say "Installed ${label}."
      offer_agent_login "$label" "$login_command" "$instructions"
    else
      say "Failed to install ${label}. You can install manually from https://opencode.ai/"
    fi
  fi
}

upsert_env_line() {
  local file="$1"
  local key="$2"
  local value="$3"
  local quoted_value
  local escaped_value
  mkdir -p "$(dirname "$file")"
  touch "$file"
  quoted_value="$(printf "'%s'" "$(printf '%s' "$value" | sed "s/'/'\\\\''/g")")"
  if grep -q "^export ${key}=" "$file"; then
    local tmp
    tmp="$(mktemp)"
    escaped_value="$(printf '%s\n' "$quoted_value" | sed 's/[|&\\]/\\&/g')"
    sed "s|^export ${key}=.*$|export ${key}=${escaped_value}|" "$file" >"$tmp"
    cat "$tmp" >"$file"
    rm -f "$tmp"
  else
    printf "\nexport %s=%s\n" "$key" "$quoted_value" >>"$file"
  fi
}

setup_api_key() {
  local key="$1"
  local profile="$2"
  if confirm "Configure ${key} now?"; then
    read -r -s -p "Enter ${key}: " value
    echo
    if [[ -n "${value}" ]]; then
      upsert_env_line "$profile" "$key" "$value"
      say "Saved ${key} to ${profile}."
    else
      say "No value entered; skipped ${key}."
    fi
  fi
}

install_cloudflared() {
  say "Cloudflare Tunnel is required for PassiveAgents remote access."
  say "This setup will install cloudflared if it is not already available."

  if command -v cloudflared >/dev/null 2>&1; then
    say "cloudflared is already installed."
    return
  fi

  local os
  os="$(uname -s)"
  case "$os" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        brew install cloudflared
      else
        say "Homebrew not found. Install from https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/"
        return 1
      fi
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        if ! is_root_or_has_sudo; then
          say "Skipping cloudflared install because elevated privileges are unavailable."
          return 1
        fi
        if ! command -v curl >/dev/null 2>&1; then
          say "Skipping cloudflared install because curl is required to add Cloudflare's APT repository."
          return 1
        fi
        run_with_optional_sudo mkdir -p --mode=0755 /usr/share/keyrings
        curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg |
          run_with_optional_sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
        printf '%s\n' \
          'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' |
          run_with_optional_sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
        run_with_optional_sudo apt-get update
        run_with_optional_sudo apt-get install -y cloudflared
      elif command -v dnf >/dev/null 2>&1; then
        if ! is_root_or_has_sudo; then
          say "Skipping cloudflared install because elevated privileges are unavailable."
          return 1
        fi
        run_with_optional_sudo dnf install -y cloudflared
      elif command -v pacman >/dev/null 2>&1; then
        if ! is_root_or_has_sudo; then
          say "Skipping cloudflared install because elevated privileges are unavailable."
          return 1
        fi
        run_with_optional_sudo pacman -Sy --noconfirm cloudflared
      else
        say "No supported package manager found. Install manually from Cloudflare docs."
        return 1
      fi
      ;;
    *)
      say "Unsupported OS for this script: ${os}."
      return 1
      ;;
  esac

  if ! command -v cloudflared >/dev/null 2>&1; then
    say "cloudflared installation did not complete successfully."
    return 1
  fi

  say "Installed cloudflared."
}

setup_allowlisted_folders() {
  say "Allowlisted folders control which local folders PassiveAgents may access."
  say "Tasks without a selected folder will use ~/.passiveagents/tasks/<task-id>."
  if ! confirm "Configure allowlisted folders now?"; then
    say "Skipped allowlisted folder setup."
    return
  fi

  if ! command -v passiveagents >/dev/null 2>&1; then
    say "The passiveagents CLI is not available yet."
    say "After installing it, run: passiveagents folders add /absolute/path"
    return
  fi

  while true; do
    read -r -p "Enter folder path (leave blank to finish): " folder_path
    folder_path="${folder_path:-}"
    if [[ -z "$folder_path" ]]; then
      break
    fi

    read -r -p "Optional label: " folder_label
    if [[ -n "${folder_label:-}" ]]; then
      if passiveagents folders add "$folder_path" --label "$folder_label"; then
        say "Added allowlisted folder ${folder_label}."
      else
        say "Failed to add allowlisted folder ${folder_path}."
      fi
    else
      if passiveagents folders add "$folder_path"; then
        say "Added allowlisted folder ${folder_path}."
      else
        say "Failed to add allowlisted folder ${folder_path}."
      fi
    fi

    if ! confirm "Add another allowlisted folder?"; then
      break
    fi
  done
}

login_passiveagents() {
  say "You need to log in to PassiveAgents with your email."
  if ! confirm "Log in to PassiveAgents now?"; then
    say "You can log in later with: passiveagents login"
    return
  fi

  passiveagents login
}

start_passiveagents() {
  say "PassiveAgents is now ready to start."
  if ! confirm "Start PassiveAgents manager now?"; then
    say "You can start it later with: passiveagents start"
    return
  fi

  passiveagents start
}

main() {
  say "Starting PassiveAgents setup (macOS/Linux)."

  # Install Homebrew and PassiveAgents first
  if ! ensure_homebrew; then
    say "Cannot continue without Homebrew."
    return 1
  fi

  if ! install_passiveagents; then
    say "Cannot continue without PassiveAgents."
    return 1
  fi

  say "Atleast one coding agent tool is required. cloudflared is required for remote access."

  local profile="${HOME}/.bashrc"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    profile="${HOME}/.bash_profile"
  fi
  if [[ -n "${ZSH_VERSION:-}" ]] || [[ "${SHELL:-}" == *"zsh"* ]]; then
    profile="${HOME}/.zshrc"
  fi

  local install_claude=0
  local install_codex=0
  local install_gemini=0
  local install_opencode=0

  confirm "Install Claude Code on this machine?" && install_claude=1
  confirm "Install Codex on this machine?" && install_codex=1
  confirm "Install Gemini CLI on this machine?" && install_gemini=1
  confirm "Install OpenCode on this machine?" && install_opencode=1

  if (( install_claude || install_codex || install_gemini || install_opencode )); then
    if (( install_claude )); then
      install_claude_code
    fi
    if (( install_codex )); then
      install_codex
    fi
    if (( install_gemini )); then
      install_gemini_cli
    fi
    if (( install_opencode )); then
      install_opencode
    fi
  else
    say "Skipped all optional coding-agent installs."
  fi

  setup_api_key "ANTHROPIC_API_KEY" "$profile"
  setup_api_key "OPENAI_API_KEY" "$profile"
  setup_api_key "GEMINI_API_KEY" "$profile"
  setup_api_key "OPENROUTER_API_KEY" "$profile"

  if ! install_cloudflared; then
    say "Skipping remote-access setup because cloudflared could not be installed automatically."
  fi
  setup_allowlisted_folders

  login_passiveagents
  start_passiveagents

  say "Done!"
  source "$profile"
}

main "$@"
