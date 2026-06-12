---
name: Claude Code Channels & Remote Access
description: Telegram channel, remote sessions, aliases, trade-offs, and when to use which — full remote access reference
type: reference
---

## Remote Access Options

| Method | Launch | Mid-session? | Interface | Best for |
|--------|--------|-------------|-----------|----------|
| **Remote Control** | `claude --remote` or `/remote` | Yes | Full Claude Code UI in browser | Steering complex work remotely |
| **Telegram Channel** | `claude --channels plugin:telegram@...` | No (launch only) | Telegram chat | Quick questions, status checks from phone |

**Key insight**: `/remote` works anytime mid-session. `--channels` (Telegram) must be set at launch. So default to `claude-tg` and add `/remote` when needed.

## Shell Aliases (in ~/.zshrc)

| Alias | Command | Use case |
|-------|---------|----------|
| `claude-tg` | `claude --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions` | Telegram-ready, hands-free |
| `claude-remote` | `claude --remote` | Remote browser UI from the start |
| `claude-full` | `claude --remote --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions` | Both remote + Telegram |

## Remote vs Telegram — When to Use Which

**Remote wins**: See terminal output, diffs, approve permissions, steer multi-step work, code review
**Telegram wins**: Push notifications, native app speed, lightweight, webhook receiver

**Telegram can't**: Show diffs, show tool output, approve permission prompts remotely, be added mid-session

| Situation | Use |
|-----------|-----|
| Quick question from phone | Telegram |
| Steering a refactor remotely | `/remote` |
| Serious code review from phone | `/remote` only |
| CI/deploy webhook alerts | Telegram channel |
| Want both available | `claude-full` |

## Telegram Setup (Complete — 2026-03-21)

- **Bot token**: `~/.claude/channels/telegram/.env` (chmod 600)
- **Access config**: `~/.claude/channels/telegram/access.json`
- **DM policy**: `allowlist` (locked down)
- **Approved senders**: `1135180972` (Vishal's Telegram ID)
- **Plugin**: `telegram@claude-plugins-official` (installed)

**Plugin install** (already done):
```
/plugin marketplace add anthropics/claude-plugins-official
/plugin install telegram@claude-plugins-official
```

**Adding someone else**:
1. `/telegram:access policy pairing` (temporarily)
2. They DM the bot → get code
3. `/telegram:access pair <code>`
4. `/telegram:access policy allowlist` (lock back)

Access changes take effect immediately (no restart). Token changes need restart.

## Discord Setup (not yet configured)
Same pattern — install plugin, configure token, launch with `--channels`, pair.

## Key Rules
- `--channels` = launch-time only, cannot add mid-session
- `/remote` = works anytime mid-session
- Permission prompts block locally unless `--dangerously-skip-permissions` is used
- Session must be running for Telegram messages to arrive
- `/telegram:configure` and `/telegram:access` only available when launched with `--channels`
