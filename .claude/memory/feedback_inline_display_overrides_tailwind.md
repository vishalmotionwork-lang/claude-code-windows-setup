---
name: feedback-inline-display-overrides-tailwind
description: Inline style display always beats Tailwind responsive display utilities like md:hidden — use className for both axes or skip inline display entirely
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5f467972-c098-49fe-95ba-127f3be970ca
---

Inline `style={{ display: "flex" }}` **overrides** any Tailwind responsive class that tries to change display (`md:hidden`, `lg:block`, `hidden md:flex`). Inline styles have higher specificity than class-based stylesheet rules, so the Tailwind `display: none` at md+ never wins.

**Why:** Caught in ecskort-web (`MobileBottomTabs`) where `className="md:hidden"` was paired with inline `display: "flex"`. The bottom nav rendered on desktop because inline `flex` beat the class-level `none`. Vishal reported "bottom navbar is still showing in the desktop view where it shouldn't be" — a direct bug from this pattern. Same antipattern exists in many React projects that mix inline styles with Tailwind responsive utilities.

**How to apply:**
- Never write `className="md:hidden"` + `style={{ display: "X" }}` on the same element. Pick one.
- Cleanest fix: use Tailwind classes for both axes (`className="flex md:hidden"`) and remove the inline `display`. Tailwind's `flex` and responsive variants are standard utilities (not arbitrary values) so they're safe under Tailwind 4 + Turbopack.
- If the layout needs inline styles for other reasons (custom flex direction, gap, etc.), keep them in the `style` prop but leave `display` to the class.
- This pattern fires for any CSS property that has a class equivalent (`display`, `visibility`, `position`, `flex-direction`). Inline always wins.

Related: [[feedback-tailwind4-arbitrary]] (Tailwind 4 + Turbopack only supports standard utilities, so the className-only fix is required, not a preference).
