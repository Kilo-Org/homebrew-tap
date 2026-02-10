# typed: false
# frozen_string_literal: true

class Kilocode < Formula
  desc "The most complete CLI for agentic engineering."
  homepage "https://github.com/Kilo-Org/kilo"
  version "1.0.16"
  url "https://registry.npmjs.org/@kilocode/cli/-/cli-1.0.16.tgz"
  sha256 "6355003bdb425ab83d4f3059c05b1d9b85f3078128cd8ccdd689c822dec70fd2"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"kilo", "--version"
  end
end
