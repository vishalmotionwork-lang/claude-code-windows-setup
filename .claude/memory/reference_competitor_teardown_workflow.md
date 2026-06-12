---
name: reference_competitor_teardown_workflow
description: End-to-end playbook for a total competitor/creator teardown (every platform → FigJam board). The exact multi-step pipeline used for the BenAI teardown — reuse for any creator/competitor.
metadata: 
  node_type: memory
  type: reference
  originSessionId: 4b905dce-bb97-4e4f-9e31-3ec9b45a950c
---

# Competitor / Creator Teardown — full pipeline

Goal: surface EVERY touchpoint of a person/brand (web, YouTube, LinkedIn, X, IG, Reddit, community, courses, revenue) → reasoned POV → brand-matched **FigJam board**. Proven on BenAI ([[projects/ben-ai-competitor-analysis/CONTEXT]]).

## 0. Recon → MASTER-MAP first (user explicitly wants the map before execution)
- `WebFetch` the homepage + `WebSearch` the name → identify person, all handles, all subdomains.
- Disambiguate same-name entities early (note who is NOT them).
- Write `MASTER-MAP.md` (touchpoint inventory) before deep work.

## 1. Confirm scope with AskUserQuestion (it's expensive/long)
Decide up front: transcription depth (curated vs all), **whether to pay/join gated communities** (don't pay without asking), and deliverable format (FigJam / HTML / markdown).

## 2. Fan out PARALLEL agents — one per surface, disjoint scope, each writes its own report file
Web/offer · YouTube content · LinkedIn · X+IG · Reviews/Reddit · Courses/community · Revenue/affiliates · VSL. Tell each: be honest about access limits, mark `[UNVERIFIED]`, cite sources, never fabricate. Auth-gated platforms (LinkedIn 999, IG) → recover what's public, say what's gated.

## 3. YouTube (do yourself, reliable)
- Channel bio + sub count: `yt-dlp --dump-single-json --playlist-items 1 "https://youtube.com/@handle"` → `.channel_follower_count`, `.description`.
- All video metadata in parallel: `yt-dlp --flat-playlist --print "%(id)s"` then `xargs -P12 yt-dlp --print "%(view_count)s\t%(upload_date)s\t%(duration)s\t%(id)s\t%(title)s"` per video (flat-playlist view_count is NA — see [[feedback_youtube_view_count_lockup]]).
- Transcripts: `yt-dlp --write-auto-subs --sub-langs en --convert-subs srt --skip-download` (instant/free; only use Groq Whisper for non-YouTube audio).
- **Brand deals = scan ALL descriptions** for affiliate links (`grep -ioE "partnerlinks|fpr=|via=|?ref="`). Creators usually run affiliates, not paid sponsorships.
- **Trend analysis:** sort videos by date, correlate spikes with AI launches → reveals the growth formula (e.g., "surfs each launch within days + 2 evergreen hooks").

## 4. VSL teardown
Wistia: `yt-dlp "wistia:<hashid>"` (the bare hashid works; the page URL may not). Then `ffmpeg` audio extract → Groq whisper-large-v3 (`response_format=verbose_json`, `timestamp_granularities[]=segment`) → timestamped transcript. `ffmpeg select='gt(scene,0.3)'` + fps=1/30 for screenshots. Map to a VSL framework (hook→problem→mechanism→proof→stack→anchor→CTA).

## 5. Website + funnel deep-dive (when user wants page-level detail)
- Authoritative sitemap: `curl https://site/sitemap.xml | grep '<loc>'`.
- **Full-page screenshots: firecrawl, NOT chrome headless** (chrome clips at window height) — see [[reference_firecrawl_fullpage_screenshot]].
- Per page: WHAT it is + WHY it's built that way (router/sales/fork/upsell/lead-bait/proof). Reconstruct funnel PATHS (entry → nurture → conversion), pricing, scarcity, guarantee (or absence).

## 6. Build the FigJam board (figma-console)
Images via CORS server — [[reference_figma_image_embed_cors]]. Brand-match colors, light bg, big numbers, per-section bands built with `figma_execute` (absolute positioning + helpers `txt/rect/img/label`), screenshot-validate each band. Sections used for BenAI: header+stats · business model · funnel · revenue+affiliates · YouTube growth (89-thumb montage + era cards) · VSL · social+bios · audience+reputation · playbook/how-to-beat · website page-by-page · customer journey maps (1 per ICP×offer).

## Deliver with a POV
Always end with vulnerabilities + "how to beat him" (not just description). See [[feedback_deep_research_creative_output]].
