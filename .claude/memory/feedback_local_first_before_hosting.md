---
name: Local-first before hosting
description: When building a new app, get it running end-to-end locally before ANY hosting/deployment discussion
type: feedback
originSessionId: 0301a7b6-74e9-468c-a9a5-b39ed40a4431
---
# Rule: local-first, always

Get the app running end-to-end on Vishal's Mac before raising Hetzner, Fly, Vercel, Caddy, DNS, subdomain, or any other hosting/deployment topic.

**Why:** During InstaShare build (2026-04-20) I kept mixing hosting decisions (Fly→Hetzner→Caddy→Meta Dev App) with implementation. Vishal said: *"I think we are confusing a lot, our goal was to get everything running locally first, lets do that, once that is done than we will do hosting."* Confusing parallel tracks slows everything and breaks focus.

**How to apply:**
- Every new app: scaffold → make it boot locally → prove login → prove happy-path → THEN host.
- When a hosting question comes up mid-build, park it with "deferred until local works."
- Local stack for web apps: docker-compose for services (Redis/Postgres), `supabase start` for Supabase, `pnpm dev` + `uvicorn` for app, `cloudflared tunnel` for the one public URL a webhook needs.
- Never bring up domain/DNS/TLS until `localhost:3000` works end-to-end.
- If the user asks "will it run without hosting?" — answer YES directly and list the local stack.
