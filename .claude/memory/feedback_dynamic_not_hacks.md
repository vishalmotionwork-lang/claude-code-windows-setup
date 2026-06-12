---
name: Dynamic flows, not hardcoded hacks
description: Always validate the feature flow end-to-end. If it doesn't make sense, pivot — don't paper over with hardcoded values or one-off hacks.
type: feedback
originSessionId: 102d77c7-f100-47a7-a15c-d0a42aa986d2
---
When building a feature:
1. **Validate the full flow first.** Trace the user journey from entry to success. If there's a gap (missing UI, missing endpoint, a step that can't happen), say so and pivot BEFORE writing code.
2. **Dynamic, not hardcoded.** Derive state from data (fps from media_file, fallback from sensible defaults, URLs from endpoints). Never hardcode values that should come from the domain model.
3. **No hacks.** No `setInterval` for display updates, no "pretend it's a version by renaming", no hardcoded gradients-per-id, no fake states. If the clean way is too hard, pause and ask rather than ship a hack.
4. **Pivot openly.** If the research/plan reveals the feature breaks at step 3, surface that. Don't build steps 1-2 and hope the rest works out.

**Why:** Vishal called this out mid-build when I was rushing implementation without validating the full flow. Prior sessions had me hardcoding gradients (`getGradientForProject`), fake versioning via rename, static drag previews that stretched — all shortcuts that had to be torn out.

**How to apply:**
- Before writing code: state the flow from user click → final persisted state. Name each endpoint, file, component involved.
- Call out breakpoints: "if the API doesn't support X, we need to add it, or pivot to Y."
- Prefer adding a real endpoint/schema field over a client-side workaround.
- If something needs a timer, reactive subscription, or event — use the real mechanism (SWR mutate, store subscribe, video events), not polling or `setInterval`.
- When user says "make it dynamic" or "don't hardcode", read it as a standing rule for the whole feature, not just the one line they pointed at.
