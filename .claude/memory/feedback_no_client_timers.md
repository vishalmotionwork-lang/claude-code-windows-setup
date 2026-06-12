---
name: No client-side timers for display
description: Don't use setInterval/tick patterns to update UI text — compute once on render, refresh on page load
type: feedback
---

Don't use `setInterval` or tick state (`useState + setInterval every 60s`) to keep countdown text updated in the browser. User considers it bad practice.

**Why:** User asked "is this good practice?" about a 60-second tick interval for shoot countdown. Prefers static display that's fresh on page load — no client-side timers.

**How to apply:** When showing relative time ("Shoot in 3h"), either:
1. Show a static label like "✓ Scheduled" with a link to the detail view
2. Compute once on render — it's fine if it's stale by 60 seconds
3. Never add `setInterval` for purely cosmetic text updates
