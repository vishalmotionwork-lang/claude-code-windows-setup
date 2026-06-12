---
name: reference_gstack_cookie_import_cloudflare_bypass
description: "Access a Cloudflare-protected, login-gated site (Circle community, LinkedIn) HEADLESSLY using the user's existing browser session — no manual login, no cookie file handoff. gstack browse + cookie-import-browser + cf_clearance/UA match."
metadata: 
  node_type: memory
  type: reference
  originSessionId: f86eb18d-9f1f-4dea-a661-41d8fab71f28
---

# Headless access to Cloudflare + login-gated sites via gstack + Brave cookies

Proven on the 9x teardown (LinkedIn + academy.go9x.com Circle community). Use when the user says "use my cookies / don't make me log in" and the target is auth-gated and/or behind Cloudflare.

## Tooling = gstack `browse` (NOT the live browser)
- gstack browse (`~/.claude/skills/gstack/browse/dist/browse`) CANNOT attach to the user's already-running browser. It only launches its OWN browser (launchPersistentContext at `~/.gstack/chromium-profile`, no CDP-attach, no profile override). Source: `browse/src/browser-manager.ts` (only env override is `GSTACK_CHROMIUM_PATH` for the executable).
- So: launch gstack's browser, then IMPORT the user's cookies into it.

## Setup gotcha (fresh installs)
gstack root (`~/.claude/skills/gstack`) may have NO `node_modules` even though `dist/browse` exists. The mac server runs from SOURCE (`bun run src/server.ts`), which needs deps. Fix:
- `cd ~/.claude/skills/gstack && bun install`  (gets `diff`, `playwright`)
- `cd ~/.claude/skills/gstack && bunx playwright install chromium`  (downloads the browser)

## Cookie import — match EXACT host_keys (the trap)
`$B cookie-import-browser brave --domain <d>` takes ONE `--domain`, matched EXACTLY against cookie `host_key` (no suffix match). "linkedin.com" imports 0 — auth cookies live on `.www.linkedin.com` (li_at!), `.linkedin.com` (liap). Steps:
1. Read host_keys from Brave DB (values stay encrypted; host_key is plaintext). Brave running locks the DB → copy first:
   `cp "$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Cookies" /tmp/x.db` (+ `-wal`), then `sqlite3 /tmp/x.db "SELECT host_key,name FROM cookies WHERE host_key LIKE '%TARGET%';"`
2. Run `cookie-import-browser brave --domain <host_key>` once PER exact host_key.
3. macOS shows a one-time Keychain "Brave Safe Storage" Allow prompt (cookie decryption) — that's NOT a login.

## Cloudflare bypass (the key trick)
The user's normal browser already passed Cloudflare → it holds `cf_clearance` (on `.domain.com`, covers subdomains) + `__cf_bm`. `cf_clearance` is bound to **user-agent + IP**. So headless can reuse it IF:
1. Import the `.domain.com` cookies (incl. `cf_clearance`).
2. Set browse UA to match the user's browser: `$B useragent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/<v>.0.0.0 Safari/537.36"` (Brave omits "Brave" from UA; uses generic Chrome). Same machine = same IP.
3. `goto` the site → Cloudflare waves it through (200, no "Just a moment").

## Order matters + session is fragile
- Set UA + import cookies BEFORE navigating.
- Every `$B disconnect` / new server = FRESH context → cookies lost. Re-import after any reconnect. Don't churn connect/disconnect mid-job.
- Headed mode (`$B connect`) can crash on mac (persistentContext closed / Mach rendezvous) with new Chromium + extension — headless `launched` mode works fine for scraping; don't fight headed if you don't need the user to watch.

## Notes
- Circle communities = cookies `_circle_session`, `remember_user_token`, `user_session_identifier` on the bare subdomain host_key.
- Screenshots: browse restricts output paths to `/tmp` or the gstack dir — save to `/tmp/x.png` then `mv` into the project.
- See also [[reference_company_founders_strategy_teardown]] (the workflow this enables).
