---
name: reference_instagram_media_pk_timestamp
description: Instagram reels/clips GraphQL has NO date field — derive post date from media pk (ID timestamp) + skip pinned in chronological scans
metadata: 
  node_type: memory
  type: reference
  originSessionId: a43cc994-ce41-4f21-8206-00dd5227df04
---

When scraping Instagram via its private GraphQL (the `clips__user__connection` /
`timeline_graphql_connection` responses the web app fires), the media objects
carry like_count, comment_count, play_count/view_count, code, media_type — but
**no timestamp field at all** (no `taken_at`, `taken_at_timestamp`, etc.). Reels
payloads (`XDTClipsItemDict`) confirmed empty of any date field.

**Derive the creation time from the media `pk` (or the part of `id` before `_`).**
Instagram media IDs encode the timestamp in the high bits:

```js
// pk is a 64-bit int as a STRING → must use BigInt (exceeds Number.MAX_SAFE_INTEGER)
const ms = (BigInt(pk) >> 23n) + 1314220021721n; // 1314220021721 = IG epoch (ms)
const date = new Date(Number(ms));
```

The shortcode in the URL (`/p/<code>/` or `/reel/<code>/`) is just base64 of the
same pk, so you can decode a date straight from a code too:
```js
const A="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
const pk=[...code].reduce((n,ch)=>n*64n+BigInt(A.indexOf(ch)),0n);
```
Verified: `DY32ySaTh70` → 2026-05-28, `DR54sRYkV4p` → 2025-12-06.

**Gotcha for time-windowed / chronological scans:** the reels tab (and profile
grid) show **pinned** posts first regardless of age. A pinned old reel has a
non-empty `clips_tab_pinned_user_ids` array — skip those when deciding "have I
scrolled past the date window," or an old pinned post stops collection early and
drops in-window items. Profile grid uses a different pinned flag.

Context: built the SortBuddy Brave-extension time-period feature (`~/SortBuddy-dev/`,
unpacked dev copy of store ext `ngbddkjgiahnljjinndalpljlpoeibip`). See
[[feedback_debug_data_pipeline]] — adding the raw-object debug dump is what
surfaced the missing date field instead of guessing.
