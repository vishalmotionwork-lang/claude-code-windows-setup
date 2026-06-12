---
name: reel-insights
description: >-
  Turn Instagram reels + their IG Insights into per-reel insight docs on a FigJam
  board, with a multi-window performance table (1h/24h/48h/weekly/lifetime) and a
  rolled-up MASTER.md context doc for feeding Meta AI / A-B comparison / scripting.
  Use when the user pastes an Instagram reel link to analyze, sends Insights
  screenshots/recordings, asks to build the "Trial strategy" board, or says
  "add this reel", "reel insights", "ab testing reels", or "update the master doc".
---

# reel-insights

End-to-end pipeline: **reel link + IG Insights → a FigJam doc per reel → a MASTER.md
context doc**. Metric of record = **views**. Built for @zeeeljain (KnowAI) but
project-parameterized (see `reels.config.json`).

Scripts live in `scripts/` and operate on the **current project directory** (cwd) — so
the same skill drives any project folder on any machine. Full pipeline + Figma gotchas:
`reference/WORKFLOW.md`. The step-by-step playbook: `reference/INTAKE.md`.

## 0. First run on a machine — check dependencies
ALWAYS run the doctor first on a new setup; it prints the exact fix for anything missing:
```bash
bash ~/.claude/skills/reel-insights/scripts/doctor.sh
```
Needs: `node` (18+), `yt-dlp`, `ffmpeg`, `curl`; optional `GROQ_API_KEY` (transcription);
the `figma-console` MCP + Figma Desktop Bridge plugin running on the target FigJam board.

## When the user pastes a reel — the flow
Work from the project directory (e.g. `~/ab-testing`). For each reel:

1. **Ask two things** (the user answers at paste time):
   - **"Main feed or Trial reel?"** → `--type feed` or `--type trial` (drives the top-right tag).
   - **"Do you have the transcript, or should I generate it?"** → if generate, add `--transcribe`.
2. **Intake** (downloads reel + caption, scaffolds the folder, optional transcript, data.json stub):
   ```bash
   scripts/new-reel.sh <reel-url> --type trial --transcribe --windows 1h,24h,48h,weekly,lifetime
   ```
3. **Insights, per time window.** The user (or an intern) sends the IG Insights for each window
   they've captured — **screenshot** or **screen-recording**:
   - screenshot → save to `reels/<id>/insights/<window>.png` → Claude reads it directly (vision).
   - recording → save to `reels/<id>/insights/<window>.mp4` → `scripts/extract-frames.sh <id> <window>`
     → Claude reads the frames.
   Windows: `1h` `24h` `48h` `weekly` `lifetime`.
4. **Claude fills `reels/<id>/data.json`** → `windows.<window>` (views, reached, avg watch, skip,
   retention end, follows, likes/comments/shares/saves/reposts, profile visits, bio taps) and the
   `stable` block once (discovery sources, audience age, languages, retention start). `null` for
   anything not visible in that capture.
5. **Put media on the board + build:** drag the reel video + an Insights recording onto the FigJam
   board, record their node ids into `data.json` → `nodes.*`, then:
   ```bash
   node scripts/prep.mjs --move-videos      # → .reel-build/_payload.js
   ```
   Paste `.reel-build/_payload.js` into figma-console **figma_execute**. Builds a section
   `#<rank> · <Title> · <views> views` with the post-type tag top-right, videos, and the doc
   (multi-window table). Without `--move-videos` it previews the doc only, in empty space.

   **Playable videos** — the ONLY way to get a real playable node on a FigJam board is the
   **OS-paste route** (clipboard → ⌘V/Ctrl+V → Figma's native importer → native MEDIA node).
   The plugin API cannot create a playable video node (createVideoAsync = static poster in FigJam;
   confirmed). Per reel, SERIAL, Claude-driven via the bridge:
   ```bash
   # macOS  (needs Accessibility permission for the terminal):
   bash scripts/paste-video-mac.sh reels/<id>/reel.mp4
   # Windows:
   powershell -ExecutionPolicy Bypass -File scripts\paste-video-win.ps1 -File reels\<id>\reel.mp4
   ```
   Orchestration: bridge snapshots MEDIA ids → run paste script → poll for the NEW MEDIA node →
   rename/resize/move into its section. Full recipe + gotchas: `reference/PASTE-AUTOMATION.md`.
   (Old `createVideoAsync`/CORS route = poster only, deprecated — see `reference/VIDEO-AUTOMATION.md`.)
6. **Refresh the master doc:**
   ```bash
   node scripts/master.mjs                  # → MASTER.md
   ```

## The intern model
An intern can run this after being shown ONE reel end-to-end. Their job: for each reel, capture
the IG Insights at 1h / 24h / 48h / weekly / lifetime and drop each as
`reels/<id>/insights/<window>.{mp4,png}`. Claude does the rest (reads, fills, builds, masters).
Keep `reference/INTAKE.md` open as their checklist.

## Time windows show as COLUMNS
Each doc's "Performance over time" section is a table: metric rows × window columns. Whatever
windows are present render as columns (so one capture = one column; five = five). FigJam has no
working interactive toggle — columns are the robust, always-visible choice.

## Sharing this skill
It's a git repo. On another machine: `git clone <url> ~/.claude/skills/reel-insights`, then run the
doctor. Project data (videos, etc.) stays OUT of the skill — each project is its own dir.
