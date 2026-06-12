#!/usr/bin/env bash
# transcribe.sh — download audio from any URL (Instagram, YouTube, TikTok, direct media)
#                 and transcribe with Groq Whisper.
#
# Usage:
#   transcribe.sh URL [URL ...]
#
# Output:
#   ~/Downloads/transcripts/YYYY-MM-DD/<slug>.mp3
#   ~/Downloads/transcripts/YYYY-MM-DD/<slug>.txt
#   prints the transcript to stdout, prefixed by === <slug> ===
#
# Env:
#   GROQ_API_KEY  — overrides the key read from ~/.claude/projects/-Users-vishal-motion/memory/groq-api-creds.md

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "usage: transcribe.sh URL [URL ...]" >&2
  exit 64
fi

# --- deps -----------------------------------------------------------------
for cmd in yt-dlp ffmpeg curl jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing dep: $cmd  (try: brew install $cmd)" >&2
    exit 69
  fi
done

# --- groq key -------------------------------------------------------------
if [ -z "${GROQ_API_KEY:-}" ]; then
  CREDS="$HOME/.claude/projects/-Users-vishal-motion/memory/groq-api-creds.md"
  if [ -f "$CREDS" ]; then
    GROQ_API_KEY=$(grep -oE 'gsk_[A-Za-z0-9]+' "$CREDS" | head -1)
  fi
fi
if [ -z "${GROQ_API_KEY:-}" ]; then
  echo "no GROQ_API_KEY set and none found in groq-api-creds.md" >&2
  exit 78
fi

MODEL="${GROQ_WHISPER_MODEL:-whisper-large-v3-turbo}"
DATE_DIR=$(date +%Y-%m-%d)
OUT_DIR="$HOME/Downloads/transcripts/$DATE_DIR"
mkdir -p "$OUT_DIR"

# --- helpers --------------------------------------------------------------
slug_for_url() {
  # derive a stable, human-readable slug from a URL
  local url="$1"
  case "$url" in
    *instagram.com*reel*|*instagram.com*/p/*)
      # instagram.com/reels/<id>/  OR  instagram.com/<user>/reel/<id>/  OR  instagram.com/p/<id>/
      local id=$(echo "$url" | sed -nE 's#.*/(reels?|p)/([^/?#]+).*#\2#p')
      local user=$(echo "$url" | sed -nE 's#https?://[^/]+/([^/]+)/(reels?|p)/.*#\1#p')
      if [ -z "$user" ] || [ "$user" = "p" ] || [ "$user" = "reel" ] || [ "$user" = "reels" ]; then
        user="ig"
      fi
      if [ -z "$id" ]; then
        id=$(echo -n "$url" | shasum | cut -c1-10)
      fi
      echo "${user}-${id}"
      ;;
    *youtube.com*|*youtu.be*)
      local id=$(echo "$url" | sed -E 's#.*[?&]v=([^&]+).*#\1#; s#.*youtu\.be/([^?&]+).*#\1#')
      echo "yt-${id}"
      ;;
    *tiktok.com*)
      local id=$(echo "$url" | sed -E 's#.*/video/([0-9]+).*#\1#')
      echo "tt-${id}"
      ;;
    *)
      # fallback: hash the url
      local h=$(echo -n "$url" | shasum | cut -c1-10)
      echo "url-${h}"
      ;;
  esac
}

transcribe_one() {
  local url="$1"
  local slug; slug=$(slug_for_url "$url")
  local mp3="$OUT_DIR/${slug}.mp3"
  local txt="$OUT_DIR/${slug}.txt"

  if [ -s "$txt" ]; then
    echo "=== ${slug} (cached) ===" >&2
    cat "$txt"
    echo ""
    echo "[saved: $txt]" >&2
    return 0
  fi

  if [ ! -s "$mp3" ]; then
    echo "[$slug] downloading…" >&2
    if ! yt-dlp -q --no-warnings -x --audio-format mp3 --audio-quality 5 \
         -o "$mp3" "$url" >&2; then
      echo "[$slug] yt-dlp failed (private/blocked?) — skipping" >&2
      return 1
    fi
  fi

  # Groq cap is 25MB. Re-encode to mono 16k mp3 if oversized.
  local size; size=$(stat -f%z "$mp3" 2>/dev/null || stat -c%s "$mp3")
  if [ "$size" -gt 25000000 ]; then
    echo "[$slug] >25MB, downsampling…" >&2
    local small="$OUT_DIR/${slug}.16k.mp3"
    ffmpeg -y -loglevel error -i "$mp3" -ac 1 -ar 16000 -b:a 32k "$small"
    mv "$small" "$mp3"
  fi

  echo "[$slug] transcribing…" >&2
  local resp
  resp=$(curl -sS --fail-with-body \
    https://api.groq.com/openai/v1/audio/transcriptions \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@${mp3}" \
    -F "model=${MODEL}" \
    -F "response_format=text" 2>&1) || {
      echo "[$slug] groq error: $resp" >&2
      return 1
    }

  printf "%s" "$resp" > "$txt"
  echo "=== ${slug} ==="
  cat "$txt"
  echo ""
  echo "[saved: $txt]" >&2
}

rc=0
for url in "$@"; do
  transcribe_one "$url" || rc=1
done

echo "" >&2
echo "all transcripts in: $OUT_DIR" >&2
exit $rc
