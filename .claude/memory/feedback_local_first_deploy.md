---
name: feedback_local_first_deploy
description: Always validate full stack locally with Docker before deploying to cloud. Never debug IAM/permissions blind.
type: feedback
---

When deploying a full-stack app, ALWAYS get it running locally first with Docker before touching cloud infrastructure.

**Why:** Session 8 Marqit deployment had 16 bugs discovered only during Cloud Build — each fix required a 10-minute rebuild cycle. Issues included: missing GraphQL schema files in Docker image, Prisma needing DATABASE_URL at build time, Tailwind 4 @theme token collisions, Express 4 vs 5 route syntax, env var vs secret conflicts, missing IAM roles, org policy blocking public access. Total: ~2 hours of cloud trial-and-error.

**How to apply:**
1. Get `docker compose up` working locally first (API + Web + all services)
2. Verify ALL endpoints work: health, auth sign-up/sign-in, GraphQL queries, file upload
3. Run the full user flow locally: signup → workspace → upload → comment → share
4. Only THEN deploy to cloud — should be a single clean deploy
5. Cloud-specific fixes (IAM, secrets, VPC) are the ONLY things to debug remotely
