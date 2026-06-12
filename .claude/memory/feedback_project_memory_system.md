---
name: Project Memory System — Tiered context loading
description: Each project gets its own folder with CONTEXT.md, SESSION.md, DECISIONS.md. Never put project details in main MEMORY.md.
type: feedback
---

Project context lives in `memory/projects/<project-name>/`, NOT in MEMORY.md.

**Structure per project:**
- `CONTEXT.md` — Static facts: stack, URLs, commands, team, creds pointer. Rarely changes.
- `SESSION.md` — Last session state: what happened, next steps. Updated at end of each session.
- `DECISIONS.md` — Non-obvious decisions that code/git can't tell you. Only for active projects.

**REGISTRY.md** — All projects listed, sorted by last-touched date. No manual hot/cold. Just dates.

**Rules:**
1. NEVER put project details in main MEMORY.md — only user prefs, feedback, and pointers
2. When starting a new project, create its folder + CONTEXT.md immediately
3. When ending a session on a project, update its SESSION.md
4. When a project is done, update its status in CONTEXT.md and REGISTRY.md
5. REGISTRY.md sorted by last-touched date — most recent first

**Why:** MEMORY.md was 106 lines, mostly project dumps. Every conversation loaded all project context even when working on just one. Tiered loading means 50 projects cost the same as 5 at startup.

**How to apply:** Whenever creating, updating, or referencing project context. When user starts a new project, create the folder structure. When session ends, update SESSION.md. Keep MEMORY.md under 40 lines.
