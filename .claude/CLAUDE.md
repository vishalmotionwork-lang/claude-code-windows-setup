# Global Operating Rules

> This is your global memory, loaded every session. File-based memory only
> (no Redis/Qdrant). Paths use `~` = your home folder
> (Windows: `C:\Users\<you>`).

## Startup Protocol

**BLOCKING — before your first response to the user, every session:**

1. Read `~/.claude/memory/MEMORY.md` — the index. Note every `feedback_*.md`.
2. Read `~/.claude/memory/USER.md` — who the user is, how they work, hard rules.
3. Read **ALL** `~/.claude/memory/feedback_*.md` — these are corrections from past
   sessions. Apply them BEFORE doing any work. Skipping them = repeating mistakes
   the user already corrected.
4. Read `~/.claude/memory/projects/REGISTRY.md` — the project list.

**Then respond:**

5. Ask which project they're working on (show top 5 by last-touched). If they
   already named one, skip the question and load it.
6. Load that project's `~/.claude/memory/projects/<name>/CONTEXT.md` (stack, URLs,
   commands) and `SESSION.md` (last state, next steps).
7. Confirm: "Last time we [summary]. Continue, or different task?"

If the user names a project not in REGISTRY, create
`~/.claude/memory/projects/<name>/` (CONTEXT.md, SESSION.md, DECISIONS.md as needed)
and add a row to REGISTRY.md immediately.

## Self-Learning Rule

After ANY correction, pushback, or preference the user expresses:
1. Save it as `~/.claude/memory/feedback_<topic>.md`
2. Frontmatter: `name`, `description`, `type: feedback`
3. Body: what went wrong, the rule for next time, and why.
4. Add a one-line pointer to `~/.claude/memory/MEMORY.md`.
5. Confirm to the user: "Saved as rule: [one-liner]".

Never put project-specific context in MEMORY.md — each project owns its folder.

## Project Memory Structure

```
~/.claude/memory/
├── MEMORY.md            index (always read first)
├── USER.md              user profile + hard rules
├── feedback_*.md        correction rules (read ALL every session)
├── reference_*.md       reusable technical know-how
└── projects/
    ├── REGISTRY.md      project list + last-touched dates
    └── <name>/
        ├── CONTEXT.md   stack, URLs, commands (load when project selected)
        ├── SESSION.md   last state + next steps (load right after)
        └── DECISIONS.md architecture choices (load only when task needs it)
```

## Session End Protocol

When wrapping up (user says bye / context getting long):
1. Update the active project's `SESSION.md` (what was done, current state, next steps, blockers).
2. Bump its last-touched date in `REGISTRY.md`.
3. Confirm: "Session saved. Next time I'll pick up from [summary]."

## Coding Rules (apply to all code)

- **Immutability**: return new objects, never mutate in place.
- **Small files**: 200–400 lines typical, 800 max. Many small > few large.
- **Error handling**: handle explicitly at every level; never silently swallow.
- **Input validation** at every system boundary; never trust external data.
- **Security**: no hardcoded secrets — env vars / secret manager only. Validate
  required secrets at startup. Parameterized queries. Sanitize HTML.
- **Permissions/roles**: server-side only; frontend asks the server, never holds role lists.
- Full language-specific standards live in `~/.claude/rules/` (common + per-language).

## Workflow Rules

- **Research & reuse first**: `gh search code/repos`, vendor docs, package registries
  before writing net-new code. Prefer porting a proven approach.
- **Plan → TDD (tests first, 80% coverage) → code review → commit** for features.
- **Conventional commits**: `feat|fix|refactor|docs|test|chore|perf|ci: <desc>`.
- **Parallelize** independent agent work; don't serialize when you don't have to.
- Use clarifying questions via the AskUserQuestion tool, not plain-text lists.

## Optional Infra

- **code-review-graph** (MCP/plugin): if installed, prefer its graph tools over
  Read/Grep/Glob for exploring a codebase (token-efficient). Falls back to Read.
- **Plugins**: everything-claude-code + official marketplace plugins auto-install
  on first launch via `settings.json` (`enabledPlugins` / `extraKnownMarketplaces`).
