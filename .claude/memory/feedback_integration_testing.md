---
name: feedback_integration_testing
description: GSD phases must include real end-to-end integration testing before claiming "done" — unit tests alone miss critical integration bugs
type: feedback
---

After building Marqit through 7 GSD phases with "51 tests passing", the first real user test found 10+ integration bugs: no Docker check, no .env files, no dotenv loading, auth token not stored in localStorage, tus upload CORS/proxy failures, route path mismatch (/asset/ vs /assets/), rate limiter blocking SSR, auto-provisioning not wired to signup flow, etc.

**Why:** GSD executor agents write code and run isolated unit tests, but never actually start the full stack and click through as a user. E2E tests mocked browser state instead of testing the real flow. "Tests passing" gave false confidence.

**How to apply:**
- Before marking any phase as complete, start ALL services and do a manual smoke test
- E2E tests must test the real browser flow (not just assert on DOM elements)
- Check for .env files, Docker/service dependencies, CORS, proxy configs BEFORE writing code
- "Phase complete" = a real user can do the core flow, not just "tests pass"
- When building full-stack apps, always verify the integration layer (frontend ↔ API ↔ DB ↔ services) before moving on
