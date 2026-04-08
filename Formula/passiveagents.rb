class Passiveagents < Formula
  desc "PassiveAgents local agent manager"
  homepage "https://passiveagents.com"
  version "1.0.0-beta.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.5/passiveagents_Darwin_arm64.tar.gz"
      sha256 "d94062a234749053f0ecc42287770ad1e948ae060c1d09e65c56ecf236a9373f"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.5/passiveagents_Darwin_amd64.tar.gz"
      sha256 "bb3b7d3fed8311cbb0f734ffd94b8b2cd4e886710b53aa0516a69df6bb563f3a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.5/passiveagents_Linux_arm64.tar.gz"
      sha256 "ab09e4c0d4bdecc80695ac42abf5dcb326fcaad51b14f322e39ec197d787cc58"
    else
      url "https://github.com/karthikp32/homebrew-passiveagents/releases/download/manager-v1.0.0-beta.5/passiveagents_Linux_amd64.tar.gz"
      sha256 "cb2fa88cc5516cac16878f47c95d43f7993d0926167a1ce9a50b46ec6899406a"
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
