---
name: feedback_youtube_ideation_flow
description: YouTube video planning flow — ideas → framework check → 25-agent research → packaging alternatives → pick → THEN script. Never write full script before research + packaging lock.
type: feedback
originSessionId: 253c2b81-1a73-45cd-8bff-08654aa3090a
---
When planning YouTube videos (especially for Zeel's channel, Claude-wave content, or any AI-niche video), the mandatory flow is:

1. **User gives topic ideas** (from whiteboard, list, anywhere)
2. **Run the 7-phase ideation/topic framework** — check if each idea fits (BENS filter, outlier shape, brand fit, packaging potential)
3. **Drop ~25 research agents in parallel** — mine what's currently working in the YouTube AI niche: trending videos last 60–90 days, format patterns, packaging motifs (title + thumbnail), outlier data, competitor coverage. YouTube is reverse engineering — what worked recently works again.
4. **Synthesize** into a candidate pool that includes user's original ideas PLUS 3–5 better examples the research surfaced (top-of-funnel, click-winning, differently packaged)
5. **User picks** 2 topics to deep-dive
6. **Packaging lock** (title + thumbnail BEFORE script, playbook's #1 rule)
7. **THEN script**

**Why:** User explicitly corrected the flow 2026-04-23 after I jumped straight from idea → packaging → full script on the "Claude ecosystem" video idea. The correct path requires outlier research BEFORE packaging so we reverse-engineer what's working, not invent in a vacuum. Also echoes prior feedback_remix_not_copy.md — don't generate topics without understanding brand POV AND market context.

**How to apply:**
- NEVER write a full script before (a) outlier research is done and (b) packaging is locked
- NEVER propose topics in a vacuum — always pair with live research on what's trending in the niche right now
- Default agent count: ~25 parallel research agents across format slices (how videos are structured), topic slices (what's popping), creator benchmarks (Dan Martell, Nick Saraev, Jeff Su, emerging creators, Indian market), and packaging/meta slices (thumbnails, titles, duration)
- Each agent writes to a dedicated file in the project's `research/` folder and returns only a short summary to main context (avoid context bloat)
- After synthesis, present candidate pool as: user's originals (framework-scored) + 3–5 research-surfaced alternatives (with outlier data attached)
- Focus lens: top-of-funnel (viral-potential, not search-optimized evergreen), what people will CLICK, how to package differently from the crowd
