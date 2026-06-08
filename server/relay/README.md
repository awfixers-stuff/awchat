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

Production runs entirely on **Railway**: one project with two services.

| Railway service | What runs | Why |
| --------------- | --------- | --- |
| **relay** | Elixir OTP release from `Dockerfile` (HTTP + WebSocket) | Single lightweight proxy process; needs `DATABASE_URL` from Postgres |
| **postgres** | Railway Postgres plugin | Ephemeral queue + auth nonces; must live in the same project/network as relay |

Do **not** split relay and Postgres across providers in v1 — the design assumes a single-node in-memory WebSocket map with no cross-region fan-out.

1. Create a Railway project.
2. Add **PostgreSQL** (Railway plugin).
3. Add a **service** from this directory (`server/relay`) using the Dockerfile.
4. Set `DATABASE_URL` from the Postgres service reference.
5. Deploy, then run migrations once:

```bash
railway up
railway run bin/relay eval "Gateway.Release.migrate()"
```