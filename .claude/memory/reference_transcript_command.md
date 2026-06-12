---
name: reference_transcript_command
description: /transcript slash command — Groq Whisper transcription of any URL (Instagram/YouTube/TikTok/direct media)
type: reference
originSessionId: 0019f671-82cc-475b-8fda-2e089f84597a
---
# /transcript command

User-installed slash command for one-shot audio/video transcription. Built 2026-04-26.

## Files
- `~/.claude/commands/transcript.md` — slash-command workflow Claude follows
- `~/.claude/scripts/transcribe.sh` — bash helper (the actual pipeline, executable)

## Usage
```
/transcript URL [URL ...]
```
Multiple URLs run in parallel. No args → ask user to paste links.

## Pipeline
1. `yt-dlp -x --audio-format mp3` downloads audio (handles Instagram, YouTube, TikTok, direct media)
2. If file >25MB, `ffmpeg` downsamples to mono 16kHz mp3 (Groq's 25MB cap)
3. POST to `https://api.groq.com/openai/v1/audio/transcriptions` with `whisper-large-v3-turbo`
4. Save `.mp3` + `.txt` to `~/Downloads/transcripts/YYYY-MM-DD/<slug>.txt`
5. Print transcript to stdout
6. Cached — re-running on same URL reuses `.txt`, no re-billing

## Slug format (stable, derived from URL)
- Instagram reel: `<username>-<post_id>` (e.g. `askcatgpt-DVmqoTwgv5g`)
- Instagram p/: `ig-<post_id>`
- YouTube: `yt-<video_id>`
- TikTok: `tt-<video_id>`
- Other: `url-<sha10>`

## Groq config
- Key auto-read from `~/.claude/projects/-Users-vishal-motion/memory/groq-api-creds.md`
- Override: `GROQ_API_KEY` env var
- Override model: `GROQ_WHISPER_MODEL` env var (default `whisper-large-v3-turbo`)
- Free tier: 7,200s audio/day, 100 req/min, 25MB max file

## Failure modes
- Private Instagram posts → may need `yt-dlp --cookies-from-browser chrome` (edit script if recurring)
- Geo-blocks → tell user, don't auto-retry
- Groq rate limit → script returns curl error verbatim
