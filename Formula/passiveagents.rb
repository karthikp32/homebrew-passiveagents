class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.1/passiveagents_Darwin_arm64.tar.gz"
      sha256 "ea80eafea759b9c22909b19b136e7f1d67e1a406fbd18d984d78a7c9ce97bbd2"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.1/passiveagents_Darwin_amd64.tar.gz"
      sha256 "f27ee81d2da36fd764cf0fbd855262f44652400b923870b0bfbdd016ad2f0008"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.1/passiveagents_Linux_arm64.tar.gz"
      sha256 "b428cde819fc5233c43d7276e4fde4fbe71f3da4952b43f18d0e346b34b57664"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.1/passiveagents_Linux_amd64.tar.gz"
      sha256 "8f44ce9f0e30a2cfa355b6ffca147fd6dd18fc67a2a6ea35d596fab954e9bed4"
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
