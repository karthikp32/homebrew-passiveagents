class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.11"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.11/passiveagents_Darwin_arm64.tar.gz"
      sha256 "2c00091715e51e435aae7f68b3bed5a12548807364e313b6669b30152bb0832f"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.11/passiveagents_Darwin_amd64.tar.gz"
      sha256 "2a538444c14692b9f2e88aecd387ae8c93fbc7c7ef2a2209e48f711a220b0103"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.11/passiveagents_Linux_arm64.tar.gz"
      sha256 "f4426b8a3fc52584e59e6f2977a79de49746c5621ec600cdfb661b6af3a34c4c"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.11/passiveagents_Linux_amd64.tar.gz"
      sha256 "002f3022552fda568df8ba5dc4a575476c1b82aab99f62b3c4645ca8f75ae7b2"
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
