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

Monorepo setup: [`RAILWAY.md`](../../RAILWAY.md). This service is named **awchat** on Railway; root `/server/relay`, config [`railway.toml`](railway.toml).

| Railway service | Root directory | Exposure |
| --------------- | -------------- | -------- |
| **broker** | `/server/broker` | Public domain only |
| **awchat** (relay) | `/server/relay` | `*.railway.internal` only |
| **auth** | `/server/auth` | `*.railway.internal` only |
| **Postgres** | — | Relay DB (`${{Postgres.DATABASE_URL}}`) |
| **Postgres-Auth** | — | Auth DB (`${{Postgres-Auth.DATABASE_URL}}`) |

Migrations run automatically on container boot.

**Required env on relay service:**

- `DATABASE_URL=${{Postgres.DATABASE_URL}}`

**Health:** `GET /v1/health` (liveness), `GET /v1/ready` (DB + migrations). Reachable via broker at the public URL.

Do **not** split relay and Postgres across providers in v1 — the design assumes a single-node in-memory WebSocket map with no cross-region fan-out.