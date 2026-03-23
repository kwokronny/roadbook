# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

小肥路书 (Roadbook) is a visual itinerary planning tool built on Amap (高德地图) and Dianping (点评). Users create travel plans with map-based schedule editing, photo uploads, collaboration, and luggage management.

## Monorepo Structure

pnpm workspace with three packages:
- `packages/roadbook-api` — Koa 2 backend (Node.js 18)
- `packages/roadbook-vue` — Vue 3 + Vite frontend
- `packages/docs` — VitePress documentation with Notion integration

## Common Commands

Run from repo root:
```bash
pnpm dev-api       # Backend dev server (port 3000)
pnpm dev-web       # Frontend dev server (port 6847)
pnpm build-api     # Build API
pnpm build-web     # Build frontend
```

Run from `packages/roadbook-api`:
```bash
npm run init:db    # Initialize database (create + migrate)
npm run db:migrate # Run pending migrations
```

## Architecture

### Backend (`packages/roadbook-api`)

**Entry**: `app.js` — Koa app setup, middleware registration, Amap proxy route (`/_AMapService/*` automatically injects `jscode`)

**Layers**:
1. `router/` — route definitions, JWT middleware (passthrough for login/register/public travel detail)
2. `controller/` — request validation, response formatting (`user.js`, `travel.js`)
3. `service/` — business logic (`user.js`, `travel.js`, `schedule.js`)
4. `models/` — Sequelize ORM: `User`, `Travel`, `Schedule`, `UserTravel`

**Database**:
- Development: SQLite at `./storage/db/roadbook.sqlite`
- Production: MySQL or PostgreSQL via environment variables (`DB_DIALECT`, `DB_HOSTNAME`, `DB_PORT`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`)
- JWT secret can be overridden by `./storage/jwt.pub` file

**Data model**:
- `User ↔ Travel` is many-to-many through `UserTravel` with roles: `view | edit | manage`
- `Travel` has-many `Schedule` (individual itinerary stops with coordinates, time, Dianping UUID, photos)

### Frontend (`packages/roadbook-vue`)

**Key directories**:
- `src/pages/` — route-level components: `auth/`, `travel/` (list + detail), `accept.vue`
- `src/components/` — shared components including `AMapContainer.vue`, `LocationSelector.vue`, `DianpinBtn.vue`
- `src/server/` — Axios API modules per domain (`user.ts`, `travel.ts`, `equip.ts`, `common.ts`)
- `src/store/index.ts` — Pinia store: token, userInfo, theme (persisted via pinia-plugin-persistedstate)
- `src/plugins/` — router, dayjs, maz-ui setup

**Styling**: Stylus with `src/style/variable.styl` for shared variables; Maz-UI component library

**Frontend env** (copy `.env.example`):
```
VITE_AMAP_KEY=...
VITE_AMAP_SECRET=...
```

In dev, Vite proxies `/api` and `/_AMapService` to the backend at port 3000.

### CI/CD

- **release.yml**: Triggers on changes to `roadbook-api`, `roadbook-vue`, or `Dockerfile`. Auto-bumps patch version, generates changelog, builds and pushes Docker images to Docker Hub (`kwokronny68/roadbook`) and GHCR.
- **deploy-doc.yml**: Triggers on changes to `packages/docs` or `CHANGELOG.md`. Deploys VitePress docs to GitHub Pages.

### Docker

Multi-stage build (Node 18 Alpine). Builds both packages, serves everything on port 3000. Persistent data in `/app/storage`.
