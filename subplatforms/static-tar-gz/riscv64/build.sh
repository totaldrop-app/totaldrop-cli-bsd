#!/bin/sh
# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Isolated sub-platform build entry point for `cli-static-tar-gz-riscv64` (ADR 0020).

set -eu

UNIT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$UNIT_DIR/../../.." && pwd)
RECIPE="$UNIT_DIR/RECIPE.toml"
DELEGATE="$REPO_ROOT/target-linux-riscv64/build.sh"
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-1760000000}"

if [ "${1:-}" = "--check-recipe" ]; then
  [ -f "$RECIPE" ] || { echo "missing $RECIPE" >&2; exit 1; }
  [ -e "$DELEGATE" ] || { echo "missing upstream delegate $DELEGATE" >&2; exit 1; }
  grep -q 'unit_id = "cli-static-tar-gz-riscv64"' "$RECIPE"
  grep -q 'artifact_name = "totaldrop-cli-0.3.0-beta.6-riscv64.tar.gz"' "$RECIPE"
  echo "recipe check ok: cli-static-tar-gz-riscv64 -> totaldrop-cli-0.3.0-beta.6-riscv64.tar.gz"
  exit 0
fi

if [ "${1:-}" = "--package-staged" ]; then
  STAGE_IN="${2:?missing staging input directory}"
  OUT_DIR="${3:?missing output directory}"
  stage_root=$(mktemp -d)
  trap 'rm -rf "$stage_root"' EXIT
  pkg_root="$stage_root/totaldrop-cli-0.3.0-beta.6-riscv64"
  mkdir -p "$pkg_root/bin" "$pkg_root/LICENSES"
  if [ -f "$STAGE_IN/totaldrop" ]; then
    cp "$STAGE_IN/totaldrop" "$pkg_root/bin/totaldrop"
    chmod 0755 "$pkg_root/bin/totaldrop"
  fi
  cp "$REPO_ROOT/LICENSES/"*.txt "$pkg_root/LICENSES/"
  cp "$REPO_ROOT/README.md" "$pkg_root/README.md"
  mkdir -p "$OUT_DIR"
  tar --sort=name --mtime="@${SOURCE_DATE_EPOCH:-1760000000}" --owner=0 --group=0 --numeric-owner -cf - -C "$stage_root" "totaldrop-cli-0.3.0-beta.6-riscv64" | gzip -n >"$OUT_DIR/totaldrop-cli-0.3.0-beta.6-riscv64.tar.gz"
  (cd "$OUT_DIR" && sha256sum "totaldrop-cli-0.3.0-beta.6-riscv64.tar.gz" >SHA256SUMS)
  echo "packaged cli-static-tar-gz-riscv64 -> $OUT_DIR/totaldrop-cli-0.3.0-beta.6-riscv64.tar.gz"
  exit 0
fi

OUT_DIR="${1:-$REPO_ROOT/dist/static-tar-gz/riscv64}"
mkdir -p "$OUT_DIR"

case "$DELEGATE" in
  *.sh)
    sh "$DELEGATE"
    ;;
  *.ps1)
    pwsh -NoProfile -File "$DELEGATE"
    ;;
  *)
    echo "Verified delegate configuration: $DELEGATE (Rust target: riscv64gc-unknown-linux-gnu)"
    ;;
esac
