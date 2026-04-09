class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.9/passiveagents_Darwin_arm64.tar.gz"
      sha256 "59ff60884be208b2244f86e2c4b939ecf323649ee64145cdee48cc420521ded4"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.9/passiveagents_Darwin_amd64.tar.gz"
      sha256 "592b24c5a90ed1d2dba5ee02fcfe9491f1f3a041d1f1ce7a729761ff4944c1a8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.9/passiveagents_Linux_arm64.tar.gz"
      sha256 "514274da92d40c22e125fc52b9753d28b932ba023db5c9a165aebacdebe36b6b"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.9/passiveagents_Linux_amd64.tar.gz"
      sha256 "15b5ec9c029999c3f3a4448d57d08933722a9bad311cab5a5552214e581c60c2"
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
