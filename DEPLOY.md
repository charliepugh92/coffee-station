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
3. **Set `RAILS_MASTER_KEY`** on **coffee-station-api** to the contents of
   `api/config/credentials/production.key` (it's git-ignored, so it isn't in the
   repo). This is now **required** — it decrypts the production credentials that
   hold `frontend_url`, `api_host`, and `api_protocol`. Without it, CORS and the
   Action Cable origin check fall back to `localhost` and the SPA can't connect.
4. The API build (`api/bin/render-build.sh`) runs `bundle install` and
   `bin/rails db:migrate` on every deploy.
5. **Custom domains.** This stack expects `api.daveys.coffee` (API) and
   `www.daveys.coffee` (SPA). Those values live in version control, not the Render
   dashboard:
   - The SPA's API URL is in [`app/.env.production`](app/.env.production)
     (`VITE_API_URL=https://api.daveys.coffee`), baked into the bundle at build time.
   - The API's `frontend_url` / `api_host` / `api_protocol` live in encrypted
     production credentials. To change them:
     `cd api && bin/rails credentials:edit --environment production`, then redeploy.

   Add both custom domains under each service's **Settings → Custom Domains**.
6. Open the SPA URL and register a host account.

## Free-tier caveats

- **Postgres expires 30 days after creation** (then a 14-day grace period before
  deletion), and is capped at 1 GB. Render emails you before expiry; upgrade or
  back up before then.
- **The API web service spins down after 15 minutes of inactivity** and cold-starts
  (~1 min) on the next request; open WebSocket connections drop and reconnect on
  wake. Free web services share 750 instance-hours/month per workspace.
- **Key Value (Redis) is non-persistent** on free — fine for Action Cable, which
  only uses it for ephemeral pub/sub.
- **Uploaded images** are stored on [Cloudflare R2](https://developers.cloudflare.com/r2/)
  in production (`config.active_storage.service = :cloudflare`), so option/preset photos
  and completion photos survive redeploys and instance spin-down. Dev/test still use
  local disk. The bucket is **private**; Active Storage serves attachments via
  short-lived signed URLs through its redirect controller.

  Before the first production deploy, add the R2 API token to encrypted credentials:
  ```
  cd api && bin/rails credentials:edit --environment production
  ```
  ```yaml
  r2:
    access_key_id: <R2 token Access Key ID>
    secret_access_key: <R2 token Secret Access Key>
  ```
  The bucket name, endpoint (which embeds the account id), and `region: auto` live in
  [`api/config/storage.yml`](api/config/storage.yml) under the `cloudflare:` service.
  To point at a different bucket/account, edit those values there.

## What the Blueprint changed in the app

- `config/environments/production.rb`: `assume_ssl`/`force_ssl` (Render terminates
  SSL), an `*.onrender.com` host allowlist, and the Action Cable
  `allowed_request_origins` from `Rails.application.credentials.frontend_url`.
- `attachment_url` (GraphQL base object) reads `api_host`/`api_protocol` from
  production credentials so image URLs are absolute `https://` links in production.
- CORS reads `Rails.application.credentials.frontend_url` (falling back to the Vite
  dev server in dev/test); `cable.yml` uses `REDIS_URL` in prod.
- Active Storage uses the `cloudflare` (R2) S3 service in production; its API token
  lives in `r2:` under encrypted production credentials.
