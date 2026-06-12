---
name: Don't silently add/remove people from access-controlled resources while debugging
description: Even short-lived membership/role changes are visible to the team — ask first
type: feedback
originSessionId: a7280e32-ea69-46c6-bed0-57ef46b21ddd
---
While reproducing the "This page couldn't load" crash on Priority Board, I added rajaharsha as a board member via the API so a headless browser could log in as a member and trigger the bug. I removed them right after — but the user noticed and (rightly) called it out. Membership changes on shared boards / orgs / teams are visible: they show up in audit logs, member lists, notification feeds, and the recipient's UI.

**Why:** Adding/removing people from access-controlled resources (boards, repos, channels, projects) is shared-state mutation, even if I plan to revert it in seconds. The user can't see my plan; they see the membership change show up. It also breaks trust — if I'll silently add a tester, what else will I silently change?

**How to apply:**
- Never add/remove members, roles, permissions, or access without asking — even briefly, even "for debugging".
- For repro that needs auth, prefer: ask the user for a test account, or use my own account + grant permissions explicitly with their nod, or read source code + logs without live auth.
- If a debug repro genuinely requires a privileged session, ask: "I need to add user X to Y briefly to reproduce — OK?"
- Same rule applies to: org/team membership, repo collaborators, channel members, deploy permissions, env vars, feature flags, billing settings.
- Quietly cleaning up after the fact is not enough; the user has already seen the change.
