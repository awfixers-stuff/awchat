# AWChat Broker

Public edge gateway for AWChat. **Elixir** (Bandit/Plug) terminates public traffic, applies security checks and rate limits, and reverse-proxies to internal Railway services over `*.railway.internal`.

## Routing

| Path prefix | Upstream | Service |
| ----------- | -------- | ------- |
| `/v1/identities`, `/v1/invites`, `/v1/addresses`, `/v1/connection-requests` | `AUTH_UPSTREAM` | Auth |
| `/v1/ws` | `RELAY_UPSTREAM` | Relay (WebSocket) |
| `/v1/*` | `RELAY_UPSTREAM` | Relay (REST) |
| `/health` | — | Broker liveness (Railway healthcheck) |
| `/ops/status` | — | Aggregated ops health (token-gated) |

Relay and auth are **not** exposed publicly — only the broker has a Railway public domain.

## Security

- Security headers (HSTS, X-Frame-Options, etc.)
- Max request body size (`MAX_BODY_BYTES`, default 1 MiB)
- JSON `Content-Type` required on mutating requests with a body
- Per-IP rate limit on `/v1/*` (`IP_RATE_LIMIT` per `RATE_LIMIT_WINDOW_MS`)
- Per-user rate limit on mutating `/v1/*` when `X-AWChat-User-Id` is present

## Environment

| Variable | Required | Example |
| -------- | -------- | ------- |
| `PORT` | No (Railway sets) | `8080` |
| `RELAY_UPSTREAM` | Yes (prod) | `awchat.railway.internal:8080` |
| `AUTH_UPSTREAM` | Yes (prod) | `auth.railway.internal:8081` |
| `BROKER_OPS_TOKEN` | Yes (prod) | random secret |
| `IP_RATE_LIMIT` | No | `120` |
| `USER_RATE_LIMIT` | No | `60` |
| `RATE_LIMIT_WINDOW_MS` | No | `60000` |
| `MAX_BODY_BYTES` | No | `1048576` |

## Ops health

```bash
curl -sS -H "X-Ops-Token: $BROKER_OPS_TOKEN" https://<broker-domain>/ops/status | jq
```

Probes auth and relay `/v1/health` and `/v1/ready` over internal upstreams.

## Local development

```bash
mix deps.get
mix test
mix run --no-halt
```

With auth and relay running locally:

```bash
AUTH_UPSTREAM=localhost:8081 RELAY_UPSTREAM=localhost:8080 BROKER_OPS_TOKEN=dev mix run --no-halt
```

Or use `docker compose up` from this directory (broker + auth + relay stack).

## Deploy (Railway)

This repo is a **monorepo**. See [`RAILWAY.md`](../../RAILWAY.md) for GitHub push-to-deploy setup.

```bash
./scripts/ops/railway-monorepo-bootstrap.sh awchat-relay
```

Per-service config: [`railway.toml`](railway.toml) — root `/server/broker`, watch `/server/broker/**`.

1. Bootstrap sets `RELAY_UPSTREAM`, `AUTH_UPSTREAM`, `BROKER_OPS_TOKEN`.
2. Generate a public domain on **broker** only (you assign `chat-api.awfixer.me`).
3. Keep `auth` and `awchat` internal-only.

**Public URL:** `https://<broker-domain>` — clients use this single base URL for REST and WebSocket.