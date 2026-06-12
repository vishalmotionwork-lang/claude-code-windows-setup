---
name: YouTube channel view-counts via yt-dlp need per-video fetch
description: yt-dlp --flat-playlist returns NA for view_count on YouTube channel /videos pages because YouTube switched to lockupViewModel. Must fetch per-video metadata in parallel to rank by views.
type: feedback
originSessionId: 1d9c49b6-d6e4-4203-a8dc-2421da3d7863
---
YouTube's `/videos` page no longer exposes `viewCountText` via the legacy `videoRenderer`. The new container is `lockupViewModel`, which omits view counts from the playlist-level payload. So:

```bash
# THIS RETURNS NA FOR view_count:
yt-dlp --flat-playlist --print "%(view_count)s|||%(id)s|||%(title)s" "https://www.youtube.com/@channel/videos"
```

**Why:** YouTube ships rendered HTML where the videos grid uses `lockupViewModel` JSON. yt-dlp's `youtube:tab` extractor reads from that without back-filling view counts from a separate API call. Sort by upload date works, sort by views does not.

**Workaround that actually works:**
```bash
# Step 1: list IDs (flat-playlist is fine for IDs)
yt-dlp --flat-playlist --print "%(id)s" "https://www.youtube.com/@channel/videos" > ids.txt

# Step 2: per-video metadata in parallel (P=12 is safe, ~3min for 286 vids)
cat ids.txt | xargs -P 12 -I {} sh -c 'yt-dlp --no-warnings --print "%(view_count)s|||%(id)s|||%(title)s|||%(duration)s|||%(upload_date)s" "https://www.youtube.com/watch?v={}"' > videos.tsv

# Step 3: sort + top N
sort -t '|' -k1 -nr videos.tsv | head -10
```

**Why this rule matters:** if you don't know this, you'll spend 20 min trying `?sort=p` (popular tab) and various URL formats, all returning NA. The per-video fetch is the only reliable path right now (May 2026).

**How to apply:** any time the task is "top N videos by views" or "most-watched videos of a channel" — skip flat-playlist for view counts, go straight to parallel per-video fetch. For ~300 videos with P=12 it's ~3 minutes total.

Tested with yt-dlp 2026.02.04 on `@nicksaraev` channel (286 videos). yt-dlp version >90 days old triggers a warning — may also need `pip install -U yt-dlp` if YouTube changes the page again.
