---
name: Graph-First Code Exploration
description: Always use code-review-graph MCP tools before Read/Grep/Glob — automated hooks enforce this
type: feedback
originSessionId: a0f997d5-14ea-4334-ab86-a0990bcb4667
---
ALWAYS use code-review-graph tools before Read/Grep/Glob for codebase exploration. Graph is fully automated now.

**Why:** Raw file reads cost 2K+ tokens each. Tracing 5 callers = 10K+ tokens. Graph tools return structured answers in 100-500 tokens — 95-98% savings per query.

**How to apply:**
- Start every task with `get_minimal_context` (~100 tokens)
- Use `semantic_search_nodes` instead of Grep to find functions
- Use `query_graph` (callers_of/callees_of/tests_for) instead of tracing imports manually
- Use `detect_changes` instead of reading diffs for review
- Use `get_impact_radius` before refactoring
- Fall back to Read ONLY when you need source code to write an actual edit
- PreToolUse hook on Read/Grep/Glob will remind you — treat it as a STOP signal

**Automation (2026-04-10):**
- SessionStart: `crg-auto-build.sh` — auto-builds graph if none exists for the repo
- PostToolUse (Edit/Write/Bash): `code-review-graph update --skip-flows` — incremental update <1s
- PreToolUse (Read/Grep/Glob): `crg-remind.sh` — prints reminder to use graph first
- CLAUDE.md: updated with mandatory decision tree and token budget rules
