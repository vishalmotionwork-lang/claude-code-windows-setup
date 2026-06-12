---
name: Don't whack-a-mole — audit systematically then fix
description: When agent-written code has bugs, trying one-at-a-time wastes hours. Do a systematic audit first, then fix in a batch.
type: feedback
originSessionId: 6cf0c903-08d9-43ec-8ad7-680e44ef48eb
---
Agent-written code that was never actually run tends to have **multiple** systemic bugs, not one. When the first bug appears, do NOT chase it alone. Stop, grep for the class of bug across the whole subsystem, and fix them all at once.

**Why:** InstaShare 2026-04-23. The worker pipeline had 20+ bugs across 10 files. First run revealed one. I fixed it, restarted the worker (~20s boot), ran again, found the next one, repeat. After 4-5 cycles the user pushed back: "make sure you are working on the right thing, you are hallucinating." They were right — I was burning minutes per cycle when a single audit pass would have found them all.

**How to apply:**
- On FIRST unexpected failure from a task/module, stop testing. Grep the class of bug (`grep -rn "fetchrow\|\$1" worker/` for asyncpg misuse, `grep -rn "logger = logging.getLogger" worker/` for stdlib-logging-with-structlog-kwargs, etc).
- List every file that has the pattern.
- Spawn a narrow-scope agent (or do it yourself) to fix them in a single batch commit.
- THEN re-run and see what surfaces next — but it should be a different class of bug, not the same one in a different file.
- Bug classes seen in InstaShare: asyncpg `$N` placeholders in psycopg3 code, `fetchrow`/`fetch` on psycopg connections, `PoolDB(dsn=)` vs `PoolDB(pool)`, `RedisStateClient(redis_url=)` vs `(Redis)`, stdlib logger with kwargs, UUID from psycopg unstringified for Celery, `payload.attachments` vs `payload.message.attachments`, pool.execute `model=` kwarg collision, missing `conn.commit()`, `body.get(x, [])` returning None when key exists but value is null.
- Shared helper: when the same 5-10 lines of bootstrap appear in 3+ task files, extract to a single helper (`pool_bootstrap.py`). Pays for itself the first time the bootstrap changes.
- Restart cycle cost is real (~20s worker boot + ~60s pipeline run). One batch fix + one restart beats N loops.
