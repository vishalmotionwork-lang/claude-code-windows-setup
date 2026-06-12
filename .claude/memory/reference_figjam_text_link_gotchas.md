---
name: reference_figjam_text_link_gotchas
description: "FigJam shapeWithText gotchas via figma-console — white-default text fill (invisible on white cards), line-clipping from internal padding, and how to make \"clickable thumbnail cards\" (hyperlink the title text, not the image)."
metadata: 
  node_type: memory
  type: reference
  originSessionId: e89d91b7-6d76-45e7-9a6b-6b1151450ae1
---

# FigJam shape-with-text + clickable-card gotchas (figma-console)

Building living-board cards with `figma.createShapeWithText()`:

1. **Default text fill can be WHITE.** In some FigJam files new shape-with-text renders white text → invisible on white cards (it looked "empty"). Pills on colored fills hid the bug. FIX: always set `sh.text.fills = [{type:"SOLID",color:<dark>}]` explicitly after setting characters. Bake it into the `card()` helper.

2. **shape-with-text CLIPS lines that don't fit** — it has generous internal vertical padding, so naive line-math overflows. A 3-line block needs ~150px tall; a 2-line block clipped to 1 line + "…" in an 82px card. FIX: prefer **single-line** card text, or give 1.5–2× the height you'd expect. (Same trap hit the ⑩ docs cards earlier — see [[feedback_knowai_living_board_style]].)

3. **Text alignment defaults vary** — set `sh.text.textAlignHorizontal="LEFT"` for content cards (pills/headers = "CENTER").

4. **"Clickable thumbnail cards":** FigJam image-fill rectangles CANNOT hold a hyperlink (links are a text-range feature). To make a video/thumbnail card clickable, put the link on the adjacent **title text node**:
   ```js
   t.setRangeHyperlink(0, t.characters.length, {type:"URL", value:url});
   t.setRangeFills(start, end, [{type:"SOLID",color:rgb("#1F5FD1")}]); // color the "Watch ↗" portion blue so it reads as a link
   ```
   Load the font (Inter Medium) before setting characters/ranges.

5. Embed the actual images via CORS server + `figma.createImage(bytes)` from `fetch()` — see [[reference_figma_image_embed_cors]] (port 9230/9231, manifest-allowlisted). 33 images in one `figma_execute` worked fine.

Used while building the KnowAI YouTube "Technical Style" reference board (channel screenshots + top/recent video cards).
