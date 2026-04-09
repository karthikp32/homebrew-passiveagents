#!/usr/bin/env bash
set -euo pipefail

NPM_CLAUDE_PKG="${NPM_CLAUDE_PKG:-@anthropic-ai/claude-code}"
NPM_CODEX_PKG="${NPM_CODEX_PKG:-@openai/codex}"
NPM_GEMINI_PKG="${NPM_GEMINI_PKG:-@google/gemini-cli}"
NPM_OPENCODE_PKG="${NPM_OPENCODE_PKG:-opencode-ai}"

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

has_interactive_tty() {
  [[ -t 0 && -t 1 ]]
}

ensure_homebrew() {
  local os
  local bp=""
  local brew_paths=("/opt/homebrew/bin/brew" "/usr/local/bin/brew" "/home/linuxbrew/.linuxbrew/bin/brew")

  for candidate in "${brew_paths[@]}"; do
    if [[ -x "$candidate" ]]; then
      bp="$candidate"
      eval "$("$bp" shellenv)"
      break
    fi
  done

  if command -v brew >/dev/null 2>&1; then
    say "Homebrew is already installed."
    return 0
  fi

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
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    say "Homebrew installation failed. Visit https://brew.sh for manual installation."
    return 1
  fi

  bp=""
  for candidate in "${brew_paths[@]}"; do
    if [[ -x "$candidate" ]]; then
      bp="$candidate"
      eval "$("$bp" shellenv)"
      break
    fi
  done

  if ! command -v brew >/dev/null 2>&1; then
    say "Homebrew installed, but could not be loaded into this shell."
    return 1
  fi

  if [[ "$os" == "Linux" && -n "$bp" ]]; then
    local line
    line="eval \"\$($bp shellenv)\""
    local profile

    for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
      touch "$profile"
      if ! grep -Fq "$line" "$profile"; then
        printf '\n# Homebrew initialization\n%s\n' "$line" >> "$profile"
      fi
    done
  fi

  say "Installed Homebrew."
  return 0
}

install_passiveagents() {
  if passiveagents --version >/dev/null 2>&1; then
    say "PassiveAgents is already installed."
    if ! confirm "Upgrade via Homebrew?"; then
      say "Skipping upgrade."
      return 0
    fi
  fi

  say "Setting up PassiveAgents via Homebrew..."

  brew update || {
    say "Failed to update Homebrew."
    return 1
  }

  brew tap karthikp32/passiveagents || {
    say "Failed to tap repository."
    return 1
  }

  if brew list --formula passiveagents >/dev/null 2>&1; then
    say "Upgrading PassiveAgents..."
    brew upgrade passiveagents || {
      say "Upgrade failed."
      return 1
    }
  else
    say "Installing PassiveAgents..."
    brew install passiveagents || {
      say "Installation failed."
      return 1
    }
  fi

  say "PassiveAgents is now installed."
}

run_with_optional_sudo() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    "$@"
    return
  fi
  sudo "$@"
}

verify_install() {
  local label="$1"
  local cmd="$2"
  if bash -c '. "${HOME}/.bashrc" 2>/dev/null; . "${HOME}/.profile" 2>/dev/null; '"$cmd --version" >/dev/null 2>&1; then
    say "${label} verified."
  else
    say "Warning: ${label} installed but '${cmd}' not found in PATH. Open a new terminal before logging in."
  fi
}

install_claude_code() {
  local label="Claude Code"
  local installed=0

  say "Installing ${label}..."
  if brew install --cask claude-code 2>/dev/null; then
    installed=1
  elif command -v npm >/dev/null 2>&1; then
    if npm install -g @anthropic-ai/claude-code; then
      installed=1
    fi
  else
    if curl -fsSL https://claude.ai/install.sh | bash; then
      installed=1
    fi
  fi

  if (( installed )); then
    say "Installed ${label}."
    verify_install "$label" "claude"
  else
    say "Failed to install ${label}. You can install manually from https://code.claude.com/"
  fi
}

install_codex() {
  local label="Codex"
  local installed=0

  say "Installing ${label}..."
  if brew install --cask codex; then
    installed=1
  elif command -v npm >/dev/null 2>&1; then
    if npm i -g @openai/codex; then
      installed=1
    fi
  fi

  if (( installed )); then
    say "Installed ${label}."
    verify_install "$label" "codex"
  else
    say "Failed to install ${label}. You can install manually from https://developers.openai.com/codex/cli"
  fi
}

install_gemini_cli() {
  local label="Gemini CLI"
  local installed=0

  say "Installing ${label}..."
  if brew install gemini-cli; then
    installed=1
  elif command -v npm >/dev/null 2>&1; then
    if npm install -g @google/gemini-cli; then
      installed=1
    fi
  fi

  if (( installed )); then
    say "Installed ${label}."
    verify_install "$label" "gemini"
  else
    say "Failed to install ${label}. You can install manually from https://github.com/google-gemini/gemini-cli"
  fi
}

install_opencode() {
  local label="OpenCode"
  local installed=0

  say "Installing ${label}..."
  if brew install opencode-ai 2>/dev/null; then
    installed=1
  elif command -v npm >/dev/null 2>&1; then
    if npm i -g opencode-ai; then
      installed=1
    fi
  else
    if curl -fsSL https://opencode.ai/install | bash; then
      installed=1
    fi
  fi

  if (( installed )); then
    say "Installed ${label}."
    verify_install "$label" "opencode"
  else
    say "Failed to install ${label}. You can install manually from https://opencode.ai/"
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

install_cloudflared() {
  say "Cloudflare Tunnel is required for PassiveAgents remote access."
  say "This setup will install cloudflared if it is not already available."

  if cloudflared --version >/dev/null 2>&1; then
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
      if passiveagents add folder "$folder_path" --label "$folder_label"; then
        say "Added allowlisted folder ${folder_label}."
      else
        say "Failed to add allowlisted folder ${folder_path}."
      fi
    else
      if passiveagents add folder "$folder_path"; then
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

login_claude_code() {
  if ! command -v claude >/dev/null 2>&1; then
    return 0
  fi

  if ! has_interactive_tty; then
    say "Skipping Claude Code login because this shell is not interactive."
    say "Log in later by running: claude"
    say "Then type: /login"
    return 0
  fi

  say "Claude Code login is interactive."
  say "The installer will continue even if you skip or interrupt it."
  if confirm "Launch Claude Code login now?"; then
    say "Launching Claude Code. Type /login once it starts."
    if ! claude; then
      say "Claude Code login was interrupted or did not complete."
    fi
  else
    say "You can log in later by running: claude"
    say "Then type: /login"
  fi
}

login_codex() {
  if ! command -v codex >/dev/null 2>&1; then
    return 0
  fi

  if ! has_interactive_tty; then
    say "Skipping Codex login because this shell is not interactive."
    say "Log in later by running: codex login"
    return 0
  fi

  say "Codex login is interactive and may open a browser-based auth flow."
  say "The installer will continue even if you skip or interrupt it."
  if confirm "Log in to Codex now?"; then
    say "Starting Codex login..."
    if ! codex login --device-auth; then
      say "Codex login was interrupted or did not complete."
    fi
  else
    say "You can log in later with: codex login"
  fi
}

login_gemini_cli() {
  if ! command -v gemini >/dev/null 2>&1; then
    return 0
  fi

  if ! has_interactive_tty; then
    say "Skipping Gemini CLI login because this shell is not interactive."
    say "Log in later by running: gemini"
    return 0
  fi

  say "Gemini CLI login is interactive and may open a browser-based auth flow."
  say "If it does not behave well in this environment, press Ctrl+C and log in later."
  if confirm "Launch Gemini CLI login now?"; then
    say "Starting Gemini CLI..."
    if ! gemini; then
      say "Gemini CLI login was interrupted or did not complete."
    fi
  else
    say "You can log in later by running: gemini"
  fi
}

login_opencode() {
  if ! command -v opencode >/dev/null 2>&1; then
    return 0
  fi

  if ! has_interactive_tty; then
    say "Skipping OpenCode login because this shell is not interactive."
    say "Log in later with: opencode auth login"
    return 0
  fi

  if confirm "Log in to OpenCode now?"; then
    if ! opencode auth login; then
      say "OpenCode login was interrupted or did not complete."
    fi
  else
    say "You can log in later with: opencode auth login"
  fi
}

login_passiveagents() {
  say "You need to log in to PassiveAgents with your email."
  if ! confirm "Log in to PassiveAgents now?"; then
    say "You can log in later with: passiveagents login"
    return 1
  fi

  if ! passiveagents login; then
    say "PassiveAgents login was interrupted or did not complete."
    return 1
  fi
}

start_passiveagents() {
  say "PassiveAgents is now ready to start."
  if ! confirm "Start PassiveAgents manager now?"; then
    say "You can start it later with: passiveagents start"
    return 1
  fi

  if ! passiveagents start; then
    say "PassiveAgents manager start did not complete."
    return 1
  fi
}

print_next_steps() {
  local login_ok="${1:-0}"
  local start_ok="${2:-0}"

  say ""
  say "Setup summary:"

  say ""
  say "  Installed:"
  command -v passiveagents >/dev/null 2>&1 && say "    - PassiveAgents"
  command -v cloudflared   >/dev/null 2>&1 && say "    - cloudflared"
  command -v claude        >/dev/null 2>&1 && say "    - Claude Code"
  command -v codex         >/dev/null 2>&1 && say "    - Codex"
  command -v gemini        >/dev/null 2>&1 && say "    - Gemini CLI"
  command -v opencode      >/dev/null 2>&1 && say "    - OpenCode"

  say ""
  if (( login_ok )); then
    say "  PassiveAgents login: logged in"
  else
    say "  PassiveAgents login: not completed — run: passiveagents login"
  fi
  if (( start_ok )); then
    say "  Manager status:      running"
  else
    say "  Manager status:      not started — run: passiveagents start"
  fi

  say ""
  say "  Next steps:"
  if command -v claude >/dev/null 2>&1; then
    say "    - Log in to Claude Code:  run ‘claude’, then type /login"
  fi
  if command -v codex >/dev/null 2>&1; then
    say "    - Log in to Codex:        codex login  (use ‘--device-auth’ if it doesn’t work)"
  fi
  if command -v gemini >/dev/null 2>&1; then
    say "    - Log in to Gemini CLI:   run ‘gemini’, choose ‘Sign in with Google’"
  fi
  if command -v opencode >/dev/null 2>&1; then
    say "    - Log in to OpenCode:     opencode auth login"
  fi

  say ""
}

main() {
  say "Starting PassiveAgents setup (macOS/Linux)."

  if ! ensure_homebrew; then
    say "Cannot continue without Homebrew."
    return 1
  fi

  if ! install_passiveagents; then
    say "Cannot continue without PassiveAgents."
    return 1
  fi

  say "At least one coding agent tool is required. cloudflared is required for remote access."

  local install_claude=0
  local install_codex=0
  local install_gemini=0
  local install_opencode=0

  if claude --version >/dev/null 2>&1; then
    say "Claude Code is already installed."
  else
    confirm "Install Claude Code on this machine?" && install_claude=1
  fi

  if codex --version >/dev/null 2>&1; then
    say "Codex is already installed."
  else
    confirm "Install Codex on this machine?" && install_codex=1
  fi

  if gemini --version >/dev/null 2>&1; then
    say "Gemini CLI is already installed."
  else
    confirm "Install Gemini CLI on this machine?" && install_gemini=1
  fi

  if opencode --version >/dev/null 2>&1; then
    say "OpenCode is already installed."
  else
    confirm "Install OpenCode on this machine?" && install_opencode=1
  fi

  if (( install_claude || install_codex || install_gemini || install_opencode )); then
    (( install_claude )) && install_claude_code
    (( install_codex )) && install_codex
    (( install_gemini )) && install_gemini_cli
    (( install_opencode )) && install_opencode
  else
    say "Skipped all optional coding-agent installs."
  fi

  if ! install_cloudflared; then
    say "Skipping remote-access setup because cloudflared could not be installed automatically."
  fi

  # (( install_claude )) && login_claude_code
  # (( install_codex )) && login_codex
  # (( install_gemini )) && login_gemini_cli
  # (( install_opencode )) && login_opencode

  local login_ok=0
  local start_ok=0

  if login_passiveagents; then
    login_ok=1
    if start_passiveagents; then
      start_ok=1
      setup_allowlisted_folders
      say "Done!"
    fi
  fi

  print_next_steps "$login_ok" "$start_ok"
}

main "$@"
