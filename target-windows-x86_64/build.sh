#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Windows x86_64 (`x86_64-pc-windows-msvc`) standalone CLI archive builder (ADR 0015).
# Links the MSVC C runtime statically (`+crt-static`) so `totaldrop.exe` runs on clean
# Windows machines without requiring `vcruntime140.dll`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET="x86_64-pc-windows-msvc"
VERSION="${TOTALDROP_VERSION:-0.2.0-beta.5}"
ARCHIVE_STEM="totaldrop-cli-${VERSION}-${TARGET}"
OUT_DIR="${ROOT_DIR}/dist/${TARGET}"

export RUSTUP_TOOLCHAIN="${RUSTUP_TOOLCHAIN:-stable}"
export RUSTFLAGS="${RUSTFLAGS:-} -C target-feature=+crt-static"

echo "==> Building static-CRT CLI for ${TARGET}"
rustup target add "${TARGET}"
cargo build \
  --manifest-path "${ROOT_DIR}/Cargo.toml" \
  --package totaldrop-cli \
  --target "${TARGET}" \
  --release \
  --locked

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}/${ARCHIVE_STEM}/LICENSES"
cp "${ROOT_DIR}/target/${TARGET}/release/totaldrop.exe" "${OUT_DIR}/${ARCHIVE_STEM}/totaldrop.exe"
cp "${ROOT_DIR}/README.md" "${OUT_DIR}/${ARCHIVE_STEM}/README.md"
cp "${ROOT_DIR}/LICENSES/"*.txt "${OUT_DIR}/${ARCHIVE_STEM}/LICENSES/"

(
  cd "${OUT_DIR}"
  if command -v zip >/dev/null 2>&1; then
    zip -r "${ARCHIVE_STEM}.zip" "${ARCHIVE_STEM}"
  else
    powershell.exe -NoProfile -Command "Compress-Archive -Path '${ARCHIVE_STEM}' -DestinationPath '${ARCHIVE_STEM}.zip' -Force"
  fi
  sha256sum "${ARCHIVE_STEM}.zip" > SHA256SUMS
)
echo "==> Created ${OUT_DIR}/${ARCHIVE_STEM}.zip"
