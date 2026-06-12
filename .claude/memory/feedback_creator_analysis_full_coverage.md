---
name: feedback_creator_analysis_full_coverage
description: "Creator competitive analysis: pull EVERY platform + full history (not top-N), and log every step to a per-creator PROGRESS-LOG.md"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d68763b8-3f01-4f67-9475-b34987d96f6e
---

For creator competitive-analysis work (the `~/creator-analysis/` workflow), Vishal wants TWO things made standing rules (2026-06-06, @mrnotion.co build):

1. **Every platform + FULL history — not just the anchor, not just top-N.** Discover and pull EVERY owned property: IG, TikTok, YouTube, Notion marketplace, every Shopify store, Skool, Facebook. Pull the complete post history, not a top-30 sample. Surface inactive/abandoned platforms too — an empty YouTube channel is itself a finding (a gap/opportunity). Cross-platform audience splits are key insight (e.g. mrnotion.co: TikTok=student/iPad angle, IG=business angle, same Notion skill).

2. **Document every step in `data/<handle>/PROGRESS-LOG.md`** — append-only, every command/finding/blocker/decision, as you go. "Every step we make needs to be documented for later use." Makes the run resumable and the techniques reusable. Mandatory.

**Why:** he studies competitors to model what works and to reuse the method on the next creator; a partial pull or an undocumented run loses both the competitive insight and the repeatable process.

**How to apply:** both are now encoded in `~/creator-analysis/WORKFLOW.md` golden rules #5/#6. Reusable scripts built this session: `scripts/ig_pull_media.py` (full IG history via rotating proxy), `scripts/transcribe_ig_proxy.py` (proxy+Groq transcription), `scripts/scrape_site.sh` (per-domain full-site crawl). Related: [[feedback_competitive_board_visual]], [[reference_ig_profile_scraping]], [[feedback_deep_research_creative_output]].
