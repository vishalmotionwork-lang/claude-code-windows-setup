---
name: html-video-element-source-resolution-frame
description: To capture a `<video>` element at ORIGINAL source resolution (not display-scaled), use canvas drawImage at videoWidth/videoHeight. Works for same-origin / CORS-enabled videos. Falls back gracefully on DRM.
type: feedback
originSessionId: 584b889f-1a76-423c-80b4-c19cbd446ba1
---
Browser extensions / scripts capturing video can grab the current frame at the video's **native source resolution** (1080p, 4K, whatever was streamed) using a canvas trick. This bypasses display scaling — a 600×400 player on screen still produces a 1920×1080 PNG if that's the source.

**Why:** Built element-png-capture (May 2026). User wanted to grab Frame.io review-video frames at original quality, not at the display-downscaled size. DevTools Protocol caps at `display_size × deviceScaleFactor`, but reading directly from the video element is unbounded.

**How to apply:**

```js
function tryNativeVideoFrame(video) {
  const w = video.videoWidth || 0;
  const h = video.videoHeight || 0;
  if (w <= 0 || h <= 0) return null;  // not loaded yet
  try {
    const c = document.createElement("canvas");
    c.width = w;
    c.height = h;
    const ctx = c.getContext("2d");
    ctx.fillStyle = "#000";  // safety background
    ctx.fillRect(0, 0, w, h);
    ctx.drawImage(video, 0, 0, w, h);
    return c.toDataURL("image/png");
  } catch (error) {
    // Tainted canvas (CORS without crossorigin attr) or DRM-protected content.
    // Fall back to whatever else you have (e.g., DevTools Protocol screenshot).
    return null;
  }
}
```

**When to invoke:** detect `<video>` in selected element first, try Path B, fall back if null.

```js
function findVideoIn(el) {
  if (!el) return null;
  if (el.tagName === "VIDEO") return el;
  return el.querySelector("video") || null;
}

const video = findVideoIn(selectedEl);
if (video) {
  const nativeFrame = tryNativeVideoFrame(video);
  if (nativeFrame) return nativeFrame;  // native res, done
}
// fall back to compositor capture (e.g., chrome.debugger Page.captureScreenshot)
```

**Limitations:**
- **DRM-protected** (Netflix, Apple TV+, sometimes Frame.io premium) → throws, returns null. No workaround.
- **Cross-origin without CORS** → canvas tainted on `drawImage` → throws on `toDataURL`. Most CDN-served videos work; some block.
- **Not yet decoded** → `videoWidth/videoHeight` are 0; return null and try later or use display-size capture.
- **HDR / wide-gamut frames** → Canvas2D drops to sRGB — color shift possible.

**For users:** pause the video on the exact frame you want before triggering capture. The function reads `currentTime` frame.
