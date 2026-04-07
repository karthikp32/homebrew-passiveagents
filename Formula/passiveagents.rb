class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.4/passiveagents_Darwin_arm64.tar.gz"
      sha256 "7d97f892a6a96b5d223ebba9f766df727a5ef348ca8c2c97c7adde10bf7261cb"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.4/passiveagents_Darwin_amd64.tar.gz"
      sha256 "d1b89e381ea0ca96a46b554fdee93120fe3860b234758566a09a9f8592a24d14"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.4/passiveagents_Linux_arm64.tar.gz"
      sha256 "adcece0bac450b8a292c2a62815c4ee143d0d961c3ca4655124dec607e183713"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.4/passiveagents_Linux_amd64.tar.gz"
      sha256 "8278615ad8c9a971484a1be43142a4049fbf6569cae488d94e4041380bbcf9e3"
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
