# AWChat Relay

Encrypted dumb relay for AWChat. **Elixir** (Bandit/OTP) + **Gleam** (protocol types) + **Rust** (libsignal XEdDSA verify).

## Local development

```bash
docker compose up -d postgres
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server  # or: iex -S mix run --no-halt
```

The gateway listens on `http://localhost:8080`.

## API

Implements the v1 contract from [`docs/DESIGN.md`](../../docs/DESIGN.md):

- `GET /v1/health`, `GET /v1/ready`
- `POST /v1/register`, `GET /v1/prekeys/:userId`
- `POST /v1/chats`, `GET /v1/chats/:chatId`, `PATCH /v1/chats/:chatId/members`
- `POST /v1/purge`
- `WS /v1/ws`

## Deploy (Railway)

Production runs on **Railway** with **CI-gated deploys** from `master` on `awfixers-stuff/awchat`.

| Railway service | Root directory | What runs |
| --------------- | -------------- | --------- |
| **awchat** (relay) | `server/relay` | Elixir OTP release (`Dockerfile`) — HTTP + WebSocket |
| **Postgres** | — | Railway Postgres plugin; reference as `${{Postgres.DATABASE_URL}}` |

Railway waits for GitHub Actions (`relay` workflow) to pass before deploying. Migrations run automatically on boot via `bin/server`.

**Required env on relay service:**

- `DATABASE_URL=${{Postgres.DATABASE_URL}}`

**Public URL:** `https://awchat-production.up.railway.app` (health: `GET /v1/health`, ready: `GET /v1/ready`).

Do **not** split relay and Postgres across providers in v1 — the design assumes a single-node in-memory WebSocket map with no cross-region fan-out.