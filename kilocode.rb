# typed: false
# frozen_string_literal: true

class Kilocode < Formula
  desc "The most complete CLI for agentic engineering."
  homepage "https://github.com/Kilo-Org/kilo"
  version "1.0.12"
  url "https://registry.npmjs.org/@kilocode/cli/-/cli-1.0.12.tgz"
  sha256 "be8d5b7dd45881b6e4014c0a635bdd71be34e2e"
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
