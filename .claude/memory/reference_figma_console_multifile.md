---
name: reference_figma_console_multifile
description: "figma-console executes in the FOCUSED Figma file, not figma_navigate's \"active\" target — guard every write with a file-name check"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 32512a66-5156-48b6-a7dc-ea4e66287474
---

When multiple FigJam/Figma files have the Desktop Bridge plugin running, `figma-console` **executes `figma_execute` in whichever file is FOCUSED on screen**, not the one `figma_navigate` set as "active". `figma_navigate` flips the bridge's active flag but the focused tab wins, so calls silently land in the wrong file (lookups by node id return null/empty — fails safe, no damage, but no progress).

**Always start a mutating `figma_execute` with a guard:**
```js
if(figma.root.name!=="<file name>"){ return {WRONG_FILE:figma.root.name}; }
```
If it trips, ask the user to (1) click the target file's tab to the front, and (2) **close the Desktop Bridge plugin in the other open file** so it stops grabbing the connection. `figma_list_open_files` shows connected files + which isActive.

Seen on the KnowAI "complete task board" vs "Youtube plan and accountability" — both open, bridge kept flipping to the focused one. Related board style: [[feedback_knowai_living_board_style]].
