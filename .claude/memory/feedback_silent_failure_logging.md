---
name: Silent failure logging on integrations
description: Notification/integration code paths must log every skip reason; empty catch blocks hide real bugs from the user
type: feedback
originSessionId: ea0dcdd4-bfdb-4e44-be5a-4084fcba94e6
---
When wiring up Slack/email/webhook/notification code, every skip path must
emit a clear `console.warn` (or `console.error`) explaining why a message
was NOT sent. Empty `catch {}` blocks and silent `if (!cond) return false`
branches turn debuggable problems into ghost bugs.

**Why:** content-ops Slack comment notifications "stopped working" — but
the infrastructure was already correct. The bug was that every layer
silently swallowed failures: `shouldNotify` returned false with no log,
`fetch` errors were caught and discarded, the call site added another
`.catch(() => {})` on top. The user had no way to know the
`comment_mentions` toggle wasn't ticked. After adding logs at every skip
point the diagnosis became obvious from Vercel logs.

**How to apply:**
- `if (!webhookUrl) { console.warn("[slack] skipped: no webhook URL configured"); return false; }`
- `if (!settings.notifications?.[eventType]) { console.warn(\`[slack] skipped: notifications.\${eventType} is not enabled\`); ... }`
- After `fetch(webhook)`, check `!response.ok` and log status + body
- `try/catch` on network calls should `console.error` the error, NEVER
  silently `return false` or `.catch(() => {})`
- At the call site, replace `.catch(() => {})` with `.catch((err) =>
  console.error("[component] send failed:", err))`

The user can read Vercel logs. They cannot read your imagination. Make
silent failures shout.
