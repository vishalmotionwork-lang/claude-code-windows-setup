---
name: Agent scope narrowing
description: Narrow agent scope to disjoint files + explicit endpoint lists; broad exploratory scope stalls at 600s
type: feedback
originSessionId: 6cf0c903-08d9-43ec-8ad7-680e44ef48eb
---
When spawning a background agent for a medium-size task (multi-file, 500-1000 LOC), narrow the scope to a file-ownership partition with explicit deliverables. Broad "write the 9 missing handlers" scopes stall out.

**Why:** InstaShare session 2026-04-21: first agent given "write 9 missing FastAPI handlers" stalled after 600s still exploring — 0 commits landed. Respawned as 3 parallel agents each owning 2-3 disjoint router files with explicit endpoint lists + exact style-reference files to copy from. All three finished in 400-700s with full implementations + tests. Later, a 4th agent for the zod/verified_users refactor (also narrow scope) finished cleanly too.

**How to apply:**
- Give each agent specific file paths it owns + forbid touching other files
- List endpoints/contracts explicitly instead of "implement the spec"
- Point at a specific existing file as the style template ("match webhooks_instagram.py — APIRouter, pydantic v2, structlog, error envelope")
- Pre-read list should be SHORT (3-6 files) — not "read the whole spec"
- Include a handoff-file instruction: if context gets heavy, write handoff-<task>.md and stop
- Ask for a <200 word return summary so the result doesn't flood main-session context
- Commits: one per logical group (e.g., "feat(api): shares list/detail/delete", "feat(api): PATCH route + audit")
- Run multiple narrow agents in parallel when files are disjoint — main.py's try/except router-mount list makes router files safe to parallelize even in FastAPI apps
