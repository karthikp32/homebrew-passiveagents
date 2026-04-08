class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.6/passiveagents_Darwin_arm64.tar.gz"
      sha256 "7c930c7646cc60edfe9cbef061d4ffe0544f5df4e2fdaeb802da5f11271696b0"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.6/passiveagents_Darwin_amd64.tar.gz"
      sha256 "ec739de88bc0271e5f9e308936e12c6576894c913b92c503e1a81488f92cfe39"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.6/passiveagents_Linux_arm64.tar.gz"
      sha256 "26a9f0bce23a1b7783be4da7f2d8ec67be97198909dbd3c7a1f6b675b894a21b"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.6/passiveagents_Linux_amd64.tar.gz"
      sha256 "7fc2425363170c648ef12127140955df354dda789c7c128e450421553e2e8e6d"
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
