---
name: feedback_competitive_board_visual
description: "Competitive-analysis FigJam boards must be visual, brand-matched, icon + real-screenshot driven — not text docs"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 7ba908fd-c934-4797-8493-d6154f54b540
---

When building competitive-analysis / creator-teardown boards in FigJam, Vishal wants them
**visual and instantly understandable to a novice**, NOT walls of text. He iterated 4× on the
@ant.lon board until it was right.

**The rule (in order of how he asked for it):**
1. One **visual board per vertical** (Identity / Business / Website / YouTube / Content), laid out as a
   row of titled SECTIONs — NOT markdown text documents. Cards, big numbers, diagrams.
2. **Icon-driven + minimal reading.** SVG line icons everywhere (`figma.createNodeFromSvg`), big
   hero numbers, funnel diagrams, "In plain English:" one-liners. Full verbatim detail stays in the
   dossier `.md` files, not on the board.
3. **Embed the creator's REAL media** — screenshots of their landing page / store / product pages /
   YouTube + a grid of actual reel covers. "We have everything we need" — so capture and show it.
4. **Match the creator's own brand tone** (sample their hero screenshot for palette/logo/serif), so it
   "feels like his only" — BUT on a **WHITE/light background** (he rejected the dark version even though
   it matched the brand).

5. **BUT it must ALSO be complete — visual is NOT a substitute for full detail.** This was a real
   miss on the first @ant.lon build: the visual boards summarized, and the **full content transcripts +
   verbatim depth got left in the dossier files instead of ON the deliverable.** He explicitly asked for
   "all the content with their transcript and everything." So the template is **BOTH**: the visual
   brand board on top + a **full-detail appendix attached to each vertical** (each reel = full verbatim
   transcript + complete teardown; each product = full verbatim copy; website = full page copy; etc.).
   Use `scripts/md_to_figjam.mjs` to render the dossier `.md` as a doc-board appendix directly below
   each visual board. Multiple sections per vertical is expected and fine.

**Why:** he studies competitors to model what works; a board you can *look at* AND drill into beats
either a dense report or a pretty-but-shallow summary. Visual for the gist, full text right there for depth.

**Full-site deep crawl (Phase 2.6, added 2026-06-06):** scrape the ENTIRE owned site — every page,
product, link, review + a full-page screenshot of each — via `scripts/scrape_site.sh <handle> <url>`
(firecrawl map→download→agent). Output `data/<handle>/site/`. SOP: `creator-analysis/SITE-SCRAPE.md`.
Feeds Phase 6 (business/revenue), Phase 7 (positioning copy), Phase 8 Website board (embed screenshots).

**How to apply:** capture screenshots first (Phase 7.5); build light brand-themed visual cards with
embedded images + icons; then append the full-detail doc-board (transcripts + verbatim) per vertical.
Image embed = CORS server on whitelisted port + `fetch`→`createImage` (PLAYBOOK Phase 8). Related:
[[feedback_screenshot_card_design]], [[feedback_readable_over_dashboard]], [[feedback_no_marketing_jargon_product_docs]].
