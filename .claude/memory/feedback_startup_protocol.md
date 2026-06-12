---
name: Startup Protocol — Always ask which project
description: Every new session must identify the project before doing any work. Load tiered context per project.
type: feedback
---

Every new conversation must follow this startup protocol:

1. Read `projects/REGISTRY.md` (silent, instant)
2. Ask: "Which project?" — show top 5 most recent. Or if user already named a project in their first message, skip the question and confirm.
3. Load that project's `CONTEXT.md` (Tier 1) + `SESSION.md` (Tier 2)
4. Confirm in one line: "Last time we [X]. Continue, or different task?"
5. Only then start working. Load `DECISIONS.md` (Tier 3) only if the task needs it.

**Why:** User has 13+ projects. Without this, Claude wastes time on wrong context or re-asks questions already answered in prior sessions. The old MEMORY.md was 106 lines of project details that bloated every conversation.

**How to apply:** At the START of every new conversation. If the user says "work on HireFlow" directly, skip step 2 — just load HireFlow context and confirm. If the user says something ambiguous like "let's continue", check REGISTRY.md for most recently touched project and confirm.

**SESSION.md is best-effort, not authoritative.** Always verify against actual git state before trusting session state claims.

**CLAUDE.md at ~/CLAUDE.md** contains the full protocol — startup, self-learning rule, and session-end protocol. It is loaded automatically every session.
