# Intern checklist — one reel at a time

You were shown one reel end-to-end. Repeat this for every new reel. Claude does the reading,
filling, and board-building; your job is to **capture and drop the files**.

## Per reel
1. **Give Claude the reel link** and answer:
   - Main feed or Trial reel?
   - Do you have a transcript, or should Claude make one?
2. Claude runs `new-reel.sh` — it downloads the reel, caption, (transcript), and makes the folder
   `reels/<id>/`.
3. **Capture the IG Insights at each time window** you can: **1h, 24h, 48h, weekly, lifetime**.
   For each, either:
   - take a **screenshot** (scroll Overview → Engagement → Audience, a few shots) → save as
     `reels/<id>/insights/<window>.png` (or `<window>_1.png`, `<window>_2.png`), OR
   - **screen-record** scrolling through all three tabs → save as `reels/<id>/insights/<window>.mp4`.
   Use the window name exactly: `1h` `24h` `48h` `weekly` `lifetime`.
4. Tell Claude which windows you added. Claude reads them and fills the data.
5. **Drag the reel video + one Insights recording onto the FigJam board** (board: "Trial strategy").
   Tell Claude — it records the node ids and builds the section.
6. Claude refreshes `MASTER.md`.

## Naming cheat-sheet
```
reels/<id>/
  reel.mp4               ← Claude downloads
  transcript.txt         ← Claude makes, or you paste
  caption.txt            ← Claude downloads
  insights/
    1h.mp4   1h.png      ← you drop, per window
    24h.mp4              ← you drop
    48h.mp4 …
    weekly.mp4 …
    lifetime.mp4 …
  data.json              ← Claude fills
```

## If something's missing
Run the doctor: `bash ~/.claude/skills/reel-insights/scripts/doctor.sh` — it tells you exactly
what to install. Don't capture Insights you can't see — just skip that window (Claude uses `null`).
