class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.12"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.12/passiveagents_Darwin_arm64.tar.gz"
      sha256 "4c11642cabbf477a159c76681ea518d611a944bf5733d628dcb127790ce2ad84"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.12/passiveagents_Darwin_amd64.tar.gz"
      sha256 "bd856f357e07458ce5571df4cb7592cc04a4c42a70b4be4572604dafba7dd5a2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.12/passiveagents_Linux_arm64.tar.gz"
      sha256 "e25bd6f8cb83bd4aab39a534fe109510c72a707cf55711872faa6f048a9fda44"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.12/passiveagents_Linux_amd64.tar.gz"
      sha256 "395b4117946bcd5445e5abe3d59e1529c1f5653abb302b6899ae5dcb0c7bc347"
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
