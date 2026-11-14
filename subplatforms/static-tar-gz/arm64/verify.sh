#!/bin/sh
# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Isolated sub-platform artifact & provenance verifier for `cli-static-tar-gz-arm64` (ADR 0020).

set -eu

UNIT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$UNIT_DIR/../../.." && pwd)
RECIPE="$UNIT_DIR/RECIPE.toml"
WORKFLOW="$REPO_ROOT/.github/workflows/pkg-static-tar-gz-arm64.yml"

if [ "${1:-}" = "--check-recipe" ]; then
  [ -f "$RECIPE" ] || { echo "missing $RECIPE" >&2; exit 1; }
  [ -f "$WORKFLOW" ] || { echo "missing workflow $WORKFLOW" >&2; exit 1; }
  sh -n "$UNIT_DIR/build.sh"
  sh -n "$UNIT_DIR/verify.sh"
  grep -q 'cli-static-tar-gz-arm64-v\*' "$WORKFLOW"
  echo "verify check ok: cli-static-tar-gz-arm64"
  exit 0
fi

ART_DIR="${1:?usage: verify.sh [--check-recipe | <artifact-dir>]}"
[ -f "$ART_DIR/totaldrop-cli-0.3.0-beta.6-arm64.tar.gz" ] || { echo "missing artifact $ART_DIR/totaldrop-cli-0.3.0-beta.6-arm64.tar.gz" >&2; exit 1; }
[ -s "$ART_DIR/totaldrop-cli-0.3.0-beta.6-arm64.tar.gz" ] || { echo "empty artifact $ART_DIR/totaldrop-cli-0.3.0-beta.6-arm64.tar.gz" >&2; exit 1; }
[ -f "$ART_DIR/SHA256SUMS" ] || { echo "missing $ART_DIR/SHA256SUMS" >&2; exit 1; }
(cd "$ART_DIR" && sha256sum -c SHA256SUMS)

members=$(tar -tzf "$ART_DIR/totaldrop-cli-0.3.0-beta.6-arm64.tar.gz")
case "$members" in
  *../*|/*)
    echo "unsafe path in totaldrop-cli-0.3.0-beta.6-arm64.tar.gz" >&2
    exit 1
    ;;
esac
printf '%s\n' "$members" | grep -q 'LICENSES/' || { echo "missing LICENSES/ in totaldrop-cli-0.3.0-beta.6-arm64.tar.gz" >&2; exit 1; }
echo "artifact verified: $ART_DIR/totaldrop-cli-0.3.0-beta.6-arm64.tar.gz"
