---
name: Follow instructions exactly — don't optimize away user's intent
description: When user says "11 agents individually", launch 11 agents individually. Don't bundle or optimize unless asked.
type: feedback
---

When the user gives specific instructions about HOW to do something (e.g., "11 agents individually"), follow them exactly. Don't bundle, optimize, or "improve" the approach.

**Why:** User asked for 11 individual agents, each with full focus on one page. I bundled 3 agents to handle multiple pages each, reducing quality and ignoring the explicit instruction. The user had to correct me and re-request.

**How to apply:**
- If user says "X agents individually" → launch X separate agents
- If user says "parallel" → all in one message, all independent
- Don't substitute your judgment for the user's explicit instruction on execution approach
- Optimization of HOW to do things is only appropriate when the user hasn't specified HOW
