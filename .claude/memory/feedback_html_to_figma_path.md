---
name: html-to-figma-editable-paths
description: How to get editable Figma layers from HTML — three viable paths ranked by fidelity. Companion plugin matches html.to.design.
type: feedback
originSessionId: 0f1d2f8e-19b3-4b12-afed-fbbae2f9eba0
---
For "convert HTML/DOM to editable Figma layers", three options exist with very different fidelity ceilings. Pick based on user's setup tolerance.

**Why:** Built this for KnowAI's element-png-capture extension (May 2026). Iterated through all three in one session. Vishal pushed back on SVG-only because text positions and Auto Layout were missing.

**How to apply:**

1. **PNG paste to Figma clipboard** — fastest, NOT editable. Figma pastes as image fill. Use `navigator.clipboard.write([new ClipboardItem({"image/png": blob})])`. Good for raster proof, useless for editing.

2. **SVG paste (real `<rect>`/`<text>`/`<image>`, not foreignObject)** — ~70% fidelity, editable text + shapes, no Auto Layout, weak effects. Walk DOM, emit real SVG elements with computed styles. Copy as `text/plain` (Figma's SVG paste handler reads plain-text SVG XML and converts to Frame + Vector + Text layers). foreignObject SVG = bitmap on paste = wasted effort.

3. **Companion Figma plugin + JSON bridge — equivalent to html.to.design (~95% fidelity)**. The unlock that SVG paste can never provide:
   - Auto Layout from CSS flex (Figma's SVG importer can't infer it)
   - Drop shadows / inner shadows as Effects (vs SVG filters Figma flattens)
   - Per-corner radii, per-side stroke widths
   - Proper font name resolution + fallback chain
   - Mixed text styles via setRangeFontName (if you go further than first-style-wins)
   
   Architecture: extension extracts every CSS computed style → JSON → clipboard text/plain → user opens companion Figma plugin → plugin reads clipboard → calls `figma.createFrame/createText/createImage` directly. The clipboard is the bridge; no backend needed.
   
   **Why html.to.design isn't magic**: their server runs headless Chrome to extract styles. Our extension does the same in the user's actual Chrome. The only difference is they have a one-click flow because their plugin auto-fetches from their server; we require user to open our plugin and click "Paste". Same fidelity ceiling.

4. **Don't waste time on**:
   - Figma REST API — read-only, no node creation
   - Reverse-engineering Figma's binary clipboard format — proprietary, attempts have stalled
   - Local WebSocket bridges — Chrome extensions can't open TCP servers

**Companion plugin install pattern**: Figma desktop → Plugins → Development → Import plugin from manifest…. KnowAI internal plugins live unpublished, imported once per machine.

**Key gotchas in plugin code**:
- `documentAccess: "dynamic-page"` requires all vector/font ops to be async (`await figma.loadFontAsync()`)
- `editorType` must be `["figma"]` not `["figma", "figjam"]` unless declaring `containsWidget`
- TS target `es2017` — QuickJS rejects `??` from es2020
- `figma.createImage(uint8Array)` for image fills; convert from base64 in plugin code
- Font fallback chain: exact match → any style of same family → Inter Regular
