---
name: reference_figma_image_embed_cors
description: Embed many local images into FigJam/Figma via figma-console with ZERO context cost — CORS server on a manifest-allowlisted port + fetch()+createImage inside figma_execute. Beats base64.
metadata: 
  node_type: memory
  type: reference
  originSessionId: 4b905dce-bb97-4e4f-9e31-3ec9b45a950c
---

# Embedding images into Figma/FigJam via figma-console — the zero-context-cost path

When building image-heavy FigJam boards (competitor teardowns, reel boards, screenshot walls) with the **figma-console** MCP, you must get raster bytes into the plugin. Three paths, in order of preference:

## ❌ What does NOT work
- `figma.createImageAsync(url)` with an **http://localhost** URL → fails: *"does not satisfy the allowedDomains"* even when localhost IS listed in the manifest. Figma's image loader effectively requires **https** for remote image URLs; plain-http localhost is rejected regardless of the allowlist.
- `figma_set_image_fill({imageData: <base64>})` works, but the base64 string must be passed inline in the tool call → it lands in YOUR context. ~3K tokens per small thumb; 89 thumbs ≈ 250K tokens. Only use for 1–3 images.
- A plain `python3 -m http.server` → plugin `fetch()` fails with **"Failed to fetch"** (no CORS headers).

## ✅ What WORKS (use this for N images)
1. Run a **CORS-enabled** static server bound to a port that is **already in the plugin manifest's `networkAccess.allowedDomains`**. For this machine's figma-console plugin (`~/.figma-console-mcp/plugin/manifest.json`) the allowlist includes `http://localhost:9223`–`9232`. The MCP websocket uses **9223**, so serve images on **9230** (9224–9232 are free). No manifest edit / plugin restart needed.
   ```python
   # /tmp/cors_server.py  — run: (python3 /tmp/cors_server.py &)
   import http.server, socketserver, os
   os.chdir(os.path.expanduser("~/<project-dir>"))
   class H(http.server.SimpleHTTPRequestHandler):
       def end_headers(self):
           self.send_header("Access-Control-Allow-Origin","*")
           self.send_header("Access-Control-Allow-Methods","GET, OPTIONS")
           super().end_headers()
       def do_OPTIONS(self): self.send_response(200); self.end_headers()
       def log_message(self,*a): pass
   socketserver.TCPServer(("127.0.0.1",9230),H).serve_forever()
   ```
2. Inside `figma_execute`, `fetch()` exists (XMLHttpRequest does not). Fetch bytes → `figma.createImage()` → image fill:
   ```js
   const res = await fetch("http://localhost:9230/screenshots/x.jpg");
   const img = figma.createImage(new Uint8Array(await res.arrayBuffer()));
   const r = figma.createRectangle(); r.resize(w,h);
   r.fills=[{type:'IMAGE',scaleMode:'FILL',imageHash:img.hash}];
   ```
   This pulls unlimited images with **zero base64 in your context**.

## ⚠️ Hostname trap (cost a full rebuild 2026-06-09)
The manifest allowlists the host **`localhost`**, NOT `127.0.0.1` — they are different origins to Figma's network gate. If you bind the server to `127.0.0.1` AND fetch `http://127.0.0.1:9230/...`, EVERY fetch throws and you only see it after the build (all images become fallback rects). Fix: **bind the server to all interfaces** `TCPServer(("",9230),H)` (so both IPv4 `localhost`→127.0.0.1 and IPv6 `::1` resolve) and **fetch via `http://localhost:9230/`**. Quick pre-flight before a big build: run one tiny `figma_execute` that does `await fetch(...).then(r=>r.arrayBuffer())` + `figma.createImage` and returns `{ok, bytes}` — verify it before rendering the whole board.

## Designed-UI ("webpage on a board") works in FigJam (confirmed 2026-06-09)
FigJam plugin supports `figma.createFrame()`, child `appendChild` (frame-relative coords), `figma.createEllipse()`, and **`node.effects=[{type:"DROP_SHADOW",...}]` on frames AND rectangles**. So build real UI cards instead of `shapeWithText` sticky-boxes: frame (white, cornerRadius, 1px stroke, drop shadow) + child layers = top accent bar (`fRect`), number badge (ellipse+centered text), trigger pill (rounded rect w/ `solidA(hex,0.14)` tinted fill), divider, dot-rows. Only `rec()` the FRAME for verify (children ride along in `finish()`); decorative top-level shapes get `zone=null` so verify skips them. Text inside frames: set `textAutoResize="HEIGHT"` BEFORE `t.resize(w,..)` or it throws (default is WIDTH_AND_HEIGHT). Pattern = section eyebrow+H2+rule headers, full-width stacked zones, his exact frames as `imgBlock` (image rect + border + shadow + caption). This is the "a lot better than pastel boxes" look. See [[feedback_screenshot_card_design]] [[feedback_knowai_living_board_style]].

## Other figma_execute gotchas confirmed this session
- Use `await figma.getNodeByIdAsync(id)` — `figma.getNodeById` throws under `documentAccess: dynamic-page`.
- Fonts: load `'Inter'` styles `Regular/Medium/Semi Bold/Bold` (space in "Semi Bold"). Set `fontName` before `characters`.
- Rounded top-only header bars: set `topLeftRadius/topRightRadius` (uniform `cornerRadius` won't do per-corner).
- Pre-resize/compress images with `sips -Z <px> -s formatOptions <q>`; build montages with `ffmpeg tile=COLSxROWS:padding=..:margin=..:color=white` over date-ordered `%03d.jpg` copies (no ImageMagick on this Mac).
- Validate with `figma_capture_screenshot` (plugin runtime state) after each band.

Related: [[feedback_competitive_board_visual]] [[feedback_figjam_autolayout_over_miro]]
