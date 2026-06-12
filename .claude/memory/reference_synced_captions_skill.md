---
name: reference-synced-captions-skill
description: synced-captions skill — word-synced phrase-aware caption SRT from local file or URL (reels-style 1-2 word lines). Built 2026-06-04.
metadata: 
  node_type: memory
  type: reference
  originSessionId: d3b517a5-8034-43b0-b312-73c8ba66978b
---

# synced-captions skill (caption SRT generator)

Shareable skill at `~/.claude/skills/synced-captions/` (SKILL.md + scripts/synced_captions.py).
Built 2026-06-04 while making 2-word synced captions for Vishal's "Paypal collab raw.mov" reel.

## What it does
Local audio/video file **OR** URL (IG/YouTube/TikTok/direct) → Groq Whisper word-level →
phrase-aware short captions (default 2 words) → punctuation-stripped → monotonic `.srt`.

Run:
```
~/.claude/skills/synced-captions/scripts/synced_captions.py "<file-or-URL>" --max-words 2
```
Flags: `--max-words N`, `--out PATH`, `--keep-punct`, `--model`, `--language`.
Output defaults: next to local file (`<base>-synced.srt`), or `~/Downloads/transcripts/<today>/` for URLs.

## Pipeline (the working recipe — reuse even outside the skill)
1. `ffprobe` duration sanity check (a 5GB ProRes .mov was only ~59s — size ≠ length).
2. `ffmpeg -vn -ac 1 -ar 16000 -b:a 64k` → mono 16kHz mp3 (fits Groq's 25MB upload limit).
3. Groq: `response_format=verbose_json` + `timestamp_granularities[]=word`.
   GOTCHA: `whisper-large-v3-turbo` REJECTS `response_format=srt` ("must be json/text/verbose_json").
   So always request verbose_json and build the SRT yourself.
4. Group words into chunks; SRT timing = first word `start` → last word `end`.
5. Clamp each caption start to previous caption end → strictly monotonic (Whisper word stamps
   overlap slightly at segment seams; un-clamped you get two captions on screen at once).

## Phrase-grouping heuristic (what "2 words that make sense" means)
Vishal's correction: a mechanical every-2-words split ("Hi, I'm" / "Zeel. I") is wrong.
Want natural units: "I'm Zeel" / "I spent" / "the last" / "10 years".
Rule: greedy chunks up to N words, but a chunk may NEVER END on a "leader" word
(a/an/the, of/to/with/from/as/for/in/on, and/or/but/so, my/your/this/that,
subject pronouns I/you/we/they…). If the candidate last word is a leader, shrink by one so
it leads the NEXT caption. TRAILING_AVOID set is in the script.
Note: the auto-heuristic is ~90% as clean as hand-grouping; stacked function words
("with a lot of") still produce occasional lone words. For a hero asset, hand-tune the groups.

## Punctuation rule
Strip `. , ! ? ; : " () [] …` BUT preserve: decimal points inside numbers (`1.9`), `%`,
and apostrophes in contractions (`I'm`/`I'll` — never let them become `Im`/`Ill`).
Regex for periods: `re.sub(r'(?<!\d)\.(?!\d)', '', text)`. `--keep-punct` keeps everything.

## Sharing caveat
Reads `GROQ_API_KEY` from env, falls back to machine-specific creds file
(`~/.claude/projects/-Users-vishal-motion/memory/groq-api-creds.md`). To share, set env var.
Deps: ffmpeg + curl (+ yt-dlp only for URLs).

## Relation to other tools
- `/transcript` command ([[reference_transcript_command]]) = plain .txt from URLs only.
  This skill = timed .srt, local files too, word-synced + phrase-aware.
- Groq key: [[groq-api-creds]].

Delivered artifact for the PayPal reel (hand-tuned, better than auto for that clip):
`~/Downloads/transcripts/2026-06-04/paypal-collab-raw-2word.srt` (115 captions).
