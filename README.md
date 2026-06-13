# Claude Code — complete one-command setup (macOS + Windows)

Reproduces a full working Claude Code environment from a single line. Idempotent — safe to re-run.

### macOS (Terminal — zsh/bash)

```bash
curl -fsSL https://raw.githubusercontent.com/vishalmotionwork-lang/claude-code-windows-setup/main/setup-mac.sh | bash
```

### Windows (PowerShell 5.1+ — the built-in one is fine)

```powershell
irm https://raw.githubusercontent.com/vishalmotionwork-lang/claude-code-windows-setup/main/setup.ps1 | iex
```

Both install the toolchain + global packages + Claude Code, then lay down a working `~/.claude`.

## What it installs

**Toolchain** — macOS via Homebrew · Windows via winget (Scoop fallback):
Git, Node, Python 3.12, uv, ffmpeg, yt-dlp, jq, GitHub CLI, ripgrep.
macOS also adds `bun` (telegram MCP runtime); Windows adds PowerShell 7.

**Global packages** — npm: `@anthropic-ai/sdk`, `@openai/codex`, `@google/gemini-cli`, `firecrawl-cli`, `vercel`, `pnpm`, `yarn`. pip: `anthropic`, `pillow`, `requests`, `requests-toolbelt` (+ `openai-whisper`, isolated via `uv tool` on macOS).

**Claude Code** — official native installer (npm fallback).

**`~/.claude` mirror** (this repo):
- `CLAUDE.md` — global operating protocol (file-based memory)
- `settings.json` — permissions + plugin marketplaces (auto-install on first launch)
- `rules/` — coding standards (common + every language)
- `memory/` — `USER.md` profile, **105 feedback rules**, reference notes, project registry
- `skills/` — figjam-board, video-inspo-extracter, reel-insights, transcript, youtube,
  design/qa/ship/gsd-*/ECC patterns, and more
- `commands/`, `agents/`, `scripts/` (Groq `transcribe.sh` + `youtube_transcript.py`), `hooks/`
- `get-shit-done/` — GSD framework

The macOS installer auto-rewrites the baked-in path slug (`-Users-vishal-motion`) to **your** machine's username, so project-memory paths line up no matter who you are.

**MCP servers** registered: `code-review-graph`, `figma-console`. HTTP/auth ones (figma, neon, miro, Gmail, Drive) are printed at the end of the run to add when you want them.

## After install

1. Open a new terminal, run `claude`, sign in.
2. Set your API keys — **none are bundled.**
   macOS: add `export KEY="..."` lines to `~/.zshrc`. Windows: `setx KEY "..."`. (Printed at the end of the run.)
3. gstack's live-browser skills (browse/benchmark/canary/qa) need gstack's own
   installer — its ~396MB compiled daemon is not in this template. On **macOS** the
   daemon runs natively (install via gstack's docs, or copy `~/.claude/skills/gstack/{bin,*/dist}`
   from another Mac). On **Windows** it can't be file-copied (macOS binary).
   All prompt-based skills already work from the mirror.

## Safety

No credentials, API keys, tokens, or business project memories are in this repo.
A hardcoded DB URL found in `bod`/`eod` was replaced with `$CORE_TEAM_DB_URL`.
