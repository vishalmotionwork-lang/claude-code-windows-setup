---
name: Supabase Realtime presence handlers must attach BEFORE subscribe()
description: cannot add 'presence' callbacks for realtime:<topic> after 'subscribe()' — hard throw, no recovery
type: feedback
originSessionId: a7280e32-ea69-46c6-bed0-57ef46b21ddd
---
Supabase Realtime hard-throws `Error: cannot add 'presence' callbacks for realtime:<topic> after 'subscribe()'` if any `.on('presence', ...)` is attached after the channel has subscribed. Same is true for `postgres_changes` and `broadcast` handlers.

This bit content-ops hard on the Priority Board canvas: useBoardRealtime called `channel.subscribe()` at the end of its useEffect, then usePresence's useEffect (running AFTER per source order) tried `channel.on('presence', ...)` — Realtime threw, the throw bubbled to the React boundary, Next.js's global error boundary rendered "This page couldn't load." No console error in production builds because Next.js suppresses unhandled rejections.

**Why:** subscribe() locks the topic config — any handler added after that moment is rejected by the realtime broker. The error is informative but hard to spot in prod (suppressed boundary).

**How to apply:**
- One hook (or one effect) owns channel creation + ALL `.on()` handlers + subscribe() in that exact order.
- Don't split the channel and presence subscriptions across hooks unless you can guarantee handler attachment runs before subscribe().
- If a consumer needs to react to presence/sync events, expose a callback prop (refed for stability) and have the channel-owning hook invoke it from its own handler — don't let the consumer touch `channel.on()`.
- `channel.track()` and `channel.send()` are SAFE after subscribe — those are ops, not handlers. Cleanup with `channel.untrack()` or `supabase.removeChannel(channel)`.
