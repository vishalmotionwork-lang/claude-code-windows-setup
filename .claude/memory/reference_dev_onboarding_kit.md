---
name: Dev Onboarding Kit
description: Reusable kit at ~/dev-onboarding-kit/ for safely onboarding any developer to any of Vishal's apps without giving production access
type: reference
originSessionId: 82d6b6a1-ac6f-411c-b449-104333846bd7
---
# Dev Onboarding Kit

Location: `~/dev-onboarding-kit/`

A complete kit for onboarding any developer (full-time, freelance, agency) to any KnowAI/DaduOS/ZeelOS/etc app safely. Created 2026-05-04.

## Files

### Part 1 — Onboard the person (legal, access, comms)

| File | Purpose |
|------|---------|
| `README.md` | Overview |
| `01-CHECKLIST.md` | Master 9-phase runbook |
| `02-ACCESS-MATRIX.md` | Per-tool grant table (GitHub, Vercel, Supabase, Stripe, AI providers, etc.) |
| `03-NDA-IP-ASSIGNMENT.md` | Legal template (have lawyer review before first use) |
| `04-DEVELOPER-WELCOME.md` | Paste-ready welcome message |
| `05-DEV-RULES.md` | The 10 hard rules + working principles |
| `06-BACKUP-BEFORE-HANDOFF.md` | Pre-handoff backup checklist (code, DB, storage, env, DNS, etc.) |
| `07-github-setup.sh` | gh CLI script — branch protection, PR rules, security settings |
| `08-env.example` | Generic .env.example with all common keys |
| `09-PR-TEMPLATE.md` | Drop into `.github/pull_request_template.md` |
| `10-TASK-TEMPLATE.md` | Format for assigning tasks |

### Part 2 — Make codebase ready (git, CI, test, build, deploy)

| File | Purpose |
|------|---------|
| `11-TECH-READINESS.md` | 7-tier "is your repo ready for a dev?" checklist — run BEFORE hiring |
| `12-REPO-README-TEMPLATE.md` | Template README section: getting started, scripts, structure, troubleshooting |
| `13-CI-WORKFLOW.yml` | GitHub Actions: lint + types + unit + integration + build + E2E + secret scan |
| `14-TESTING-STRATEGY.md` | Three-layer pyramid (unit/integration/E2E) with examples |
| `15-BUILD-DEPLOY.md` | Build + deploy pipeline, three environments, rollback, migrations, safety gates |

## Core principle

> Give them enough access to *build*, never enough to *destroy*.

Production DB, prod env vars, payment keys, domain/DNS = NEVER granted.
Staging-only access for everything.

## How to use for a specific dev

1. **First**, audit codebase with `11-TECH-READINESS.md` — fix Tier 1-3 gaps before hiring
2. Walk through `01-CHECKLIST.md` Phase 1 (verify identity)
3. Sign `03-NDA-IP-ASSIGNMENT.md` BEFORE any access
4. Run `06-BACKUP-BEFORE-HANDOFF.md` end-to-end
5. Run `./07-github-setup.sh <owner/repo>` to lock branches
6. Drop `13-CI-WORKFLOW.yml` into `.github/workflows/ci.yml` if not already present
7. Send filled-in `04-DEVELOPER-WELCOME.md`
8. Hand them their first task using `10-TASK-TEMPLATE.md`

## When to update

- After first real onboarding: incorporate any gaps you hit
- When adding a new tool/service to the stack: add row to `02-ACCESS-MATRIX.md`
- When lawyer reviews NDA: replace `03-NDA-IP-ASSIGNMENT.md` with their version
- When stack changes (e.g. switch from Bun to pnpm): update `12-REPO-README-TEMPLATE.md`, `13-CI-WORKFLOW.yml`
