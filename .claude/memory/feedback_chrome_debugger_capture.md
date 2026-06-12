---
name: chrome-debugger-api-capture
description: For high-DPR screenshots in Chrome extensions, use chrome.debugger + Page.captureScreenshot. Captures videos/iframes/canvases that html2canvas can't. Same API Puppeteer/Lighthouse use.
type: feedback
originSessionId: 584b889f-1a76-423c-80b4-c19cbd446ba1
---
For Chrome extension screenshots that need high quality AND must work with videos / iframes / canvases / heavy CSS effects, use Chrome DevTools Protocol via `chrome.debugger`. NOT html2canvas. NOT captureVisibleTab.

**Why:** Built element-png-capture (May 2026). html2canvas missed video pixels and produced transparent backgrounds. captureVisibleTab caps at native DPR. Debugger API is the only path that gives both arbitrary DPR AND captures actual compositor output.

**How to apply:**

1. Add `"debugger"` permission to manifest. (Triggers a "Debug your browser" warning at install — required for Page.captureScreenshot.)

2. Background-script flow:
   ```js
   await chrome.debugger.attach({ tabId }, "1.3");
   await chrome.debugger.sendCommand({ tabId }, "Emulation.setDeviceMetricsOverride", {
     width: 0, height: 0, deviceScaleFactor: scale, mobile: false,
   });
   await new Promise(r => setTimeout(r, 140)); // let renderer apply DPR
   const result = await chrome.debugger.sendCommand({ tabId }, "Page.captureScreenshot", {
     format: "png",
     clip: { x, y, width, height, scale: 1 }, // doc coordinates, scale ALWAYS 1
     captureBeyondViewport: true,
     fromSurface: true,
     optimizeForSpeed: false,
   });
   await chrome.debugger.sendCommand({ tabId }, "Emulation.clearDeviceMetricsOverride");
   await chrome.debugger.detach({ tabId });
   const dataUrl = "data:image/png;base64," + result.data;
   ```

3. **Use deviceScaleFactor for DPR, not clip.scale.** Output dims = `clip.w × deviceScaleFactor × clip.scale`. Both work, but deviceScaleFactor triggers re-render (vectors crisp), clip.scale is pure post-capture upscale.

4. **Pass `clip: null` when you want the natural rendered viewport.** In your background, omit clip + captureBeyondViewport when no clip is provided. Chrome captures whatever is currently visible.

5. **Always `clear` and `detach` in a `finally`.** If you crash with debugger still attached, the yellow bar stays until manually canceled.

6. **Yellow "Extension started debugging this browser" bar** appears for the duration of the attach. ~1–3 s for normal captures. Tell users it's expected.

7. **Caveats:**
   - DRM-protected video (Netflix, EME) returns black — no extension-level workaround
   - Chrome.debugger conflicts with DevTools open on the same tab — error message "Cannot attach to this target" or "Another debugger is already attached" — surface clearly to user
   - `chrome://`, `brave://`, extension pages — can't attach
