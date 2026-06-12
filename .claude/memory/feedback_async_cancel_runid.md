---
name: async-cancel-via-runid-token
description: When a user-cancellable operation is async (capture, fetch, etc.), Cancel must invalidate in-flight work, not just remove UI. Use a monotonic runId token compared after every await; bail if runId changed.
type: feedback
originSessionId: 584b889f-1a76-423c-80b4-c19cbd446ba1
---
"Cancel" buttons that only close the UI but don't invalidate in-flight async work cause delayed side effects — user clicks Cancel, then 3 seconds later a download still arrives because the capture promise was already in flight.

**Why:** Flagged in Master's review of element-png-capture (May 2026). My `stopPicker()` removed the picker UI but the `captureElement()` / `capturePage()` async functions kept running. Race condition where user cancels → another action triggers → both downloads arrive.

**How to apply (runId pattern):**

```js
let runId = 0;

function startPicker() { /* ... */ }

function stopPicker() {
  runId++;  // invalidates any in-flight runs
  // ... remove UI, listeners ...
}

async function captureElement() {
  const myRun = ++runId;
  // ... start work
  const dataUrl = await captureAPI(clip, scale);
  if (myRun !== runId || !active) return;  // bail — user canceled

  await downloadDataUrl(dataUrl, filename);
  if (myRun !== runId || !active) return;  // bail — user canceled (after capture, before download finished)

  setStatus("Saved");
}
```

**Key points:**
1. **Increment runId in stopPicker** — every cancel invalidates ALL prior runs.
2. **Capture runId at the START of each async function** — local copy.
3. **Compare after EACH `await`** — bail if mismatch. Don't proceed with side effects (no download, no UI updates).
4. **Also check an `active` flag** — defensive; the runId check is sufficient but `!active` is faster and self-documenting.

**Why runId monotonic counter, not boolean cancel flag:** boolean races. If user cancels then immediately starts a new run, the new run's `cancelled = false` could clobber the previous run's "still cancelled" state. Monotonic counter never resets, so each run only sees its own ID.

**For chrome.debugger captures specifically:** if you've attached the debugger and the user cancels, you still need to detach in the `finally` block — even when bailing early. Otherwise the yellow bar stays.

```js
try {
  await chrome.debugger.attach({ tabId }, "1.3");
  // ... metrics override ...
  const result = await captureScreenshot(...);
  if (myRun !== runId) return;  // bail before download
  // ... download ...
} finally {
  await chrome.debugger.detach({ tabId }).catch(() => {});  // ALWAYS detach
}
```
