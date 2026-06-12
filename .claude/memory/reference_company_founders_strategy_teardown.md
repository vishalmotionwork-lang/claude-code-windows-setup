---
name: reference_company_founders_strategy_teardown
description: "End-to-end playbook for a MULTI-FOUNDER company teardown focused on STRATEGY & PLANNING (positioning, GTM, content, offer, channel) — not financials. Extends the single-creator teardown for companies with several founders. Deliverable = brand-matched FigJam board with a how-to-win POV."
metadata: 
  node_type: memory
  type: reference
  originSessionId: f86eb18d-9f1f-4dea-a661-41d8fab71f28
---

# Company + Founders Teardown — STRATEGY-focused, multi-founder

Goal: tear down a whole company AND every founder behind it, surfacing **how they think and operate** — positioning, GTM motion, content strategy, offer architecture, channel strategy — and end with a **POV: the playbook + gaps + how to win + what to steal**. Strategy/planning lens, NOT funding/revenue math. Deliverable = brand-matched **FigJam board**. Builds on the single-creator pipeline [[reference_competitor_teardown_workflow]].

## Scope rules (locked with the user)
- **Lens = strategy & planning, light on financials.** DROP: revenue estimates, Crunchbase funding rounds, hiring/tech-stack trivia (unless user asks for a light touch). KEEP anything that reveals the *playbook*.
- **Deliverable = FigJam board** (figma-console), brand-matched, real screenshots baked in, big numbers, final how-to-win POV band.
- **Depth:** curated video transcripts (~20-25 strategic, not all) + **full VSL teardown** if they have a sales video + **public surfaces only** (never pay/join gated communities without asking — [[feedback_no_silent_membership_changes]]).
- Confirm any expensive/long branch + never fabricate; mark `[UNVERIFIED]`, cite sources ([[feedback_no_script_fabrication]], [[feedback_no_assumptions_ask_instead]]).
- Plain-English synthesis, real POV not dumps — use the design system, genuine fan-out ([[feedback_deep_research_creative_output]], [[feedback_no_marketing_jargon_product_docs]]).

## 0. Recon → MASTER-MAP (before any deep work)
- `WebFetch` homepage + `WebSearch` company name → identify the company, ALL founders (about/team page, LinkedIn company "People", Crunchbase team), every handle, every subdomain, the core offer.
- Build the **founder roster** first: name → role → all personal handles each.
- Disambiguate same-name people/companies early (note who is NOT them).
- Write `MASTER-MAP.md` = company touchpoints + per-founder touchpoint inventory.

## 1. Confirm scope with AskUserQuestion (it's expensive/long)
Target (name+link), deliverable format, depth (curated transcripts / VSL / gated). User defaults this run: FigJam · curated transcripts + full VSL · public only.

## 2. Fan out PARALLEL agents — disjoint scope, each writes its own report file
**Per founder (one agent each, or batch small ones):** LinkedIn (full profile, work history, post archive + engagement, recurring themes, comment-to-DM plays) · X/Twitter (bio, followers, top posts, what they amplify) · personal YouTube / podcast guest spots · IG/TikTok · personal site / Substack / newsletter · founder narrative (how each frames the origin story, where stories align vs diverge) · screenshot every profile.
**Company-level agents:** website+offer · company content (YouTube/LinkedIn page/X/IG/TikTok) · blog/SEO footprint (what they rank for, cadence) · reviews & sentiment (G2/Capterra/Trustpilot/Reddit/App Store) · VSL.
Tell each agent: be honest about access limits, mark `[UNVERIFIED]`, cite sources, never fabricate. Auth-gated (LinkedIn 999 / IG) → recover what's public, say what's gated. Narrow scope to disjoint files + explicit URL lists so agents don't stall ([[feedback_agent_scope_narrowing]]).

## 3. YouTube (do yourself, reliable) — for company + any founder channel
- Bio + sub count: `yt-dlp --dump-single-json --playlist-items 1 "https://youtube.com/@handle"` → `.channel_follower_count`, `.description`.
- All video metadata in parallel: `yt-dlp --flat-playlist --print "%(id)s"` then `xargs -P12 yt-dlp --print "%(view_count)s\t%(upload_date)s\t%(duration)s\t%(id)s\t%(title)s"` (flat-playlist view_count is NA — [[feedback_youtube_view_count_lockup]]).
- Transcripts: `yt-dlp --write-auto-subs --sub-langs en --convert-subs srt --skip-download` (instant/free; Groq Whisper only for non-YouTube audio).
- **Content strategy read:** which platform does which funnel job (TOF/MOF/BOF), formats, cadence, hook patterns; sort by date + correlate spikes with launches/trends to reveal the growth formula.

## 4. VSL teardown (if a sales video exists)
Wistia: `yt-dlp "wistia:<hashid>"` (bare hashid works). `ffmpeg` audio → Groq whisper-large-v3 (`response_format=verbose_json`, `timestamp_granularities[]=segment`) → timestamped transcript. `ffmpeg select='gt(scene,0.3)'` + fps=1/30 for frame screenshots. Map to framework: hook→problem→mechanism→proof→stack→anchor→CTA.

## 5. Website + funnel deep-dive (strategy lens)
- Sitemap: `curl https://site/sitemap.xml | grep '<loc>'`.
- **Full-page screenshots: firecrawl, NOT chrome headless** (chrome clips at window height) — [[reference_firecrawl_fullpage_screenshot]].
- Per page: WHAT + WHY (router/sales/fork/upsell/lead-bait/proof). Reconstruct funnel PATHS (entry→nurture→conversion), positioning, messaging, offer architecture (free→paid logic, upsell path) as STRATEGY — not dollar figures. Note scarcity/guarantee (or absence) as tactics.

## 6. Strategic adds (the "think more" — they reveal the playbook)
- **Meta + Google Ad Library** — pull live ad creative & copy = their *tested* messaging strategy.
- **Wayback Machine** — how positioning/pricing/messaging EVOLVED (what they doubled down on vs killed).
- **Content velocity & themes** over time.
- **Founder channel-size comparison matrix** — who's the real reach/distribution engine vs silent partner.
- **Press/podcast circuit** — where they get covered.

## 7. Build the FigJam board (figma-console)
Images via CORS server [[reference_figma_image_embed_cors]] OR baked via `createImage` (preferred — no server needed). Brand-match colors, light bg, big numbers, per-section bands via `figma_execute` (absolute positioning + helpers `txt/rect/img/label`), screenshot-validate each band. Auto-layout hugs content to avoid overflow ([[feedback_figjam_autolayout_over_miro]], [[reference_figjam_section_coords]]).
**Bands:** header+company stats · founder roster (a card/section per founder: role, handles, channel sizes, narrative, screenshots) · founder channel comparison matrix · positioning & messaging · GTM motion / funnel paths · content strategy (platform→funnel-job map, cadence, hooks) · offer architecture · website page-by-page (firecrawl screenshots + per-page why) · ad library creative · reviews/sentiment · **POV band: the playbook + gaps + how to win + what to steal.**

## Deliver with a POV
Always end with the strategic synthesis: their repeatable playbook, the gaps/vulnerabilities, how to win against them, and what to steal. Not just description. [[feedback_deep_research_creative_output]]
