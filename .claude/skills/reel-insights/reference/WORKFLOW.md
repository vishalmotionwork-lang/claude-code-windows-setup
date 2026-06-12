# Pipeline + Figma gotchas (reel-insights)

Reel link + IG Insights → per-reel FigJam doc (multi-window table) → MASTER.md.
Metric of record = **views**.

## Pipeline
1. **Acquire** — `yt-dlp` the reel + caption → `reels/<id>/`.
2. **Transcribe** — ffmpeg → Groq `whisper-large-v3-turbo`, or user-provided `transcript.txt`.
3. **Insights per window** — user/intern captures IG Insights at 1h/24h/48h/weekly/lifetime as
   `insights/<window>.{mp4,png}`. Recording → `extract-frames.sh <id> <window>` → read frames.
   Screenshot → read directly. Fill `windows.<window>` in `data.json`; fill `stable` once.
4. **Build** — `prep.mjs [--move-videos]` → paste `.reel-build/_payload.js` into figma_execute.
5. **Master** — `master.mjs` → `MASTER.md`.

IG Insights tabs the capture scrolls through: **Overview** (views, reached, avg watch, follows,
views-over-time, skip + share/like/save/repost/comment rates, retention curve, top sources),
**Engagement** (profile visits/follows/bio taps, likes/comments/reposts/shares/saves),
**Audience** (followers vs non, age, country, gender, languages). Icon order = Likes · Comments ·
Reposts · Shares · Saves.

## Doc anatomy (per section)
- Section named `#<rank> · <Title> · <views> views`.
- **Post-type tag** pinned top-right: `Trials` (red-orange #E8512D) or `Main feed` (blue #146DF7).
- Top band: link preview (left) + tag (right). Below: reel video (9:16) + insights video (iPhone
  aspect), playable. Below: the doc frame.
- Doc: avatar + @handle + #rank pill + IG mark; title; posted/windows/CTA + hook; **Performance
  over time** TABLE (metric rows × window columns); rates (latest); discovery; audience; script.
- Aesthetic: white, Roboto Mono grey labels, Inter Bold numbers, no boxes, green #1B8F5A accents.

## CRITICAL Figma gotchas (learned the hard way)
- **Cloned MEDIA nodes are NOT playable** (poster frame only). Use the ORIGINAL node → MOVE it in.
- **Videos inside a FRAME aren't click-to-play** — put them as DIRECT children of the SECTION.
- **NEVER delete a frame/section still containing the user's media** — the media nodes die with it
  and can't be recreated (`mediaData.hash` read-only, no `createMedia`, re-upload needs full bytes).
  Detach/move first, then delete. (This deleted 11/12 videos once; recovered via user Cmd+Z.)
- **SECTION child coords are RELATIVE but appendChild doesn't reconcile** — set x/y AFTER appendChild.
- **Images**: `createImageAsync(httpURL)` is blocked. Use `figma_set_image_fill(node, base64)` →
  imageHash → `node.fills=[{type:'IMAGE',scaleMode:'FILL',imageHash}]`. Keep avatars tiny (~110px).
- **`figma.getNodeById` fails** under documentAccess: dynamic-page → use `getNodeByIdAsync` after
  `await figma.loadAllPagesAsync()`.
- **No `Intl`/`toLocaleString`** in the plugin sandbox → format thousands manually (regex).
- **No cornerRadius on MEDIA nodes** ("object is not extensible").
- Node ids reset after a Cmd+Z recovery — re-read the board before reusing `nodes.*`.
