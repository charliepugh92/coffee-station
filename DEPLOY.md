# Deploying to Render

[`render.yaml`](render.yaml) is a [Render Blueprint](https://render.com/docs/blueprint-spec)
that provisions the whole stack on Render's **free tier**:

| Resource | Type | Plan |
|---|---|---|
| `coffee-station-db` | PostgreSQL | free |
| `coffee-station-cable` | Key Value (Redis) — Action Cable pub/sub | free |
| `coffee-station-api` | Rails GraphQL API + Action Cable (web service) | free |
| `coffee-station-app` | Vue SPA (static site) | free |

## Steps

1. **Push this repo to GitHub** (it must include `render.yaml`).
2. In the Render dashboard: **New → Blueprint**, connect the repo, and approve the
   plan. Render creates all four resources and wires the env vars (`DATABASE_URL`,
   `REDIS_URL`, `SECRET_KEY_BASE`, etc.) automatically.
3. The API build (`api/bin/render-build.sh`) runs `bundle install` and
   `bin/rails db:migrate` on every deploy.
4. **Verify the assigned URLs.** Render usually gives
   `https://<name>.onrender.com`, but may append a random suffix if the name is
   taken. If the API or SPA hostnames differ from the defaults, update:
   - `FRONTEND_URL` on **coffee-station-api** → the SPA's real URL
   - `VITE_API_URL` on **coffee-station-app** → the API's real URL

   then redeploy. These drive CORS, the Action Cable origin check, and the
   compiled-in API URL.
5. Open the static site URL and register a host account.

`RAILS_MASTER_KEY` is marked `sync: false` (optional). The app derives its JWT
secret from `SECRET_KEY_BASE` (generated once by Render and kept stable), so you
can leave the master key unset unless you add encrypted credentials.

## Free-tier caveats

- **Postgres expires 30 days after creation** (then a 14-day grace period before
  deletion), and is capped at 1 GB. Render emails you before expiry; upgrade or
  back up before then.
- **The API web service spins down after 15 minutes of inactivity** and cold-starts
  (~1 min) on the next request; open WebSocket connections drop and reconnect on
  wake. Free web services share 750 instance-hours/month per workspace.
- **Key Value (Redis) is non-persistent** on free — fine for Action Cable, which
  only uses it for ephemeral pub/sub.
- **Uploaded images are ephemeral.** Active Storage writes to the API instance's
  local disk (`config.active_storage.service = :local`), which Render wipes on every
  redeploy/spin-down — so option/preset photos and completion photos won't survive.
  For durable images, switch to S3-compatible storage (the `aws-sdk-s3` gem is
  already bundled): add an `amazon` service to `config/storage.yml`, set
  `config.active_storage.service = :amazon` in production, and provide the bucket
  credentials as env vars. [Cloudflare R2](https://developers.cloudflare.com/r2/)
  has a generous free tier and an S3-compatible API.

## What the Blueprint changed in the app

- `config/environments/production.rb`: `assume_ssl`/`force_ssl` (Render terminates
  SSL), an `*.onrender.com` host allowlist, and the Action Cable
  `allowed_request_origins` from `FRONTEND_URL`.
- `attachment_url` (GraphQL base object) reads `API_HOST`/`API_PROTOCOL` so image
  URLs are absolute `https://` links in production.
- CORS already reads `FRONTEND_URL`; `cable.yml` already uses `REDIS_URL` in prod.
