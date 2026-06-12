---
name: feedback_askuserquestion_default
description: Always use the AskUserQuestion tool when asking the user questions — never plain-text question lists
type: feedback
originSessionId: 253c2b81-1a73-45cd-8bff-08654aa3090a
---
When asking the user ANY clarifying/narrowing questions, use the `AskUserQuestion` tool instead of typing questions in plain markdown.

**Why:** User explicitly requested this as a standing preference (2026-04-23). Plain-text question lists require them to reply with unstructured prose; AskUserQuestion gives them a clean picker UI with options, makes answers unambiguous, and avoids missed sub-questions.

**How to apply:**
- Any time I'd type "Before I do X, I need to know: 1) ... 2) ... 3) ..." — use AskUserQuestion instead
- Batch related questions into one AskUserQuestion call (multi-question support) rather than one-by-one
- Always provide sensible options when the answer space is finite; use free-text only when truly open-ended
- Applies to ALL projects, not just this session
- Exception: not for single trivial yes/no confirmations inside a flow (e.g. "proceed?") where a one-line text reply is faster — use judgment, but default to the tool
