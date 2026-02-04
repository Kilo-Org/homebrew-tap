# typed: false
# frozen_string_literal: true

class Kilocode < Formula
  desc "The most complete CLI for agentic engineering."
  homepage "https://github.com/Kilo-Org/kilo"
  version "1.0.14"
  url "https://registry.npmjs.org/@kilocode/cli/-/cli-1.0.14.tgz"
  sha256 "8c034dfde1f2e4ec74c08073c37a6e42c9187569a3f507e634036d1b6faa8202"
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
