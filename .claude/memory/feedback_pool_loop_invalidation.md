---
name: psycopg async pool dies when asyncio.run() rotates the loop
description: AsyncConnectionPool cached across asyncio.run() calls hangs on the second use because internals bind to the dead loop
type: feedback
originSessionId: d58ade87-7373-46ce-891f-0d767c003cbd
---
When a long-lived Python process (Celery prefork, etc.) wraps each task in
`asyncio.run(...)`, an `AsyncConnectionPool` cached at module level will
work for the first task and then hang every subsequent task with a
30-second `PoolTimeout: couldn't get a connection`.

**Why:** `asyncio.run()` creates a fresh event loop per call and closes
it on exit. The pool's internal asyncio primitives (queue, locks,
watchdog tasks) are bound to whichever loop was running when
`pool.open()` was awaited. When that loop closes those primitives go
dead. The cached `_pool` reference is still alive, so the next task
gets back the same pool object and awaits a queue tied to a closed
loop — which never resolves.

**How to apply:** Don't cache an async pool across loop boundaries
without invalidation. Track the loop the pool was opened on (via
`asyncio.get_running_loop()` at create time) and rebuild when the
running loop differs. Don't try to `await pool.close()` on the old
pool — its primitives are dead. Abandon it; GC handles it once the
dead loop is collected. (See InstaShare commit aae40ce.)

Same trap applies to any asyncio resource with a watchdog task or
internal queue: redis-py async, aiohttp connection pools, etc. If a
resource is built inside `asyncio.run()` and intended to be cached
across runs, assume it's broken across runs unless the docs explicitly
say otherwise.
