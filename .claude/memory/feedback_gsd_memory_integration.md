---
name: GSD + Memory + gstack integration rules
description: How GSD, our memory system, and gstack work together without duplicating state
type: feedback
---

GSD and our memory system must not duplicate state. gstack tools are suggested after execution, not forced.

**Why:** SESSION.md and .planning/STATE.md were tracking the same things (phase progress, next steps), causing two sources of truth. gstack skills (QA, review, ship) naturally follow GSD execution but shouldn't be chained automatically.

**How to apply:**
- When GSD is active on a project: SESSION.md only tracks human-side context (blockers, stakeholder decisions, "why" context). Execution state lives in .planning/STATE.md.
- When no GSD: SESSION.md is full source of truth (default behavior).
- After /gsd:execute-phase: suggest /qa or /review. After /qa passes: suggest /ship. After milestone: suggest /retro. For big plans: suggest /plan-ceo-review or /plan-eng-review.
- Always suggestions, never automatic chains. Let user decide.
- CONTEXT.md feeds GSD agents so they skip discovery.
