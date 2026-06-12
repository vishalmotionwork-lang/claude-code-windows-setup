---
name: Fix root cause, don't patch symptoms
description: When a UI/behavior issue keeps reappearing, find the shared source and fix it there — not the callsite
type: feedback
originSessionId: ca87d7de-a494-4067-8b2c-66c695d1e7ce
---
When user reports a recurring issue ("logo is small", "why different color", "keeps happening"), **do not patch the symptom** (bump this one size, hardcode this one card). Find the shared source and fix it there so the fix propagates to every consumer.

**Why:** User called this out twice in the same session on 2026-04-23:
- "the knowai logo is really small... fix the root cause of this and make the logo normal size so this never happens"
- "why different color, you hardcoded first card, fix the root cause, when new card is created, it should be like the first one only"

**Pattern examples:**
- **Icon sizing**: logomark looks small in sidebar AND favicon AND apple-icon → root cause was SVG `viewBox="0 0 884 888"` with ~28% transparent padding baked in. Fix = crop viewBox tight to the mark. All consumers auto-fix.
- **Card inconsistency**: one card purple, another black → root cause was `getGradientForProject(project.id)` hashing UUIDs to different tint classes as a fallback. Fix = remove the fallback entirely so all cards render `var(--surface-dark)`. Any new project looks identical by default.

**How to apply:**
1. Before editing a specific instance, grep for where the underlying value/asset/helper is defined.
2. Ask: "if I fix it here, will the next new instance also be fixed?"
3. If NO → you're patching a symptom. Walk upstream to the actual source (SVG file, fallback function, token definition, template component).
4. Fix there. Verify every consumer updated.
5. Only fall back to per-callsite patches when the root source is genuinely out of your control (third-party library, user content).

**Anti-pattern:** Bumping `h-7 w-7` → `h-10 w-10` at one callsite, or hardcoding `style={{ background: "var(--surface-dark)" }}` on one card. These won't survive the next addition.

**Red-flag phrases from user that trigger this rule:**
- "why do we keep doing this"
- "fix the root cause"
- "so this never happens"
- "when X is created/added, it should be like Y"
- "you hardcoded"
