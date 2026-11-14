#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# macOS Intel (x86_64-apple-darwin) & Universal (`lipo`) CLI archive builder (ADR 0009 & ADR 0015).
# Re-signs the stripped binary ad-hoc (`codesign --force --sign -`) and verifies with `codesign -v`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET="x86_64-apple-darwin"
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

# Optional universal-apple-darwin archive when Apple Silicon binary is also present
ARM64_BIN="${ROOT_DIR}/target/aarch64-apple-darwin/release/totaldrop"
if [[ -f "${ARM64_BIN}" ]]; then
  UNIV_STEM="totaldrop-cli-${VERSION}-universal-apple-darwin"
  UNIV_DIR="${ROOT_DIR}/dist/universal-apple-darwin"
  echo "==> Merging universal-apple-darwin CLI binary with lipo"
  rm -rf "${UNIV_DIR}"
  mkdir -p "${UNIV_DIR}/${UNIV_STEM}/LICENSES"
  lipo -create -output "${UNIV_DIR}/${UNIV_STEM}/totaldrop" \
    "${ARM64_BIN}" \
    "${ROOT_DIR}/target/${TARGET}/release/totaldrop"
  strip "${UNIV_DIR}/${UNIV_STEM}/totaldrop"
  codesign --force --sign - "${UNIV_DIR}/${UNIV_STEM}/totaldrop"
  codesign -v "${UNIV_DIR}/${UNIV_STEM}/totaldrop"
  cp "${ROOT_DIR}/README.md" "${UNIV_DIR}/${UNIV_STEM}/README.md"
  cp "${ROOT_DIR}/LICENSES/"*.txt "${UNIV_DIR}/${UNIV_STEM}/LICENSES/"
  (
    cd "${UNIV_DIR}"
    tar -czf "${UNIV_STEM}.tar.gz" "${UNIV_STEM}"
    shasum -a 256 "${UNIV_STEM}.tar.gz" > SHA256SUMS
  )
  echo "==> Created ${UNIV_DIR}/${UNIV_STEM}.tar.gz"
fi
