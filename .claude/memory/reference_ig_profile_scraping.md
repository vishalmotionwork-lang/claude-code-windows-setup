---
name: reference_ig_profile_scraping
description: "How to enrich IG usernames → profiles at scale cheaply/safely (anonymous endpoint, curl_cffi, rotating residential, hybrid drain)"
metadata: 
  node_type: memory
  type: reference
  originSessionId: e3cee564-d484-4a38-9f01-5d7d19e27121
---

Reusable playbook for turning a list of Instagram **usernames** into full profiles (bio, follower/following/post counts, category, external link, verified, private) — cheaply and without risking a real account. Proven in [[ig-follower-analysis]] (2026-06-04, ~118k followers).

**The endpoint:** `https://www.instagram.com/api/v1/users/web_profile_info/?username=X` with header **`x-ig-app-id: 936619743392459`**. Returns everything in one JSON call, **including for private accounts** (name/bio/counts, just no posts).

**It works ANONYMOUSLY** — no login, no cookies. Confirmed live (natgeo → 200, full data). So you usually need **zero accounts**; only risk is an **IP rate-limit**, never an account ban.

**UPDATE 2026-06-04 (live at scale):** The rate-limit is harsher than "~200/hr" — a single IP gets **soft-blocked after ~80 requests**, returning `401 {"require_login":true,"igweb_rollout":true}` / `"Please wait a few minutes"`. This is **per-IP, not global** — a fresh residential IP gets 200+full-data immediately on retry (proven: home IP walled at req 76, DataImpulse residential IP returned full data same instant). **Critical gotcha: a curl_cffi/requests Session keep-alives to ONE exit IP** — 5 sequential calls = same IP. So a long-lived worker pins one IP and cooks it. **You MUST rebuild the session (new connection = fresh gateway IP) every ~20 requests AND immediately on any 401/429.** With that, wall rate at 40 workers ≈ 2%, all auto-rotated through, 0 losses, ~52k profiles/hr. Without it, every worker dies after ~80 reqs.

**`200 {"status":"ok"}` (empty, no `data.user`) is AMBIGUOUS — do NOT auto-classify as dead (corrected 2026-06-06, @mrnotion.co).** Two distinct causes: (1) genuinely dead/special account (consistent across *fresh* IPs); (2) **AGE-RESTRICTED (25+) profile hit from a FLAGGED IP.** Your home/office IP, once flagged from heavy prior scraping, gets this degraded empty `{"status":"ok"}` for age-restricted profiles **even while normal profiles (natgeo) still return full 600KB data from that same IP** — so a working natgeo test does NOT prove your IP is clean for restricted profiles. Logged-in cookies don't fix it (the login account isn't age-verified 25+; Playwright then renders the literal "You must be 25 years old or over to see this profile" wall). **FIX: hit the anonymous `web_profile_info` AND `feed/user/{uid}` endpoints through the rotating residential proxy — the FIRST fresh residential IP returns full data immediately** (mrnotion.co: 256KB on attempt 1). So before calling any `{"status":"ok"}` dead, retry it through ≥2 fresh proxy IPs. Proxy file: `~/ig-follower-analysis/proxies.txt` (DataImpulse `gw.dataimpulse.com:823`). Shell gotcha: never name a var `UID` (reserved → "failed to change user ID").

**Non-negotiables:**
- **`curl_cffi` impersonating Chrome is MANDATORY** — IG TLS/JA3-fingerprints and blocks plain python-`requests` on request #1. `from curl_cffi import requests; Session(impersonate="chrome124")`.
- **Rotating residential proxies, NOT fixed IPs.** Buy bandwidth (GB), not IPs — the pool auto-rotates millions. **DataImpulse $1/GB, never expires (~$15-20 for 118k).** Datacenter IPs die on request #1; mobile is overkill.
- **No VMs/Docker/anti-detect browsers** — a headless JSON scraper only exposes IP + TLS fingerprint + cookies + headers. Just run N plain Python worker threads, one rotating-gateway proxy, each request a fresh IP. ~40 workers @ ~1.5s delay → ~1.5-2 hr for 118k.
- Running on your **own PC is safe** because all traffic exits through the proxy — your home IP never touches Instagram.

**Error model:** `200`=ok · `404`=deactivated/deleted (store + count, never retry, unrecoverable anywhere) · `429`=rate-limited (re-queue, rotate IP) · `401/403`/HTML=login wall (rotate IP or fall back to a sessionid/paid API). Make `error` rows **retry free on rerun**; only skip `ok`+`not_found`.

**Hybrid = cheapest robust:** free anonymous DIY clears ~80%, then drain only the errored/missing through a pay-as-you-go API. Cheapest paid: **ScrapeCreators ~$0.001-0.002/profile (~$117 for 118k, credits never expire)** or **HikerAPI**. Skip ScrapingDog (~0% IG success), Phantombuster (100/day cap + uses your cookie), Modash/HypeAuditor (enterprise, 1k+ followers only). Total hybrid ~$30-45 vs ~$117 pure-paid.

**What the raw object actually contains (per public account, verified Jun 2026):** beyond the flat fields, `raw.edge_owner_to_timeline_media.edges[]` = up to **12 recent posts**, each with: `shortcode` (→ `instagram.com/p/<sc>`), `thumbnail_src`/`display_url`, `edge_liked_by.count`, `edge_media_to_comment.count`, `edge_media_to_caption` text, `taken_at_timestamp`, `is_video`, `location.name` (geotag!), `edge_media_to_tagged_user`, `coauthor_producers`. **Post geotags are the best location source** (IG has no profile location field) — covered ~2× more accounts than bio parsing in practice. **Anonymous scrape kills viewer-relative fields**: `edge_mutual_followed_by`=empty, `followed_by_viewer`=false, `edge_related_profiles` sparse (need a logged-in sessionid for those).

**Displaying IG images on your own site:** IG **blocks cross-origin hotlinking**. Proxy through **weserv** (`images.weserv.nl/?url=<enc>&output=webp`). For post thumbnails, DON'T store the (huge, expiring) signed URL — render from the shortcode: `.../p/<shortcode>/media/?size=m` through weserv (always fresh, tiny dataset). Note: `img.loading="lazy"` on a detached `new Image()` never fires onload.

**The followers.csv export carries a real follow DATE** (IG "Download Your Information" → `timestamp` column = when they followed, not export date; spans the full follow history). Powers cohort/growth/new-follower analysis.

**⚠️ The DYI follower export UNDERCOUNTS — do NOT treat it as the complete follower list.** Confirmed on @zeeeljain: a year-old mutual follower was 100% absent from the raw export's `followers_*.html` (and his IG id absent everywhere), yet present in the live followers tab. IG's export silently drops some real followers (more likely on large accounts). For a COMPLETE list, scrape the live endpoint with a logged-in sessionid: paginate `https://www.instagram.com/api/v1/friendships/<userid>/followers/?count=50&max_id=<cursor>` (or GraphQL `edge_followed_by`) following the `next_max_id` cursor until exhausted. Export = convenient but lossy; live session = authoritative.

Full worked build (scraper + static Vercel web app over 117k: explorer, filters, geotag location, recent-posts, demand-mining/hidden-VIP/community-map insights, relevance search) documented in [[ig-follower-analysis]] CONTEXT.md.

Related: [[sortbuddy]] (decode IG media `pk` → post timestamp), [[reference_instagram_media_pk_timestamp]].
