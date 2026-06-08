# AWChat Auth

Identity and connection-request service for AWChat. **Elixir** (Bandit/OTP) + **Rust** (libsignal XEdDSA verify).

Simplex-inspired model: one-time invites, long-term rotatable addresses, display names in connection requests only — no phone/email.

## Local development

```bash
docker compose up -d postgres
mix deps.get
mix ecto.create
mix ecto.migrate
mix run --no-halt
```

The gateway listens on `http://localhost:8081`.

## API v1

- `GET /v1/health`, `GET /v1/ready`
- `POST /v1/identities` — register `{userId, identityKey, proofSignature}`
- `POST /v1/invites` — create one-time invite (auth)
- `GET /v1/invites/:token` — resolve invite (public)
- `POST /v1/invites/:token/requests` — submit connection request (auth)
- `POST /v1/addresses` — create long-term address (auth)
- `GET /v1/addresses/:token` — resolve address (public)
- `DELETE /v1/addresses/:token` — revoke address (auth)
- `POST /v1/addresses/:token/requests` — submit connection request (auth)
- `GET /v1/connection-requests` — list pending (auth)
- `PATCH /v1/connection-requests/:id` — accept/reject `{action}` (auth)

### Address URIs

- One-time: `awchat://i/<token>`
- Long-term: `awchat://a/<token>`

Tokens are base64url-encoded 24 random bytes.

### REST authentication

Same headers as relay: `X-AWChat-User-Id`, `X-AWChat-Timestamp`, `X-AWChat-Signature`.

Identity registration proof signs `register|{userId}|{identityKeyB64}` with the identity private key.

## Deploy (Railway)

1. Create a Railway project with **PostgreSQL**.
2. Add a service from `server/auth` using the Dockerfile.
3. Set `DATABASE_URL` from the Postgres service.
4. Deploy — migrations run automatically via `bin/server`.