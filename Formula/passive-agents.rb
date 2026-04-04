class PassiveAgents < Formula
  desc "Orchestrate AI coding agents locally on your laptop"
  homepage "https://www.passiveagents.com/" # Or your landing page
  
  # Point this to where you uploaded the .tar.gz (e.g., a GitHub Release)
  url "https://github.com/karthik/passive-agents/releases/download/v1.0.0-beta.1/passive-agents-v1.0.0-beta.1.tar.gz"
  sha256 "PASTE_YOUR_SHASUM_HERE"
  
  version "1.0.0-beta.1"
  license "Proprietary"

  def install
    # This moves the binary from the extracted tarball into the Homebrew /bin
    bin.install "passive-agents"
  end

  test do
    # A simple check to ensure it installed correctly
    system "#{bin}/passive-agents", "--version"
  end
end
