# AWChat Railway monorepo

This repository is an **isolated monorepo**: three deployable server services under `server/`, each with its own `railway.toml`. Do **not** deploy from the repository root as a single service.

| Railway service | Root directory   | Config file                   | Exposure                             |
| --------------- | ---------------- | ----------------------------- | ------------------------------------ |
| `broker`        | `/server/broker` | `/server/broker/railway.toml` | Public (only service with a domain)  |
| `auth`          | `/server/auth`   | `/server/auth/railway.toml`   | Internal (`auth.railway.internal`)   |
| `awchat`        | `/server/relay`  | `/server/relay/railway.toml`  | Internal (`awchat.railway.internal`) |

Postgres plugins (add in Railway): **Postgres** → relay, **Postgres-Auth** → auth.

**Redis** plugin (shared): attach to **`broker`** and **`awchat`** via `REDIS_URL=${{Redis.REDIS_URL}}` (confirm reference name in dashboard). See [Plan 002](plans/server/002-redis-durable-encrypted-pipeline.md).

### Serverless and teardown (bring-up)

During initial deployment, **serverless** and **teardown** may stay **enabled** on all services (including `broker`, `auth`, `awchat`) to limit idle cost. **Disable serverless/teardown on `broker` when the public API is production-ready** so clients always hit a warm edge. Internal `auth` / `awchat` may remain serverless longer; ciphertext durability relies on **Postgres** + **Redis**, not relay process memory.

## GitHub push-to-deploy (recommended bootstrap)

1. Create an **empty** Railway project (do not deploy the whole repo as one service).
2. Run the bootstrap script (requires `railway login`):

```bash
./scripts/ops/railway-monorepo-bootstrap.sh awchat-relay
```

3. In the Railway dashboard:
   - Generate a public domain on **broker** only (you assign `chat-api.awfixer.me`).
   - Do **not** add public domains to `auth` or `awchat`.
4. Set broker upstreams if not applied by bootstrap:
   - `RELAY_UPSTREAM=awchat.railway.internal:8080`
   - `AUTH_UPSTREAM=auth.railway.internal:8081`
   - `BROKER_OPS_TOKEN=<random secret>`

## Manual setup (dashboard)

For each service (`broker`, `auth`, `awchat`):

1. **Settings → Source:** connect `awfixers-stuff/awchat`, branch `master`.
2. **Settings → Root Directory:** set per table above.
3. **Settings → Config file:** set absolute path per table above (config does **not** follow root directory).
4. **Settings → Watch Paths:** leave empty — `watchPatterns` in each `railway.toml` handles this.

`watchPatterns` in config-as-code are repo-root paths (e.g. `/server/broker/**`), so only the affected service redeploys on push.

## Wait for CI

Railway can defer deploys until GitHub Actions succeed. For each service (`broker`, `auth`, `awchat`):

1. **Settings → Deploy:** enable **Wait for CI**.
2. Ensure the repo has the root [`.github/workflows/ci.yml`](.github/workflows/ci.yml) workflow (runs on every `master` push).
3. After the workflow is on `master`, apply branch protection so merges cannot bypass the gate:

```bash
./scripts/ops/github-branch-protection.sh
```

The required status check name is **`gate`** (final job in the CI workflow). Railway waits for all push-triggered workflows to succeed; keep only the unified `CI` workflow as the deploy gate.

## Verify

```bash
./scripts/ops/railway-health.sh
```

See also [`server/broker/README.md`](server/broker/README.md), [`server/auth/README.md`](server/auth/README.md), [`server/relay/README.md`](server/relay/README.md).
