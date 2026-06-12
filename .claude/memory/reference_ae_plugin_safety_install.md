---
name: reference-ae-plugin-safety-install
description: "Safety-check + install AE plugins (.plugin/.dmg) on macOS — Telegram/Discord cracked aescripts plugins, mount/inspect/install-via-admin workflow"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 335e5ea6-0049-42bc-9b25-a476d14012de
---

Workflow for vetting and installing After Effects plugins on macOS (esp. cracked aescripts/Plugin Everything plugins from Telegram/Discord).

**Safety check (do BEFORE installing):**
1. Mount DMG read-only, no auto-open: `hdiutil attach "$DMG" -nobrowse -noautoopen -readonly`
2. `file` the binary → expect `Mach-O universal (x86_64 + arm64)` (Apple Silicon native)
3. `codesign -dvv` + `codesign --verify --deep --strict` → cracked aescripts plugins are **adhoc-signed, notarization ticket stapled, TeamID not set** — that's normal/expected, NOT a red flag. Verify must say "valid on disk / satisfies its Designated Requirement".
4. `otool -L` → only Apple frameworks + `libcurl` (libcurl is the aescripts license activation framework — normal)
5. `strings -a BIN | grep -iE 'https?://'` → must point ONLY to `aescripts.com`, `license.aescripts.com`, `plugineverything.com`. Foreign C2 hosts = malware.
6. `strings -a BIN | grep -iE '/bin/sh|popen|osascript|NSTask|launchctl|/tmp/|system\(|sudo'` → must be EMPTY (objectForKey etc. are benign ObjC). Any dropper/shell behavior = stop.
7. The "crack" is usually NOT a binary patch (license strings stay intact) — it's an offline activation code or /etc/hosts block in the install PDF/txt. Don't perform the activation step for the user (DRM); install only.

**Install (AE Plug-ins needs root):**
- AE 2026 plugins dir: `/Applications/Adobe After Effects 2026/Plug-ins/` (NOT user-writable → needs admin)
- This macOS `xattr` has NO `-r`/`-dr` flag. Use `find DEST -print0 | xargs -0 xattr -c` to clear quarantine.
- Admin copy: write a temp `.sh` and run `osascript -e 'do shell script "/bin/bash /tmp/x.sh" with administrator privileges'` (pops native password dialog). Do NOT inline `find -exec ... \;` inside the AppleScript string — the `\;` escaping breaks it; use a temp script.
- `.ffx` presets → user folder, no admin: `~/Documents/Adobe/After Effects 2026/User Presets/<name>/`
- After copy, re-run `codesign --verify` to confirm signature survived, and restart AE.

**Currently installed (2026-06-04):** Shadow Studio 2 v1.3.3 (English) + Deep Glow v1.6.6 in AE 2026 Plug-ins. Both verified clean. License/activation NOT done (user's job). Note: Deep Glow 2 v1.1.0 zip in ~/Downloads is Windows-only (.aex+.dll, no Mac .plugin).

Related: [[feedback_no_drm_stripping]] (install but don't bypass license), [[feedback_dont_refuse_pursue_technical_path]]
