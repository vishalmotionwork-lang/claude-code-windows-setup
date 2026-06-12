---
name: Skip background revalidate after PATCH when optimistic update already mirrors server state
description: After a successful optimistic PATCH, the trailing background `mutate()` refetch is pure waste — the cache already has the right state. Only revalidate after POST (real id swap) and DELETE (consistency).
type: feedback
originSessionId: d8cb254e-dd03-4ce3-aeb7-34c23e9bea83
---
The standard SWR optimistic-update pattern is:
1. Apply optimistic local update via `mutate(updater, { revalidate: false })`
2. Fire the network request
3. On success, `mutate()` to revalidate from server

Step 3 is where waste hides. For PATCH operations that just edit fields the client already knows about (drag-end positions, title changes, owner picks), the optimistic local update IS the server result. The trailing 40KB GET refetch confirms what we already know.

**Why:** content-ops Priority Board fired a 40KB snapshot GET after every drag, every keystroke, every owner change. Network panel was solid blue. Optimistic updates felt instant locally but the trailing refetch caused a brief data flicker as the cache replaced its in-flight rows.

**How to apply:**
In your shared mutation helper (e.g. `callApi`), only trigger the background revalidate for:
- **POST** — need to swap optimistic temp ids for real server ids
- **DELETE** — consistency check (cascading deletes, FK cleanup)
- **error** — revert to server truth

For PATCH:
- Skip the background revalidate entirely. Trust your optimistic updater.
- Realtime subscriptions (when present) will refresh state when truly needed.

```ts
const callApi = async (url, method, body, optimistic?) => {
  if (optimistic) void mutate(optimistic, { revalidate: false });
  const res = await fetch(url, { method, body: JSON.stringify(body) });
  if (!res.ok) {
    await mutate();  // revert
    return null;
  }
  if (method === "POST" || method === "DELETE") {
    void mutate();  // id swap / consistency only
  }
  return res.json();
};
```

If a PATCH might return server-computed fields the client can't predict (e.g. an `updated_at` timestamp the client cares about for display), update the optimistic updater to set them from the response, OR keep the revalidate for that specific endpoint. Don't blanket-revalidate "just in case".
