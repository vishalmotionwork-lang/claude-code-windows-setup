---
name: ZeelOS auth needs rework
description: Login/auth disabled temporarily — needs proper cross-device solution before deploy
type: project
---

Auth and login flow for ZeelOS needs a full rework before deployment.

**Why:** NextAuth v5 credentials provider doesn't work cross-device on local network. `signIn()` from `next-auth/react` hardcodes base URL, CSRF cookies don't transfer across hosts, native form POST also fails. Middleware + layout auth checks both redirect to login which loops.

**Current state (2026-04-07):** Auth check disabled in middleware.ts and layout.tsx (commented out). App is open to anyone on the network. Login page exists but is bypassed.

**How to apply:** Before deploying or giving Zeel access, re-enable auth with a proper solution:
- Consider token-based auth with a simple PIN/password check (no NextAuth complexity)
- Or fix NextAuth by ensuring `AUTH_TRUST_HOST=true` works end-to-end
- Or switch to cookie-based session with a simple `/api/login` endpoint
- Test on phone + different Mac before declaring it fixed
