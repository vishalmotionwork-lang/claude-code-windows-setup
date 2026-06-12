---
name: Qdrant deprecated — use Code Review Graph instead
description: Qdrant semantic search was underused — replaced by Code Review Graph for code, direct file reads for context
type: feedback
originSessionId: 43113de1-79d6-48e8-b2c6-2ce362740c4e
---
Qdrant vector search (both MiniLM fast and BGE-large deep) is deprecated. Don't run prefetch, deep-search, task-search, or re-index commands.

**Why:** In practice, the actual session workflow is hot.md → CONTEXT.md → SESSION.md → start working. Qdrant's prefetched.md was rarely referenced, task-search was used maybe twice across all sessions, deep-search was never used. The 3-tier memory system was over-engineered for how sessions actually work.

**How to apply:**
- Don't run Qdrant queries or reference prefetched.md/deep-search.md
- For code understanding: use Code Review Graph (callers_of, get_impact_radius, semantic_search_nodes)
- For project context: read CONTEXT.md + SESSION.md directly
- For cross-project context: check REGISTRY.md and read the relevant project's files
- Redis hot.md still works and is useful — keep using it
