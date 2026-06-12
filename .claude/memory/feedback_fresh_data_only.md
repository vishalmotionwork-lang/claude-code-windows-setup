---
name: Fresh data only when user is feeding strategic content
description: When user is dictating fresh strategic content (briefs, plans, docs), don't pull from memory unless explicitly asked
type: feedback
originSessionId: 526f90a7-f6c3-43ad-a2e4-b80743b523a9
---
When the user is feeding fresh data for a strategic document, plan, or brief, do NOT pull anything from memory or prior context unless they explicitly ask for it.

**Why:** User said directly: "I will give u fresh data on everything use that nothing to be pulled from memory not unless I ask to". Memory may be outdated or contain stale context that contradicts the current intent. The user's freshly dictated data is the source of truth for the new artifact.

**How to apply:**
- When user says "I'll give you data" or "fresh data" or similar — treat memory as off-limits for that task
- Don't pre-fill, don't auto-suggest from prior projects, don't enrich with old context
- Only use memory if user explicitly says "what do we have on X" or "pull from memory"
- Default reading order is still followed (hot.md, MEMORY.md feedback) — but those inform HOW we work, not WHAT goes in the artifact
