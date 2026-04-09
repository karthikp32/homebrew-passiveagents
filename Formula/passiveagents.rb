class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.8/passiveagents_Darwin_arm64.tar.gz"
      sha256 "641849aeaad75847cfe6dd1e612b0c227f8a133469283ad60a63accc0a923e3a"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.8/passiveagents_Darwin_amd64.tar.gz"
      sha256 "642318a221518af3b956abb93dee490ad070df7ff3b9ec792fdb4bb8576dc14f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.8/passiveagents_Linux_arm64.tar.gz"
      sha256 "d59bd61d70d3bf08dc3573b510b0c6cc78930a9e47bfe552b6cc868df9b326c0"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.8/passiveagents_Linux_amd64.tar.gz"
      sha256 "01a7bc2dc31e7a5b97b6f9160a9f99f37345bb91a0844b068399eeae03bf44dc"
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
