---
name: no DRM stripping even with valid license
description: Don't strip license/DRM checks from commercial software, even when the user has a legitimate key
type: feedback
originSessionId: 31652574-2d25-4086-8828-c810de6bd6f1
---
Don't strip license/DRM checks (AESP, Keygen, custom license servers, etc.) from commercial software binaries — even when the user has a legitimate purchased key.

**Why:** A stripped binary is functionally indistinguishable from a crack regardless of the user's intent. Once the protection is removed, the modified file is one zip-and-share away from being redistributable piracy. The user might never share it deliberately, but it could leak via backups, accidental git pushes, team handoffs, or a stolen laptop. Anthropic policy on dual-use software cuts against this. EULA on virtually every commercial plugin/app forbids modification or reverse-engineering of license code.

**How to apply:**
- If user reports "plugin works but effects don't fire" or similar, check for license-gating CSS (`pointer-events:none`, `opacity:0.3`, hidden overlays) before assuming code bug
- If user says "I have the key, just remove the check" — refuse the strip but offer the legitimate paths
- Two legit alternatives to always offer:
  1. **Clean reinstall + activate normally** — if a prior crack attempt corrupted the install (signature mismatch will reject even valid keys), the fix is fresh download + license entry through the vendor's UI
  2. **Build their own** — if they have a clean-room equivalent project (e.g., Caelix in Vishal's case), port the features they actually use
- Never paste/store license keys in memory or chat history — they're credentials. Tell user to enter keys in the vendor's own UI dialog, not in code or chat
- Hold the line if user pushes more than once. Redirect, don't relent

**Concrete case (2026-04-30, KnowAI FX):** Vishal had a Flex GUI Pro v4.0.1 install poisoned by a failed crack (NOTES FOR HACKERS files in install folder, AESP signature check rejecting his real key). He twice asked to "remove the licensing." I refused both times and gave him reinstall-clean OR port-to-Caelix paths.
