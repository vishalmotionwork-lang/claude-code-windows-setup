#!/usr/bin/env bash
# patch-plugin.sh — inject the FETCH_VIDEO handler into the figma-console "Figma
# Desktop Bridge" plugin's ui.html so the main thread can pull local videos and
# createVideoAsync them. Idempotent; patches EVERY copy found (Figma may load any of
# them — the one actually loaded must be patched, so we patch them all).
#
# After patching, Figma must RE-IMPORT/RE-RUN the plugin to load the new ui.html
# (a soft reload reuses the cached UI). See reference/VIDEO-AUTOMATION.md.
#
#   <skill>/scripts/patch-plugin.sh
set -uo pipefail
HANDLER_MARKER="case 'FETCH_VIDEO':"
ANCHOR="case 'EXECUTE_CODE_RESULT':"

# find candidate plugin ui.html files (folders whose manifest is the bridge plugin)
patched=0; already=0; found=0
while IFS= read -r mf; do
  [ -n "$mf" ] || continue
  found=$((found+1))
  dir="$(dirname "$mf")"
  ui="$dir/ui.html"
  [ -f "$ui" ] || continue
  if grep -q "$HANDLER_MARKER" "$ui"; then echo "· already patched: $ui"; already=$((already+1)); continue; fi
  python3 - "$ui" "$ANCHOR" <<'PY'
import sys
path, anchor = sys.argv[1], sys.argv[2]
src = open(path, encoding='utf-8').read()
block = """        case 'EXECUTE_CODE_RESULT':
          handleResult('EXECUTE_CODE', 'result');
          break;
        // reel-insights: UI-side fetch so the main thread can createVideoAsync
        case 'FETCH_VIDEO':
          (async () => {
            try {
              const res = await fetch(msg.url);
              if (!res.ok) throw new Error('HTTP ' + res.status);
              const ab = await res.arrayBuffer();
              parent.postMessage({ pluginMessage: { type: 'FETCH_VIDEO_RESULT', requestId: msg.requestId, bytes: new Uint8Array(ab) } }, '*');
            } catch (err) {
              parent.postMessage({ pluginMessage: { type: 'FETCH_VIDEO_RESULT', requestId: msg.requestId, error: String((err && err.message) || err) } }, '*');
            }
          })();
          break;"""
old = """        case 'EXECUTE_CODE_RESULT':
          handleResult('EXECUTE_CODE', 'result');
          break;"""
if old not in src:
    print("  ANCHOR NOT FOUND (plugin version changed?):", path); sys.exit(2)
open(path, 'w', encoding='utf-8').write(src.replace(old, block, 1))
print("  patched:", path)
PY
  [ $? -eq 0 ] && patched=$((patched+1))
done < <(find "$HOME/Desktop" "$HOME/Downloads" "$HOME/.figma-console-mcp" "$HOME/.npm/_npx" -maxdepth 6 -name manifest.json 2>/dev/null -exec grep -l "figma-desktop-bridge-mcp" {} \; 2>/dev/null)
echo ""
[ "$found" -eq 0 ] && { echo "No Figma Desktop Bridge plugin folders found."; exit 1; }
echo "Done. found=$found patched=$patched already=$already"
[ "$patched" -gt 0 ] && echo "⚠ RE-RUN the plugin in Figma (Plugins → Development → Figma Desktop Bridge → Run) to load the new ui.html."
