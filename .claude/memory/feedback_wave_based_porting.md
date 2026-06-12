---
name: feedback-wave-based-porting
description: "For multi-thousand-line React→Next.js ports, split into named \"waves\" handed to subagents with foundation already in place — each wave 5-15 files, builds on prior wave's primitives"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 45c76727-0963-4a3d-9ff6-496ec17302a1
---

# Wave-based porting pattern (large React → Next.js ports)

Pattern that shipped the ecskort-web port (2026-05-27) — 23k lines, 44 routes, 5 dashboard surfaces in one session.

## The structure

Don't ask an agent to "port everything." Instead:

**Phase A (orchestrator)** — Scaffold + port shared primitives (BRAND/Icon/Display/Silhouette/AdSlot/Logo/Button/Marquee). Verify with a smoke-test `/preview` page rendering every primitive. This is the foundation later waves stand on.

**Phase B (Wave 1)** — Port the most-visited public page using those primitives. Sets the pattern for responsive layouts, route group organization, ISR config.

**Phase B (Waves 2-5)** — Each subsequent wave is one or two pages + their components. Each agent invocation sees the foundation already exists. They import the same primitives. They follow the same patterns.

**Phase C, D, E** — Dashboard surfaces. Each port reuses dashboard primitives created in C.

**Phase F** — Scale wiring (cache, security headers, sitemap, observability).

## Per-wave prompt template

Each subagent gets:
- Source file paths and line numbers for the functions to port
- Destination paths (already-created folders from Phase A)
- Exact imports cheat sheet — what's already ported and named
- Explicit bug-list to fix during port (from FEATURE-AUDIT.md)
- Quality bar: tsc clean, next build pass, listed URLs return 200
- "Don't port yet" list — what belongs to the next wave
- Handoff fallback: write `~/.claude/context/handoff-<wave>.md` if context runs low

## Why this works

- **Each subagent's context window is fresh**, no carryover from earlier ports
- **Foundation imports are concrete** — the prompt names `@/components/primitives/Silhouette` etc., subagent doesn't have to discover
- **Fixes happen during port**, not after — no double-work
- **Verification is per-wave** — failures caught at 15-file scope, not 100-file scope
- **Main session orchestrates** — keeps mental model of the whole, delegates the typing

## Pitfalls

- **API overload mid-wave** — happened on the Model dashboard wave (23 routes). Mitigation: split large waves into "foundation files first, ports second" so a fresh agent can resume with partial work intact.
- **Server→Client boundary on prop passing** — RSC rejects function props. NAV arrays with icon factories must be imported in the client component, not passed from server layout. Spell this out in the prompt.
- **Original code with random/non-deterministic values** (Math.random country counts, etc.) — agents tend to preserve them; flag to use deterministic alternatives so SSR/CSR match.

## Why save: pattern is reusable

Will apply to any port: HireFlow→v2, DaduOS→v2, ZeelOS additions. The agent-orchestrator template above is the actual artifact worth saving.
