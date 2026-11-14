# TotalDrop — Universal CLI & BSD Native Module (`09-cli-and-bsd`)

Standalone repository module for the TotalDrop command-line interface (`totaldrop-cli`) and native FreeBSD, OpenBSD, Linux, macOS, and Windows packaging units, aligned with upstream TotalDrop (`ebe2b19`), **ADR 0015** (*Package managers rest first on CLI binaries built in CI*), and **ADR 0019** (*English by default*).

## Highlights

- **100% Safe Rust (`unsafe_code = "forbid"`)**: Built on `totaldrop-core`, `totaldrop-crypto` (CPace + ML-KEM-768 hybrid post-quantum key agreement + ChaCha20-Poly1305), `totaldrop-proto`, and `totaldrop-l10n` (35+ localized UI languages with terminal-safe rendering and invisible format-character visualization).
- **Direct QUIC + Encrypted Relay Fallback**: Transfers files, recursive directories, and short UTF-8 text snippets directly over dual-stack IPv4/IPv6 QUIC with PCP / NAT-PMP / UPnP port mapping and automatic zero-knowledge relay fallback.
- **11 Isolated OS × Architecture Target Units**: Dedicated build scripts and native package manager recipes for FreeBSD, OpenBSD, Linux (`musl` static), macOS (`ad-hoc` signed & `universal-apple-darwin`), and Windows (`+crt-static` standalone `.zip`).

---

## Repository Layout

```text
09-cli-and-bsd/
├── Cargo.toml                  # Workspace manifest (resolver = "3", edition = "2024", rust-version = "1.99")
├── Cargo.lock                  # Locked dependency graph synced to upstream ebe2b19
├── crates/
│   ├── totaldrop-cli/          # Universal `totaldrop` CLI binary + Flatpak/sandbox detection + E2E tests
│   ├── totaldrop-core/         # QUIC transport, rendezvous client, port mapping, transfer state machine
│   ├── totaldrop-crypto/       # CPace PAKE, ML-KEM-768, Ed25519/X25519, chunked AEAD
│   ├── totaldrop-l10n/         # Compile-time ARB message catalog, plural rules, locale negotiation
│   └── totaldrop-proto/        # Transfer codes (`from_link`), deterministic CBOR wire framing, STUN/PCP
├── l10n/                       # Shared localization catalogs (`app/` and `cli/` ARB bundles)
├── server/                     # Local `totaldrop-relay` & `totaldrop-rendezvous` crates for CLI E2E tests
├── target-freebsd-x86_64/      # FreeBSD amd64 (`x86_64-unknown-freebsd`) Ports, Qt 6 Wayland port & Jail rc.d
├── target-freebsd-arm64/       # FreeBSD arm64 (`aarch64-unknown-freebsd`) Ports, Qt 6 Wayland port & Jail rc.d
├── target-openbsd-x86_64/      # OpenBSD amd64 (`x86_64-unknown-openbsd`) Port + pledge(2)/unveil(2) profile
├── target-openbsd-arm64/       # OpenBSD arm64 (`aarch64-unknown-openbsd`) Port + pledge(2)/unveil(2) profile
├── target-linux-x86_64/        # Static musl x86_64 build + AUR (`totaldrop-cli`, `totaldrop-bin`) + Nix
├── target-linux-arm64/         # Static musl aarch64 build + AUR (`aarch64`) + Nix
├── target-linux-riscv64/       # Linux riscv64gc build + AUR (`riscv64`) + Nix
├── target-macos-arm64/         # Apple Silicon (`aarch64-apple-darwin`) ad-hoc signed build + Formula + Nix
├── target-macos-x86_64/        # Intel & `lipo` `universal-apple-darwin` build + Homebrew Formula + Nix
├── target-windows-x86_64/      # Static-CRT `x86_64-pc-windows-msvc` `.zip` + Winget (`TotalDrop.CLI`) + Scoop
└── target-windows-arm64/       # Static-CRT `aarch64-pc-windows-msvc` `.zip` + Winget (`arm64`) + Scoop
```

---

## OS × Architecture Target Units

| Target Directory | Rust Target Triple | Native Packaging & System Integration Included |
| :--- | :--- | :--- |
| `target-freebsd-x86_64/` | `x86_64-unknown-freebsd` | FreeBSD Ports `net/totaldrop-cli/{Makefile,pkg-descr}`, FreeBSD Wayland Qt 6 desktop port `net/totaldrop-qt6/{Makefile,pkg-descr}`, and TrueNAS CORE / FreeBSD Jail `rc.d/totaldrop` service script |
| `target-freebsd-arm64/` | `aarch64-unknown-freebsd` | FreeBSD Ports `net/totaldrop-cli/{Makefile,pkg-descr}`, FreeBSD Wayland Qt 6 desktop port `net/totaldrop-qt6/{Makefile,pkg-descr}`, and TrueNAS CORE / FreeBSD Jail `rc.d/totaldrop` service script |
| `target-openbsd-x86_64/` | `x86_64-unknown-openbsd` | OpenBSD Ports `net/totaldrop/Makefile`, `pkg/DESCR`, `pkg/PLIST`, and `pledge(2)` / `unveil(2)` sandboxing profile (`pledge-unveil-profile.md`) |
| `target-openbsd-arm64/` | `aarch64-unknown-openbsd` | OpenBSD Ports `net/totaldrop/Makefile`, `pkg/DESCR`, `pkg/PLIST`, and `pledge(2)` / `unveil(2)` sandboxing profile (`pledge-unveil-profile.md`) |
| `target-linux-x86_64/` | `x86_64-unknown-linux-musl` | Static musl archive builder, AUR source `PKGBUILD` (`totaldrop-cli`), AUR binary `PKGBUILD.totaldrop-bin`, and Nix `default.nix` |
| `target-linux-arm64/` | `aarch64-unknown-linux-musl` | Static musl archive builder, AUR `PKGBUILD` (`aarch64`), and Nix `default.nix` |
| `target-linux-riscv64/` | `riscv64gc-unknown-linux-gnu` | RISC-V 64 archive builder, AUR `PKGBUILD` (`riscv64`), and Nix `default.nix` |
| `target-macos-arm64/` | `aarch64-apple-darwin` | Apple Silicon CLI archive builder (`strip` + `codesign --force --sign -` + `codesign -v`), Homebrew Tap `Formula/totaldrop-cli.rb`, and Nix `default.nix` |
| `target-macos-x86_64/` | `x86_64-apple-darwin` | Intel Mac + `lipo` `universal-apple-darwin` archive builder (`codesign -v`), Homebrew Tap `Formula/totaldrop-cli.rb`, and Nix `default.nix` |
| `target-windows-x86_64/` | `x86_64-pc-windows-msvc` | Static-CRT (`+crt-static`) `.zip` builder, Winget `TotalDrop.CLI` manifests (`version`, `installer`, `defaultLocale`), and Scoop `totaldrop-cli.json` |
| `target-windows-arm64/` | `aarch64-pc-windows-msvc` | Static-CRT (`+crt-static`) `.zip` builder, Winget `arm64` installer manifest, and Scoop `totaldrop-cli.json` |

---

## BSD Integration Details

### FreeBSD & TrueNAS CORE / Jail (`target-freebsd-*`)
- **CLI Port (`net/totaldrop-cli`)**: Uses `USES=cargo` and installs `/usr/local/bin/totaldrop` plus the `rc.d/totaldrop` service hook (`USE_RC_SUBR=totaldrop`).
- **Wayland Desktop Port (`net/totaldrop-qt6`)**: Uses `USES=cargo cmake pkgconfig qt:6` (`USE_QT=base declarative wayland svg`) with `LIB_DEPENDS` on `libwayland-client.so` and `libxkbcommon.so` for native Wayland compositors on FreeBSD (`sway`, `river`, KDE Plasma Wayland).
- **TrueNAS CORE / Jail Service (`rc.d/totaldrop`)**: Runs an unprivileged `daemon(8)` wrapper around `totaldrop receive --yes --out ${totaldrop_inbox}` inside a dedicated FreeBSD Jail or TrueNAS dataset (`totaldrop_enable="YES"` in `/etc/rc.conf`).

### OpenBSD (`target-openbsd-*`)
- **Ports Tree (`net/totaldrop`)**: Uses `MODULES = devel/cargo` with `SEPARATE_BUILD = Yes` for `amd64` and `aarch64`.
- **`pledge(2)` & `unveil(2)` Profile (`pledge-unveil-profile.md`)**: Documents path unveiling (`/etc/ssl/cert.pem` `"r"`, source paths `"r"` on `send`, destination directory `"rwc"` on `receive`, followed by `unveil(NULL, NULL)`) and progressive `pledge(2)` promise narrowing (`stdio rpath inet dns tty` for `send`; `stdio rpath wpath cpath inet dns tty` for `receive`; `stdio` for `code`).

---

## CLI Quick Start

```bash
# Send files or folders
totaldrop send ./report.pdf ./photos/

# Send a short text message without writing temporary files
totaldrop send --text "Meet at gate B12"

# Receive using a transfer code or pasted share link
totaldrop receive 7-harbor-rocket
totaldrop receive "https://totaldrop.app/r#7-harbor-rocket" --out ~/Downloads

# Inspect canonical numeric form of a transfer code offline
totaldrop code 7-harbor-rocket
```

---

## Building & Testing

Run the full workspace linter and test suite (including all 55 `totaldrop-cli` unit, program, and live QUIC/relay end-to-end tests):

```bash
RUSTUP_TOOLCHAIN=stable cargo clippy --workspace --all-targets -- -D warnings
RUSTUP_TOOLCHAIN=stable cargo test --workspace
```

---

## License

- `crates/totaldrop-cli`: **GPL-3.0-or-later**
- `crates/totaldrop-core`, `crates/totaldrop-crypto`, `crates/totaldrop-proto`, `crates/totaldrop-l10n`: **MIT OR Apache-2.0**

Full license texts are provided in `LICENSES/`.
