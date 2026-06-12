---
name: feedback_figjam_autolayout_over_miro
description: "For rich multi-card visual boards (task/planning canvases), prefer FigJam via figma-console MCP over Miro — auto-layout hugs content (no overflow), and you can screenshot via MCP."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09d83e73-5e08-4692-a103-a6126bbff0aa
---

For rich multi-card boards (task boards, planning canvases, delegation maps) for Vishal, prefer **FigJam via figma-console MCP** over Miro.

**Why:** Miro's `layout_create` DSL is coordinate-only → you hand-calculate every card height → overflow and dead gaps (we shipped "okay but not great" twice). Miro also has **no screenshot tool**, so verifying meant driving the desktop with computer-use (slow; Miro felt slow to the user).

FigJam via `mcp__figma-console__figma_execute` runs real plugin JS:
- **Auto-layout frames hug their content** → zero overflow, zero height-guessing. Build each card as a HORIZONTAL auto-layout `[accent rectangle (layoutAlign STRETCH) | vertical content frame (layoutGrow 1)]`; the vertical container is a VERTICAL auto-layout that stacks header + cards with `itemSpacing`. Text nodes: set width + `textAutoResize="HEIGHT"`, `layoutAlign="STRETCH"`.
- **`figma_capture_screenshot`** (plugin exportAsync, no token) verifies through the MCP — no computer-use. (`figma_take_screenshot` uses REST and needs a non-expired token; prefer capture.)

**Critical gotcha:** `node.resize(w,h)` forces THAT axis's sizing mode back to `FIXED`, silently breaking the hug. Set `primaryAxisSizingMode`/`counterAxisSizingMode = "AUTO"` **after** any resize() call (or only resize the fixed axis). Symptom: frame collapses to ~10px tall.

**Connect:** open Figma Desktop → FigJam file → Plugins → Development → "Figma Desktop Bridge" → Run. Verify with `figma_get_status {probe:true}`. `getNodeById` is async-only under dynamic-page (`figma.getNodeByIdAsync`). Aeonik isn't installed → use Inter. See [[reference_knowai_design_system]].

**Multi-bridge gotcha:** stale MCP server instances on ports 9224/9225 (from prior sessions) can steal the plugin connection — `get_status` shows transport `none` while the plugin "looks" open. Fix: close + reopen the plugin once (or fully quit/relaunch Figma Desktop) so it reconnects on the live server's port (9223). `figma_diagnose` confirms which port is listening.

**Auto-layout ⇄ manual-drag is a HARD trade-off (can't have both).** Auto-layout = no overflow but children are LOCKED: a click selects the whole parent frame, and dragging a card makes the frame re-flow/snap. If the user wants to **hand-drag cards between groups**, convert the column/lane **FRAMES → FigJam SECTIONS**. Sections let every card be single-click-selected + freely dragged, and dropping a card into another section reparents it (perfect for reassigning owners). Cost: no more auto-spacing — dropped cards can overlap (offer a "re-stack section" tidy command). Section shows its `name` as a corner label.
- **Convert recipe (positions preserved):** snapshot each child's relative `x/y` (auto-layout already baked them) → `const s = figma.createSection(); parent.appendChild(s); s.x=f.x; s.y=f.y; s.resizeWithoutConstraints(f.width,f.height); s.fills=f.fills;` → `for(k of kids){ s.appendChild(k.node); k.node.x=k.x; k.node.y=k.y; }` → `f.remove()`. Because the section sits at the SAME origin as the old frame, children keep identical relative coords → pixel-identical result.
- **Section API gotcha:** SectionNode has **`resizeWithoutConstraints(w,h)`**, NOT `resizeTo` (that throws "not a function"). It DOES support `.fills`, `.x/.y`, `.appendChild`. On a failed convert mid-run, clean orphans: `figma.currentPage.children.filter(n=>n.type==='SECTION'&&!n.children.length).forEach(s=>s.remove())`.
