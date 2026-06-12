---
name: Code Review Graph (source + install)
description: Upstream repo and install path for the code-review-graph MCP server used for Graph-First workflow
type: reference
originSessionId: 03d32c30-4a30-495c-8a3c-cae99b4c0824
---
- **Repo**: https://github.com/tirth8205/code-review-graph (author: tirth8205)
- **Local clone**: `~/code-review-graph/` (has CLAUDE.md, docs/, hooks/, VS Code extension subfolder `code-review-graph-vscode/`)
- **Install**: registered in `~/.mcp.json` as `code-review-graph`, runs via `uvx code-review-graph serve` (stdio, Python package from PyPI)
- **Related hooks**: SessionStart auto-builds graph if missing; PostToolUse (Edit/Write/Bash) auto-updates incrementally; PreToolUse (Read/Grep/Glob) prints a reminder to use graph tools first
- **When user asks about source/repo/customisation** — point here instead of guessing
