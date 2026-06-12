---
name: element-capture-visual-rect-bounded
description: getBoundingClientRect doesn't include shadows or overflowing children. Compute "visual rect" by unioning descendants + parsing box-shadow expansion — but BOUND it (skip fixed-position descendants, clamp overflow tolerance) or you over-expand to portals.
type: feedback
originSessionId: 584b889f-1a76-423c-80b4-c19cbd446ba1
---
When capturing a DOM element as an image, `getBoundingClientRect()` returns just the CSS box. The captured PNG will visually clip:
- Box shadows extending 10–30 px beyond the element
- `filter: drop-shadow(...)` similarly
- Absolutely-positioned children that overflow the parent (badges, tooltips inside the element)

**Why:** Built element-png-capture (May 2026). Iterated through:
1. `getBoundingClientRect` only → shadows cropped ("cutoff")
2. Naive descendant union + shadow expansion → over-expanded to React Portals and accessibility-positioned helpers ("adding too much")
3. Bounded visual rect → balanced

**How to apply (the bounded algorithm):**

```js
function getVisualRect(el) {
  const own = el.getBoundingClientRect();
  const cs = getComputedStyle(el);

  // 1. Shadow expansion, capped (some pages have huge ambient shadows like 0 0 200px)
  const shadowEx = Math.min(60, Math.max(
    parseBoxShadowExpansion(cs.boxShadow),
    parseFilterDropShadowExpansion(cs.filter),
  ));

  let l = own.left - shadowEx, t = own.top - shadowEx;
  let r = own.right + shadowEx, b = own.bottom + shadowEx;

  // 2. Tolerance for overflowing children (badges, tooltips that legitimately extend)
  const tolerance = Math.min(80, Math.max(own.width, own.height) * 0.5);
  const allowL = own.left - tolerance;
  const allowT = own.top - tolerance;
  const allowR = own.right + tolerance;
  const allowB = own.bottom + tolerance;

  for (const d of el.querySelectorAll("*")) {
    const ds = getComputedStyle(d);
    if (ds.display === "none" || ds.visibility === "hidden") continue;
    if (ds.position === "fixed") continue;  // skip portals — they're rendered relative to viewport
    const dr = d.getBoundingClientRect();
    if (dr.width === 0 || dr.height === 0) continue;
    if (dr.right < allowL || dr.left > allowR || dr.bottom < allowT || dr.top > allowB) continue;
    // CLAMP to allowed neighborhood — far-extending children can't blow up the rect
    const cl = Math.max(allowL, dr.left);
    const ct = Math.max(allowT, dr.top);
    const cr = Math.min(allowR, dr.right);
    const cb = Math.min(allowB, dr.bottom);
    if (cl < l) l = cl;
    if (ct < t) t = ct;
    if (cr > r) r = cr;
    if (cb > b) b = cb;
  }

  return { left: l, top: t, right: r, bottom: b, width: r - l, height: b - t };
}
```

**Key bounds (don't skip these):**
- **60 px shadow cap** — protects against huge ambient blurs
- **80 px / 50%-of-element tolerance** — allows legit overflow, blocks far portals
- **Skip `position: fixed` descendants** — they're DOM children but render at viewport coords, often far from parent
- **Clamp descendant rect to allowed neighborhood before union** — hard cap on growth

**Performance caveat:** `querySelectorAll('*')` is slow on huge elements. Skip the descendant walk when `el === document.body || el === document.documentElement` or when descendants > 2000.

**Highlight UX:** for hover (every mousemove), use cheap `getBoundingClientRect`. Switch to `getVisualRect` only for the *selected* element so user sees what will actually be captured.
