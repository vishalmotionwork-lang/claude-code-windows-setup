---
name: Neon MCP and app DB can diverge
description: Don't use Neon MCP for data changes — verify through app's own API instead
type: feedback
originSessionId: 21fb51e5-97ad-44a7-b8c1-6ef15540a610
---
Neon MCP (`mcp__Neon__run_sql`) and the app's Vercel serverless functions may see different database states, even when both connect to the same Neon project.

**Why:** Spent significant time making DB changes (DELETE, UPDATE, INSERT) via Neon MCP, then wondering why the app's API returned different data. The MCP's changes appeared committed but the app's neon() driver saw stale/different values. Likely caused by connection pooling, read replica routing, or branch isolation.

**How to apply:**
- Use the app's own API endpoints for data changes (e.g., `/api/sync`, `/api/cleanup`)
- Use Neon MCP only for schema changes (CREATE TABLE, ALTER) and read-only investigation
- When debugging data issues, always verify through the app's API (`curl https://...`), not through MCP queries
- If MCP and API return different counts/values, trust the API — that's what users see
