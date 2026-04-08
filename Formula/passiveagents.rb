class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.7/passiveagents_Darwin_arm64.tar.gz"
      sha256 "fc20c4ec6ad46aa5c246a396f7cadfa3fe740242d64b1f1be4d03d03af79091c"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.7/passiveagents_Darwin_amd64.tar.gz"
      sha256 "fabf7a704d309752048182707eeae6707bb6f7b8ec0ebf85d6fe9716be18e827"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.7/passiveagents_Linux_arm64.tar.gz"
      sha256 "80575fec5ae6fb489773aa4f1379b2050ce489a1356427b6dac57944ab0e856a"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.7/passiveagents_Linux_amd64.tar.gz"
      sha256 "a680e8797deaf3cc0860895a265c5b2ebe21a4d9fc8b8a1d704913ec4189ed08"
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
