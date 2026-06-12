---
name: reference_meta_ad_library_competitor
description: "Pull a competitor's Meta ad creatives from the PUBLIC Ad Library — resolve their advertiser Page ID via the keyword-box typeahead, then view_all_page_id"
metadata: 
  node_type: memory
  type: reference
  originSessionId: d68763b8-3f01-4f67-9475-b34987d96f6e
---

The Meta Ad Library is **publicly searchable per advertiser** — no login needed (corrected 2026-06-06, @mrnotion.co; I had wrongly claimed only EU/political ads are searchable). Anyone can pull a competitor's live ad creatives.

**Workflow (Playwright, public, no cookies):**
1. Go to `https://www.facebook.com/ads/library/?active_status=all&ad_type=all&country=US&media_type=all`.
2. The search needs two dropdowns set first: **country** (defaults), then click **"Ad category" → "All ads"** (the keyword box is inert until a category is chosen; its placeholder misleadingly reads "Choose an ad category").
3. Click the keyword input (`input[placeholder*='keyword' i]`), type the brand (e.g. "Mr. Notion"). The typeahead returns a **"Advertisers"** group under the keyword option — each entry shows page name · followers · @handle (e.g. `Mr.Notion · @mrnotion.co · 102.2K followers`). Iterate `[role=option]`, click the one whose text matches the handle.
4. That navigates to `...?view_all_page_id=<PAGE_ID>...`. Grab the **Page ID** from the URL. Then hit it directly for any country: `https://www.facebook.com/ads/library/?active_status=all&ad_type=all&country=ALL&view_all_page_id=<PAGE_ID>&media_type=all`.
5. Scroll to lazy-load ad cards; collect creative images via `img` with `naturalWidth>=200` and `scontent`/`fbcdn` in src; download (skip <15KB = icons). The **About tab** gives "Page created on DATE" + managing-org/country (page transparency).

**Key facts about coverage:**
- A page appears as a searchable **advertiser only if it has run ads** — so finding the advertiser = confirmed they advertise.
- For **non-EU commercial** advertisers the library only retains ads **while ACTIVE**. Paused/finished commercial creatives drop off. EU/UK ads + social-issue/political ads are kept historically (7 yrs). So a US e-commerce advertiser between campaigns shows **0 ads** even though they advertise — check `Active` count and revisit when live.
- Resolving the Page ID by guessing from the FB page DOM is unreliable (login-walled); the typeahead-select flow is the reliable path.

Worked example: @mrnotion.co → advertiser "Mr.Notion", **Page ID 147032665166037**, created 31 Oct 2023, 0 active ads on 2026-06-06 (swept US/GB/CA/AU/IN/AE/ALL). Scraper: `~/creator-analysis/scripts/adlibrary.py`. Related: [[reference_ig_profile_scraping]], [[feedback_creator_analysis_full_coverage]].
