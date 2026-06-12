---
name: dnd-kit drag handle — don't blanket-stopPropagation on click-only buttons
description: PointerSensor's distance:6 already separates click from drag; intercepting pointerdown on every child kills drag entirely
type: feedback
originSessionId: a7280e32-ea69-46c6-bed0-57ef46b21ddd
---
In a dnd-kit Sortable where the drag listeners sit on a container, blanket-adding `onPointerDown={e => e.stopPropagation()}` to every interactive child kills drag entirely — there's nowhere left for pointerdown to bubble to the parent. This is exactly what broke Priority Board canvas drag: header was 100% buttons (chevron, title, owner pill, ⋮), each stopping pointerdown, so dnd-kit never received a single pointerdown.

**Why:** PointerSensor's `activationConstraint: { distance: 6 }` already distinguishes a stationary click (fires `onClick`, no drag) from movement (starts drag). Click-only buttons therefore don't need to intercept pointerdown — they'll fire onClick fine even if the parent's drag listener is also reading pointerdown. The two coexist via the activation constraint.

**How to apply:**
- Click-only buttons (toggle, navigate, fire action): NO pointerdown handler. Let the event bubble to dnd-kit.
- Dropdown / popover triggers that open a menu on pointerdown: DO `stopPropagation` — they actually need to consume the event to open immediately, not after a 6px movement budget expires.
- Active form inputs (textarea, input being typed in): DO `stopPropagation` — typing-while-dragging would feel awful.
- Resize / scroll / native-drag handles inside the sortable: DO `stopPropagation` (or use a different sensor scope).

Set `activationConstraint: { distance: 6 }` on the PointerSensor at the DndContext level. Test the click vs drag UX first — if a stationary click still drags, you've over-stopped propagation OR the constraint is missing.
