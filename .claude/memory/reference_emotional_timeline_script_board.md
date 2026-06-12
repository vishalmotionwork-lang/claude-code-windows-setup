---
name: reference_emotional_timeline_script_board
description: "FigJam \"emotional timeline\" design for laying a video script INTO a beat framework — colored beat blocks + per-beat cards (WHAT/WHY/SCRIPT/YOUR-TURN), placeholders highlighted. Built for KnowAI Raw-intro scripts; reusable for any creator script."
metadata: 
  node_type: memory
  type: reference
  originSessionId: 096e7c7d-874f-4a50-8902-a2f27573ae6a
---

A reusable FigJam layout for putting a **video script inside its beat framework** so framework + script + fill-in-blanks are all visible at once. First built 2026-06-10 for the KnowAI Raw/Palki-style intro ([[knowai-youtube-plan-board]] — section `52:1073`, Versions A `57:1759` 6-beat and B `57:2084` 8-beat).

## The layout (top → bottom), one full-width `figma_execute` auto-layout master
1. **Hero video** (the recreation) — big 16:9 slot/embed.
2. **"VERSION X" tag** (tiny uppercase) → **big centered title** → **centered legend-subtitle** that doubles as the key: *"color = the emotional job each beat does · the peaks are beats N & M · amber/blue box = your turn to fill in."*
3. **Horizontal row of N colored beat blocks** (rounded rect, white-bold time range inside, "▲ PEAK" marker on the peak beats), each block sitting directly above **its card**.
4. **Card** (one per beat) = italic **micro-label** → **WHAT** (the framework move) → optional **WHY** (the rationale) → **SCRIPT** (the actual spoken lines, in a light `#F8FAFC` panel) → **YOUR TURN** box (the fill-in prompt; amber by default, **blue** for the catalyst/peak beat — mirrors the "amber/blue box" legend).

## Two highlight layers (the whole point)
- **Framework** = the lavender/tinted bands + colored blocks + WHAT/WHY labels = "the structure we engineer."
- **Placeholders** = anything Zeel must supply, written inline as `[placeholder]` / `[ZEEL FILL …]` and **highlighted amber-bold** so "what's left to fill" is obvious. Never fabricate the personal specifics — leave the bracket. See [[feedback_no_script_fabrication]].

## Build mechanics (figma_execute)
- Columns = `layoutGrow:1` inside a fixed-width horizontal row (`resize(FULLW, h)` then `counterAxisSizingMode="AUTO"`); cards/text use `layoutAlign="STRETCH"` to fill; text `textAutoResize="HEIGHT"`. Block height fixed via `primaryAxisSizingMode/counterAxisSizingMode="FIXED"` + `resize`.
- **Placeholder highlight:** loop `/\[[^\]]*\]/g` over the text and `setRangeFills(0xC2410C amber)` + `setRangeFontName(Inter Bold)` per match (load Inter Regular/Medium/Bold/Italic first).
- Beat block palette used: coral `#E0857A` · amber `#E0A552` · green `#8FBF7F` · blue `#5B9BD5` · teal `#5FA6AD` · purple `#8B8FD9` · rose `#D25D6E`.
- Place the master into the existing SECTION with `sec.appendChild(master)` then set section-relative `master.x/master.y`; grow the section with `resizeWithoutConstraints`. Guard writes with the focused-file root-name check ([[reference_figma_console_multifile]]).

## When to reuse
Any "lay a script onto a beat/emotional framework" ask — Raw intro, teardown-derived scripts, a creator's signature structure. Pairs with the breakdown format already on the KnowAI YouTube board. Keep wording consistent across the framework table, the cards, and the source `.md` ("no context rot").
