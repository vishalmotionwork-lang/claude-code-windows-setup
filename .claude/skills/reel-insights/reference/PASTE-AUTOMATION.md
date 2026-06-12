# Playable video on a FigJam board — the OS-paste route (THE working method)

**Goal:** a *native, playable* video node (the one with a real play button, that plays inline
with audio on the FigJam canvas) — created with automation, not by hand.

**Why this is the only way.** Figma's plugin API has **no** call that creates a playable video
MEDIA node from bytes. Every API route was exhaustively tested (2026-06-01, board "Trial strategy"):

| API attempt | Result |
|---|---|
| `createVideoAsync(bytes)` → `{type:'VIDEO'}` fill on a shape | **static poster** in FigJam (full asset is stored + exportable, but the canvas only paints frame 1; autoplay/loop fire only in Figma **Design** files / prototype). |
| `createGif(hash)` | makes a **GIF-kind** MEDIA node → video bytes show **"Could not play this GIF"**. GIF/image only. |
| `node.clone()` of a real video MEDIA node | plays, but `mediaData.hash` is **immutable** → locked to the source clip, can't inject new content. |
| `pluginDrop` with a real `File` | reaches `figma.on('drop')` but Figma does **not** run its native importer → no node. |
| private multiplayer / REST API | node-create exists but the media-blob upload step is unsolved; REST is read-only. |

The **only** thing that produces a native playable node is a **real OS paste/drag of the file**,
which goes through Figma's own importer. Proven live; this is the productized route.

## The mechanic

```
reel.mp4
  → OS clipboard (as a FILE reference, not bytes)
  → activate Figma Desktop  → send paste keystroke (⌘V mac / Ctrl+V win)
  → Figma's native importer creates a real MEDIA node (playable, preserves 9:16)
  → the figma-console bridge detects the NEW MEDIA node (id-diff) → rename/resize/move into its section
```

Platform paste scripts:
- macOS: `scripts/paste-video-mac.sh <file>` (Swift `NSPasteboard` + `osascript` ⌘V)
- Windows: `powershell -ExecutionPolicy Bypass -File scripts\paste-video-win.ps1 -File <path>` (`Set-Clipboard -LiteralPath` + `SendKeys ^v`)

## Orchestration (per reel — SERIAL, driven by Claude via the bridge)

Do ONE reel at a time and confirm the new node before the next, or you can't tell which node is which.

1. **Snapshot** (bridge / `figma_execute`):
   ```js
   await figma.loadAllPagesAsync();
   globalThis.__before = figma.currentPage.findAll(n => n.type === 'MEDIA').map(n => n.id);
   ```
2. **Paste** (shell): call the platform script with the reel path. Figma comes to the foreground.
3. **Poll for the new node** (bridge, retry up to ~30s for big files; import takes seconds):
   ```js
   await figma.loadAllPagesAsync();
   const before = new Set(globalThis.__before);
   const fresh = figma.currentPage.findAll(n => n.type === 'MEDIA' && !before.has(n.id));
   return fresh.map(n => n.id);   // expect exactly 1
   ```
4. **Place it** (bridge): rename, resize to the section's video slot, move into the SECTION
   (append + set small relative x/y AFTER appendChild — section children coords are relative).

## Gotchas (hard-won)

- **Paste lands wherever Figma decides** (often NOT the viewport center — we saw `-4816,13008`).
  Don't rely on position; identify the node by **id-diff vs the snapshot**, then move it.
- **Serial only.** One paste → confirm new MEDIA → place → next. Parallel pastes are unattributable.
- **Focus-stealing.** Figma must be frontmost during the paste; the script activates it. Don't touch
  the machine mid-run — a stray click/focus change can drop the keystroke.
- **Timing.** An 8–25 MB reel takes a few seconds to import (Figma transcodes to VP9). Poll, don't assume.
- **macOS Accessibility permission** required for the app sending the keystroke (Terminal/iTerm):
  System Settings → Privacy & Security → Accessibility. `doctor.sh` checks this.
- **Windows:** the Figma **window must exist** for `AppActivate("Figma")`; if multiple windows match,
  it focuses the first. Run from a normal PowerShell (not ISE).
- **Not unattended-grade.** It's focus-driven and one-at-a-time; great for a batch you supervise,
  not a headless cron. For headless/cross-platform-no-focus needs, the EMBED-via-oEmbed route is the
  alternative (plays inline, but is an embed card, needs a public host).
