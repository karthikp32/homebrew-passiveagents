class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.3/passiveagents_Darwin_arm64.tar.gz"
      sha256 "10627825e34836bb405ee52d660be71b3bac0304542932e085bbabbe5e1c13df"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.3/passiveagents_Darwin_amd64.tar.gz"
      sha256 "1ab60e2d8f09457291c787d2cb0790ffb0a82c75f8efadb00b27d822c36cd3ec"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.3/passiveagents_Linux_arm64.tar.gz"
      sha256 "0134793fe2100b234ed1f0fad89bc1a784137d57f99f8bdeb36017960e8aef87"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.3/passiveagents_Linux_amd64.tar.gz"
      sha256 "7e49f6821b008dfa6a9ae0a9b6ab4d87a30802b58407f5d40114c9af9e7977e3"
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
