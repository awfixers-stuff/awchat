# AWChat

Encrypted ephemeral chat — X-Lite-style UX, Signal Protocol E2EE, and 1-day post-seen-all deletion.

AWChat is **mobile-first**. The only **official, production-grade** client target is **Android** (Material 3 Expressive, Jetpack Compose). We are also **experimenting** with a **Linux desktop** app (`desktop/`, GTK) and a **terminal UI** (`tui/`, Rust) intended for **Linux and macOS**. Those clients are exploratory and not part of the v1 ship path.

We do **not** have Apple hardware in the lab right now, so there is no active **macOS** or **iOS** app work. When that hardware is available, we plan to start macOS/iOS clients aligned with the same E2EE and retention model.

We will **never** ship an **official, production-grade Windows** client ourselves. Windows is out of scope for core-team development and release engineering.

**Volunteer-maintained clients:** If you want to build and ship a Windows (or other non-official) client anyway, we may provide **signing keys** and related release support when you:

- keep the implementation **in this repository** (same monorepo, reviewable history);
- accept **code ownership** for that client tree (directory/module) and respond to bugs filed against it;
- agree to maintain the port through protocol and dependency updates that affect your area.

Reach out via the usual project channels to discuss scope before starting. Nothing here is a promise of keys until ownership and layout are agreed in writing.

## Status

Early development. See the [roadmap](ROADMAP.md) for live progress (currently **PR 12 / 24**).

| Area | Stack |
| --- | --- |
| Android client (official) | Kotlin, Jetpack Compose, Room + SQLCipher, libsignal-android, Hilt |
| Linux desktop (experimental) | Rust, GTK (`desktop/`) |
| TUI — Linux & macOS (experimental) | Rust (`tui/`) |
| Relay server | Elixir (Bandit/OTP), Gleam protocol core, Rust libsignal NIF, PostgreSQL |
| Auth server | Elixir gateway + Rust crypto NIF |
| CI | GitHub Actions on Blacksmith runners |

## Quick start

Requires [Nix](https://nixos.org/download.html) (recommended), Java 21, Android SDK API 36, and [Bun](https://bun.sh) for repo scripts.

```bash
direnv allow          # optional: auto-enter Nix shell via .envrc
just build            # assembleDebug
just test             # unit tests
just pull             # git pull --ff-only (master)
just push             # git push (after commits)
bun run lint          # oxlint
bun run fmt:fix       # oxfmt
```

Agent/MCP tooling is optional. Copy `.mcp.json.example` to `.mcp.json` locally and fill in your own API keys — **never commit `.mcp.json`**.

## Documentation

| Doc | Purpose |
| --- | --- |
| [ROADMAP.md](ROADMAP.md) | Central progress tracker (24-PR plan) |
| [docs/DESIGN.md](docs/DESIGN.md) | Full system design, crypto, retention, API catalog |
| [AGENTS.md](AGENTS.md) | AI agent charter and session handoff |
| [server/relay/README.md](server/relay/README.md) | Relay server |
| [server/auth/README.md](server/auth/README.md) | Auth/identity gateway |
| [plans/](plans/) | Post-v1 feature plans |

## Architecture (summary)

Clients own cryptographic state and retention policy. The relay is a **dumb encrypted relay** — it stores and forwards ciphertext envelopes but never decrypts message bodies. Seen-by-all read receipts trigger coordinated purge across clients and server.

```
Android (official) — Compose + libsignal + SQLCipher
Linux desktop / TUI (experimental) — in progress
        │  WSS / HTTPS
        ▼
Relay (Elixir + Gleam + Rust NIF + PostgreSQL)
```

## Security & secrets

- **No secrets in git.** Use `.env` (gitignored) for local overrides. MCP config: `.mcp.json.example` → `.mcp.json` (gitignored).
- **Server secrets** (`DATABASE_URL`, TLS certs, API keys) belong in deployment env (Railway/Fly), not the repo.
- **Release signing** (PR 23) uses CI secrets only — never commit keystores or passwords.
- Docker Compose files ship **local-dev-only** credentials (`POSTGRES_PASSWORD=awchat`); do not reuse in production.

See [AGENTS.md — Security](AGENTS.md#security--secrets) for the full agent-facing checklist.

## License

Proprietary — see [LICENSE.md](LICENSE.md). Source availability is offered under the terms described there.

Built by [awfixer](https://awfixer.me)