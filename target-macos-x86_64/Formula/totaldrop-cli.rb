# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Homebrew Formula for `totaldrop-app/homebrew-tap` (ADR 0015) — Intel Mac & Universal Darwin.
# Installs the CI-built `totaldrop` binary on macOS (Intel & Apple Silicon) and Linux.

class TotaldropCli < Formula
  desc "Send files straight to another device, end-to-end encrypted"
  homepage "https://totaldrop.app"
  version "0.2.0-beta.5"
  license any_of: ["GPL-3.0-or-later", "MIT", "Apache-2.0"]

  on_macos do
    url "https://github.com/totaldrop-app/totaldrop/releases/download/cli-v#{version}/totaldrop-cli-#{version}-universal-apple-darwin.tar.gz"
    sha256 "REPLACE_WITH_CI_UNIVERSAL_APPLE_DARWIN_SHA256"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/totaldrop-app/totaldrop/releases/download/cli-v#{version}/totaldrop-cli-#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "REPLACE_WITH_CI_LINUX_ARM64_MUSL_SHA256"
    else
      url "https://github.com/totaldrop-app/totaldrop/releases/download/cli-v#{version}/totaldrop-cli-#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "REPLACE_WITH_CI_LINUX_X86_64_MUSL_SHA256"
    end
  end

  def install
    bin.install "totaldrop"
  end

  test do
    output = shell_output("#{bin}/totaldrop code 7-harbor-rocket")
    assert_match "canonical: 7-840-1499", output
  end
end
