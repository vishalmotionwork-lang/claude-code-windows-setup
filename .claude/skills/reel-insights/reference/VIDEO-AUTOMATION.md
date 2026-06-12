# ⚠️ DEPRECATED for FigJam playback — use reference/PASTE-AUTOMATION.md instead

> **This `createVideoAsync` route does NOT produce a playable video on a FigJam board.**
> Confirmed 2026-06-01 with a real reel: a `{type:'VIDEO'}` fill renders as a **static poster**
> on the FigJam canvas (the full asset is stored + exportable, and `playbackSettings` says
> autoplay/loop, but the canvas only paints frame 1 — autoplay fires only in Figma **Design**
> files, never FigJam). For a real **playable** node, use the OS-paste route in
> **`reference/PASTE-AUTOMATION.md`** (clipboard → ⌘V/Ctrl+V → Figma's native importer →
> native MEDIA node). The `FETCH_VIDEO` bridge handler below is still useful for *pulling bytes*
> (e.g. to `createVideoAsync` for a poster/thumbnail), just not for playback.

---

# Automatic video insertion (the createVideoAsync workaround — poster only)

Figma's plugin **main thread has no network**, so `figma_execute` can't fetch a file to feed
`createVideoAsync`. But the plugin's **UI iframe can** fetch (it runs the bridge's WebSocket).
The workaround bridges them: a small `FETCH_VIDEO` handler in the plugin UI fetches a local file
and hands the bytes to the main thread, which calls `createVideoAsync` and applies a VIDEO fill.

## Why each piece is needed (all confirmed by testing)
- **Patch the plugin UI** (`scripts/patch-plugin.sh`) — adds the `FETCH_VIDEO` case to `ui.html`.
  There are usually MULTIPLE copies of the plugin on disk; Figma may load any one — the patcher
  patches them all. ⚠ A soft reload reuses the cached UI; you must **re-run the plugin** so Figma
  re-reads `ui.html` from disk.
- **CORS headers** (`scripts/serve.sh`) — the UI fetch is cross-origin; a plain `python -m http.server`
  returns no `Access-Control-Allow-Origin`, so the browser blocks it ("Failed to fetch"). serve.sh
  adds the header.
- **Whitelisted port** — the plugin manifest only allows fetch to `localhost:9223–9232`. We use **9232**.
  Port 9223 is the bridge WebSocket. Start serve.sh only AFTER the plugin is connected, so it doesn't
  collide with the plugin's launch-time port probing (a server squatting on a probed port hangs the
  launch). Stop it when done.

## One-time setup (per machine)
```bash
bash scripts/patch-plugin.sh          # injects FETCH_VIDEO into every plugin copy
# then in Figma: Plugins → Development → Figma Desktop Bridge → Run   (re-run to load the patch)
```
If the figma-console MCP updates and overwrites the plugin, just re-run `patch-plugin.sh` + re-run the plugin.

## Per build (when you want playable videos on the board)
```bash
bash scripts/serve.sh                 # CORS server on :9232 serving ./reels
node scripts/prep.mjs --videos        # adds CTX.videoBaseUrl=http://localhost:9232
# paste .reel-build/_payload.js into figma_execute
pkill -f 'reel_cors_server.py 9232'   # stop the server after
```
For each reel the builder fetches `http://localhost:9232/<id>/reel.mp4` and the latest window's
`insights/<window>.mp4`, runs `createVideoAsync`, and places them as playable videos in the top band
(reel 203×360, insights 166×360), with the doc below. Screenshot-only windows (no `<window>.mp4`)
are skipped silently.

## Confirmed working
2026-06-01: full chain proven on board "Trial strategy" — fetched a 6.4 MB reel.mp4 + the Insights
recording, `createVideoAsync` succeeded, both rendered as playable VIDEO fills in section #7. videoHash
e1bf0028… (reel), 2c41dfe8… (insights).

## If it stops working
- "Failed to fetch" → server missing CORS headers, or wrong port (must be 9223–9232).
- "timeout (handler not loaded)" → plugin UI not re-run after patching, OR a different plugin copy is
  loaded (run `patch-plugin.sh` again — it patches all copies).
- Plugin stuck "Running…" on launch → a file server is squatting on a 9224–9232 probe port; kill it,
  relaunch, start serve.sh only after connect.
