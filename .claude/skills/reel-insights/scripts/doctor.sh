#!/usr/bin/env bash
# doctor.sh — preflight for the reel-insights skill. Checks every dependency the
# pipeline needs and prints the EXACT fix for anything missing. Run on a new machine
# before first use. Run from inside a project dir to also check project-local config.
#
#   <skill>/scripts/doctor.sh
set -uo pipefail
ROOT="${REEL_PROJECT:-$PWD}"
OK="✅"; NO="❌"; WARN="⚠️ "
hard_fail=0

echo "── reel-insights doctor ─────────────────────────────────────"
echo "project dir: $ROOT"
echo ""

check () { # name  command  fix
  if command -v "$2" >/dev/null 2>&1; then
    printf "%s %-14s %s\n" "$OK" "$1" "$($2 --version 2>&1 | head -1)"
  else
    printf "%s %-14s missing — fix: %s\n" "$NO" "$1" "$3"; hard_fail=1
  fi
}

echo "REQUIRED tools"
check "node"   node   "install Node 18+ → https://nodejs.org  (or: brew install node / fnm install --lts)"
check "yt-dlp" yt-dlp "brew install yt-dlp   (or: pipx install yt-dlp)"
check "ffmpeg" ffmpeg "brew install ffmpeg"
check "curl"   curl   "preinstalled on macOS; else: brew install curl"
echo ""

echo "TRANSCRIPTION (optional — only if Claude generates transcripts)"
KEY="${GROQ_API_KEY:-}"
if [ -z "$KEY" ] && [ -f "$ROOT/.env" ]; then KEY="$(grep -E '^GROQ_API_KEY=' "$ROOT/.env" | cut -d= -f2-)"; fi
if [ -n "$KEY" ]; then echo "$OK GROQ_API_KEY    set (${KEY:0:7}…)"; else
  echo "$WARN GROQ_API_KEY    not set — add to the project's .env:  echo 'GROQ_API_KEY=gsk_...' >> .env"
  echo "                   (skip if you always paste your own transcript.txt)"
fi
echo ""

echo "FIGMA (the board builder)"
MCP_FOUND=0
for f in "$HOME/.claude.json" "$HOME/.mcp.json" "$ROOT/.mcp.json"; do
  [ -f "$f" ] && grep -q "figma-console" "$f" 2>/dev/null && { echo "$OK figma-console   MCP configured in $f"; MCP_FOUND=1; break; }
done
[ "$MCP_FOUND" = 0 ] && { echo "$NO figma-console   MCP not found in config — add the figma-console MCP server"; hard_fail=1; }

# 2) Figma Desktop app installed?
case "$(uname -s)" in
  Darwin)
    if [ -d "/Applications/Figma.app" ]; then echo "$OK Figma Desktop   /Applications/Figma.app"
    else echo "$NO Figma Desktop   not found — install from https://www.figma.com/downloads/ (Desktop app required; the bridge plugin is desktop-only)"; hard_fail=1; fi ;;
  *)
    echo "$WARN Figma Desktop   verify the Figma DESKTOP app is installed (bridge plugin is desktop-only; browser won't work)" ;;
esac

# 3) Desktop Bridge plugin present on disk? (must be IMPORTED into Figma manually)
PLUGIN_MANIFEST=""
for d in "$HOME/Desktop/figma-desktop-bridge" "$HOME/.figma-console-mcp/plugin" "$HOME/Desktop/figma-bridge-plugin"; do
  [ -f "$d/manifest.json" ] && { PLUGIN_MANIFEST="$d/manifest.json"; break; }
done
if [ -n "$PLUGIN_MANIFEST" ]; then
  echo "$OK bridge plugin   on disk: $PLUGIN_MANIFEST"
  echo "                   → in Figma: Plugins → Development → Import plugin from manifest (this file), then Run."
else
  echo "$WARN bridge plugin   manifest not found on disk — the figma-console MCP installs it on first run;"
  echo "                   start the MCP once, then look in ~/Desktop/figma-desktop-bridge/ or ~/.figma-console-mcp/plugin/."
fi
echo "                   ⚠ LIVE connection (plugin running + correct file) is verified at RUNTIME via the MCP"
echo "                     (figma_get_status: currentFileName must be your target board). doctor can't check that."
echo "                   Board to target: a FigJam board; note its fileKey into reels.config.json."
echo ""

echo "PLAYABLE-VIDEO PASTE (OS route — the only way to get a playable node; see reference/PASTE-AUTOMATION.md)"
case "$(uname -s)" in
  Darwin)
    if command -v swift >/dev/null 2>&1; then echo "$OK swift           present (file→clipboard)"; else echo "$NO swift           missing — install Xcode Command Line Tools: xcode-select --install"; fi
    if command -v osascript >/dev/null 2>&1; then echo "$OK osascript       present (sends ⌘V)"; else echo "$NO osascript       missing (unexpected on macOS)"; fi
    echo "$WARN accessibility    grant your terminal Accessibility: System Settings → Privacy & Security →"
    echo "                   Accessibility (required to send the ⌘V keystroke). Test: scripts/paste-video-mac.sh reels/<id>/reel.mp4"
    ;;
  *) echo "$WARN windows          use scripts\\paste-video-win.ps1 (PowerShell 5+, Set-Clipboard -LiteralPath + SendKeys). Figma window must be open/focusable." ;;
esac
echo ""

echo "PROJECT config"
[ -f "$ROOT/reels.config.json" ] && echo "$OK reels.config.json present" || echo "$WARN reels.config.json missing — create it (see templates/reels.config.json): handle, followers, avatarHash, board fileKey"
[ -d "$ROOT/reels" ] && echo "$OK reels/ ($(ls -d "$ROOT"/reels/*/ 2>/dev/null | wc -l | tr -d ' ') reels)" || echo "$WARN reels/ not created yet — run new-reel.sh <url> to start"
echo ""

echo "─────────────────────────────────────────────────────────────"
if [ "$hard_fail" = 1 ]; then
  echo "$NO Missing required tools above. Install them, then re-run the doctor."
  exit 1
else
  echo "$OK All required tools present. You're ready: scripts/new-reel.sh <reel-url> --type trial|feed --transcribe"
fi
