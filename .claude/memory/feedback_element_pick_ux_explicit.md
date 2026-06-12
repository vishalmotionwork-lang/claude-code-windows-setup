---
name: element-picker-ux-no-auto-activate
description: Don't auto-activate element-pick mode (crosshair) when a screenshot extension is invoked. Show an explicit modal with Capture Visible / Full Page / Pick Element / Cancel. Removes "I clicked the wrong thing" misfires entirely.
type: feedback
originSessionId: 584b889f-1a76-423c-80b4-c19cbd446ba1
---
Screenshot extensions that auto-activate element-picking on invoke (Alt+Shift+S → crosshair → click an element) cause repeated "I captured the wrong thing" bugs. Users default to clicking the most visually prominent element on screen (often a popover or button) when they actually wanted "snapshot what I see now."

**Why:** Built element-png-capture (May 2026). Spent multiple debug cycles thinking the engine was broken when actually the user kept clicking on popovers in element-pick mode. Restructuring to require explicit choice eliminated the entire bug class.

**How to apply:**

On invoke (icon click or keyboard shortcut), show a centered modal with explicit choices:

```
┌────────────────────────────────────────┐
│  Choose what to capture                │
│                                        │
│  📸 Capture Visible Area  (primary)    │
│  📜 Capture Full Page     (primary)    │
│  🎯 Pick Specific Element (secondary)  │
│  Cancel                   (secondary)  │
└────────────────────────────────────────┘
```

- "Capture Visible Area" — most common case, snapshot current viewport. **Default action.**
- "Capture Full Page" — entire scrollable doc.
- "Pick Specific Element" — **ONLY THIS** activates the crosshair element-picker.
- Cancel — close modal, do nothing.

Modal centered on screen, ~460 px wide, large buttons (12 px padding, 13 px font). Position at top:80px so it doesn't fight with browser chrome.

**Don't add the crosshair / mousemove tracking on invoke.** Add it lazily inside the "Pick Specific Element" handler. This prevents accidental element selection.

**For UX feedback:** show captured PNG dimensions in the success banner — `SAVED 5760×3600 — page.com_visible_2026-05-05.png`. Lets user immediately see whether the engine did something reasonable.

**Why "Capture Visible" matters:** when the user has a popover/dropdown/tooltip open and wants to capture it WITHOUT closing, element-pick is awkward (hovering changes the highlighted element, clicking might dismiss the popover). Capture Visible just snapshots the current state.
