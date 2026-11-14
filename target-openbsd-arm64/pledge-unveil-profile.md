# OpenBSD `pledge(2)` & `unveil(2)` Sandboxing Profile (`arm64` / `aarch64`)

This specification defines the least-privilege kernel sandboxing profile for `totaldrop` on OpenBSD `arm64` (`aarch64-unknown-openbsd`), running alongside ARMv8.5-A `BTI` (Branch Target Identification), `PAC` (Pointer Authentication), `W^X`, and `RETGUARD`.

## Subcommand Privilege Matrix

| Subcommand | `unveil(2)` Paths & Permissions | Initial `pledge(2)` Promises | Post-Offer / Steady-State `pledge(2)` Promises |
| --- | --- | --- | --- |
| `totaldrop code <code>` | `unveil("/", "")` then `unveil(NULL, NULL)` | `"stdio"` | `"stdio"` |
| `totaldrop send --text …` / `send -` | `/etc/resolv.conf` (`"r"`), then `unveil(NULL, NULL)` | `"stdio inet dns"` | `"stdio inet"` |
| `totaldrop send <paths…>` | Each explicit `<path>` (`"r"`), `/etc/resolv.conf` (`"r"`), then `unveil(NULL, NULL)` | `"stdio rpath inet dns"` | `"stdio rpath inet"` |
| `totaldrop receive [--out <dir>] <code>` | Resolved `<dir>` (`"rwc"`), `/etc/resolv.conf` (`"r"`), then `unveil(NULL, NULL)` | `"stdio rpath wpath cpath inet dns tty"` | File offer: `"stdio rpath wpath cpath inet"` · Text offer (`#313`): `"stdio inet"` |

## Enforcement Invariants

- **Strict `W^X` Compatibility:** Pure Rust cryptography (`totaldrop-crypto`, RustCrypto, `snow`, `blake3`, `ring`) uses zero runtime JIT or executable stack/heap mappings, satisfying OpenBSD's mandatory `W^X` enforcement without `wxneeded`.
- **Immutable `unveil` Lock Before Network:** `unveil(NULL, NULL)` is invoked before opening any WebSocket or UDP QUIC socket so untrusted network frames never execute in an unlocked filesystem view.
- **Monotonic `pledge` Reduction:** Once DNS resolution and mailbox/QUIC connection establishment complete (and after `ask()` reads confirmation on `/dev/tty` or `stdin`), `dns` and `tty` promises are permanently dropped.
