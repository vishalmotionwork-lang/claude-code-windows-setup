---
name: KnowAI Design System location
description: Authoritative source for KnowAI-family UI primitives — React JSX recipes + rendered HTML previews with exact CSS
type: reference
originSessionId: ca87d7de-a494-4067-8b2c-66c695d1e7ce
---
All KnowAI-family apps (content-ops, knowframes, future KnowAI products) share one design system. When the user references a component from "the design system" or shows a screenshot from `/design-system/preview/*`, find and port from here — don't reinvent.

## Locations

- **React primitives (source of truth for tokens + behavior)**: `~/content-ops/app/design-system/ui_kits/_shared.jsx`
  - `Button` — variants: ink, white, secondary, outline, ghost
  - `Card` — tones: white, paper, dark × elevations: flat, pillow, chip, nested
  - `GlowBadge` — tones: success, warning, danger, ink (inner+outer glow; ONLY for dark cards)
  - `Badge` / `Chip` — variants: neutral, ink, outline, accent, success, warning, danger
  - `Dot`, `Eyebrow`, `Avatar`, `Icon`, `IconButton`, `Input`, `Kbd`, `Wordmark`, `Logomark`

- **Rendered previews with authoritative CSS (easiest to port from)**: `~/content-ops/app/design-system/preview/*.html`
  - `components-cards.html` — `.card-flat`, `.card-nested`, `.card-dark` (22px radius, 26px padding, pillow shadow)
  - `.chip-success` — green jewel pill with `.puck` disc (radial-gradient #D9F4BC→#8BD16A→#5EA844, outer glow)
  - `.caps` — mono 11px uppercase eyebrow (white/.45 on dark, var(--ink-3) on light)

- **Color + type tokens**: `~/content-ops/app/design-system/colors_and_type.css`

## Palette tokens (already in Knowframes `apps/web/app/globals.css`)
- `--surface-dark: #05121B` — the dark card background
- `--hairline-dark: rgba(255,255,255,0.10)` — borders on dark surfaces
- `--green / --success: #00B67A` — KnowAI mint green
- `--ink / --ink-2..--ink-5` — full ink ramp
- `--accent / --blue: #146DF7` — KnowAI primary blue
- Fonts: `--font-display` (Aeonik), `--font-sans` (Aeonik), `--font-mono` (JetBrains Mono)

## How to use
1. User says "make X look like [design system card]" → grep `~/content-ops/app/design-system/preview/` for the matching recipe.
2. Port CSS values inline to the target component (Tailwind can't express layered shadows / radial gradients without a preset; inline `style={{}}` is fine here and keeps it byte-for-byte).
3. Knowframes stays on Tailwind 3 + Radix (different from content-ops's Tailwind 4 + Base UI) — match VISUALLY, not structurally. Use inline styles pulled from the preview CSS.

## Example: "Secure deployment" pillar card in Knowframes
Ported into `apps/web/components/projects/project-card.tsx` on 2026-04-22:
- `.card-dark` → `background: var(--surface-dark); border-radius: 22; padding: 26; box-shadow: 0 1px 2px rgba(0,0,0,.25), 0 24px 48px -18px rgba(0,0,0,.45)`
- `.caps` on dark → `font-family: var(--font-mono); font-size: 11; uppercase; letter-spacing: .08em; color: rgba(255,255,255,.45)`
- Title → `font-family: var(--font-display); weight 700; 22px; letter-spacing: -0.02em; line-height 1.18`
- `.chip-success` + `.puck` → jewel-green pill with inner highlight, inner base, 1px green border, radial-gradient puck with outer glow.

## When NOT to use
- One-off prototypes where structure doesn't matter
- Internal admin tools that don't need KnowAI branding
- Third-party widgets (Tiptap, Radix primitives) — style them to match KnowAI but don't replace them
