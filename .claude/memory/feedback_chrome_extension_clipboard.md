---
name: chrome-extension-clipboard-mv3
description: MV3 clipboard write patterns — service workers can't, offscreen docs can't writeText, PNG via ClipboardItem works, text via textarea+execCommand
type: feedback
originSessionId: 0f1d2f8e-19b3-4b12-afed-fbbae2f9eba0
---
In MV3 Chrome/Brave extensions, the clipboard write paths have hard, non-obvious constraints. Pick the right one or you get silent or confusing failures.

**Why:** Hit during element-png-capture build (May 2026). Lost iterations to "Document is not focused" errors and `<a download>` blocks on `file://`.

**How to apply:**
- **Service workers (background.js) cannot access `navigator.clipboard` at all.** Don't try.
- **Need to write clipboard from extension code?** Use a `chrome.offscreen` document at `chrome-extension://` origin. Add `offscreen` + `clipboardWrite` permissions, declare reasons `["CLIPBOARD"]`.
- **From the offscreen doc, `navigator.clipboard.writeText(string)` ALWAYS fails** with "Document is not focused" — offscreen documents are intentionally hidden so they can never be focused. Modern Clipboard API blocks them.
- **Working pattern for text/JSON/SVG**: textarea + `document.execCommand("copy")`:
  ```js
  const ta = document.createElement("textarea");
  ta.value = text;
  ta.style.cssText = "position:fixed;top:0;left:0;width:1px;height:1px;opacity:0;";
  document.body.appendChild(ta);
  ta.focus(); ta.select(); ta.setSelectionRange(0, text.length);
  document.execCommand("copy"); // ignores focus, reads selection
  ta.remove();
  ```
- **Working pattern for PNG/images**: `navigator.clipboard.write([new ClipboardItem({"image/png": blob})])` works fine in offscreen — different code path, no focus check.
- **Downloads on `file://` pages**: programmatic `<a download>` clicks are silently blocked. Use `chrome.downloads.download({url: dataUrl, filename})` from background — bypasses page-origin restrictions because the extension is the initiator.
