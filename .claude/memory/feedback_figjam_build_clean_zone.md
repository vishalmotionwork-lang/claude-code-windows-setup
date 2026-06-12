---
name: feedback_figjam_build_clean_zone
description: "Before building on an existing FigJam file, scan ALL page children (first scan can be stale) and build only in verified-empty space — overlapping existing sections absorbs/loses your nodes."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 55a27296-8750-4e0d-8733-eb9345020251
---

When building a new FigJam board/section on a file that already has content, NEVER assume the canvas
is empty from a single scan — the plugin's first `currentPage.children` read after (re)connect can be
STALE and return only one node. Re-scan via `loadAllPagesAsync()` + list every top-level SECTION with
bounds BEFORE placing anything.

**Why:** building cards/sections that overlap an existing section causes FigJam to ABSORB your nodes
into that section on a later re-render — your `wrapBand()` section dissolves and the work is lost
(node IDs even get reassigned). On the 9x-teardown go9x file this cost a whole rebuilt band: the page
already held the user's ZEEL board + a tall BenAI "TEARDOWNS" section, but the first scan showed only 1
node, so the new board was built at x40 right on top of them.

**How to apply:**
1. First action on any existing FigJam file = enumerate all sections + bounds; compute the real
   occupied bbox (it can be huge — 10,000px+ wide/tall).
2. Pick a clean origin OUTSIDE every existing section (usually far right, x > max-right + 200, or far
   below). Build the whole new board as a vertical stack of sections there.
3. If you already overlapped and nodes vanished, relocate surviving sections by setting `section.x/y`
   into clean space and rebuild the lost ones there — don't fight the absorption in place.
4. Never delete/extract from the user's existing sections to "recover" — leave their boards untouched
   and rebuild yours clean.

Related: [[reference_figjam_section_coords]], [[feedback_figjam_autolayout_over_miro]], [[feedback_no_silent_membership_changes]].
