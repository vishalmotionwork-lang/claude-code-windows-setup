---
name: feedback-next16-breaking
description: "Next.js 16 breaking changes that bit during ecskort-web port (async params/cookies, proxy.ts rename, font name changes, revalidateTag arg, PPR removed)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 45c76727-0963-4a3d-9ff6-496ec17302a1
---

# Next.js 16 breaking changes — gotchas

When porting to Next.js 16 (2026-05-27 ecskort-web port), these tripped the build despite Server Component intuition:

1. **`params` and `searchParams` are `Promise<...>`** in `page.tsx`, `layout.tsx`, `route.ts`. Must `await` them.
   ```ts
   export default async function Page({ params }: { params: Promise<{ id: string }> }) {
     const { id } = await params; // ← required
   }
   ```
   Run `npx next typegen` to generate `PageProps<'/path'>` helpers.

2. **`cookies()`, `headers()`, `draftMode()` are async.** Must `await`. Synchronous compat from Next 15 is fully removed.

3. **`middleware.ts` → `proxy.ts`.** File convention renamed. Old name still works with deprecation; new name is canonical. No `runtime` export needed — proxy is always edge.

4. **`revalidateTag` requires a second arg** specifying `cacheLife` profile:
   ```ts
   revalidateTag("posts", "max"); // ← second arg now required
   ```
   For immediate expiration, use `updateTag` in Server Actions.

5. **Google font name changes** between Next versions — `Big_Shoulders_Display` became `Big_Shoulders`. Check `node_modules/next/dist/compiled/@next/font/dist/google/index.d.ts` when a font fails to import.

6. **Turbopack is default** for both `next dev` and `next build`. No `--turbopack` flag needed. Custom webpack config fails build — use `--webpack` to opt out, or migrate.

7. **PPR (Partial Prerendering) flag removed** — replaced by `cacheComponents` config.

8. **Async parameters in image generation** — `opengraph-image`, `twitter-image`, `icon`, `apple-icon` receive `params` and `id` as Promises.

**Why**: Next 16 standardized async request-time APIs to enable streaming + server components without sync escape hatches. Compatibility shims removed.

**How to apply**: When scaffolding a fresh Next 16 app, read `node_modules/next/dist/docs/01-app/02-guides/upgrading/version-16.md` BEFORE writing pages — saves debugging time. Run `npx next typegen` to get `PageProps<...>`. Audit any `params.x` access — must be `(await params).x`. Audit any `cookies().get(...)` — must be `(await cookies()).get(...)`.
