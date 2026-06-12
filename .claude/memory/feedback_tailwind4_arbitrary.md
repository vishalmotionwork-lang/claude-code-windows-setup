---
name: tailwind4-arbitrary-values
description: Tailwind 4 with Turbopack does NOT generate arbitrary value classes (w-[40px], w-[18%]) in production builds
type: feedback
---

Tailwind 4 arbitrary values like `w-[40px]`, `w-[18%]` work in dev mode (JIT on-the-fly) but are NOT included in production CSS bundles when using Turbopack.

**Why:** Discovered during HireFlow deployment — table columns had no widths in production, causing Tier column to be pushed off-screen. Multiple deploy cycles wasted.

**How to apply:**
- Always use standard Tailwind classes (`w-10`, `w-24`, `w-36`, `max-w-48`) instead of arbitrary values
- For precise widths that don't have standard classes, use inline `style={{ width: "40px" }}` instead
- After building, verify critical classes exist: `grep "class-name" .next/static/chunks/*.css`
- For table column widths specifically, use `<colgroup>` with inline styles — most reliable approach
