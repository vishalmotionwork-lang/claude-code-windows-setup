# Claude Code — complete Windows setup

One command, from **Windows PowerShell** (5.1+ — the built-in one is fine):

```powershell
irm https://raw.githubusercontent.com/vishalmotionwork-lang/claude-code-windows-setup/main/setup.ps1 | iex
```

That installs everything and lays down a working `~/.claude`. It's idempotent — safe to re-run.

## What it installs

**Toolchain** (winget, Scoop fallback): PowerShell 7, Git, Node LTS, Python 3.12, uv, ffmpeg, yt-dlp, jq, GitHub CLI, ripgrep.

**Global packages** — npm: `@anthropic-ai/sdk`, `@openai/codex`, `@google/gemini-cli`, `firecrawl-cli`, `vercel`, `pnpm`, `yarn`. pip: `anthropic`, `openai-whisper`, `pillow`, `requests`, `requests-toolbelt`.

**Claude Code** — official native installer (npm fallback).

**`~/.claude` mirror** (this repo):
- `CLAUDE.md` — global operating protocol (file-based memory; Windows paths)
- `settings.json` — permissions + plugin marketplaces (auto-install on first launch)
- `rules/` — coding standards (common + every language)
- `memory/` — `USER.md` profile, **105 feedback rules**, reference notes, project registry
- `skills/` — figjam-board, video-inspo-extracter, reel-insights, transcript, youtube,
  design/qa/ship/gsd-*/ECC patterns, and more
- `commands/`, `agents/`, `scripts/` (Groq `transcribe.sh` + `youtube_transcript.py`)
- `get-shit-done/` — GSD framework

**MCP servers** registered: `code-review-graph`, `figma-console`. HTTP/auth ones (figma, neon, miro, Gmail, Drive) are listed at the end of the run to add when you want them.

## After install

1. Reopen the terminal, run `claude`, sign in.
2. Set your API keys with `setx` (printed at the end of the run) — **none are bundled.**
3. gstack's live-browser skills (browse/benchmark/canary/qa) need gstack's own
   installer — its 396MB compiled daemon is macOS-built and can't be file-copied.
   All prompt-based skills already work from the mirror.

## Safety

No credentials, API keys, tokens, or business project memories are in this repo.
A hardcoded DB URL found in `bod`/`eod` was replaced with `$CORE_TEAM_DB_URL`.
