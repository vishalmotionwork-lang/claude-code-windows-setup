---
name: feedback_crucible_groups_not_boards
description: Crucible canvas containers are "groups" not "boards". Boards = workspaces (gallery level). Groups = content containers on canvas.
type: feedback
---

In Crucible, the terminology is:
- **Board** = workspace selected from gallery (the whole canvas view)
- **Group** = container ON the canvas that holds content cards (videos, images, text, carousels)

**Why:** User clarified that the canvas shouldn't create "boards inside boards". The dock creates groups, and groups hold content pieces. This matches Blort's model where titled containers hold video cards.

**How to apply:**
- Dock "+" creates a Group, not a Board
- GroupNode on canvas (dark header, white body, holds cards)
- Database: `groups` table (belongs to a board/workspace)
- Canvas store manages group nodes
- Board CRUD stays at gallery level only
