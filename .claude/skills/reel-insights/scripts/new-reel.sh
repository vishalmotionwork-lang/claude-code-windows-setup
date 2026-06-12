#!/usr/bin/env bash
# new-reel.sh — intake a reel by URL into the CURRENT project (cwd). Downloads the
# video + caption, scaffolds reels/<id>/, optionally transcribes (Groq Whisper),
# writes a data.json stub. Steps 1-2 of the intake (see reference/INTAKE.md).
#
#   <skill>/scripts/new-reel.sh <reel-url> [--type trial|feed] [--transcribe] [--rank N] [--windows 1h,24h,48h,weekly,lifetime]
#
# Run from inside your project directory (where reels/ should live).
set -euo pipefail
URL="${1:?usage: new-reel.sh <instagram-reel-url> [--type trial|feed] [--transcribe] [--rank N] [--windows ..]}"
shift || true
TRANSCRIBE=0; RANK=""; TYPE=""; WINDOWS="lifetime"
while [ $# -gt 0 ]; do case "$1" in
  --transcribe) TRANSCRIBE=1 ;;
  --rank) RANK="${2:-}"; shift ;;
  --type) TYPE="${2:-}"; shift ;;
  --windows) WINDOWS="${2:-}"; shift ;;
esac; shift; done

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${REEL_PROJECT:-$PWD}"
cd "$ROOT"
[ -f .env ] && { set -a; . ./.env; set +a; }

ID="$(yt-dlp --no-warnings --print id "$URL")"
DIR="reels/$ID"
mkdir -p "$DIR/insights/frames"
echo "▸ reel id: $ID  →  $ROOT/$DIR"

if [ ! -f "$DIR/reel.mp4" ]; then
  yt-dlp -q -o "$DIR/reel.%(ext)s" "$URL"
  [ -f "$DIR/reel.mp4" ] || for f in "$DIR"/reel.*; do mv "$f" "$DIR/reel.mp4"; break; done
  echo "✓ reel.mp4"
fi

yt-dlp --no-warnings --print "%(description)s" --skip-download "$URL" > "$DIR/caption.txt" 2>/dev/null || true
echo "✓ caption.txt"

if [ "$TRANSCRIBE" = 1 ] && [ ! -s "$DIR/transcript.txt" ]; then
  if [ -z "${GROQ_API_KEY:-}" ]; then
    echo "⚠ GROQ_API_KEY not set (.env) — skipping transcribe (or drop your own transcript.txt)"
  else
    ffmpeg -y -loglevel error -i "$DIR/reel.mp4" -ac 1 -ar 16000 "$DIR/insights/_audio.mp3"
    curl -s https://api.groq.com/openai/v1/audio/transcriptions \
      -H "Authorization: Bearer $GROQ_API_KEY" \
      -F "file=@$DIR/insights/_audio.mp3" -F "model=whisper-large-v3-turbo" -F "response_format=text" \
      > "$DIR/transcript.txt"
    rm -f "$DIR/insights/_audio.mp3"
    echo "✓ transcript.txt (Groq whisper-large-v3-turbo)"
  fi
fi

if [ ! -f "$DIR/data.json" ]; then
  node "$SKILL_DIR/stub-data.mjs" "$ID" "$URL" --windows "$WINDOWS" ${RANK:+--rank "$RANK"} ${TYPE:+--type "$TYPE"}
fi

echo ""
echo "▸ next: for EACH window (1h/24h/48h/weekly/lifetime) drop the Insights capture into:"
echo "        $DIR/insights/<window>.mp4   (recording)  or  $DIR/insights/<window>.png  (screenshot)"
echo "        recording → run  scripts/extract-frames.sh $ID <window>  then Claude reads + fills data.json"
echo "        finally:  node scripts/prep.mjs --move-videos   → paste payload into figma_execute"
ls -R "$DIR"
