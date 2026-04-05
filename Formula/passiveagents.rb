class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.2/passiveagents_Darwin_arm64.tar.gz"
      sha256 "1fc191a59dc05330b2a5af2d0deab3871fecc0241a0594201c38aa81add72834"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.2/passiveagents_Darwin_amd64.tar.gz"
      sha256 "abcc24aa74131d5d8af44ed201ba63947a2b660acd8da29523748a91fedb15dc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.2/passiveagents_Linux_arm64.tar.gz"
      sha256 "cbe24233dd00123c10fbb5ec609a822c18afd8d47378f3d13a2c872648cf41b7"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.2/passiveagents_Linux_amd64.tar.gz"
      sha256 "feb8222aef4ccb4ac8e01295dea52eb5c100e7c2425761361126451996cc5f03"
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
