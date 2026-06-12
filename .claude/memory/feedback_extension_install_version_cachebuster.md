---
name: chrome-extension-install-version-cachebuster
description: Chrome extension content scripts persist in tabs even after extension reload. Use a versioned `__pkgInstalled` flag at top of content script — bump version string on every code change, force re-init when versions don't match.
type: feedback
originSessionId: 584b889f-1a76-423c-80b4-c19cbd446ba1
---
After reloading a Chrome/Brave extension, the OLD content script is still alive in any tab where it was previously injected. Just reloading the extension is not enough — the next time you invoke the extension on that tab, executeScript injects fresh code, but if your guard logic is `if (window.__installed) return`, the new code early-returns and the old picker / UI keeps running.

**Why:** Hit this 5+ times in element-png-capture (May 2026). Every "I see no changes" debugging session traced back to either:
1. Extension reloaded but tab not refreshed, OR
2. Content script `INSTALL_VERSION` flag not bumped → new code thinks old code is good

**How to apply:**

```js
(() => {
  const INSTALL_VERSION = "v15-feature-name";  // BUMP this on every code change

  if (window.__myExtInstalled === INSTALL_VERSION) {
    if (typeof window.__myExtRestart === "function") window.__myExtRestart();
    return;  // reuse existing setup, just restart
  }
  window.__myExtInstalled = INSTALL_VERSION;

  // ... initialize fresh UI, attach listeners ...
  window.__myExtRestart = startPicker;
})();
```

**Reload sequence to give users:**

> 1. `chrome://extensions` (or `brave://extensions`) → click circular Reload arrow on the extension card
> 2. **`Cmd+R` on the page tab you want to test** ← most-skipped step; without this the old content script stays alive
> 3. Invoke the extension again — new INSTALL_VERSION mismatches old, fresh init runs

**Version string format that's worked:** `v<N>-<short-feature-tag>` like `v15-visual-rect-bounded`. Both digits and tag bump together.

**Don't use semver here.** It's not a public version. Bump on every iteration during dev — including bug-fix iterations within a session — so each test cycle is unambiguous.

**Caveat:** even with version bump, reloading just the extension reactivates the new code only on next icon click / shortcut. If the user has a stale picker open, they may need to Esc and re-invoke.
