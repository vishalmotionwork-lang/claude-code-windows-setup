---
description: Beginning of Day — log planned tasks, match to verticals, push to core team dashboard
---

# BOD (Beginning of Day)

Fast, smart task logging for the core team dashboard. Uses a local cache to reason instantly.

## Step 1: Load Local Cache

Read the dashboard snapshot file:

```
~/.claude/context/dashboard-cache.md
```

If it doesn't exist or is older than 24 hours, refresh it:

```bash
psql "$CORE_TEAM_DB_URL" -c "
SELECT tm.name as member, v.id as vertical_id, v.name as vertical, v.icon, v.priority,
       json_agg(json_build_object('name', t.name, 'status', t.status, 'priority', t.priority) ORDER BY t.sort_order) FILTER (WHERE t.id IS NOT NULL) AS tasks
FROM team_members tm
JOIN verticals v ON v.team_member_id = tm.id
LEFT JOIN tasks t ON t.vertical_id = v.id
GROUP BY tm.name, tm.sort_order, v.id, v.name, v.icon, v.priority, v.sort_order
ORDER BY tm.name, v.sort_order;
" --pset=format=csv 2>/dev/null
```

Write the result to `~/.claude/context/dashboard-cache.md` with a timestamp header.

Also fetch team member IDs:
```bash
psql "$CORE_TEAM_DB_URL" -c "
SELECT id, name FROM team_members ORDER BY sort_order;
" --pset=format=csv 2>/dev/null
```

## Step 2: Collect & Infer

The user dumps tasks — text, voice, photos, bullet list, anything.

**Infer the person automatically** from context:
- If the user says "my tasks" or just lists tasks → it's **Vishal** (he's the primary user)
- If they mention a name ("Kunal needs to...", "for Harshit") → use that person
- If ambiguous for a specific task → ask ONLY for that task, not all of them
- If tasks span multiple people, group by person silently

## Step 3: Smart Reasoning (the core logic)

For each task, reason through these checks using the cached data:

### 3a. Vertical Matching
Match each task to the best vertical by comparing against:
- Vertical name and description
- Existing tasks in that vertical (semantic similarity)
- The person's vertical set (not another person's)

### 3b. Redundancy Detection
Before adding, check if the task **already exists** in the vertical:
- Exact match → skip, tell user "already tracked"
- Near match (same intent, different words) → ask "Is this the same as '[existing task]'? If so, skipping."
- Subtask of existing → suggest adding as a note on the existing task instead

### 3c. Contradiction Detection
Flag if:
- A task contradicts an existing task (e.g., "pause hiring" when "Hire 3 editors" is active)
- A task is assigned to a vertical that conflicts with the person's role
- A task duplicates work assigned to another person (cross-person overlap)
- Priority seems wrong (e.g., marking something p2 when the vertical is p0)

### 3d. New Vertical Detection
If a task doesn't fit ANY vertical:
- Suggest 1-2 closest verticals it COULD go under
- OR propose a new vertical with name + icon + description pre-filled
- Ask user to pick

## Step 4: Present Reasoning Table

Show ONE clean table with decisions already made (not asking for each one):

```
## BOD — [Person] — [Date]

| # | Task | → Vertical | Reasoning | Action |
|---|------|-----------|-----------|--------|
| 1 | Fix DaduOS login | ⚙️ Development | Matches DaduOS scope | ADD as new task |
| 2 | Review editor cuts | 🎬 Zeel IP | Already exists: "Quality control on all outgoing videos" | SKIP (duplicate) |
| 3 | Hire 2 more editors | 👥 Hiring | Similar to "Create freelance editor team" — more specific | REPLACE existing |
| 4 | Set up CRM pipeline | ❓ None | Closest: 💡 KnowAI or new vertical | NEEDS DECISION |

⚠️ Contradictions:
- None found (or list them)

📋 Today's Plan:
1. [vertical icon] Task 1
2. [vertical icon] Task 2
...
```

Only ask the user about items marked NEEDS DECISION. Everything else is pre-decided.

## Step 5: Confirm

> **Push this BOD?** (y/n/edit)
> - `y` = push all
> - `n` = cancel
> - `edit` = let me change something

## Step 6: Execute (single SQL batch)

On confirm, run ONE psql call with all operations:

```bash
psql "$CORE_TEAM_DB_URL" <<'SQL'
BEGIN;

-- Create daily entry
INSERT INTO daily_entries (team_member_id, entry_date, summary)
VALUES ('<member_id>', '<today>', '<summary>')
RETURNING id AS entry_id;
-- Use the returned ID below (or use a CTE)

-- Better: use CTE for atomic operation
WITH entry AS (
  INSERT INTO daily_entries (team_member_id, entry_date, summary)
  VALUES ('<member_id>', '<today>', '<summary>')
  RETURNING id
)
-- Planned items
INSERT INTO daily_items (daily_entry_id, vertical_id, type, content, sort_order)
SELECT entry.id, vals.vertical_id, 'planned', vals.content, vals.sort_order
FROM entry, (VALUES
  ('<vertical_id_1>'::uuid, '<task 1>', 0),
  ('<vertical_id_2>'::uuid, '<task 2>', 1)
) AS vals(vertical_id, content, sort_order);

-- New tasks (only genuinely new ones)
INSERT INTO tasks (vertical_id, name, note, status, priority, deadline, sort_order)
VALUES
  ('<vertical_id>', '<task name>', '<note>', 'active', '<priority>', 'Today', <N>);

-- New vertical (if needed)
INSERT INTO verticals (team_member_id, name, icon, priority, health, description, sort_order)
VALUES ('<member_id>', '<name>', '<icon>', '<priority>', 'on_track', '<desc>', <N>);

COMMIT;
SQL
```

## Step 7: Update Cache

After pushing, update `~/.claude/context/dashboard-cache.md` with the new data (append the new tasks/verticals to the cached copy so next BOD/EOD is instant).

## Step 8: Confirm

> BOD pushed for **[Person]** — [date]
> - [N] planned items logged
> - [N] new tasks added
> - [N] skipped (duplicates)
> - [N] new verticals created

## Connection

- **DB**: `$CORE_TEAM_DB_URL`
- **Cache**: `~/.claude/context/dashboard-cache.md`

## Daily Reset Rule

**Every day starts clean.** Previous days' planned items do NOT carry forward to today's dashboard.

- Yesterday's planned items (whether EOD was filed or not) stay in the **log tab under their date** as historical records
- They are NOT shown as today's priority — today's priority is ONLY what gets added via today's `/bod`
- If someone wants to work on the same task again, they must re-add it in today's `/bod`
- This prevents stale tasks from piling up and forces intentional daily planning
- The **Verticals tab** (long-running tasks) is separate — those persist until marked done. Daily planned items are ephemeral by design.

## Rules

- Default person = Vishal unless stated otherwise
- Pre-decide everything possible, only ask when genuinely ambiguous
- Always check for redundancy BEFORE presenting the table
- Flag contradictions prominently — don't bury them
- One SQL transaction, not multiple calls
- Update local cache after every push
- Today = current date, never hardcoded
- Previous days' planned items NEVER carry forward — each day is a clean slate
