---
name: feedback_preserve_existing_ui
description: Never rewrite pages that already have working UI. Extend them, don't replace them.
type: feedback
---

When building new backend/logic, NEVER rewrite existing page components that already have working UI/UX. The agents completely replaced working ideation, projects, tasks, team, and dashboard pages with new server-component versions that broke the existing design.

**Why:** The existing pages had working UI with proper hooks, layout, design system integration. Agents rewrote them as server components with completely different UX, breaking the flow.

**How to apply:**
- Read existing page code FIRST before touching it
- If a page already renders and works, EXTEND it — don't rewrite it
- New backend (repos, actions, engine) should plug INTO existing pages, not replace them
- Only create new pages for genuinely new routes
- If the existing page uses client components + hooks, keep that pattern — don't force server components
