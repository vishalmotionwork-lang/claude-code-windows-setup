#!/usr/bin/env bash
# serve.sh — serve the current project's reels/ over HTTP **with CORS headers** on a
# port the figma-console plugin whitelists, so the patched FETCH_VIDEO handler can
# fetch reel/insights videos and createVideoAsync them onto the board.
#
# WHY: the Figma plugin main thread has no network; the UI iframe can fetch, but only
# whitelisted localhost ports (9223-9232) AND only with CORS headers (cross-origin).
# Port 9223 is the bridge WS; we use 9232. Start AFTER the plugin is connected (so it
# doesn't collide with the plugin's launch-time port probing), and stop it when done.
#
#   <skill>/scripts/serve.sh [port]      # default 9232
#   URLs become:  http://localhost:9232/<id>/reel.mp4  ·  /<id>/insights/<window>.mp4
set -euo pipefail
PORT="${1:-9232}"
ROOT="${REEL_PROJECT:-$PWD}"
DIR="$ROOT/reels"
[ -d "$DIR" ] || { echo "no reels/ in $ROOT"; exit 1; }
pkill -f "reel_cors_server.py $PORT" 2>/dev/null || true
SRV="$(dirname "${BASH_SOURCE[0]}")/reel_cors_server.py"
cat > "$SRV" <<'PY'
import sys, os
from http.server import HTTPServer, SimpleHTTPRequestHandler
os.chdir(sys.argv[2])
class H(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        super().end_headers()
    def log_message(self, *a): pass
HTTPServer(('127.0.0.1', int(sys.argv[1])), H).serve_forever()
PY
(python3 "$SRV" "$PORT" "$DIR" >/tmp/reel_cors_$PORT.log 2>&1 &)
sleep 1
if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/" | grep -q "200\|403\|301"; then
  echo "✓ CORS server on http://localhost:$PORT  (serving $DIR)"
  echo "  stop with:  pkill -f 'reel_cors_server.py $PORT'"
else
  echo "⚠ server may not have started — check /tmp/reel_cors_$PORT.log"
fi
