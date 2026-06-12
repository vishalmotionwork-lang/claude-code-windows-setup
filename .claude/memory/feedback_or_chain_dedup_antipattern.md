---
name: OR-chain dedup is an anti-pattern past ~50 values
description: For "is X in this set of N values?" queries, use inArray()/= ANY() against an indexed column — never or(...n × eq/ilike) which becomes a planner bomb at scale
type: feedback
originSessionId: 87b89a91-b08d-4c56-8e57-f3169917de4c
---
When dedup-checking a batch of candidates/users/whatever against existing rows in
Postgres, NEVER write `or(eq(col, v1), eq(col, v2), ...)` or
`or(ilike(col, v1), ilike(col, v2), ...)`. Drizzle (and most query builders)
build a deep binary OR-tree, and Postgres has to plan/evaluate every leaf.

**Why:** Verified failure on HireFlow 2026-04-26. `detectDuplicates` did
`emails.map(e => ilike(candidates.email, e))` and dumped them through
`or(...)`. At ~150 emails it was slow, at 554 it crashed in production with a
generic "Server Components render error" (Postgres planner blowup, surfaced as
a server-action throw). The query had **1108 bound parameters** in one
statement — close to Postgres's 65,535 hard cap and well past pgBouncer's
patience.

**How to apply:**
1. **Batch lookups** → `inArray(column, valuesArray)` (Drizzle) or `= ANY($1)`
   (raw SQL). One bound param (an array). Single bitmap/index scan.
2. **Indexed column required** for scale → if you need case-insensitive or
   normalized comparison, add a STORED generated column with the normalized
   form (e.g. `email_normalized text GENERATED ALWAYS AS (lower(trim(email)))
   STORED`) and a partial btree index on it. Postgres backfills the column
   automatically on `ADD COLUMN` — instant on tables under ~100k rows. See
   HireFlow `drizzle/0010_dedup_normalized_columns.sql` for a worked example
   (email + phone + name normalization with `normalize_phone()` IMMUTABLE
   helper function).
3. **Don't fan a single query into N OR clauses** — fire 1 query per axis
   (email / phone / name) in `Promise.all`, dedup by id in JS afterwards.
4. **Threshold**: this matters from ~50 values up. Below that, OR-chain is fine
   but still less efficient.

**Red flags in code review:**
- `array.map(x => ilike(col, x))` followed by `or(...)`
- `array.map(x => eq(col, x))` followed by `or(...)`
- Any "fetch all, filter in JS" path that scales with the candidate table
  (was the phone path on HireFlow before this fix — 538 rows fetched per
  dedup call)

**Migration safety pattern (verified working on HireFlow):**
- Apply DDL via direct Postgres connection, NOT the Supabase pooler
  (`pooler.supabase.com:6543` doesn't allow DDL). Use
  `db.<ref>.supabase.co:5432` from local for migrations.
- `ADD COLUMN ... GENERATED ALWAYS AS (...) STORED` is additive — backfill is
  automatic, won't break existing reads.
- `CREATE INDEX IF NOT EXISTS` is idempotent and cheap on small tables; for
  >100k rows use `CONCURRENTLY` to avoid lock.
- Sequence: migration first, code deploy second. New code references new
  columns — must exist before deploy.
- Omit internal generated columns from public Drizzle-inferred types via
  `Omit<...>` so consumers don't see them.
