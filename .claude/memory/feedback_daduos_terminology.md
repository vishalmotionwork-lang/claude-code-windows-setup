---
name: feedback_daduos_terminology
description: DaduOS naming — Project/Stage/Task/Checklist confirmed by team usage
type: feedback
---

Updated 2026-03-28 after questioning session. Team naturally says "project" for a content piece.

**Confirmed naming:**
- **Project** = content piece (e.g., "AI Wellness Reel #12") — code: `ContentProject`
- **Stage** = major phase (Scripting, Shoot, Edit, QC, etc.) — code: `FlowStage`
- **Task** = actionable assignment inside a stage — code: `ProjectTask`
- **Checklist item** = substep within a task — code: `TaskSubstep`

**Why:** Senior reviewer recommended this, Vishal confirmed team says "project" for content. Old naming (Task=project, Subtask=stage) was confusing.

**How to apply:** UI labels, API names, schema references, documentation all use Project/Stage/Task/Checklist. The code model names align with this.
