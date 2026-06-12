---
name: KnowAI Brand System 2026
description: Real KnowAI design tokens from Brand Guidelines 2026 — blue primary, Aeonik font, systems-first tone. Supersedes any older navy/green info in MEMORY.md.
type: reference
originSessionId: 130ee5fd-02f4-41af-b2bd-058747067418
---
# KnowAI Brand System 2026

**Source of truth**: `~/Downloads/KnowAI Design System/` (colors_and_type.css, README.md, fonts/, ui_kits/, preview/)

## Tokens

- **Primary**: `#146DF7` (brand blue) — links, accents, delta chips, focus rings
- **Blue-ink**: `#0F55C6` (pressed/hover)
- **Blue-deep**: `#0A3C91` (emphatic text on light)
- **Blue-soft**: `#CFF0FF` (tints, chips)
- **Ink** (text/near-black): `#05121B`
- **Ink-2/3/4/5**: `#10222F` / `#4C5963` / `#5B6B76` / `#A6B5BF`
- **Paper** (app bg): `#F7F7F7` (cool gray, never warm)
- **Surface** (cards): `#FFFFFF`
- **Extended**: purple `#8B3FE9`, green `#00B67A`, amber `#E67D21`, red `#CB3939`
- **Radii**: xs 4 / sm 6 / md 10 / lg 14 / xl 20 / 2xl 28 — small, structured (no pillowy 24px+ default)
- **Shadows**: crisp, restrained — no heavy drop shadows

## Type

- **Display + sans**: `Aeonik` (local OTF files in `KnowAI Design System/fonts/`), fallback `Inter Tight`
- **Mono**: `JetBrains Mono` — for data, numbers, telemetry, eyebrow labels
- **Scale**: h1 44 / h2 32 / h3 22 / body 15 / small 13 / micro 11
- **Display**: clamp up to 104px
- **Tracking**: tight on display (-0.035em), loose caps (0.08em)

## Tone

> "Our brand does not compete through noise. It stands apart through clarity, discipline, and credibility." — Brand Guidelines 2026

- Declarative, confident, precise — systems-first operator voice
- No emoji, no em-dash theatrics, no exclamation marks
- Sentence case in UI; digits for metrics ("4 frameworks", not "four")
- Anti-hype vocab: **frameworks, structure, clarity, execution, discipline, practical, reliable, systems, stability, control, intentional**
- Banned: revolutionary, magic, unleash, supercharge, "let's get you set up", "oops"

## Why: Previous memory had wrong tokens (navy + green + lime) — that was from an older mental model. The 2026 brand book is **blue + ink + Aeonik**, not navy + green + Inter.

## How to apply

- Any KnowAI-branded asset (video overlays, slides, web, print, docs): start from `colors_and_type.css` and the `ui_kits/` folder, not from memory
- Load Aeonik from the local path `KnowAI Design System/fonts/AeonikTRIAL-*.otf` when building assets in `~/Downloads/` or similar
- Use JetBrains Mono for numeric data in charts, telemetry labels, eyebrows
- Keep surfaces white on paper `#F7F7F7` with hairline dividers at `rgba(5,18,27,.08)`
