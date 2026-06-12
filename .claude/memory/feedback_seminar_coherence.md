---
name: Seminar/long-form docs need coherent rewrite, not patchwork expansion
description: When generating long-form academic/template documents (seminars, reports, theses), if the draft is weak or short, rewrite the whole thing as one coherent narrative — don't glue expansion paragraphs onto existing sections.
type: feedback
originSessionId: 8166891a-2f45-407c-b86b-eae599581704
---
When generating long-form template-bound documents (B.Tech. seminars, theses,
formal reports), if the existing draft is short or weak, **rewrite from
scratch as a single coherent narrative** rather than refining and expanding it
section-by-section.

**Why:** Vishal explicitly flagged this on the model_drift seminar after I had
applied 4 idempotent rounds of expansion paragraphs to bring a 30-page draft
to 47 pages. The result reached the page count but read as patchwork —
"bits and pieces, not the whole thing." His exact words: "the whole doc
should make sense, not just bits and pieces, it should make sense of the
whole thing, if I am reading I should get complete knowledge about it while
following the guidelines 100%". The rewritten version (single linear
narrative, every chapter transitions from the previous one, unified notation
introduced once and used throughout) hit 45 pages on the second build and
satisfied him on the first read.

**How to apply:**

1. **For new seminar topics**: copy `~/btech-seminar-generator/scripts/build_world_models_seminar.py` as a template. Replace topic-specific prose, tables, figure captions, ToC entries, abbreviations and references. Do NOT mix-and-match content from different sources.

2. **For weak drafts (≤35 pp, broken heading typography)**: don't run `refine_seminar.py`. Rewrite from scratch using the build-script pattern.

3. **Verify page count via Pages.app** (osascript), never via char/word-count heuristics — they under-estimate by 30-50% for technical documents with tables, headings and page-breaks.

4. **Coherence checklist** for the rewrite:
   - Every chapter opens by recalling where the prior chapter left off
   - Every section closes with a hand-off into the next
   - Cross-references are explicit ("as introduced in 2.1", "we return to this in 4.3")
   - Notation introduced once, used consistently
   - Same authorial voice top to bottom — single linear pass should leave the reader with complete knowledge

5. **45 pages = ~12,000 words body + ~7 pages front matter + ~3-4 pages references.**

**Toolkit lives at**: `~/btech-seminar-generator/` with project memory at
`memory/projects/btech-seminar-generator/{CONTEXT,SESSION}.md`.
