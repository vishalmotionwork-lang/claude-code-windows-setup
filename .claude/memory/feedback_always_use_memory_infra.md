---
name: Memory infrastructure — what to use and why
description: Automated hooks handle tracking + project switch. Qdrant's value = cross-project task search, not finding files by name.
type: feedback
originSessionId: 21fb51e5-97ad-44a7-b8c1-6ef15540a610
---
## Automated (hooks handle it, no action needed)
- **Learning loop**: PostToolUse tracks Read calls, Stop hook auto-classifies useful/ignored
- **Project switch**: Reading a project's CONTEXT.md auto-triggers Qdrant re-prefetch
- **Lock cleanup**: Orphaned Qdrant locks auto-removed (no holder = remove, no age check)

## Manual (still required — 4 things)
1. Read `~/.claude/context/hot.md` FIRST (enforced by memory-gate hook — blocks until read)
2. Read all feedback memories before touching work
3. **Cross-project task search** — when user describes a non-trivial task:
   ```
   uvx --with qdrant-client --with sentence-transformers --with redis \
     python3 ~/.claude/scripts/hot_memory.py task-search --query "<task>"
   ```
   Then read `~/.claude/context/task-context.md`. This surfaces how OTHER projects solved similar problems. Skip for trivial tasks.
4. **Always use full 3-tier pipeline when saving feedback/decisions:**
   - `hot_memory.py store --key "..." --value "..."` → Redis (instant next session)
   - Write the `.md` file → cold storage (persistent)
   - Qdrant re-index at session end if new files added
   - Don't skip Redis to save tool calls — got called out for being lazy (2026-04-10)

## Why task-search matters
Qdrant is useless for finding project files (folders do that). Its real value: cross-project knowledge.
- "deploy to Vercel" → returns feedback_vercel_git (past HireFlow mistake) + deployment patterns
- "build notifications" → returns HireFlow + Hotaru implementations + Supabase patterns
- "add Google OAuth" → returns HireFlow auth decisions + credential patterns

**Why:** 135 sessions with 0 manual tracking calls proved that Claude won't run commands voluntarily. Everything that needs Claude's cooperation must either be automated by hooks or provide immediate visible value. Task-search provides immediate value (cross-project context). Manual tracking does not (goes into a stats file nobody reads).
