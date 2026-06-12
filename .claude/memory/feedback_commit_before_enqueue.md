---
name: Commit DB tx before enqueueing a Celery task
description: Insert-then-send_task across a still-open transaction races the worker; always explicit commit before enqueue
originSessionId: cf20d620-bddb-4a6c-b471-1f7c5479841f
---
name: Commit DB tx before enqueueing Celery tasks
description: Always explicit-commit the inserting connection before sending a Celery task that reads the row back
type: feedback
---

If an HTTP handler `INSERT`s a row then calls `send_task(...)` while the
connection context manager is still open, the Celery worker routinely picks
up the task within milliseconds — before the psycopg_pool context manager
commits on exit — and queries for the row using its own fresh connection
under READ COMMITTED. Result: `row IS NULL`, task logs "not found", silent
drop. psycopg_pool's default `pool.connection()` context commits only on
exit, not at send_task time.

**Why:** Hit in InstaShare webhook + paste handlers (2026-04-24). Symptom
was `correlate.raw_event_not_found` firing 8ms after the insert even though
a follow-up DB query 5s later confirmed the row existed.

**How to apply:**
- In any HTTP / async handler that does `INSERT ... ; await
  celery.send_task(...)`, add an explicit `await db.commit()` between the
  insert and the enqueue.
- Same rule applies to sync Django / Flask handlers with `@transaction.atomic`
  — enqueue *after* the atomic block, or use `transaction.on_commit(...)`.
- If you can't refactor the boundary, use an outbox table + polling worker
  so the enqueue is always at-most-once-per-committed-row.
