---
name: reference_figma_figjam_video_insert
description: "How to programmatically put a PLAYABLE video into a FigJam board via the figma-console MCP — the working answer is EMBED nodes via public oEmbed, not video fills or MEDIA. Plus every approach that fails and why."
metadata: 
  node_type: memory
  type: reference
  originSessionId: 4f2a39ce-197c-4a21-9568-99a0e2926e91
---

Goal: insert a **playable** reel video (with audio) into a **FigJam** board through the
figma-console MCP (`figma_execute` / `createLinkPreviewAsync`), at scale, no manual drag/paste.
Researched + proven live 2026-06-01 on board "Trial strategy". Used by the [[reel-insights]] skill.

## 🔬 NATIVE-MEDIA ROUTE — EXHAUSTIVELY TESTED 2026-06-01, ALL DEAD ENDS (don't re-test)
Goal was a native playable FigJam MEDIA node (type "MEDIA") from NEW bytes, fully API-driven.
Every primitive tested live on "Trial strategy":
- `createVideoAsync(bytes)`/`createVideo(bytes)` → returns a **Video FILL handle** (not a node) +
  a server-known hash. In FigJam a VIDEO fill renders as a **static poster**. (The hash upload IS real.)
  **CONFIRMED 2026-06-01 with a REAL reel (8MB, fetched via the FETCH_VIDEO bridge → createVideoAsync →
  VIDEO fill on a RECTANGLE):** Figma fully ingests + transcodes the asset (right-click→"export video"
  downloads the COMPLETE clip: VP9 1080×1920, 1306 frames, 43.5s, AAC audio) AND `playbackSettings` reads
  `{autoplay:true, loop:true, muted:false}` — BUT the FigJam canvas only paints the **first frame, no play
  button, not marked as video, does NOT animate**. Video-fill autoplay/loop fires ONLY in Figma **Design**
  files + prototype/present mode, NEVER on the FigJam canvas. A rectangle video-fill IS freely resizable
  (unlike EMBED), but it's a dead poster in FigJam. Also: a MEDIA node's `mediaData.hash` is REJECTED as a
  VIDEO-fill `videoHash` ("Invalid SHA1 hash") — fill-hashes and media-hashes are separate namespaces.
- `createGif(hash)` → makes a **GIF-kind MEDIA node**. Feeding it a video hash → on-canvas
  **"Could not play this GIF"**. `createGif` is the ONLY documented MediaNode creator and it's GIF/image-only.
- `node.clone()` of an existing playable video MEDIA node → **IS playable**, BUT `mediaData.hash` is
  immutable: direct `=` silently ignored, whole-object assign throws `TypeError: no setter for property`,
  `Object.defineProperty` ignored. So clone is welded to the source video — can't inject new content.
- **`pluginDrop` with a real `File`** (UI iframe `parent.postMessage({pluginDrop:{files:[File]}})`):
  the File DOES reach the main-thread `figma.on('drop')` handler (with working `getBytesAsync()`), BUT
  Figma does **NOT** run its native importer on it → **no MEDIA node created**. `DropFile` only exposes
  `name/type/getBytesAsync/getTextAsync` — no media-creation method. pluginDrop = input channel to the
  plugin, NOT a gateway to native import. (Patched bridge ui.html with a TRY_PLUGIN_DROP handler to test.)
- `Object.keys(figma)` is empty (methods live on prototype). No `createMedia/uploadMedia/createVideoNode`.
- Private multiplayer/Kiwi WS API (allan-simon/figma-kiwi-protocol) can create nodes but the
  **media-blob upload→server-SHA1 step has never been reverse-engineered**; REST API is read-only.
**Conclusion: NO programmatic surface can bind an uploaded video hash to a native playable MEDIA node.**
Only routes to a NEW playable video on a FigJam board: (1) OS-level real paste/drag automation, or
(2) the EMBED-via-oEmbed route below.

## ✅✅ CONFIRMED WORKING (2026-06-01): OS clipboard-PASTE → native playable MEDIA node
Chosen + proven live. **Decision: user wants this (native play button) for both macOS + Windows.**
Mechanic: put `reel.mp4` on the OS clipboard as a FILE → activate Figma Desktop → send paste keystroke
(⌘V mac / Ctrl+V win) → **Figma's own importer creates a real `type:"MEDIA"` node that PLAYS** (preserves
9:16, e.g. pasted DYwCeZcqF9F → 270×480 MEDIA, user confirmed it plays with the play button). Then the
figma-console bridge detects the new node (MEDIA id-diff vs a pre-paste snapshot) and renames/resizes/moves
it into its section. macOS clipboard = Swift `NSPasteboard.writeObjects([url as NSURL])`; paste = `osascript`
System Events ⌘V (needs Terminal Accessibility permission). Windows = `Set-Clipboard -LiteralPath` +
`SendKeys ^v` after `AppActivate("Figma")`. SERIAL only (1 reel → confirm new node → place → next); paste
lands at an unpredictable spot so identify by id-diff not position; ~secs to import (Figma transcodes→VP9).
**Built into the reel-insights skill**: `scripts/paste-video-mac.sh`, `scripts/paste-video-win.ps1`,
`reference/PASTE-AUTOMATION.md` (full recipe+gotchas), doctor.sh paste check, SKILL.md updated. Old
`createVideoAsync`/CORS route deprecated (poster only) — banner added to `reference/VIDEO-AUTOMATION.md`.

## (alt) THE WORKING ANSWER: FigJam EMBED node via public oEmbed
```
reel.mp4 → PUBLIC host → a per-reel PAGE that advertises oEmbed
→ figma.createLinkPreviewAsync(pageUrl) → returns an EmbedNode (type "EMBED") → plays inline in FigJam (click "View")
→ position the EmbedNode in the section. Verify node.type === "EMBED" (else it fell back to static).
```
Proven: a custom oEmbed server (player page + `/oembed` JSON returning an `<iframe>` + `/embed` page
with `<video controls>` + the mp4), exposed publicly via `cloudflared tunnel --url http://localhost:9232`,
then `createLinkPreviewAsync(https://<tunnel>/v/<id>)` → **EMBED node** (EmbedNode), playable with audio.

**Two make-or-break requirements:**
1. **PUBLIC https URL** — Figma resolves oEmbed **server-side**. `localhost` is rejected with
   "The provided text was not a URL". So the page must be publicly reachable (R2/S3/own server/tunnel).
2. **The page must serve oEmbed** — a `<link rel="alternate" type="application/json+oembed" href="...">`
   in the page head, and an `/oembed` endpoint returning `{version,type:"video",html:"<iframe...>",width,height,thumbnail_url}`.
   A raw `.mp4` URL has none of this → static card. Add `thumbnail_url` (poster jpg) so the embed card
   shows the cover instead of a gray "View" card.

FigJam embeds work for any provider exposing oEmbed (YouTube/Vimeo/Loom confirmed by Figma docs;
YouTube tested → inline thumbnail+play because Figma special-cases it; a CUSTOM provider shows a
poster card + "View" → click loads the iframe player). Both play with audio.

## ❌ What does NOT work (all tested, don't retry)
- **`createVideoAsync(bytes)` + `{type:'VIDEO',videoHash}` fill on a rectangle** → in FigJam this is a
  **static poster** (the "it's just an image" complaint). NOTE: in a Figma **design file** the same VIDEO
  fill DOES autoplay/loop — so if the board were a design file, that route would work fully API-driven.
- **Native `MEDIA` node** (what drag-drop creates, `type:"MEDIA"`, `mediaData.hash`) IS playable, but
  there is **no API to create it**: no `createMedia`, `mediaData` has "no setter", clones aren't playable.
  Only `figma.createGif(hash)` makes a FigJam MediaNode — GIF only (no audio, huge).
- **OS clipboard paste** (swift NSPasteboard writes the file-url → `osascript` Cmd+V into Figma) DOES
  create a real playable `MEDIA` node — but it's manual/focus-stealing, not viable for 100-reel batches.
  Rejected as the product solution.
- **Direct `.mp4` URL / Vimeo / Instagram URL** via `createLinkPreviewAsync` → static `LINK_UNFURL`
  (just a link card), NOT playable.

## figma-console MCP plugin internals (learned the hard way)
- `figma_execute` runs code in the plugin **main thread** (code.js), which has **NO working `fetch`**
  (every URL fails, even whitelisted). Only the plugin **UI iframe** (ui.html, runs the bridge WebSocket)
  can fetch. To pull bytes to the main thread: add a `FETCH_VIDEO` handler in ui.html's `window.onmessage`
  switch that `fetch`es and `parent.postMessage`s a `Uint8Array` back; from `figma_execute` use
  `figma.ui.on('message', h)` (coexists with the bridge's `figma.ui.onmessage`). The skill's
  `scripts/patch-plugin.sh` injects this. (Only needed for the createVideoAsync route, now superseded by EMBED.)
- **The server is npm (`npx figma-console-mcp@latest`) — NOT editable.** Only the local **plugin** files are.
- **Figma loads the plugin from `~/Desktop/figma-desktop-bridge/`** (NOT `~/.figma-console-mcp/plugin/`
  which the MCP `pluginPath` status misleadingly reports). There are ~4 copies on disk; patch ALL.
- **Soft reload reuses cached UI** — after editing ui.html you must RE-IMPORT/RE-RUN the plugin from its
  manifest (Plugins → Development) to load it; `figma_reload_plugin` / kill+restart reuse `__html__`.
- **Local file fetch from the UI needs CORS** (`Access-Control-Allow-Origin: *`) AND a whitelisted port
  (`localhost:9223–9232`; bare `http://localhost` did NOT cover 8080). 9223 = bridge WS. A file server on
  a 9224–9232 probe port HANGS the plugin launch ("Running…") — start it only AFTER the plugin connects.
- `figma.createLinkPreviewAsync(url)` is FigJam-only; returns `EmbedNode` (oEmbed found) or `LinkUnfurlNode`.

## Production architecture (for the reel-insights library)
Permanent public oEmbed service (per-reel page + /oembed + /embed iframe + mp4 + poster thumbnail) on
Hetzner / Cloudflare R2+Worker / Vercel → uploader pushes reels → builder calls createLinkPreviewAsync
per reel, asserts type==="EMBED", positions the embed in the section. PENDING: user's hosting choice.
