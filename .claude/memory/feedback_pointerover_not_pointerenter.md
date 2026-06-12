---
name: Use pointerover (not pointerenter) when wrapper needs to discriminate between hover targets
description: pointerenter doesn't bubble and only fires once at wrapper boundary, so you can't tell which child the user is currently over. pointerover bubbles + fires on every child transition — pair it with `event.target.closest("[data-attr]")` to route hover behavior.
type: feedback
originSessionId: d8cb254e-dd03-4ce3-aeb7-34c23e9bea83
---
When two regions of the same component need different hover behaviors (e.g. card body opens an info panel; an inner subtask tray expands inline only), `onPointerEnter` on the wrapper is the wrong tool:
- `pointerenter` does NOT bubble.
- It fires once when the pointer crosses the wrapper's outer boundary, regardless of which child is under the pointer.
- Subsequent moves between children don't fire it again (pointer never leaves the wrapper).

So you can't disambiguate the hover target. The wrapper's panel opens whether the user entered via the card body or via the inner tray, and once it's open you can't react to "the user moved from card to tray".

**Why:** content-ops kanban hover-expand needed two mutually exclusive hover targets. The user wanted: hover card body → panel opens, hover tray → only tray's subtask list expands (panel stays closed). pointerenter couldn't tell them apart and stopPropagation on children didn't help because pointerenter doesn't propagate anyway.

**How to apply:**
- Use `onPointerOver` on the wrapper. It bubbles + fires on every transition into a child element.
- Mark non-default zones with a data attribute (e.g. `data-no-hover-panel="true"`).
- In the handler, check `e.target.closest("[data-no-hover-panel]")`. If truthy, suppress the default behavior and cancel any pending timer; otherwise fire the default after a hover delay.
- Use `onPointerLeave` (which DOES fire when pointer fully exits the wrapper) for the cleanup case.

```tsx
const handlePointerOver = (e: React.PointerEvent) => {
  const target = e.target as Element | null;
  if (target?.closest("[data-no-hover-panel]")) {
    clearEnterTimer();
    setExpanded(false);
    return;
  }
  if (expanded || enterTimer.current) return;
  enterTimer.current = setTimeout(() => setExpanded(true), 120);
};
```

Performance is fine: pointerover only fires on element-boundary crossings, not on every pointer pixel. Cheap.

Same pattern works for: tooltip-on-some-children-but-not-others, drag-only-from-handle-but-pan-everywhere-else, etc.
