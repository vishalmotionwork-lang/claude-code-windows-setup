---
name: Seminar PPTX assembly workflow (parallel-agent + python-pptx)
description: Reusable pattern for building reference-styled seminar decks — N parallel agents source one image each, python-pptx assembles
type: reference
originSessionId: 14ff73ce-b098-4aee-b857-48cb6b22aee8
---
# Seminar PPTX Assembly Workflow

Battle-tested 2026-05-08 on the World Models deck. Use whenever Vishal needs a multi-slide presentation with real images and a consistent visual style modelled on a reference deck.

## Pattern
1. **Reference parse** — read the reference PDF/PPT, extract: palette, fonts, layout types, title/subtitle scale, accent panel side, image style (real photo vs vector).
2. **Slide plan** — one row per slide: title, subtitle, optional body/quote, image subject, layout name.
3. **Workspace** — `mkdir -p /tmp/<deck>-ppt/{images,content}`.
4. **Parallel agents** — spawn N general-purpose agents in a SINGLE message (one Agent block per slide). Each agent:
   - Gets a self-contained brief: slide topic, exact title/subtitle, image guidelines, JSON schema, save paths.
   - Sources ONE image (real photo for people, paper figure for technical diagrams, vector illustration for concepts).
   - Saves to `/tmp/<deck>-ppt/images/slide-NN.{jpg|png}`, verifies with PIL.
   - Writes `/tmp/<deck>-ppt/content/slide-NN.json` with title/subtitle/body/quote/image_path/layout fields.
5. **Assembler** — python-pptx script reads all slide JSONs, dispatches by `layout` field, renders the deck. See `/tmp/world-models-ppt/build_pptx.py` for working reference.
6. **PDF export** — Keynote AppleScript: `tell application "Keynote" ... export theDoc to outputPath as PDF`. Bare form (no properties dict) is most reliable. Properties like `image quality:Best` cause `-2741` parse errors in osascript heredocs.

## Image source preferences
- **People** → Wikimedia Commons (CC-licensed, attribution-safe). Search `commons.wikimedia.org/wiki/Category:<Name>`.
- **Paper figures** → arXiv PDFs (extract figure pages), worldmodels.github.io, Google Research blog, Meta AI blog. Most are reusable for academic seminars.
- **Vector illustrations** → unDraw (MIT, recolorable), Pixabay (CC0), Wikimedia, Freepik (CC).
- **Photos** → Unsplash (Unsplash License — broadly free).
- **Avoid**: Cloudflare-blocked stocks (Pixabay/Freepik often block bots — agents may need to fall back to other sources or build SVGs themselves).

## Style spec (for KnowAI/CTAE seminar look — modelled on XAI reference)
- Slide size: 13.333" × 7.5" (16:9)
- Accent panel: `#DCEEFB` (light blue), full-half-width
- Heading: Cambria Bold 36pt, color `#101A2D`
- Subtitle: Calibri 20pt, color `#4A5566`
- Quote: Cambria italic 22pt, color `#146DF7`
- Body caption: Calibri italic 16pt centered gray

## Layout vocabulary
- `image_left_blue_panel` — image in left half blue panel, title+subtitle right
- `image_right_blue_panel` — mirrored
- `title_top_image_below` — title spans top, large centered diagram below (good for technical figures)
- `centered_text_blue_bg` — full blue bg, large centered title (closing/section slides)
- `two_column_split` — used sparingly, two equal cards

## Common pitfalls
- python-pptx not preinstalled → `pip3 install --user --break-system-packages python-pptx pillow`
- Agents writing bare `<path>` placeholder in JSON instead of real path — verify with `python3` validation script after spawn returns
- LibreOffice/soffice often missing on macOS; Keynote AppleScript is the reliable PPTX→PDF path
- PIL import on transparent PNGs — composite onto white bg before placing if you need RGB output
