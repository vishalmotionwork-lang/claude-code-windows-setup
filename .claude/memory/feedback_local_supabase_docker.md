---
name: feedback_local_supabase_docker
description: Always use local Supabase via Docker (supabase CLI) during development, not cloud dashboard
type: feedback
---

When setting up Supabase projects, use `npx supabase init` + `npx supabase start` for local Docker development. Don't send user to cloud dashboard for initial setup.

**Why:** User wants everything running locally with Docker for dev. Cloud Supabase is for deployment later. Local-first development is faster and doesn't require internet.

**How to apply:** 
- Use Supabase CLI (`supabase init`, `supabase start`) which runs Postgres, Auth, Storage, etc. in Docker
- `.env.local` points to `http://127.0.0.1:54321` (local Supabase)
- Migrations in `supabase/migrations/` — push to cloud later with `supabase db push`
- When deploying: `supabase link` to cloud project, then `supabase db push`
