# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Nix derivation for totaldrop-cli on x86_64-darwin.

{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "totaldrop-cli";
  version = "0.2.0-beta.5";

  src = fetchFromGitHub {
    owner = "totaldrop-app";
    repo = "totaldrop";
    rev = "cli-v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
  buildAndTestSubdir = "crates/totaldrop-cli";
  doCheck = false;

  meta = with lib; {
    description = "Send files straight to another device, end-to-end encrypted";
    homepage = "https://totaldrop.app";
    license = with licenses; [ gpl3Plus mit asl20 ];
    mainProgram = "totaldrop";
    platforms = [ "x86_64-darwin" ];
  };
}
