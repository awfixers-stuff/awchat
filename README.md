# AWChat

Encrypted ephemeral chat for Android — X-Lite-style UX on Material 3 Expressive, Signal Protocol E2EE, and 1-day post-seen-all deletion.

## Status

Early development. See the [roadmap](ROADMAP.md) for live progress (currently **PR 12 / 24**).

| Area | Stack |
| --- | --- |
| Android client | Kotlin, Jetpack Compose, Room + SQLCipher, libsignal-android, Hilt |
| Relay server | Elixir (Bandit/OTP), Gleam protocol core, Rust libsignal NIF, PostgreSQL |
| Auth server | Elixir gateway + Rust crypto NIF |
| CI | GitHub Actions on Blacksmith runners |

## Quick start

Requires [Nix](https://nixos.org/download.html) (recommended), Java 21, Android SDK API 36, and [Bun](https://bun.sh) for repo scripts.

```bash
direnv allow          # optional: auto-enter Nix shell via .envrc
just build            # assembleDebug
just test             # unit tests
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
Android (Compose + libsignal + SQLCipher)
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