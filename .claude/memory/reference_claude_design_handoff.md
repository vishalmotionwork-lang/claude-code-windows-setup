---
name: Claude Design handoff bundle workflow
description: How claude.ai/design packages designs and how to consume them as Claude Code
type: reference
originSessionId: 3edf6c33-fb30-4183-ace6-058002fe63a5
---
# Claude Design (claude.ai/design) handoff bundles

Anthropic Labs product (launched April 2026, runs on Claude Opus 4.7). Generates HTML/CSS/JS prototypes and packages them as "handoff bundles" for Claude Code to consume.

## Bundle format

URL pattern: `https://api.anthropic.com/v1/design/h/<ID>?open_file=<path>`

Response is a **gzipped tar archive** (bytes look corrupted in WebFetch — re-save the raw tool-result binary as `.tar.gz` and extract).

Extract pattern:
```bash
cp <webfetch-binary> /tmp/design.tar.gz
tar -xzf /tmp/design.tar.gz -C /tmp/
```

## Bundle contents

```
<project-name>/
├── README.md          # "CODING AGENTS: READ THIS FIRST" — scope + instructions
├── chats/             # chat transcript(s) — where the INTENT lives
│   └── chat1.md       # [tool: *] markers, design assistant ↔ user iterations
└── project/
    ├── index.html     # primary entry, React+Babel CDN based
    ├── src/           # .jsx files loaded via <script type="text/babel">
    ├── styles/        # tokens.css + app.css
    ├── fonts/         # font files referenced from styles/
    ├── assets/        # logos, SVGs
    └── uploads/       # user-provided context (PDFs, screenshots)
```

## README contract

- "Recreate **pixel-perfectly** in whatever technology makes sense for the target codebase — don't copy the prototype's internal structure unless it fits."
- "Read the chat transcripts FIRST — intent lives there, not in the final HTML."
- "Don't render in a browser or screenshot unless asked — source has everything you need."

## Typical implementation routes

1. **Standalone preview** — serve the prototype as-is via `python3 -m http.server` (Babel standalone needs HTTP, not `file://`) so the user can eyeball the design before any port.
2. **Token swap** — keep the prototype's screens, swap the CSS token file. Fast if the target design system has compatible `var(--*)` names.
3. **Full rebuild** — discard prototype screens, rebuild in target framework using target design system primitives. Highest fidelity, most work.

## Key constraints (Babel standalone / React CDN bundles)

- NO ES module `import`/`export` in .jsx files
- NO TypeScript syntax
- NO `<>` fragment shorthand (use `<React.Fragment>`)
- Primitives register on `window` via `Object.assign(window, {…})`
- Script load order matters: primitives → data → screens → shell → bootstrap

## Related

- 50-agent orchestration pattern: see `feedback_50agent_orchestration.md`
- First example built: `~/DaduOS/design-preview-v2/` (full rebuild on new KnowAI kit)
