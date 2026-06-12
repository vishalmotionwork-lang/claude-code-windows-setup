---
name: No assumptions when deepening strategy content — ask the user instead
description: When expanding strategy/brief/positioning content, never fabricate depth via agents or generalize from training. Ask the user with specific clarifying questions instead.
type: feedback
originSessionId: 526f90a7-f6c3-43ad-a2e4-b80743b523a9
---
When the user asks for "more details" on a strategy doc, brief, or positioning content, do NOT spawn agents that generalize from training data or fill gaps from memory. Ask the user for the actual depth.

**Why:** User said directly: "no assumptions, ask me more details if u need". They got frustrated when I tried to drop 10 parallel agents that would have invented sub-frameworks, content-mix ratios, format archetypes, and operational details from generic social-media-strategy training. The whole point of the doc is to capture HIS thinking, not industry-generic playbook content.

**How to apply:**
- When user says "more detail" / "expand" / "deeper" on strategy content — ask, don't infer
- Use AskUserQuestion tool for clarifying questions (matches feedback_askuserquestion_default.md)
- Pick ONE topic at a time, ask focused questions (max 4 per AskUserQuestion call)
- Generic "industry best practices" content is exactly what user does NOT want — they want their specific approach
- This pairs with feedback_fresh_data_only.md — same principle, applied to depth-expansion not just initial fill
