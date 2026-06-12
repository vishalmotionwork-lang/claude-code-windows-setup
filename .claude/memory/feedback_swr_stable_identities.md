---
name: SWR returns new array refs on every revalidate — React.memo never skips without identity recycling
description: SWR doesn't preserve object identity between fetches; new array refs + new row objects bust React.memo even when content is identical. Use a ref-held Map<id, prev> + shallowEqual to recycle previous object refs across refreshes.
type: feedback
originSessionId: d8cb254e-dd03-4ce3-aeb7-34c23e9bea83
---
`useSWR<T[]>` returns a new array reference on every revalidate. Even rows whose fields are byte-identical get new object references. Components wrapped in `React.memo` see the prop change and re-render, defeating the optimization.

This is the silent killer of "I added React.memo and it still re-renders everything."

**Why:** content-ops Priority Board (90 subtasks × 12 cards × 3 frames) was re-rendering EVERY row on every snapshot tick. React.memo on FrameNode/CardNode/SubtaskRow looked correct but did nothing because every prop was a new reference.

**How to apply:**
At the top of the component that owns the SWR data, derive ref-stable maps using a ref-held cache + shallowEqual:

```ts
const stableCardsRef = useRef(new Map<string, Card>());
const cardsByFrameId = useMemo(() => {
  const next = new Map<string, Card>();
  const prev = stableCardsRef.current;
  const grouped = new Map<string, Card[]>();
  for (const c of snapshot.cards) {
    const cached = prev.get(c.id);
    const stable = cached && shallowEqual(cached, c) ? cached : c;
    next.set(c.id, stable);
    const list = grouped.get(stable.frameId) ?? [];
    list.push(stable);
    grouped.set(stable.frameId, list);
  }
  stableCardsRef.current = next;
  return grouped;
}, [snapshot.cards]);

function shallowEqual<T extends object>(a: T, b: T): boolean {
  if (a === b) return true;
  const ak = Object.keys(a) as (keyof T)[];
  if (ak.length !== Object.keys(b).length) return false;
  for (const k of ak) if (a[k] !== b[k]) return false;
  return true;
}
```

Apply the same pattern to `members`, `subtasks`, `checklist`, and any other arrays passed down to memoized children.

Without this, `React.memo` on row components is decorative — it WILL run its component body every render. Don't waste time wrapping rows in memo unless you've fixed identity stability first.

Same applies to TanStack Query, Apollo, raw fetch caches — anything that returns fresh objects per fetch.
