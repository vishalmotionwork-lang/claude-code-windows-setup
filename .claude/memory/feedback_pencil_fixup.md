---
name: Pencil fix-up safety rules
description: Never use destructive Replace operations on groups with working children in .pen files
type: feedback
---

When fixing .pen files after Figma paste, NEVER use R() (Replace) on parent groups that contain working children (text, buttons, illustrations). This destroys all the content inside.

**Why:** Replaced the home screen card groups with flattened images, which deleted all text labels, buttons, and vector illustrations that were working perfectly from the paste.

**How to apply:**
- Only use U() (Update) to modify existing node properties (safe — non-destructive)
- Only fix specific broken properties (like empty image URLs) — don't restructure the node tree
- The paste gives ~95% fidelity. Chasing the last 5% with node replacements risks breaking what already works
- If a mask group isn't clipping correctly, leave it — unclipped artwork is better than deleted artwork
- Test any R() operation on a SINGLE node first, verify with screenshot, before doing bulk replacements
