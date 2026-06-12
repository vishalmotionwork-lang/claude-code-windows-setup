---
name: AI Chat UI Style Reference
description: Merged UI style — layout from Script/SuperChat screenshots + lavender design system from DESIGN.md. Use for webapp builds.
type: reference
---

# Webapp Build Style Guide

## Source
- **Layout/UX**: Script AI + Super Chat screenshots (2026-04-04)
- **Color/Visual**: ~/Downloads/DESIGN.md — "Intelligent Atmosphere" lavender design system

---

## Layout
- **3-column**: Left sidebar (~220px fixed, collapsible) | Center content (fluid, ~700px max) | Right sidebar (~280px)
- Right panel: contextual (history, projects, upsell cards)
- Asymmetrical by design — wide main + narrow offset sidebar

## Typography — Manrope
- Display: 28-36px, bold, letter-spacing -0.02em
- Headline/section: `on-surface` (#1E1B4B), high contrast
- Body: 15-16px, line-height 1.6, `on-surface-variant` (#595689)
- Labels/meta: 12px, uppercase, letter-spacing +0.05em
- Nav labels: 14px, medium weight
- **Never use pure black (#000000)** — always #1E1B4B

## Color Palette (from design system sheet)
| Token | Hex | Usage |
|-------|-----|-------|
| **primary** | #8B5CF6 | CTAs, filled buttons, checked states, active nav icons |
| **secondary** | #A78BFA | Gradient end, lighter purple accents, hover states |
| **tertiary** | #F472B6 | Pink accent — AI insights, critical highlights, sparingly |
| **neutral** | #1E1B4B | Dark navy — inverted buttons, headlines, primary text |
| surface (Layer 0) | #f9f5ff | Canvas/page background |
| surface-container-low (L1) | #f3eeff | Section grouping, input bg, card backgrounds |
| surface-container-lowest (L2) | #ffffff | Primary interactive cards, max contrast |
| surface-container-highest (L3) | #ddd9ff | Tooltips, popovers, secondary button bg |
| on-primary | #ffffff | Text on primary/inverted buttons |
| on-surface | #1E1B4B | Headlines, primary text (never pure black) |
| on-surface-variant | #595689 | Body text, descriptions, muted content |
| outline-variant | #aba7e0 | Ghost borders at 15% opacity only |

### Button Variants (from sheet)
- **Primary**: Filled #8B5CF6 bg, white text, pill-shaped
- **Secondary**: Light purple bg (#f3eeff or #ddd9ff), dark text, no border
- **Inverted**: #1E1B4B bg, white text, pill-shaped
- **Outlined**: Transparent bg, 1px border #8B5CF6, purple text

### Gradient
- Primary CTA gradient: `linear-gradient(135deg, #8B5CF6, #A78BFA)`
- Accent gradient (waveforms, hero): `linear-gradient(135deg, #8B5CF6, #F472B6)`

### Icon Styles (from sheet)
- Nav icons: Outlined, #8B5CF6 fill when active, circle bg on active state
- Action icons: Small squares with rounded corners, color-coded:
  - Edit/tools: #F472B6 (pink)
  - Label/tag: #A78BFA (secondary purple)
  - Delete/destructive: dark rose/maroon
- Icon + label pill: #A78BFA bg with icon + text

## The No-Line Rule (STRICT)
- **No 1px solid borders** for sectioning or layout
- Define boundaries through tonal shifts (e.g., #ffffff card on #f3eeff section)
- Use whitespace (16-24px) instead of dividers between list items
- If border needed for a11y: `outline-variant` at **15% opacity** only

## Surface Layering (Depth)
- Depth via stacking tonal surfaces, not shadows
- Layer 0 (#f9f5ff) → Layer 1 (#f3eeff) → Layer 2 (#ffffff) → Layer 3 (#ddd9ff)
- Shadows: `on-surface` (#2b2959) at 6% opacity, blur 32-64px, Y-offset 4-8px — **never pure black shadows**

## Glassmorphism
- Nav bars and floating menus: surface at 70% opacity + `backdrop-blur: 20px`
- Input bar: floating glass effect

## Components

### Sidebar Nav
- Icon + label rows, active = filled background pill
- Glass effect on nav bar

### Buttons
- **Primary**: Gradient `linear-gradient(135deg, #6a37d4, #ae8dff)`, white text, pill-shaped (full radius)
- **Secondary**: #ddd9ff background, no border, on-secondary-container text
- **Ghost/Tertiary**: No background, #6a37d4 text

### Cards
- No dividers inside cards
- Border-radius: 12px (md) or 16px (lg)
- Background: #ffffff on #f3eeff sections
- AI insight cards: 2px left accent bar in #a02d70
- Soft ambient shadow (tinted #2b2959 at 6%)

### Action Cards (Welcome State)
- 2x2 grid of rounded pill buttons: icon + label + "+" action
- Centered heading + subtitle above

### Chat Bubbles
- No hard borders — tonal bg differentiation
- 16-20px padding, generous spacing
- Message actions below: inline text buttons (Copy, Add to Editor, thumbs)

### Input Bar
- Bottom-pinned, floating glass effect
- Rounded rectangle 20-24px radius
- Background: #f3eeff, focus: #ffffff + ambient shadow
- Ghost border on focus only (15% #aba7e0)
- Helper row below: Attach, Voice, Browse Prompts as small text buttons
- Character counter, disclaimer text

### Right Sidebar
- Stacked cards with 12px gap
- History list: icon + truncated text, compact rows
- Upsell/pricing card: gradient primary → primary-container background

### Input Fields
- Background: #f3eeff
- Focus: shifts to #ffffff + ghost border + soft shadow

### Tags & Labels
- Full roundedness (pill), uppercase small text
- Speaker labels: secondary-container background
- Badges: small colored pills

## Spacing
- Card padding: 16-24px
- List item gap: 12-16px (whitespace, no dividers)
- Section gap: 24-32px
- Border radius: 12-16px cards, 20-24px inputs/pills

## Key Patterns to Replicate
1. Welcome state: centered display heading + subtitle + 2x2 action card grid
2. Chat: AI/user differentiated by tonal background layers
3. Right sidebar: history list + contextual cards
4. Bottom input: floating glass bar with secondary actions
5. Pill nav with active state
6. Tonal depth over borders/shadows
7. Gradient CTAs, ghost everything else
8. Tertiary (#a02d70) only for critical AI insights — sparingly
