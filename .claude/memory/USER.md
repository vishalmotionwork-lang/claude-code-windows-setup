---
name: User Profile
description: Who Vishal is, how he works, stack prefs, hard rules (Priority 0 — loaded every session)
type: user
---

## Who
- **Vishal** — Motion Designer, Lead Video Editor, Creative Director at KnowAI
- NOT a founder — key team member who also builds platforms the company needs
- Based in Ahmedabad

## KnowAI Leadership
- **Zeel** — Co-founder, has her own IP (@zeeel.ai), public face for content/brand
- **Nikhil** — Co-founder, back-face operator (funding, strategy, business). The main guy alongside Zeel.
- Vishal reports to them, but operates with high autonomy on creative + dev

## What I Do at KnowAI
- Motion design, lead video editing, creative direction (primary roles)
- Platform development — builds internal tools the company needs (HireFlow, DaduOS, Beacon, Marqit, etc.)
- Recruiting — especially talented video editors ("we need an army of talented editors")
- Multiple projects in parallel (23+ tracked)

## How I Work
- Build fast, ship fast, iterate — don't over-plan
- Quality matters — no half-baked features, but don't gold-plate
- When I say redo/rebuild, just ask what I want — don't argue
- Always save context — everything must be resumable across sessions
- TDD approach, 80% coverage target

## Stack Preferences
- Next.js + React + TypeScript + Tailwind CSS 4
- Supabase (auth + DB + realtime) over Clerk/Neon/Firebase
- Drizzle ORM over Prisma (smaller bundle)
- Server actions over REST API routes
- shadcn/ui v4 (Base UI, no asChild)
- Anthropic SDK installed: Python (anthropic v0.86.0) + Node.js (@anthropic-ai/sdk global)
- Python: system Homebrew (3.14), needs --break-system-packages for pip installs

## Hard Rules
- Tailwind 4: standard classes only, no arbitrary values (broken in prod with Turbopack)
- Pencil .pen files: never R() groups with working children
- Vercel: never connect GitHub without verifying identity/permissions — use CLI deploy
- GSD active? SESSION.md = human context only, STATE.md = execution truth
- Suggest gstack tools after execution, never auto-chain
