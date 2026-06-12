---
name: dnd-kit DragOverlay is mandatory for cross-container drag
description: dnd-kit's useSortable alone keeps the dragged item pinned to its source DOM slot — for cross-frame/column moves the user sees nothing follow the cursor. Always pair with `<DragOverlay>`.
type: feedback
originSessionId: d8cb254e-dd03-4ce3-aeb7-34c23e9bea83
---
When dragging items between containers in dnd-kit (e.g. cards across kanban columns, cards across react-flow frames, items between sortable lists), `useSortable` ONLY transforms the item within its own container's DOM. It can't relocate the DOM node to a different parent. So during cross-container drag the source slot just fades (opacity ~0.4) and nothing visibly follows the pointer to the target — looks like the card disappeared mid-move.

**Why:** content-ops Priority Board users couldn't see what they were dragging when moving cards between frames. Source card faded in place, target frame highlighted, but no visible card under the cursor.

**How to apply:**
- Whenever a `<DndContext>` spans multiple `<SortableContext>` containers (cross-list drag) OR cards/items can be dropped onto a non-sortable drop target, render a `<DragOverlay>` inside the context.
- Track the active drag id via `onDragStart` (`setActive(e.active.id)`), clear it via `onDragEnd` and `onDragCancel`.
- Always clear the active id FIRST in `onDragEnd` (before any early returns) so the overlay always vanishes on drop.
- Use `dropAnimation={null}` to suppress dnd-kit's default drop-snap animation when you have an optimistic-update pattern that already moves the real card to the new spot.
- The overlay child can be a simplified preview (title + accent border + drop-shadow) rather than a full card render — cheaper and reads cleaner.

```tsx
<DndContext onDragStart={(e) => setActiveId(String(e.active.id))} onDragEnd={(e) => { setActiveId(null); /* persist */ }} onDragCancel={() => setActiveId(null)}>
  ...
  <DragOverlay dropAnimation={null}>
    {activeId ? <CardPreview ... /> : null}
  </DragOverlay>
</DndContext>
```

Within the same single `<SortableContext>` (vertical reorder within one list), useSortable's transform IS enough — no overlay needed. Overlay is for cross-container moves.
