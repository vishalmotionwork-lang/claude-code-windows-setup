---
name: Debug data pipelines by tracing, not guessing
description: When dashboard/UI shows wrong data, add debug output immediately — don't guess through deploy cycles
type: feedback
originSessionId: 21fb51e5-97ad-44a7-b8c1-6ef15540a610
---
When a dashboard or UI shows wrong data, **add visible debug diagnostics FIRST** — trace the data at each stage (DB → API → client) to find exactly where it breaks. Don't guess through multiple deploy-and-refresh cycles.

**Why:** Spent 2 hours on a 20-minute fix. Made 6+ deploys guessing at causes (daemon threads, hostname, session dedup, CDN cache) when the real blocker was a Neon driver `::timestamptz` cast bug. Adding debug output to the API response and the page footer found the root cause in 2 minutes.

**How to apply:**
- First step for any "wrong data" bug: add a debug endpoint or visible debug line showing raw counts/values at each layer
- Never trust MCP database tools to reflect what the app sees — verify through the app's own API
- Don't make DB changes through MCP when the app has its own write endpoints
