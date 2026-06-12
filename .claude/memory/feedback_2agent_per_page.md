---
name: feedback_2agent_per_page
description: DaduOS UI build must use 2-agent pattern per page — planner then implementer — matching StudioFlow reference exactly
type: feedback
---

When building DaduOS UI pages, ALWAYS use 2 agents per page:
1. **Planning Agent** — reads stitch prompt + UI-MAP.md + StudioFlow reference code + FINAL-SPEC. Outputs detailed component spec (layout, component tree, props, data flow, responsive). Does NOT write code.
2. **Implementation Agent** — receives the planner's spec, reads existing StudioFlow components at ~/studioflow/, writes React/TSX with Tailwind wired to real backend repos/actions.

**Why:** Single agents kept rewriting existing UI or creating designs that didn't match the reference. Separation of planning and implementation ensures the visual target (StudioFlow) is matched exactly.

**The reference image:** StudioFlow workspace at ~/studioflow/ (localhost:3000/project/p1). Key UI features:
- Left sidebar: stage accordion (Ideation → Scripting → Shoot → Post-Production → Distribution), each expandable with task steps
- Breadcrumb: WORKFLOW > STAGE PHASE
- Task header: title + description + Save Draft / Send for Review buttons
- Tabs: Overview / SOP / Upload
- Tiptap editor with colored section labels (HOOK & INTRO, MAIN BODY FOCUS, CTA SECTION, CLOSING)
- Word count + LIVE collab indicator in toolbar
- Right panel: Task Progress (steps with green check / blue active / gray pending), Assigned Team (avatars), Stage References (Selected/Research/Brief cards)
- Light theme, white bg, blue #2D5BFF accent, Inter + Manrope fonts

**How to apply:** Every page must visually match this reference's design language. Read ~/studioflow/src/ components before building any DaduOS page.
