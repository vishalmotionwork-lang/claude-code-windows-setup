---
name: feedback_backend_first
description: For Marqit (and likely other projects), build all schema/API/backend first, then wire frontend to working APIs
type: feedback
---

When building full-stack apps, do backend-first: schema → API → processing → frontend → polish.

**Why:** User prefers having everything backend strong and tested before touching frontend. Avoids integration debugging and "deep bugging" when backend + frontend are built simultaneously. APIs should be testable via GraphQL Playground before any UI exists.

**How to apply:** When planning phases for full-stack projects, group all schema/API/backend work into early phases and frontend into later phases. Don't mix backend + frontend in the same phase unless user explicitly asks for it.
