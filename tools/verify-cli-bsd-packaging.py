#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 The TotalDrop Contributors
# SPDX-License-Identifier: GPL-3.0-or-later

"""Cross-platform packaging, runner-pin, and Node 24 workflow verifier for totaldrop-cli-bsd.

Validates:
  - `Cargo.toml` workspace version (`0.2.0-beta.5`) parity across FreeBSD Ports,
    OpenBSD Ports, Linux AUR PKGBUILDs, Nix derivations, macOS Homebrew Formulas,
    Windows Scoop JSON manifests, and WinGet YAML manifests
  - All 9 isolated `subplatforms/*/*/RECIPE.toml` units and `.github/workflows/pkg-*.yml`
    workflows (`0.3.0-beta.6`, Node 24 `upload-artifact` v7.0.2 and
    `attest-build-provenance` v4.2.2 SHA pins)
  - `.github/workflows/ci.yml` pinned `macos-15` runner (zero unpinned `macos-latest`, ADR 0009)
  - OpenBSD `pledge(2)` / `unveil(2)` security profiles and FreeBSD `rc.d/totaldrop` scripts
"""

from __future__ import annotations

import json
import sys
import tomllib
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

EXPECTED_SUBPLATFORM_VERSION = "0.3.0-beta.6"
EXPECTED_UNITS = 9
EXPECTED_MACOS_RUNNER = "macos-15"
EXPECTED_UPLOAD_ARTIFACT_PIN = "actions/upload-artifact@cf430e030ddbb5b0abf93d22962f4752f3646cd9"
EXPECTED_ATTEST_PIN = "actions/attest-build-provenance@4d101475d8b20a2381f78447822ac1eab6504dd8"


def fail(msg: str) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def check_contains(rel_path: str, needle: str, label: str) -> None:
    p = REPO_ROOT / rel_path
    if not p.is_file():
        fail(f"missing {rel_path}")
    text = p.read_text(encoding="utf-8")
    if needle not in text:
        fail(f"{rel_path}: expected {label} ({needle!r})")


def main() -> int:
    # 1. Read workspace CLI version from Cargo.toml
    ws_toml = tomllib.loads((REPO_ROOT / "Cargo.toml").read_text(encoding="utf-8"))
    cli_version = ws_toml["workspace"]["package"]["version"]
    openbsd_pkgname_ver = cli_version.replace("-", "").replace(".", ".")
    # e.g. 0.2.0-beta.5 -> 0.2.0beta5
    if "-beta." in cli_version:
        base, beta_num = cli_version.split("-beta.", 1)
        openbsd_pkgname_ver = f"{base}beta{beta_num}"

    # 2. Check CI workflow pins macos-15 (ADR 0009)
    ci_text = (REPO_ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
    if "macos-latest" in ci_text:
        fail(".github/workflows/ci.yml: unpinned macos-latest violates ADR 0009")
    if EXPECTED_MACOS_RUNNER not in ci_text:
        fail(f".github/workflows/ci.yml: missing pinned {EXPECTED_MACOS_RUNNER}")

    # 3. Verify all 9 subplatforms & Node 24 packaging workflows
    recipes = sorted((REPO_ROOT / "subplatforms").glob("*/*/RECIPE.toml"))
    if len(recipes) != EXPECTED_UNITS:
        fail(f"expected {EXPECTED_UNITS} subplatform recipes, found {len(recipes)}")
    for recipe_path in recipes:
        rel_recipe = recipe_path.relative_to(REPO_ROOT).as_posix()
        data = tomllib.loads(recipe_path.read_text(encoding="utf-8"))
        if data["version"] != EXPECTED_SUBPLATFORM_VERSION:
            fail(
                f"{rel_recipe}: version {data['version']!r} != {EXPECTED_SUBPLATFORM_VERSION!r}"
            )
        if EXPECTED_SUBPLATFORM_VERSION not in data["artifact_name"]:
            fail(f"{rel_recipe}: artifact_name missing {EXPECTED_SUBPLATFORM_VERSION}")

        wf_rel = data["workflow"]
        check_contains(wf_rel, f"runs-on: {data['runner']}", f"runner {data['runner']}")
        check_contains(wf_rel, data["artifact_name"], f"artifact {data['artifact_name']}")
        check_contains(wf_rel, EXPECTED_UPLOAD_ARTIFACT_PIN, "Node 24 upload-artifact v7.0.2 pin")
        check_contains(wf_rel, EXPECTED_ATTEST_PIN, "Node 24 attest-build-provenance v4.2.2 pin")

    # 4. FreeBSD Ports & rc.d
    for arch in ("x86_64", "arm64"):
        check_contains(
            f"target-freebsd-{arch}/net/totaldrop-cli/Makefile",
            f"DISTVERSION=\t{cli_version}",
            f"FreeBSD DISTVERSION {cli_version}",
        )
        check_contains(
            f"target-freebsd-{arch}/net/totaldrop-cli/pkg-descr",
            "TotalDrop",
            "FreeBSD pkg-descr",
        )
        check_contains(
            f"target-freebsd-{arch}/rc.d/totaldrop",
            "run_rc_command",
            "FreeBSD rc.d runner",
        )

    # 5. OpenBSD Ports & pledge/unveil profiles
    for arch in ("x86_64", "arm64"):
        check_contains(
            f"target-openbsd-{arch}/net/totaldrop/Makefile",
            f"GH_TAGNAME =\t\tcli-v{cli_version}",
            f"OpenBSD GH_TAGNAME cli-v{cli_version}",
        )
        check_contains(
            f"target-openbsd-{arch}/net/totaldrop/Makefile",
            f"PKGNAME =\t\ttotaldrop-{openbsd_pkgname_ver}",
            f"OpenBSD PKGNAME totaldrop-{openbsd_pkgname_ver}",
        )
        check_contains(
            f"target-openbsd-{arch}/pledge-unveil-profile.md",
            "pledge",
            "OpenBSD pledge profile",
        )

    # 6. Linux AUR PKGBUILDs & Nix derivations
    for arch in ("x86_64", "arm64", "riscv64"):
        check_contains(
            f"target-linux-{arch}/aur/PKGBUILD",
            f"_ver={cli_version}",
            f"AUR _ver={cli_version}",
        )
        check_contains(
            f"target-linux-{arch}/nix/default.nix",
            f'version = "{cli_version}";',
            f"Nix version {cli_version}",
        )

    # 7. macOS Homebrew Formulas & Nix derivations
    for arch in ("x86_64", "arm64"):
        check_contains(
            f"target-macos-{arch}/Formula/totaldrop-cli.rb",
            f'version "{cli_version}"',
            f"Homebrew version {cli_version}",
        )
        check_contains(
            f"target-macos-{arch}/nix/default.nix",
            f'version = "{cli_version}";',
            f"macOS Nix version {cli_version}",
        )

    # 8. Windows Scoop JSON & WinGet YAML manifests
    for arch in ("x86_64", "arm64"):
        scoop_rel = f"target-windows-{arch}/scoop/totaldrop-cli.json"
        scoop_data = json.loads((REPO_ROOT / scoop_rel).read_text(encoding="utf-8"))
        if scoop_data.get("version") != cli_version:
            fail(f"{scoop_rel}: version {scoop_data.get('version')!r} != {cli_version!r}")
        check_contains(
            f"target-windows-{arch}/winget/TotalDrop.CLI.installer.yaml",
            f"PackageVersion: {cli_version}",
            f"WinGet PackageVersion {cli_version}",
        )
    check_contains(
        "target-windows-x86_64/winget/TotalDrop.CLI.yaml",
        f"PackageVersion: {cli_version}",
        f"WinGet version manifest {cli_version}",
    )

    print(
        f"cli-bsd packaging & parity OK: cli={cli_version}, "
        f"subplatforms={EXPECTED_SUBPLATFORM_VERSION} (9 Node 24 workflows), "
        f"runner={EXPECTED_MACOS_RUNNER}, 11 OS/arch targets verified."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
