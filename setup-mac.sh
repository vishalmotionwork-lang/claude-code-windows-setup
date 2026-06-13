#!/usr/bin/env bash
# ============================================================================
#  Claude Code - COMPLETE macOS mirror (one command)
#  --------------------------------------------------------------------------
#  Reproduces the full working environment on a Mac:
#    - Toolchain (Homebrew): git, node, python@3.12, uv, ffmpeg, yt-dlp, jq,
#      gh, ripgrep, bun (telegram MCP)
#    - Global packages: @anthropic-ai/sdk, codex, gemini-cli, firecrawl-cli,
#      vercel, pnpm, yarn  +  pip: anthropic, pillow, requests, requests-toolbelt
#      +  openai-whisper (via uv tool, isolated)
#    - Claude Code (official native installer; npm fallback)
#    - ~/.claude mirror: CLAUDE.md, settings.json, rules/, memory/ (USER.md +
#      feedback rules + reference notes), skills/, commands/, agents/, scripts/
#      (Groq transcribe.sh + youtube_transcript.py), hooks/, get-shit-done/
#    - MCP servers registered (code-review-graph, figma-console)
#    - Plugin marketplaces auto-install on first launch (ECC + official)
#  Run from Terminal (zsh/bash):  curl -fsSL <raw-url> | bash
#  Idempotent. NO credentials included; set API keys yourself (printed at end).
# ============================================================================

# Continue on error (mirror of PS $ErrorActionPreference='Continue'); track failures.
set +e
FAILED=()
REPO_URL='https://github.com/vishalmotionwork-lang/claude-code-windows-setup.git'
CLAUDE_DIR="$HOME/.claude"

# --- colors (fall back to plain if not a tty) ------------------------------
if [ -t 1 ]; then
  C_CYAN=$'\033[36m'; C_GREEN=$'\033[32m'; C_YEL=$'\033[33m'; C_MAG=$'\033[35m'; C_GRY=$'\033[90m'; C_RST=$'\033[0m'
else
  C_CYAN=''; C_GREEN=''; C_YEL=''; C_MAG=''; C_GRY=''; C_RST=''
fi
step(){ printf '\n%s=== %s ===%s\n' "$C_CYAN" "$1" "$C_RST"; }
ok(){   printf '  %s[ok]%s  %s\n' "$C_GREEN" "$C_RST" "$1"; }
warn(){ printf '  %s[warn]%s %s\n' "$C_YEL" "$C_RST" "$1"; }
gray(){ printf '  %s%s%s\n' "$C_GRY" "$1" "$C_RST"; }
have(){ command -v "$1" >/dev/null 2>&1; }

printf '%s\n' "$C_MAG"
cat <<'BANNER'
  +--------------------------------------------------------------+
  |   Claude Code  -  COMPLETE macOS mirror                      |
  |   toolchain + packages + Claude Code + skills + memory       |
  +--------------------------------------------------------------+
BANNER
printf '%s\n' "$C_RST"

if [ "$(uname -s)" != "Darwin" ]; then
  printf 'This installer is for macOS. On Windows use setup.ps1.\n'; exit 1
fi

# ---------------------------------------------------------------------------
# Homebrew (package manager)
# ---------------------------------------------------------------------------
step "Homebrew"
if have brew; then
  ok "Homebrew found"
else
  warn "Homebrew missing - installing (may prompt for your password via sudo)"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || { warn "Homebrew install failed"; FAILED+=("Homebrew"); }
fi
# Put brew on PATH for THIS session (arm64 -> /opt/homebrew, intel -> /usr/local)
if [ -x /opt/homebrew/bin/brew ]; then BREW_BIN=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then BREW_BIN=/usr/local/bin/brew
else BREW_BIN="$(command -v brew 2>/dev/null)"; fi
if [ -n "$BREW_BIN" ]; then eval "$("$BREW_BIN" shellenv)"; fi
# Persist brew shellenv to ~/.zprofile (standard) if not already there
if [ -n "$BREW_BIN" ] && ! grep -qs 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  printf '\n# Homebrew\neval "$(%s shellenv)"\n' "$BREW_BIN" >> "$HOME/.zprofile"
fi

brew_install(){ # $1 = probe cmd, $2 = formula, $3 = label
  local probe="$1" formula="$2" label="$3"
  if have "$probe"; then ok "$label already installed"; return; fi
  gray "installing $label ..."
  if brew install "$formula" >/dev/null 2>&1; then
    hash -r 2>/dev/null
    if have "$probe"; then ok "$label installed"; else ok "$label installed (open a new terminal for PATH)"; fi
  else
    warn "$label failed"; FAILED+=("$label")
  fi
}

# ---------------------------------------------------------------------------
# Toolchain
# ---------------------------------------------------------------------------
step "Toolchain"
brew_install git    git           'Git'
brew_install node   node          'Node.js'
brew_install python python@3.12   'Python 3.12'
brew_install uv     uv            'uv (Python tool runner)'
brew_install ffmpeg ffmpeg        'ffmpeg'
brew_install yt-dlp yt-dlp        'yt-dlp'
brew_install jq     jq            'jq'
brew_install gh     gh            'GitHub CLI'
brew_install rg     ripgrep       'ripgrep'
brew_install bun    bun           'bun (telegram MCP runtime)'

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------
step "Claude Code"
if have claude; then
  ok "claude already installed"
else
  DONE=0
  curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1 && { hash -r 2>/dev/null; have claude && DONE=1; }
  # native installer drops into ~/.local/bin
  [ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
  hash -r 2>/dev/null; have claude && DONE=1
  if [ "$DONE" = 1 ]; then ok "Claude Code installed (native)"
  else
    warn "native installer failed - falling back to npm"
    if have npm && npm install -g '@anthropic-ai/claude-code' >/dev/null 2>&1; then
      hash -r 2>/dev/null
      if have claude; then ok "Claude Code installed (npm)"; else ok "Claude Code installed (npm) - open a new terminal for PATH"; fi
    else
      warn "Claude Code install failed"; FAILED+=("Claude Code")
    fi
  fi
  # ensure ~/.local/bin is persisted to PATH
  if [ -d "$HOME/.local/bin" ] && ! grep -qs '.local/bin' "$HOME/.zprofile" 2>/dev/null; then
    printf '\n# Claude Code (native installer)\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.zprofile"
  fi
fi

# ---------------------------------------------------------------------------
# Global packages (npm + pip) - "all my packages"
# ---------------------------------------------------------------------------
step "Global npm packages"
if have npm; then
  for p in '@anthropic-ai/sdk' '@google/gemini-cli' '@openai/codex' 'firecrawl-cli' 'vercel' 'pnpm' 'yarn'; do
    gray "npm -g $p"
    npm install -g "$p" >/dev/null 2>&1 || warn "npm $p failed"
  done
  hash -r 2>/dev/null
  ok "npm globals attempted (@anthropic-ai/sdk, codex, gemini-cli, firecrawl-cli, vercel, pnpm, yarn)"
else
  warn "npm not on PATH yet - open a new terminal and re-run"; FAILED+=("npm globals")
fi

step "Python packages"
if have python3; then
  PY_LIBS=(anthropic pillow requests requests-toolbelt)
  # Homebrew's python is externally-managed (PEP 668): try clean, then --break-system-packages.
  if python3 -m pip install --quiet --upgrade "${PY_LIBS[@]}" >/dev/null 2>&1 \
     || python3 -m pip install --quiet --upgrade --break-system-packages "${PY_LIBS[@]}" >/dev/null 2>&1; then
    ok "pip libs installed (${PY_LIBS[*]})"
  else
    warn "some pip libs failed - retry later"; FAILED+=("pip libs")
  fi
  # openai-whisper is large + CLI-ish -> isolate via uv tool (no system pollution)
  if have uv; then
    gray "uv tool install openai-whisper (large; pulls torch)"
    uv tool install openai-whisper >/dev/null 2>&1 && ok "openai-whisper installed (uv tool)" \
      || warn "openai-whisper install skipped (retry: uv tool install openai-whisper)"
  fi
else
  warn "python3 not on PATH yet - open a new terminal and re-run"
fi

# ---------------------------------------------------------------------------
# Clone the ~/.claude mirror (rules, memory, skills, commands, agents, scripts, hooks, GSD)
# ---------------------------------------------------------------------------
step "~/.claude mirror (skills + commands + agents + scripts + rules + memory)"
if ! have git; then
  warn "git not on PATH yet - open a new terminal and re-run to get the mirror"; FAILED+=("mirror (git missing)")
else
  mkdir -p "$CLAUDE_DIR"
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    BK="$CLAUDE_DIR/settings.json.bak-$(date +%Y%m%d-%H%M%S)"
    cp "$CLAUDE_DIR/settings.json" "$BK" && warn "backed up existing settings.json -> $(basename "$BK")"
  fi
  TMP="$(mktemp -d /tmp/claude-mirror.XXXXXX)"
  if git clone --depth 1 "$REPO_URL" "$TMP" >/dev/null 2>&1; then
    # copy the payload (incl. dotfiles) into ~/.claude
    cp -R "$TMP/.claude/." "$CLAUDE_DIR/" 2>/dev/null

    # --- adapt baked-in path slug to THIS machine's username -----------------
    # Mirror was built on /Users/vishal.motion -> slug "-Users-vishal-motion".
    # Rewrite to this machine's slug so any project-memory paths line up.
    SRC_SLUG="-Users-vishal-motion"
    NEW_SLUG="$(printf '%s' "$HOME" | sed 's#/#-#g')"   # /Users/john -> -Users-john
    if [ "$NEW_SLUG" != "$SRC_SLUG" ]; then
      gray "adapting path slug $SRC_SLUG -> $NEW_SLUG"
      # BSD sed needs the empty-string arg after -i
      grep -rl "$SRC_SLUG" "$CLAUDE_DIR" 2>/dev/null | while IFS= read -r f; do
        sed -i '' "s#${SRC_SLUG}#${NEW_SLUG}#g" "$f" 2>/dev/null
      done
      ok "path slug adapted to $NEW_SLUG"
    else
      ok "username matches mirror ($SRC_SLUG) - no path rewrite needed"
    fi

    rm -rf "$TMP" 2>/dev/null
    SK=$(find "$CLAUDE_DIR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    CM=$(find "$CLAUDE_DIR/commands" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    AG=$(find "$CLAUDE_DIR/agents" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    FB=$(find "$CLAUDE_DIR/memory" -maxdepth 1 -name 'feedback_*.md' 2>/dev/null | wc -l | tr -d ' ')
    ok "mirror placed: $SK skills, $CM commands, $AG agents, $FB feedback rules"
  else
    warn "mirror clone failed"; FAILED+=("mirror"); rm -rf "$TMP" 2>/dev/null
  fi
fi

# ---------------------------------------------------------------------------
# MCP servers (the scriptable, secret-free ones; HTTP/auth ones listed at end)
# ---------------------------------------------------------------------------
step "MCP servers"
if have claude; then
  claude mcp add code-review-graph -- uvx code-review-graph serve >/dev/null 2>&1 && ok "code-review-graph registered" || warn "code-review-graph add skipped"
  claude mcp add figma-console -- npx -y figma-console-mcp@latest >/dev/null 2>&1 && ok "figma-console registered" || warn "figma-console add skipped"
else
  warn "claude not ready - register MCP servers after opening a new terminal"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
step "Done"
if [ "${#FAILED[@]}" -eq 0 ]; then
  printf '  %sEverything installed cleanly.%s\n' "$C_GREEN" "$C_RST"
else
  printf '  %sCompleted with warnings on: %s%s\n' "$C_YEL" "$(IFS=', '; echo "${FAILED[*]}")" "$C_RST"
  printf '  %sOpen a new terminal and run this command again to retry those.%s\n' "$C_YEL" "$C_RST"
fi

cat <<'NEXT'

  -------------------------------------------------------------------
  NEXT STEPS
  -------------------------------------------------------------------
  1) OPEN A NEW TERMINAL (PATH refresh), then run:  claude
     - First launch auto-installs plugin marketplaces
       (everything-claude-code + official frontend-design/telegram).
     - Loads CLAUDE.md, USER.md, all feedback rules, your skills/commands.
     - Sign in to Claude when prompted.

  2) SET YOUR API KEYS (none are bundled). Add to ~/.zshrc, then `source ~/.zshrc`:
       export GROQ_API_KEY="gsk_..."          # transcribe.sh / Groq Whisper
       export OPENAI_API_KEY="sk-..."         # /codex skill
       export GEMINI_API_KEY="..."            # gemini-cli
       export FIRECRAWL_API_KEY="fc-..."      # firecrawl skills
       export CORE_TEAM_DB_URL="postgresql://..."   # /bod /eod dashboard
       export ANTHROPIC_API_KEY="sk-ant-..."  # optional; SDK / scripts

  3) FRAMEWORKS that need their own installer (not file-copyable):
     - gstack browser skills (browse/benchmark/canary/qa live-test):
       the ~396MB compiled browser daemon is NOT in this public template
       (keeps the repo light). On macOS the daemon DOES run natively - install
       gstack per its own docs, or copy ~/.claude/skills/gstack/{bin,*/dist}
       from another Mac. All PROMPT skills already work from the mirror.
     - GSD (get-shit-done) is bundled; commands/skills load automatically.

  4) MCP servers needing sign-in (add when you want them):
       claude mcp add --transport http figma https://mcp.figma.com/mcp
       claude mcp add --transport http neon  https://mcp.neon.tech/mcp
       claude mcp add --transport http miro  https://mcp.miro.com
     (Gmail / Google Drive / Meta Ads are claude.ai-managed - sign in there.)
     (pencil MCP needs Pencil.app; figma-desktop needs the Figma desktop app.)

  Your setup lives in:  ~/.claude
  No credentials were installed anywhere. Add per-project secrets locally.
  -------------------------------------------------------------------

NEXT
