---
name: reference_video_inspo_extracter_skill
description: The video-inspo-extracter skill — turn a video into FigJam inspiration. Mode A = extract every edited segment (scene-detect → classify-by-vision → clips → segregated grid). Mode B = creator teardown (transcribe → analysis panels → story-beat clips). Built+validated 2026-06-10.
metadata: 
  node_type: memory
  type: reference
  originSessionId: 84c35394-dcef-4006-8d12-3a80505ef8f4
---

# video-inspo-extracter skill

Lives at `~/.claude/skills/video-inspo-extracter/` (SKILL.md + scripts/ + reference/). Built 2026-06-10 from the Zach Ep1/Ep2 + Anthropic Think School sessions. Trigger: "/video-inspo-extracter", "extract the edited parts / all the b-roll", "video breakdown", "creator teardown", "inspo board". See [[project_knowai_video_teardowns]].

## Two modes
- **Mode A — edited-segment extraction:** download → `detect_and_sheet.py` (PySceneDetect → labeled contact sheets) → **agent classifies each shot A/B/C by READING the sheets** (A=no talking head/b-roll/anim/screen/external-clips, B=talking-head+overlay, C=plain talking-head→skip; face-detect alone can't tell B from C, vision IS the classifier) → write `classes.txt` → `plan_from_classes.py` (merge consecutive same-type → passages) → `extract_clips.sh` → FigJam grid via `reference/board-grid.md`, segregated A-block/B-block. Anthropic run: 220 shots → 156 keep → 65 merged clips (60% of video was edited).
- **Mode B — creator teardown:** transcribe (`~/.claude/scripts/transcribe.sh`, Groq) → 2 analysis panels (strategy + "position as same", plain English) → story-beat clips → mirrored board via `reference/board-teardown.md`.

## The non-obvious bits baked into the scripts (don't relearn)
- Plugin can't create video → OS clipboard file-paste (`set_clipboard.sh`) + scripted `Cmd+V` (`paste_batch.sh`, needs macOS Accessibility perm; test 1 first). URL paste → EMBED widget (`paste_url_embed.sh`).
- Position pasted MEDIA by **node-id order == paste order == segment order**; re-running is idempotent/self-correcting. Segregate = delete+rebuild slots/labels, keep media, re-derive order from id-sort.
- FigJam media import cap ~32MB ok / ~66MB fails ([[reference_figjam_video_embed_paste]]). 720p clips, 360p full video.
- CORS server on 9230 feeds label CSVs/thumbnails/panel text into figma_execute at zero context cost ([[reference_figma_image_embed_cors]]).
- `figma_capture_screenshot` (plugin) not `figma_take_screenshot` (REST token expires). ffmpeg in a `while read` loop needs `-nostdin`. No `timeout` on macOS.
- Validated 2026-06-10: generic `plan_from_classes.py` re-ran on real Anthropic scenes.csv → exact 143A/13B/64C → 65 passages.

Related board styles: [[reference_knowai_living_board_style]] [[feedback_figjam_autolayout_over_miro]] [[reference_competitor_teardown_workflow]].
