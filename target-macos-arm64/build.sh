#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# macOS Apple Silicon (aarch64-apple-darwin) CLI archive builder (ADR 0009 & ADR 0015).
# Re-signs the stripped binary ad-hoc (`codesign -s -`) and verifies with `codesign -v`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET="aarch64-apple-darwin"
VERSION="${TOTALDROP_VERSION:-0.2.0-beta.5}"
ARCHIVE_STEM="totaldrop-cli-${VERSION}-${TARGET}"
OUT_DIR="${ROOT_DIR}/dist/${TARGET}"

export RUSTUP_TOOLCHAIN="${RUSTUP_TOOLCHAIN:-stable}"

echo "==> Building CLI for ${TARGET}"
rustup target add "${TARGET}"
cargo build \
  --manifest-path "${ROOT_DIR}/Cargo.toml" \
  --package totaldrop-cli \
  --target "${TARGET}" \
  --release \
  --locked

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}/${ARCHIVE_STEM}/LICENSES"
cp "${ROOT_DIR}/target/${TARGET}/release/totaldrop" "${OUT_DIR}/${ARCHIVE_STEM}/totaldrop"
strip "${OUT_DIR}/${ARCHIVE_STEM}/totaldrop"
codesign --force --sign - "${OUT_DIR}/${ARCHIVE_STEM}/totaldrop"
codesign -v "${OUT_DIR}/${ARCHIVE_STEM}/totaldrop"

cp "${ROOT_DIR}/README.md" "${OUT_DIR}/${ARCHIVE_STEM}/README.md"
cp "${ROOT_DIR}/LICENSES/"*.txt "${OUT_DIR}/${ARCHIVE_STEM}/LICENSES/"

(
  cd "${OUT_DIR}"
  tar -czf "${ARCHIVE_STEM}.tar.gz" "${ARCHIVE_STEM}"
  shasum -a 256 "${ARCHIVE_STEM}.tar.gz" > SHA256SUMS
)
echo "==> Created ${OUT_DIR}/${ARCHIVE_STEM}.tar.gz"
