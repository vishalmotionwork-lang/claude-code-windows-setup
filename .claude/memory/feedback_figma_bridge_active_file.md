---
name: feedback_figma_bridge_active_file
description: figma-console bridge routes to the FOCUSED file when multiple Figma files have the plugin open — verify currentFileName before any write/delete
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 281a3743-d9be-4333-aaa6-9b39fe21f7bf
---

When multiple Figma files have the Desktop Bridge plugin open, the figma-console MCP routes
every command to whichever file is **"active" (focused)** — NOT to a fixed file.

**Why:** the bridge plugin's `ui.html` scans ports 9223–9232 and connects to ALL local MCP
servers ("so every Claude instance has Figma access"). There is **no per-file port pinning** —
every file's bridge talks to every server, and each server targets the single focused file.
So two terminals canNOT be cleanly isolated to two different files in parallel; both hit the
focused window, and focus changes flip both. (Confirmed 2026-06-01: commands silently jumped
from "Trial strategy" to "Content Planning" because a 2nd file became active.)

**How to apply:**
- BEFORE any write/delete via figma_execute, call `figma_get_status` and proceed ONLY if
  `currentFileName` matches the intended board (e.g. "Trial strategy" / fileKey
  6d4thXqsXL5caR7Ay4yg2x). The status itself warns: "verify the file name before destructive
  operations when multiple files have the plugin open."
- If `currentFileName` is wrong: ask the user to focus the correct Figma window, or close the
  other file's bridge. Do NOT guess.
- `connectedFiles[]` in get_status lists every connected file with an `isActive` flag — the
  active one is the target. `otherInstances` lists extra MCP servers on other ports.
- For true parallel work on different files, the only reliable isolation is separate machines/
  accounts — the plugin auto-connects to all local servers in range.

Related: [[reference_figma_figjam_video_insert]] (the reel-insights board work this guards).
