---
description: End of Day — log what got done, issues, notes, update task statuses in core team dashboard
---

# EOD (End of Day)

Fast end-of-day logging. Cross-references today's BOD, updates task statuses, flags what didn't get done.

## Step 1: Load Local Cache + Today's BOD

Read `~/.claude/context/dashboard-cache.md` for verticals/tasks.

Then fetch today's BOD entry:

```bash
psql "$CORE_TEAM_DB_URL" -c "
SELECT de.id as entry_id, de.summary,
       json_agg(json_build_object('id', di.id, 'content', di.content, 'type', di.type, 'vertical_id', di.vertical_id, 'is_completed', di.is_completed) ORDER BY di.sort_order) AS items
FROM daily_entries de
LEFT JOIN daily_items di ON di.daily_entry_id = de.id
JOIN team_members tm ON de.team_member_id = tm.id
WHERE tm.name = '<MEMBER_NAME>' AND de.entry_date = CURRENT_DATE
GROUP BY de.id, de.summary;
" --pset=format=csv 2>/dev/null
```

## Step 2: Collect & Infer

User dumps what they did today. Same inference rules as BOD:
- Default person = Vishal
- Infer from context, only ask if ambiguous

## Step 3: Smart Reasoning

### 3a. Classify Each Item
- **done** — completed work
- **issue** — blocker, problem, something that went wrong
- **note** — observation, decision, context for future

### 3b. BOD Cross-Reference (if BOD exists)
For each BOD planned item, determine:
- **Completed** — user mentioned doing it → mark `is_completed = true`
- **Not mentioned** — user didn't mention it → note as incomplete, stays in the date log (no carry-forward)
- **Partially done** — user mentions progress but not completion → log as note, keep planned item incomplete

### 3c. Task Status Updates
For each done item, check if it matches an existing task in the vertical:
- If task exists and is now fully complete → suggest `status = 'done'`
- If task exists but this was just progress → keep `status = 'active'`, add as daily done item only
- If no matching task exists → it's ad-hoc work, log as daily done item only (don't create a new task just to mark it done)

### 3d. Redundancy & Contradiction (same as BOD)
- Don't log the same done item twice
- Flag if a done item contradicts a planned item (e.g., planned "hire editors" but did "paused all hiring")
- Flag cross-person overlap

## Step 4: Present Reasoning

```
## EOD — [Person] — [Date]

### BOD Completion
| # | Planned | Status |
|---|---------|--------|
| 1 | Fix DaduOS login | DONE |
| 2 | Review editor cuts | NOT DONE — stays in log |
| 3 | Script research | PARTIAL — logged progress |

### Today's Work
| # | Item | Type | → Vertical | Task Update |
|---|------|------|-----------|-------------|
| 1 | Fixed DaduOS login flow | done | ⚙️ Development | Mark "Fix DaduOS login" → done |
| 2 | Editor no-showed | issue | ✂️ Editing | No task change |
| 3 | Decided brand colors with Kunal | note | 🚀 Vishal IP | No task change |
| 4 | Built hiring form from scratch | done | 👥 Hiring | New ad-hoc work (no task created) |

⚠️ Contradictions: None

### Not Done (stays in log, won't carry to tomorrow)
- Review editor cuts → logged under today, not carried forward
```

Pre-decide everything. No carry-forward questions — incomplete items just stay in the date log.

## Step 5: Confirm

> **Push this EOD?** (y/n/edit)

## Step 6: Execute (single SQL batch)

```bash
psql "$CORE_TEAM_DB_URL" <<'SQL'
BEGIN;

-- If no daily entry exists (no BOD), create one
-- If BOD exists, use that entry_id and update summary
UPDATE daily_entries SET summary = '<updated summary>'
WHERE id = '<entry_id>';

-- Add done/issue/note items
INSERT INTO daily_items (daily_entry_id, vertical_id, type, content, sort_order)
VALUES
  ('<entry_id>', '<vid1>'::uuid, 'done', '<what was done>', 0),
  ('<entry_id>', '<vid2>'::uuid, 'issue', '<the issue>', 1),
  ('<entry_id>', NULL, 'note', '<the note>', 2);

-- Mark BOD planned items as completed
UPDATE daily_items SET is_completed = true
WHERE id IN ('<planned_item_id_1>', '<planned_item_id_2>');

-- Update task statuses
UPDATE tasks SET status = 'done' WHERE id = '<task_id>';

COMMIT;
SQL
```

If no daily entry exists (skipped BOD):
```sql
WITH entry AS (
  INSERT INTO daily_entries (team_member_id, entry_date, summary)
  VALUES ('<member_id>', CURRENT_DATE, '<EOD summary>')
  RETURNING id
)
INSERT INTO daily_items (daily_entry_id, vertical_id, type, content, sort_order)
SELECT entry.id, vals.vertical_id, vals.type, vals.content, vals.sort_order
FROM entry, (VALUES
  ('<vid>'::uuid, 'done', '<task 1>', 0),
  ('<vid>'::uuid, 'issue', '<issue 1>', 1)
) AS vals(vertical_id, type, content, sort_order);
```

## Step 7: Update Cache

Update `~/.claude/context/dashboard-cache.md`:
- Mark completed tasks as `done` in the cache
- Add any new data

## Step 8: Confirm

> EOD pushed for **[Person]** — [date]
> - [N] done items logged
> - [N] issues flagged
> - [N] notes added
> - [N] tasks marked done
> - [N] BOD items completed ([M] of [Total] planned)
> - [N] incomplete (stays in date log, no carry-forward)

## Connection

- **DB**: `$CORE_TEAM_DB_URL`
- **Cache**: `~/.claude/context/dashboard-cache.md`

## Daily Reset Rule

**Every day starts clean.** Planned items do NOT carry forward — they stay in the log under their date.

- If EOD is filed: planned items get marked done/issue/note — they're logged and archived under that date
- If NO EOD is filed: planned items still stay under that date in the log — they do NOT appear on tomorrow's dashboard
- Tomorrow's "Today" tab is empty until tomorrow's `/bod` is run
- The **Verticals tab** (long-running tasks) is separate and persists until explicitly marked done
- Daily planned items are ephemeral by design — forces intentional daily planning

When showing BOD cross-reference, do NOT ask "carry forward?" for incomplete items. Instead:
- Log them as-is (incomplete planned items under today's date)
- They'll be visible in the Log tab history
- If the person wants to work on them again, they re-add via tomorrow's `/bod`

## Rules

- Default person = Vishal
- Pre-decide everything, only ask about genuinely ambiguous items
- Always show BOD cross-reference if BOD exists
- Don't create tasks just to mark them done — ad-hoc work is a daily_item only
- Flag contradictions between planned and actual work
- One SQL transaction
- Update local cache after push
- Today = current date
- NO carry-forward — each day is a clean slate
