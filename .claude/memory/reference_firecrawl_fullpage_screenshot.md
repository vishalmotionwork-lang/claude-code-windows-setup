---
name: reference_firecrawl_fullpage_screenshot
description: Capture true full-page screenshots of live (JS/Webflow) sites with the firecrawl CLI — chrome --headless --screenshot clips at window height. Batch + download pattern.
metadata: 
  node_type: memory
  type: reference
  originSessionId: 4b905dce-bb97-4e4f-9e31-3ec9b45a950c
---

# Full-page screenshots of live web pages — use firecrawl, not chrome headless

## The gotcha
`"/Applications/Google Chrome.app/.../Google Chrome" --headless=new --screenshot=out.png --window-size=1440,3200 URL` only captures the **window height** (clips long pages). New headless has no reliable CLI flag for full-page; you'd need puppeteer `fullPage:true` (usually not installed). Also `timeout` is not on macOS (use nothing or `gtimeout` from coreutils).

## What works (firecrawl CLI, already installed here)
```bash
firecrawl scrape "URL" --format markdown --full-page-screenshot --json --wait-for 3500 -o out.json
```
- `--full-page-screenshot` = true full scrollable page (handles Webflow/JS SPAs).
- Do NOT combine `--full-page-screenshot` with `--format screenshot` → error "may only specify one screenshot format". `--format markdown` + `--full-page-screenshot` is fine and returns both.
- The screenshot comes back as a **signed GCS URL** nested in the JSON (key `screenshot`), not inline. Recurse the JSON to find it, then `urllib.request.urlretrieve(url, path)`.
- Batch: loop URLs with `&` + `wait` (background the whole thing for many pages). 16 pages ≈ under a minute.

## Post-process for boards (sips + ffmpeg, no ImageMagick on this Mac)
- Hero crop (top of page) anchored to TOP: `ffmpeg -i in.png -vf "crop=iw:min(ih\,1300):0:0,scale=900:-1" out.jpg` (sips `-c` crops CENTERED — wrong for hero).
- Full-length skinny mini (to show page length/structure): `ffmpeg -i in.png -vf "scale=360:-1" mini.jpg`.

Full-page heights are diagnostic on their own: a 12,000px page = long-form VSL/sales letter; a 1,100px page = a router/fork. Report the page height as a signal.

Related: [[reference_competitor_teardown_workflow]] [[reference_figma_image_embed_cors]]
