---
name: Neon neon() driver timestamptz cast bug
description: Never use ::timestamptz shorthand with neon() driver — use ::timestamp with time zone
type: feedback
originSessionId: 21fb51e5-97ad-44a7-b8c1-6ef15540a610
---
When using the `neon()` tagged template SQL driver (`@neondatabase/serverless`), NEVER use `::timestamptz` shorthand for casting parameters. Use `::timestamp with time zone` instead.

**Why:** The neon() HTTP driver silently misparses certain ISO timestamp strings when cast with `::timestamptz`. Specific values (e.g., `2026-04-02T18:30:00.000Z`) return wrong results while others work fine. The full type name `::timestamp with time zone` works correctly for all values. This caused the dashboard to show 1 session instead of 10 — took 2 hours to find.

**How to apply:**
- In any `sql\`...\`` query with neon(), replace `::timestamptz` → `::timestamp with time zone`
- Also applies to neon() queries in API routes, server actions, etc.
- This is specific to the neon-http driver, not regular pg/postgres.js drivers
