---
name: reference_figjam_video_embed_paste
description: "Get real VIDEO into a FigJam board (the plugin can't) — OS clipboard file-paste for direct media + URL-paste for YouTube embed widget; FigJam media import size cap sits between 32MB (ok) and 66MB (fails)."
metadata: 
  node_type: memory
  type: reference
  originSessionId: 84c35394-dcef-4006-8d12-3a80505ef8f4
---

# Putting video on a FigJam board via figma-console

The figma-console plugin **cannot create video media** (`figma.createVideoAsync` is not usable here; `createImage` only does rasters). Get video in at the OS level, then reposition the pasted node with the plugin.

## Direct (playable) video clip → OS clipboard file-paste
1. Cut clips with ffmpeg (use `-nostdin` or ffmpeg eats a `while read` loop's stdin → only every other clip renders). Encode small: `-vf scale=-2:480 -c:v libx264 -crf 30 -c:a aac -b:a 96k -movflags +faststart`.
2. Put the file on the macOS clipboard as a file ref (NOT base64):
   ```bash
   osascript -e 'set theFile to POSIX file "/abs/clip.mp4"' -e 'tell application "Finder" to set the clipboard to theFile'
   # verify: osascript -e 'clipboard info'  → «class furl»
   ```
3. User clicks the FigJam canvas and presses **Cmd+V** (chosen "you paste, I position" flow). Pasted node = `type:"MEDIA"`. Detect it by diffing `figma.currentPage.children` against a known-id set (selection is often empty after paste).
4. Reposition with the plugin: `m.resize(w,h); m.x=…; m.y=…`. For a 633×408 slot, 577×325 (16:9) centered (+28x,+41y) matches the Ep1 look.

## Full-video / YouTube link → URL-paste makes an EMBED widget
- `printf "https://youtu.be/ID" | pbcopy` → user Cmd+V on canvas → FigJam makes a clickable **`type:"EMBED"`** widget (~496×395), same as a manually-pasted YouTube embed. It's a link card, NOT inline footage.
- For inline "direct" full video, paste the compressed full file as MEDIA (above). **FigJam media import cap: 66MB mp4 FAILED ("Files failed to import / [object ProgressEvent]"), 32MB (full 17min @360p crf33 64k audio) SUCCEEDED.** Keep full-length direct videos ≤ ~35–40MB. The embed widget remains the reliable full-length link regardless.

## Build pattern for these creator-teardown boards
Mirror the existing board's exact nodes, don't use the figjam-kit card/kanban style: white `SHAPE_WITH_TEXT` SQUARE (fill #FFFFFF, stroke #757575 @4, cornerRadius 6), Inter Bold 48 panel titles, Inter Medium 30–32 clip labels, Inter Regular ~14 body, connectors (`createConnector`, magnet TOP/BOTTOM, `connectorEndStrokeCap:"ARROW_LINES"`) fanning source→clips. Fetch long panel text + thumbnail through the CORS:9230 server (see [[reference_figma_image_embed_cors]]) so it never hits your context. Build free on page at absolute coords (targeted FIX-flow reposition is fine even though the figjam-board hook nags). Related: [[reference_competitor_teardown_workflow]] [[feedback_knowai_living_board_style]] [[reference_figjam_text_link_gotchas]].
