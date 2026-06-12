---
name: reference_video_inspo_clip_pipeline
description: Working multi-video clip-extraction pipeline + the FigJam content-hash trick (mediaData.hash === file SHA-1) to map pasted clips reliably. Assets at ~/Downloads/inspo-2026-06-10.
metadata: 
  node_type: memory
  type: reference
  originSessionId: 73ed9815-0bee-41de-b067-f72b9e176a0e
---

Built 2026-06-10 for a 5-video motion-graphics teardown (Aevy TV ×2, Varun Mayya, Breakdown ×2).
Extraction + classification works great; FigJam delivery of 600 videos does NOT — see
[[feedback_figjam_video_quantity_limit]]. Assets + scripts in `~/Downloads/inspo-2026-06-10/`.

## Pipeline (per video, parallel subagents — one per video, disjoint folders)
1. yt-dlp 1080p + `--write-auto-subs`. Get creator chapters: `--dump-json` → `chapters` (3/5 had them;
   derive from .srt for the rest).
2. `detect_and_sheet.py video.mp4 27` → scenes.csv + contact sheets.
3. Agent reads every sheet, classifies each shot into **4 classes** (NEW: T):
   - **T = title/chapter animation** (full-screen card announcing a section/the title; cross-checked
     vs creator chapter start-times, or derived from transcript). A = b-roll/motion-gfx. B = talking
     head+overlay. C = plain talking head (skip).
4. `plan_from_classes_v2.py` (T/A/B keep, merges consecutive same-class) → plan_merged.csv.
5. `extract_clips.sh` → `clips/segNN_<T|A|B>_<tc>.mp4`. meta.json per video (seg→cls/chapter/note).

## FigJam clip-identity trick (IMPORTANT, reusable)
FigJam strips filenames (every pasted clip node is named "Media"), so paste-order mapping is fragile
(a 604-file paste scrambled order via Finder date-sort AND dropped 9 + errored uploads). BUT a MEDIA
node exposes `node.mediaData.hash` which **equals the file's SHA-1**. So:
- Build `hash_map.json` = SHA-1(clip) → {slug,cls,slot,chapter,tc,note}.
- Match every pasted node to its source by hash → order-independent, drop-proof, dedupe-proof.
- Detect dropped pastes = manifest hashes absent on board; re-paste just those.
- Reliable paste = scripted one-at-a-time (set_clipboard.sh + osascript Cmd+V, ~1.5s, re-activate
  Figma each time). Bulk multi-file paste is unreliable (order + upload errors).

Consolidate all clips into ONE name-sorted folder (`NNNN_slug_cls_seg_tc.mp4`, hardlinks) for a single
paste. Layout/positioning math in `board_layout.json` + `positioning_pass.md`.
Skill: `~/.claude/skills/video-inspo-extracter`. Related [[reference_competitor_teardown_workflow]].
