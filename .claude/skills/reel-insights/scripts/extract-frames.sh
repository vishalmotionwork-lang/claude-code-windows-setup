#!/usr/bin/env bash
# extract-frames.sh — frames from one window's Insights screen-recording so Claude
# can read the metrics via vision. Run from inside your project dir.
#   <skill>/scripts/extract-frames.sh <id> <window> [fps]      # window: 1h|24h|48h|weekly|lifetime
# Reads reels/<id>/insights/<window>.mp4 → reels/<id>/insights/frames/<window>/f%02d.jpg
set -euo pipefail
ID="${1:?usage: extract-frames.sh <id> <window> [fps e.g. 1/2]}"
WIN="${2:?window required: 1h|24h|48h|weekly|lifetime}"
FPS="${3:-1/2}"
ROOT="${REEL_PROJECT:-$PWD}"
SRC="$ROOT/reels/$ID/insights/$WIN.mp4"
OUT="$ROOT/reels/$ID/insights/frames/$WIN"
[ -f "$SRC" ] || { echo "no $SRC — drop the $WIN recording there as $WIN.mp4 (or use a $WIN.png screenshot, no frames needed)"; exit 1; }
mkdir -p "$OUT"; rm -f "$OUT"/f*.jpg
ffmpeg -y -loglevel error -i "$SRC" -vf "fps=$FPS" -q:v 2 "$OUT/f%02d.jpg"
echo "✓ $(ls "$OUT"/f*.jpg | wc -l | tr -d ' ') frames → reels/$ID/insights/frames/$WIN/  (read them to fill windows.$WIN in data.json)"
