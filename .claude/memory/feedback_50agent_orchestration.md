---
name: 50-agent parallel orchestration pattern
description: Wave-based agent orchestration that scales without breaking — foundation → screens → audits → fixers
type: feedback
originSessionId: 3edf6c33-fb30-4183-ace6-058002fe63a5
---
# 50-agent orchestration pattern (for "drop N agents in parallel" requests)

User asked this pattern for rebuilding the DaduOS design-preview-v2 (April 2026). It worked — zero file conflicts, all exports wired, smoke test PASS, only minor warnings in consistency review.

## The rule

When the user says "50 agents", "many agents", "parallel team", etc.:

**Why:** Raw parallelism breaks easily. The pattern below respects dependencies while maximizing per-wave parallelism — agents inside a wave run concurrently, waves run sequentially. Anti-break guarantees: strict file ownership per wave, audits read-only, fixers partitioned.

**How to apply:**

### 4-wave shape (scales from ~20 to ~60 agents)

**Wave 1 — Foundation (3 parallel, Sonnet 4.6)**
- Shared files everyone downstream depends on: tokens/styles, primitives/shared components, base layout CSS
- Each agent writes a DIFFERENT foundation file — no conflicts

**Wave 2 — Component/screen builders (10-15 parallel, Sonnet 4.6)**
- One agent per screen/component file
- Write a `CONTRACT.md` in the target folder first — shared design rules, available primitives, CSS classes, tokens, component-name contract for routing
- Each agent reads the contract + its specific spec + the old prototype for structure reference only
- Each agent owns ONE file exclusively — no cross-edits
- Names register on `window` so shell.jsx can route without imports

**Wave 3 — Audits (30 parallel, mostly Haiku, some Sonnet)**
- READ-ONLY audits across 4 lenses:
  - Lens A: token conformance (raw hex → var lookups) — 12 agents, one per file, Haiku
  - Lens B: responsive collapse (bare `1fr`, missing `minmax`, fixed widths) — 6 Sonnet agents on pairs
  - Lens C: a11y (clickable divs, aria-label, color-only semantics) — 6 Sonnet
  - Lens D: design rules (e.g. "blue = current/active only") — 6 Sonnet
- Write a single `AUDIT-RULES.md` once, reference in every audit agent
- Each writes to `.audits/<lens>-<file>.md` — no conflicts since distinct output paths
- Strict output format: severity (HIGH/MED/LOW), file:line, one-line fix suggestion

**Wave 4 — Fix + verify (5 parallel split across 4a/4b)**
- **4a: 3 Opus fixers**, STRICT file ownership partition. Each reads all audits for its files, applies HIGH+MED findings with documented judgment calls. File ownership is the anti-break guarantee.
- **4b: 3 finalizers** (Opus consistency review + Haiku smoke test + Haiku README) — all read-only or disjoint writes, true parallel.

### Anti-break guarantees (critical)

1. **No two agents ever write the same file in the same wave.**
2. **Wave N+1 fires only after Wave N completes** (use `run_in_background: true` + wait for notifications before firing next wave).
3. **Audits are read-only** — they can't introduce regressions.
4. **Fixers partition files** by agent ID — 3 × disjoint sets.
5. **Consistency review runs AFTER fixers** to catch drift.
6. **Smoke test curls every asset** + parse-checks braces + confirms `Object.assign(window,…)` suffix.

### Model strategy

- **Sonnet 4.6** = coding champion → Wave 1 + 2 (most JSX work)
- **Opus 4.7** = deepest reasoning → Wave 4a fixers (multi-audit synthesis) + Wave 4b consistency (cross-file)
- **Haiku 4.5** = cheap + fast → Wave 3 token audits + Wave 4b smoke test + README

### Design judgment calls (critical)

Audits find violations the fixer shouldn't always apply literally. Always give fixer explicit "KEEP these / FIX these" guidance in the brief. Example from DaduOS:
- KEEP: colored entry tiles in Home/Mobile (signature pattern intentional)
- FIX: decorative blue upload drop-zone tile (truly decorative)
- FIX: secondary blue "Assign one" link (not a primary CTA)

### What NOT to do

- Don't fire 50 micro-agents at component-level — coordination cost > execution cost
- Don't parallelize writes to the same file even briefly — race conditions
- Don't let fixers run parallel without file partition — they will clobber each other
- Don't have reviewers and polishers chained unless fixers have committed first

## Budget

For DaduOS rebuild: 51 agents, ~42 minutes wall clock, ~6 waves of parallel batching. Total cost dominated by Opus fixers (3 × ~100k tokens each).

## Reference implementation

`~/DaduOS/design-preview-v2/.audits/` has the full audit trail — AUDIT-RULES.md, 30 lens-specific findings, consistency.md post-fix report, smoke-test.md.
