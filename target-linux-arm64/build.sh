#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# ADR 0015 static musl Linux ARM64 (aarch64-unknown-linux-musl) CLI release builder.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET="aarch64-unknown-linux-musl"
VERSION="${TOTALDROP_VERSION:-0.2.0-beta.5}"
ARCHIVE_STEM="totaldrop-cli-${VERSION}-${TARGET}"
OUT_DIR="${ROOT_DIR}/dist/${TARGET}"

export RUSTUP_TOOLCHAIN="${RUSTUP_TOOLCHAIN:-stable}"

echo "==> Building static CLI for ${TARGET}"
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
cp "${ROOT_DIR}/README.md" "${OUT_DIR}/${ARCHIVE_STEM}/README.md"
cp "${ROOT_DIR}/LICENSES/"*.txt "${OUT_DIR}/${ARCHIVE_STEM}/LICENSES/"

(
  cd "${OUT_DIR}"
  tar -czf "${ARCHIVE_STEM}.tar.gz" "${ARCHIVE_STEM}"
  sha256sum "${ARCHIVE_STEM}.tar.gz" > SHA256SUMS
)
echo "==> Created ${OUT_DIR}/${ARCHIVE_STEM}.tar.gz"
