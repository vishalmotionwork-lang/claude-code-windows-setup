---
name: reference_dom_capture_clip_aware_bounds
description: "How to bound a DOM element for screenshot/capture WITHOUT bad cutouts — clip-aware rect, no tolerance fudge. Plus how html.to.design actually works (serialize, not screenshot)."
metadata: 
  node_type: memory
  type: reference
  originSessionId: a43cc994-ce41-4f21-8206-00dd5227df04
---

For an element-capture tool (screenshot a picked DOM node), the wrong approach is
a heuristic "expand to descendants within ±N px tolerance" box — it both slices
children that overflow beyond N and over-grows into `overflow:hidden`/empty area,
so it's wrong unpredictably (this was the element-png-capture v15 bug).

**Correct, clip-aware bounds:**
1. Base = element's `getBoundingClientRect()` (border box) + outset box-shadow /
   filter drop-shadow expansion (cap ~60px).
2. If the element itself **clips** (`overflowX/Y !== "visible"`, or `clip-path`,
   or legacy `clip: rect(...)`) → return the base box. Overflowing children are
   not visible. (Fixes cards/containers — the common case.)
3. Else (overflow visible) → union descendants in FULL (no tolerance), but first
   intersect each descendant's rect with every clipping ancestor between it and
   the picked element. Skip `display:none`/`visibility:hidden`/`opacity:0` and
   `position:fixed` (viewport-anchored, not part of the element).
4. Clamp the whole result to every clipping ancestor ABOVE the element (they clip
   it too) and to the document bounds — never capture clipped/off-page area.

**Also:** the on-screen highlight MUST use the same rect function as the capture,
or "what you see ≠ what you get." Throttle it with rAF; use the cheap border box
on hover and the full clip-aware rect once selected.

**How html.to.design actually works (fact-checked, ext id
`ldnheaepmnmbjjjahokphckbpgciiaed`, `assets/src/contentScript/serializeDom/`):**
it does NOT screenshot — it SERIALIZES the DOM (`cloneNode`/`outerHTML` +
`getComputedStyle` over a fixed property list incl. overflow/clip/clipPath) and
reconstructs editable vector layers in Figma, so each node keeps its own geometry
and nothing crops. Its visibility test keys on `overflowX!=="visible" && width<1`,
`clip:rect(0px,0px,0px,0px)`, and `clipPath`. For a raster screenshot tool you
can't copy that, but you copy the clip-awareness.

Context: applied in `~/element-png-capture/content-script.js` v16. See
[[element-png-capture-session]].
