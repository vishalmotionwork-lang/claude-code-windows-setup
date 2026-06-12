---
name: Project files go in project directory, not memory
description: Never store actual project files (docs, code, specs, features) in the Claude memory folder. Memory only holds small pointer files (CONTEXT.md, SESSION.md, DECISIONS.md).
type: feedback
---

Actual project files (architecture docs, feature specs, code, assets) must live in the project's own directory (e.g., ~/Marqit/docs/). The memory folder (`~/.claude/projects/.../memory/projects/<name>/`) only holds small context pointers.

**Why:** Vishal caught me storing 25 feature breakdowns (1.49 MB) in the memory folder instead of ~/Marqit/. Memory is for session context, not project artifacts.

**How to apply:** When creating any project file — docs, specs, code, configs — always put it in the project's actual directory (listed in REGISTRY.md path column). The memory folder ONLY gets CONTEXT.md, SESSION.md, and DECISIONS.md.
