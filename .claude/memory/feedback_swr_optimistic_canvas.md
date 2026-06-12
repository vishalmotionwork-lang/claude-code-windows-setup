---
name: Don't await snapshot revalidate after every action — use optimistic SWR mutations
description: Awaiting mutate() blocks the UI on a full network round-trip; pass an updater for instant local update
type: feedback
originSessionId: a7280e32-ea69-46c6-bed0-57ef46b21ddd
---
Pattern that wrecked perf on the content-ops Priority Board canvas: every action handler did `await callApi(...)` which internally did `await onSnapshotMutate()` — and `onSnapshotMutate` called SWR's `mutate()` with no args, forcing a full revalidate. Each drag-end / add card / patch field paid a ~40KB snapshot refetch + re-render before the UI updated. Drag visually snapped back to old position until refetch landed; users called it "broken".

**Why:** SWR's `mutate(key)` with no updater forces a network refetch and waits for it. The await chain bubbles all the way up so the click handler doesn't return until the refetch completes. The user sees a blank latency window between click and visual response.

**How to apply (the canvas pattern):**
1. Wrap parent's `mutate` so it accepts an optional updater:
   ```ts
   onSnapshotMutate(updater?) => updater
     ? mutate(updater, { revalidate: false })  // local-only, instant
     : mutate()                                  // full background refetch
   ```
2. Each mutation handler computes an optimistic local update:
   ```ts
   onPatchCard(id, patch) => callApi(url, "PATCH", patch, "update card",
     (s) => s ? { ...s, cards: s.cards.map(c => c.id === id ? { ...c, ...patch } : c) } : s
   );
   ```
3. callApi shape:
   - apply optimistic updater (no await)
   - fetch
   - on success: `void onSnapshotMutate()` — non-awaited background revalidate so server state eventually wins (fixes temp-id swaps and races)
   - on error: `await onSnapshotMutate()` — force a full refetch to revert
4. For inserts use temp ids like `temp-card-${random}` so React keys are stable until real id arrives.

Cost: handler code is verbose because each updater spells out the local mutation. Worth it. The UI feels native instead of network-bound.
