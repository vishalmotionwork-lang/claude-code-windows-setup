---
name: College report revisions
description: When the user shares handwritten college/guide notes for a thesis-style report, parse each item literally, separate sectional removal from word removal, and preserve factual narrative
type: feedback
originSessionId: f12caccb-dc9b-45eb-ad50-76d514d6b5cc
---
When the user shares handwritten/photographed notes from their college guide or coordinator about a B.Tech / thesis-style project report:

**Rule**: Each numbered item is a discrete edit. Parse them one by one. Distinguish "remove this section" (delete the heading + body, renumber) from "remove this word/concept" (only delete where the concept is the subject, leave incidental factual mentions alone).

**Why**: On 2026-04-28 the MeetPilot AI B.Tech report revision pass had 5 numbered changes plus a "not required in DOCX" header. Items like "Speech diarization (Remove) from Lit (Identified Research gap)" needed careful interpretation: the user wanted Section 2.8 (Speaker Diarisation Future Scope Survey) deleted entirely from the Lit Survey, AND the closing reference in §2.10. But "calibrated SVM" mentions elsewhere in the report were factual descriptions of the deployed model — those stayed. Same logic for "Node.js Remove from Software Req" — drop from Ch 3.8 software stack table, but leave incidental Ch 5 implementation narrative alone unless it's redundant.

**How to apply**:
- Read every numbered note as a discrete TaskCreate item before starting work
- For "remove X from Y": ask whether "X" is a section title or a topic word. Section title = delete heading + body + renumber subsequent sections + update TOC + fix cross-references. Topic word = delete only where X is the subject/focus.
- Front-matter notes ("Not Required in DOCX") usually mean physical pages bound separately; the DOCX needs structural changes (section setup, page numbering origin, TOC entries dropped).
- After deletions, audit: grep for cross-references ("Section X.Y", "surveyed in", "as discussed in") and fix dangling pointers.
- TOC tables built as static `add_table()` won't refresh on F9 — flag this if the user expects Word to re-paginate.
- After report-side changes that drift from deployed app reality (e.g., Brevo replacing Gmail SMTP), call out the gap explicitly so the app-side migration doesn't get forgotten.
