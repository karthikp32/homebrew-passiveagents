class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.10"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.10/passiveagents_Darwin_arm64.tar.gz"
      sha256 "36777a3434073d945311e82f2b62c04496c423232ba43b34cae91808bf8feace"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.10/passiveagents_Darwin_amd64.tar.gz"
      sha256 "204cf465723033cfcda219ef71869b90522884d334a3a7aa334a490bd5d56c21"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.10/passiveagents_Linux_arm64.tar.gz"
      sha256 "e35f10388dc41643091b24b5358681fa078086420eac6c35eb503078322b810d"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.10/passiveagents_Linux_amd64.tar.gz"
      sha256 "3c629ca5ef8b5b11c99ec71ed84082c705a3915bb4c72df0cf8232aa23a078f8"
    end
  end

  def install
    bin.install "passiveagents"
  end

  test do
    output = shell_output("#{bin}/passiveagents version")
    assert_match version.to_s, output
  end
end
