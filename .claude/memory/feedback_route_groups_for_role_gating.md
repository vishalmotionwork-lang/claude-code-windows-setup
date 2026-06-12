---
name: feedback-route-groups-for-role-gating
description: "Use Next.js App Router route groups with role-checking layouts to gate multiple routes at once, instead of adding inline `notFound()` calls to every page"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5f467972-c098-49fe-95ba-127f3be970ca
---

When you have many role-locked routes that should 404 for the wrong role, **use a route group with a role-checking layout** instead of duplicating `const role = await getRole(); if (role !== "X") notFound()` at the top of every page.

**Why:** In ecskort-web's unified `/account/*` shell, 13 routes were model-only, 2 were member-only, 5 were agency-only. Inline guards meant 20 file edits + a maintenance burden. Route groups make it one layout file per role bucket. Vishal explicitly approved this pattern via QA — code-reviewer flagged the missing guards, route groups closed the gap in 3 layout files.

**How to apply:**
- Create a route group folder like `(model-only)/`, `(member-only)/`, `(agency-only)/` inside the parent path (e.g., `/account/(model-only)/stories/page.tsx`). The parentheses make Next ignore the folder in the URL.
- Drop a `layout.tsx` in the group folder:
  ```ts
  import { notFound } from "next/navigation";
  import { getRole } from "@/lib/auth/role";
  export default async function ModelOnlyLayout({ children }) {
    const role = await getRole();
    if (role !== "model") notFound();
    return <>{children}</>;
  }
  ```
- Move role-locked routes inside the group. URLs do not change.
- Shared routes (that any role can hit) stay outside the group and either dispatch on role (rendering different content) or render content all roles can see.
- This works because Next.js route groups are layout-scoping primitives — they're invisible to the URL but they DO compose layouts.

**When NOT to use:**
- If only 1-2 routes are role-locked, inline `notFound()` is fine.
- If the page itself must do role dispatch (render different content per role at the same URL), use a single page with `if (role === "X") return <XView />` — not a group.

Related: this is the cleanest equivalent of NestJS guards or Rails `before_action :authorize` for App Router. Layout-level gating + 404 instead of redirect is correct for "this URL doesn't exist for you" semantics — redirect would imply the URL exists but you're blocked.
