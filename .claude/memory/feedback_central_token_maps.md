---
name: Centralize per-type tokens (labels, accents, hints) in one map
description: When a feature has N variants (link types, stage types, etc.) with per-variant labels/colors/copy, define them as Records keyed by the type — NEVER duplicate the literals at callsites
type: feedback
originSessionId: ea0dcdd4-bfdb-4e44-be5a-4084fcba94e6
---
When a feature has multiple variants — link types, stage types, role
types, etc. — and each variant needs UI copy or accent colors, define
them as `Record<VariantKey, T>` constants in one place (typically
`lib/types.ts`). Callsites then read from those maps. Never let
hex colors, copy strings, or icon choices live as literals at the
callsite, and never duplicate the same literal across multiple files.

**Why:** content-ops shipped a 3-link-bucket feature today. The first
agent generated correct code but hardcoded `#a78bfa`/`#f59e0b` accent
literals in BOTH `components/task/links.tsx` AND
`app/tasks/new/page.tsx`. Adding a new bucket later would need
edits in both files; tweaking the violet would mean a search-and-replace
hunt. After the user's "modular over hardcoded" reminder, I lifted
them into `LINK_TYPE_ACCENTS`/`LABELS`/`HINTS` Records — both files
now read from the same map and a `hexToRgba` helper derives header
tints. Callsites only know the type key.

**How to apply:**
- For any per-type UI surface, define `LINK_TYPE_ACCENTS: Record<LinkType, string>`,
  `LINK_TYPE_LABELS: Record<LinkType, string>`, etc. alongside the type.
- Component callsites: `accent={LINK_TYPE_ACCENTS[linkType]}` — never
  `accent="#f59e0b"`.
- Empty-state hint, icon, header tint: derive from the same map (color
  via `hexToRgba(LINK_TYPE_ACCENTS[type], 0.06)` etc.) so the variant's
  visual identity is one decision, one place.
- Apply this for stages too — `STAGE_LABELS`, `STAGE_COLOR_TOKENS`,
  `STAGE_BADGE_VARIANTS` already follow this pattern in lib/types.ts.
  Anything new should match.

The instinct: when an agent's output has a hex color literal more than
once, or the same copy string in two files, refactor it into a typed
Record before committing.
