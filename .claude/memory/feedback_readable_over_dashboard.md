---
name: feedback_readable_over_dashboard
description: Long-form content HTML (scripts, plans, docs) needs a single-column reading layout with generous type. Not a cramped 3-column dashboard with micro-pills and badges.
type: feedback
originSessionId: 253c2b81-1a73-45cd-8bff-08654aa3090a
---
When rendering long-form content (scripts, plans, synthesis docs) as an HTML page, use a **single-column reading layout** — max-width ~760–820px, 16–17px body type, generous line-height, restrained metadata. Not a dashboard with 3-column cards, tiny pills, dense stat grids, or cramped meta-strips.

**Why:** User flagged on 2026-04-23 after I delivered a SCRIPT.html with 3-column hook cards, stacked pills, and a 1100px grid: *"improve the webpage of that script to be able to read clearly like I don't need to see Hooks Card in the actual hook is so small return and lot of love going on in small points. Remove those as well."* Dashboard-style layouts signal "glance at metrics" — they kill reading flow. For prose-heavy documents, the page should feel like Medium / Substack / a product whitepaper, not a product dashboard.

**How to apply:**
- **Max width**: 760–820px for the main content column. 1100px is for dashboards, not reading.
- **Body type**: 16–17px minimum. 18px for primary script text. Line-height 1.7–1.8.
- **Stack vertically**: hooks, beats, sections — all in a single column, full-width inside the reading column. Never 2-col or 3-col grids for prose.
- **Minimize chrome**: one monochrome meta line per beat (clock, duration, one hook indicator). No stacked pills, no decorative badges, no 3-field stat strips inside cards.
- **Expandables over visible density**: use `<details>` for shooting notes / secondary metadata so the main flow stays clean. Reader opens only what they need.
- **Whitespace generous**: 48–80px vertical gaps between sections, 28–48px inside cards.
- **One accent color**: e.g., blue for callouts. Don't use 3 accent colors unless there's a semantic reason.
- **Stats go in dedicated tiles, not inline with prose**: separate "production package" tile grid, not mini-pills sprinkled through script text.
- When in doubt, read the page out loud. If the eye bounces around looking for what to read next, the layout is wrong.
