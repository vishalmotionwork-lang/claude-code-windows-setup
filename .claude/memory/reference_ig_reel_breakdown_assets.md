---
name: reference_ig_reel_breakdown_assets
description: Where the Story Sequence reel deliverables live — self-contained HTML teardown + the native 9:16 FigJam story-slide board — plus the reusable reel→board pipeline used.
metadata: 
  node_type: memory
  type: reference
  originSessionId: b5fc7121-2ab8-44f9-bb30-f24579104f1f
---

# Story Sequence reel — deliverables & pipeline (2026-06-09)

Source reel: IG **DSH20zdjNqN** (Nicolas Clay). Framework decoded in [[reference_story_sequence_framework]].

## Assets (all in `~/Downloads/ig-breakdown-DSH20zdjNqN/`)
- `breakdown.html` — self-contained teardown (embedded video + hero frames, line-by-line script, 7 frameworks, funnel). ~28MB. The "analysis" artifact.
- `figjam_build4.js` / `build_body4.js` — final FigJam build script (kit + native UI). Earlier iterations: build_html.py (HTML), build_body2/3.js (board iterations).
- `video.mp4`, `frames/`, `hero/`, `transcript.json`, `zoom_*.jpg`, `emb_*.jpg` — working assets.
- `cors_server.py` — local CORS image server (only needed for the image-embed iteration; final native board needs no server).

## FigJam board (final)
- File **"Story sequence"** (fileKey `sFBgE2udPakSEVZWnK86o9`), one movable wrapper section **"Story Sequences — 7 frameworks ▸"**.
- Native, no screenshots: "what it is" + "how to use it" (4 steps) + 7 sequences, each = **5 × 9:16 story-slide mockups** (progress bar, role tag, live copy centered, "Send message" bar) + per-slide prompt caption. Generic/reusable, bracketed placeholders.
- Built via figma-console MCP. Connection trap: plugin binds to ONE server; when another terminal holds it, open the bridge in a NEW file so it grabs a free port (9227/9228) — see [[reference_figma_console_multifile]].

## Reusable pipeline (reel → teardown → board)
1. `ffmpeg` extract audio + frames (1/2s) + scene-detect + loudness.
2. Transcribe: Groq Whisper `whisper-large-v3-turbo` (key in `memory/groq-api-creds.md`), `verbose_json` segment timestamps.
3. Read the visual track via ffmpeg contact sheets + zoom-crops (PIL) — no ImageMagick on this Mac.
4. Decode the framework off the board; scrape any lead magnet (firecrawl).
5. Build native FigJam UI with the figjam-board kit + a component library (panel/badge/pill/slide). Designed-UI in FigJam works — see [[reference_figma_image_embed_cors]].

Preference that drove the final form: [[feedback_strip_framework_not_teardown]] (strip to framework + how-to, rebuild natively, slides as 9:16 mockups).
