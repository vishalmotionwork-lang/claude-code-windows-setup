---
name: Use code-review-graph before Read/Grep for important files
description: When exploring important/unknown files, query the code-review-graph first. Use Read/Grep only to edit or when the graph returns nothing useful.
type: feedback
originSessionId: 102d77c7-f100-47a7-a15c-d0a42aa986d2
---
Before cracking open a significant source file, check the code-review-graph:
- `get_minimal_context` for task orientation
- `semantic_search_nodes` to locate a function/class by name or concept
- `query_graph` (callers_of / callees_of / imports) to trace relationships
- `get_impact_radius` before refactors

Only fall back to Read/Grep when the graph isn't built, the target isn't in the graph, or you need the actual source to write an edit.

**Why:** Vishal explicitly reminded me mid-session to "use code review graph when needed to read through important files only". He was watching Read/Grep spam for files the graph could have answered in ~200 tokens. Hooks auto-build and auto-update the graph after every edit — ignoring it is wasted context.

**How to apply:**
- Default to graph tools for "where is X?" or "what calls X?" questions.
- Use Read only after the graph tells you the exact file+line you need.
- If the graph is missing (e.g. fresh repo), build or update it before spelunking (`build_or_update_graph_tool`).
- Don't read whole files just to glance at a section — the graph can point to the right block.
