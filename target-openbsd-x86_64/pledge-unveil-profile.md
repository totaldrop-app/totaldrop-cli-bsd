# OpenBSD `pledge(2)` & `unveil(2)` Sandboxing Profile (`amd64`)

This specification defines the least-privilege kernel sandboxing profile for `totaldrop` on OpenBSD `amd64` (`x86_64-unknown-openbsd`), complementing `IBT` and `RETGUARD` hardware/compiler mitigations.

## Subcommand Privilege Matrix

| Subcommand | `unveil(2)` Paths & Permissions | Initial `pledge(2)` Promises | Post-Offer / Steady-State `pledge(2)` Promises |
| --- | --- | --- | --- |
| `totaldrop code <code>` | `unveil("/", "")` then `unveil(NULL, NULL)` (zero filesystem visibility) | `"stdio"` | `"stdio"` |
| `totaldrop send --text …` / `send -` | `/etc/resolv.conf` (`"r"`), then `unveil(NULL, NULL)` | `"stdio inet dns"` | `"stdio inet"` |
| `totaldrop send <paths…>` | Each explicit `<path>` (`"r"`), `/etc/resolv.conf` (`"r"`), then `unveil(NULL, NULL)` | `"stdio rpath inet dns"` | `"stdio rpath inet"` |
| `totaldrop receive [--out <dir>] <code>` | Resolved `<dir>` (`"rwc"`), `/etc/resolv.conf` (`"r"`), then `unveil(NULL, NULL)` | `"stdio rpath wpath cpath inet dns tty"` | File offer: `"stdio rpath wpath cpath inet"` · Text offer (`#313`): `"stdio inet"` |

## Security Properties

1. **TLS Roots Compiled In:** `totaldrop-core` verifies rendezvous and relay TLS certificates against compiled-in `webpki-roots`, so `/etc/ssl/cert.pem` does not need to be unveiled unless custom system CA roots are explicitly enabled.
2. **Destination Containment:** Unveiling only the target `<dir>` with `"rwc"` and locking the namespace via `unveil(NULL, NULL)` before connecting to the rendezvous server ensures that even a hypothetical bug above `totaldrop-proto::validate_path` cannot read `~/.ssh` or write outside `<dir>`.
3. **In-Memory Text Drop (`#313`):** When an incoming offer is a text note (`summary.text == true`), `rpath wpath cpath tty` are dropped immediately after the confirmation prompt so nothing can touch disk.
4. **No `exec` or `proc`:** Neither `proc` nor `exec` is ever pledged in any mode; `totaldrop` never spawns child processes.
