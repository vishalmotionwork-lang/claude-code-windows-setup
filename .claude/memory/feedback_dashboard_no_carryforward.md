---
name: Dashboard daily reset — no carry-forward
description: Core team dashboard BOD/EOD planned items never carry forward to next day. Each day starts clean.
type: feedback
---

Daily planned items do NOT carry forward to the next day's dashboard priority view.

**Why:** Vishal wants intentional daily planning — each day starts clean. Stale tasks piling up on the dashboard defeats the purpose. If something wasn't done, it stays in the historical log under its date.

**How to apply:**
- `/bod` creates planned items for today only — they don't persist to tomorrow
- `/eod` logs done/issue/note items and marks BOD items complete or not — incomplete items stay in the date log
- No "carry forward?" questions in EOD — incomplete = stays in log, period
- If someone wants the same task tomorrow, they re-add it via tomorrow's `/bod`
- The Verticals tab (long-running tasks) is separate and persists — only daily planned items are ephemeral
