---
name: feedback_figjam_video_quantity_limit
description: "FigJam can't embed ~600 playable videos (most go \"Could not play\"); never substitute image stills for motion-graphics study — find a video-native path."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 73ed9815-0bee-41de-b067-f72b9e176a0e
---

Pasting ~600 video clips into one FigJam file does NOT work: after all 604 landed, most rendered
"Could not play this video" (export ≈163 bytes = gray error box). The file already had ~223 working
videos; +604 (793 MB) blew past FigJam's practical capacity. ~200 videos/file is roughly the ceiling.

When that failed I pivoted to **image thumbnails (mid-frames) + click-to-timestamp captions**. Zeel
**rejected it hard**: "I don't need images. What am I going to do with the images? This is not
acceptable at all." Stills are useless for studying MOTION graphics — the whole point is the motion.

**Why:** the deliverable is a motion-graphics inspiration board; the value is playable motion, not
a frame grid. A technically-reliable stills fallback is still the wrong deliverable.

**How to apply:** For large video-clip inspo sets (hundreds of clips) the clips MUST stay playable.
Do NOT dump them all into one FigJam file, and do NOT fall back to stills. Use a video-native
solution: split across multiple FigJam files (~100–150 videos each, like the existing working
boards), or build a local HTML grid that plays each clip inline, or a media app (Eagle/Milanote).
Confirm the target medium can actually hold the quantity of *playable* video BEFORE extracting.
Relates to [[reference_video_inspo_clip_pipeline]] and [[reference_video_inspo_extracter_skill]].
