---
name: Chrome print engine ignores counter-reset on named @page rules
description: When generating PDFs via `chrome --print-to-pdf` with @page named pages, counter-reset/counter-set on element classes is silently ignored. Use TOC-matches-actual approach instead.
type: feedback
originSessionId: 41adc402-ae58-4978-a160-4b216ed4d238
---
When building HTML→PDF with Chrome's headless `--print-to-pdf`, you cannot reset the `page` counter mid-document via CSS. Both `counter-reset: page 0` and the newer `counter-set: page 0` are silently ignored when the element belongs to a named `@page` rule (e.g. `.body { page: main; counter-reset: page 0; }`).

**Symptom:** prelim shows i/ii/iii via lower-roman as expected, but body section starts at the next sequential page number (e.g. 10) instead of resetting to 1. Same for trying to reset a roman counter starting at LOF.

**Why:** `counter-set` for the `page` counter on element-level rules isn't supported by Chromium's print pipeline as of 2026. WeasyPrint handles it correctly, but needs system libs (libgobject) on macOS.

**How to apply:**
- Don't sink time into trying counter-reset variants (`reset` / `set` / inline / on `<body>` / on a wrapper div) — none work.
- Use one of these workarounds:
  1. **Update the TOC entries to match actual rendered page numbers** after rendering once and inspecting page positions (most reliable)
  2. Render two HTMLs separately (prelim + body), each with its own counter, and concat the PDFs (e.g. `pdfunite`)
  3. Install `weasyprint` via brew (needs cairo + pango + gdk-pixbuf + libffi)
- For (1), use `pypdf` to extract section start pages: scan `page.extract_text()` for "CHAPTER N" / section markers and update the TOC TDs accordingly.

**Other pitfall encountered same session:** never name a CSS class `page` if you also use `.page { page-break-after: always }` on sections — `<td class="page">` cells will inherit the rule and force every cell to break onto its own page. Rename to `pgno` or similar.
