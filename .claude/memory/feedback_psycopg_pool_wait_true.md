---
name: psycopg_pool open(wait=True) inside asyncio.run
description: When creating AsyncConnectionPool inside a Celery task body (asyncio.run), open with wait=True or connections get cancelled as the loop closes
type: feedback
originSessionId: cf20d620-bddb-4a6c-b471-1f7c5479841f
---
When a Celery task calls `asyncio.run(_coro(...))` and that coroutine opens a
`psycopg_pool.AsyncConnectionPool` with `open=False` then `await pool.open()`
(no wait), the pool launches a *background* task to fulfil `min_size`
connections. The task completes → `asyncio.run()` closes the loop → the
background connect task gets `asyncio.CancelledError`. psycopg_pool's
`CLIENT_EXCEPTIONS` includes `CancelledError`, and its `__str__` is empty, so
the log line is the misleading `error connecting in 'pool-N': ` (nothing after
the colon). Subsequent `pool.connection()` calls block forever because the
pool has zero live connections.

**Why:** Hit in InstaShare route_match / transcribe / vision / classify
(2026-04-24). The empty error string made the bug look like a DNS or
networking problem; the real cause was lifecycle, not connectivity.

**How to apply:**
- Any short-lived `AsyncConnectionPool` created inside a Celery task body
  (fork-pool or solo) must be opened with
  `await pool.open(wait=True, timeout=10.0)` so min connections are ready
  before the task starts.
- Also applies to any other context where the pool is created and torn down
  within a single `asyncio.run()` — scripts, one-shot async CLIs, etc.
- Long-lived pools created in a FastAPI lifespan are fine without
  `wait=True` because the loop never closes underneath them.
