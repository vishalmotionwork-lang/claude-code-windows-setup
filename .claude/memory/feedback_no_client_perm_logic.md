---
name: feedback_no_client_perm_logic
description: Permissions, role lists, and security-relevant rules belong on the server only — never duplicated in the frontend
type: feedback
originSessionId: ba80dbe7-c2b8-43dc-9923-d3baa5adfa76
---
When a feature has role-based access or permission rules, the frontend MUST NOT carry the role list, the rule logic, or any duplicated check. The frontend asks the server "can this user do X?" and renders accordingly. The server is the only gate.

**Why:** The user explicitly called this out 2026-04-30 in content-ops. Their phrasing: "all by modular no hardcode or loose logic" / "use standard practice no hardcoding and ui logics and security no logic in frontend." They had just discovered that the link-submissions UI was doing its own role check (`copy.roles.includes(userRole) || userLevel === "lead"`) — which (a) could be edited by anyone with devtools, (b) had a real bug where any "lead" access level could submit at any stage, and (c) duplicated the rules already in the API. Two-place rules drift.

**How to apply:**

1. **Single rule module** in `lib/`. Server-only. Never imported by anything in `components/` or `app/` outside `app/api/`. Example: `lib/submission-rules.ts` exporting `SUBMISSION_RULES` map + `getAllowedRule(stage, role, level)` helper.
2. **Permission helpers** (`canManageLink`, `canEditTask`, etc.) live in `lib/permissions.ts` and accept primitive args (level, role, ids). Used both by API for gating AND by API to compute per-row flags returned to the client.
3. **Status endpoint** for "can I do X right now?" — e.g., `GET /api/links/submission-status?taskId=&userId=` returns `{ canSubmit, copy, nextStage, waitingOnRoles }`. Frontend fetches and renders.
4. **Per-row flags on list endpoints** when actions are per-item — e.g., `GET /api/links?...&userId=` returns each row with `canEdit`/`canDelete` precomputed. UI gates buttons on `row.canEdit`, never on `user.role === "admin"`.
5. **Mutation endpoints re-validate** with the same helper — never trust the client passed `userId` without looking up that user's actual role/level from the DB.
6. UI copy that depends on rules (button labels, hint text, "waiting on…" banners) also comes from the server, not a client switch statement on `stage`. Otherwise copy drifts when rules change.

**Anti-patterns to refuse:**
- `if (user.role === "admin") { showButton() }` in a component.
- A `ROLES_WHO_CAN_X = ["editor", "admin"]` constant in `components/`.
- `const canSubmit = stage === "editing" && (role === "editor" || level === "lead")` anywhere outside `lib/<feature>-rules.ts`.
- Duplicating server enums/maps to a frontend file "for convenience."

**Test it:** if you can `curl -X DELETE /api/<resource>?id=X&userId=<member-id>` and the server lets it through, the gate isn't real — fix the API before fixing the UI.
