# Davey's Coffee

A real-time app for running a small-town, local coffee station. A host configures a
drink menu, opens the station, and shares a link (or QR code). Guests order through
the link with no login; orders stream to the host's board live over WebSockets; the
host marks each ready with a photo; guests get a live "your coffee's ready" notice,
can rate and comment, and — even after closing their browser — return to see their
history and reorder.

## Stack

Monorepo with two apps:

- **`/api`** — Rails 8.1 API-only, GraphQL ([graphql-ruby](https://graphql-ruby.org)),
  PostgreSQL, Devise + JWT (email/password), Active Storage for images, and GraphQL
  subscriptions over Action Cable.
- **`/app`** — Vue 3 + Vite + TypeScript, Pinia, Vue Router, Tailwind, Apollo Client
  (multipart uploads + `ActionCableLink` for subscriptions), and graphql-codegen for
  end-to-end typed operations.

## Prerequisites

- Ruby 3.3.x (`rbenv`), PostgreSQL running locally
- Node 22 (via `nvm`)
- `tmux` (for `bin/dev`)

## Setup

```bash
cd api && bundle install && bin/rails db:create db:migrate && cd ..
cd app && nvm use 22 && npm install && cd ..
```

## Run

```bash
bin/dev            # tmux: API on :3000, Vue on :5173
```

Then open <http://localhost:5173>. The GraphQL explorer is at
<http://localhost:3000/explorer>. After changing the GraphQL schema or `.graphql`
operations, regenerate types: `cd app && npm run codegen`.

## Quality checks

```bash
bin/check          # RuboCop, RSpec (90% coverage floor), Brakeman, bundle-audit,
                   # TypeScript, ESLint, Vitest, npm audit — all in parallel
```

## How it works

- A **User** (host) owns multiple **Stations**, each with its own reusable menu
  (customization categories/options + curated presets, all with optional images).
- Opening a station creates a **Session** with an unguessable share token; closing it
  blocks new orders. One open session per station.
- Guests place **Orders** (no account); the server mints a per-order **guest token**
  returned once and stored in the browser's localStorage. Possession of the token is
  the authorization for reading status, rating, commenting, and reordering.
- Realtime is GraphQL subscriptions over Action Cable: `orderAdded` (host board),
  `orderUpdated` (guest status + live queue position), `sessionUpdated` (open/close).
