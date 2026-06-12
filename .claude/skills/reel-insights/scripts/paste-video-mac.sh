#!/usr/bin/env bash
# paste-video-mac.sh — put a media file on the macOS clipboard and paste it into
# Figma Desktop, triggering Figma's NATIVE importer → a real playable MEDIA node.
#
# WHY: Figma's plugin API has NO way to create a playable video MEDIA node from bytes
# (createVideoAsync = static poster in FigJam; createGif = GIF-only; clone = locked to
# source). The ONLY automated route to a native playable node is a real OS paste/drag,
# which hits Figma's own importer. Proven live 2026-06-01 on board "Trial strategy".
# See reference/PASTE-AUTOMATION.md.
#
# REQUIREMENTS:
#   - macOS, Figma Desktop running with the target file open.
#   - Accessibility permission for the app sending the keystroke (Terminal/iTerm/etc.):
#     System Settings → Privacy & Security → Accessibility.
#   - `swift` (Xcode CLT) for the file-clipboard step.
#
# USAGE:  scripts/paste-video-mac.sh <file> [activate_delay_seconds]
#   The orchestrator (Claude via the figma-console bridge) should:
#     1) snapshot existing MEDIA node ids,
#     2) call this script,
#     3) poll for the NEW MEDIA node, then resize/move it into its section.
set -euo pipefail

FILE="${1:?usage: paste-video-mac.sh <file> [delay]}"
DELAY="${2:-0.6}"
[ -f "$FILE" ] || { echo "no file: $FILE" >&2; exit 1; }
# absolute path
FILE="$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")"

# helper swift: put the FILE (as a file reference, not its bytes) on the pasteboard
SWIFT="$(dirname "${BASH_SOURCE[0]}")/_clip_file.swift"
if [ ! -f "$SWIFT" ]; then
cat > "$SWIFT" <<'PY'
import Cocoa
let path = CommandLine.arguments[1]
let url = URL(fileURLWithPath: path)
let pb = NSPasteboard.general
pb.clearContents()
let ok = pb.writeObjects([url as NSURL])
print(ok ? "ok" : "FAILED")
PY
fi

out="$(swift "$SWIFT" "$FILE" 2>&1)"
[ "$out" = "ok" ] || { echo "clipboard set failed: $out" >&2; exit 1; }

# activate Figma and paste (Cmd+V) — Figma's native importer creates the MEDIA node
osascript \
  -e 'tell application "Figma" to activate' \
  -e "delay $DELAY" \
  -e 'tell application "System Events" to keystroke "v" using command down' \
  >/dev/null 2>&1

echo "pasted: $FILE"
