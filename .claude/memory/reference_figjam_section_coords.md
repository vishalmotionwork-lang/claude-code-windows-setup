---
name: reference_figjam_section_coords
description: FigJam via figma_execute — section.appendChild ADDS section origin to children (displaces them); absoluteBoundingBox is stale right after reparent; figma.createPage() is not a function in FigJam
metadata: 
  node_type: memory
  type: reference
  originSessionId: 0f8c0ca7-a3e9-40c5-bfda-6e2745d7d0bc
---

Building FigJam boards through `figma-console` `figma_execute` (raw figma plugin API). Three gotchas that cost a lot of round-trips, in order of nastiness:

1. **`section.appendChild(node)` ADDS the section's origin to the child's coords.** It treats the child's existing x/y as section-relative, so a child created on the page at abs (200,-1630) appended to a section at (130,-1740) renders at (330,-3370). Fix: AFTER appending, convert each child to section-relative — `k.x -= section.x; k.y -= section.y`. (Plain `createSticky`/`figjam_create_*` helper tools handle this for you; only raw appendChild bites.)

2. **`node.absoluteBoundingBox` is STALE for ~one tick after a reparent.** Measuring children's bounds in the SAME `figma_execute` call right after `appendChild`/detach returns their OLD positions → you size the wrapper wrong. Split into two calls: reparent in call A, measure + size in call B (fresh call = settled). Or read `.x/.y` which update synchronously.

3. **`figma.createPage()` throws "TypeError: not a function" in FigJam** (editorType `figjam`). Can't make a new page programmatically. Build on `figma.currentPage` in a clear empty region instead (compute existing-content bbox, offset well past it), and wrap everything in one SECTION so the user can right-click → Move to page manually.

Also: SECTION supports `resizeWithoutConstraints(w,h)`; setting `section.x/.y` MOVES all children with it (can't realign a wrapper by moving it — detach children, fix, re-append). Screenshot a finished board region by capturing the wrapper section node id via `figma_capture_screenshot` (caps longest side at 1568px).

**These fixes are baked into the `/figjam-board` skill** (`~/.claude/skills/figjam-board/`) — a place-and-verify engine: `figjam-kit.js` provides coordinate-safe `zone/card/text/kanban/row` + `verify()` (overlap/overflow/out-of-zone) + `finish()` (wraps in one movable section, computes bbox from records not stale absoluteBoundingBox). Use the skill instead of hand-rolling board JS.

Related: [[feedback_figjam_autolayout_over_miro]] · [[feedback_figma_plugin_gotchas]] · [[reference_figma_image_embed_cors]]
