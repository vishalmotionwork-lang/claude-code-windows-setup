# Content Agent

Create content from multiple sources (YouTube, PDFs, Instagram, local files) with proper source referencing and analysis.

## Quick Reference

| Action | How |
|--------|-----|
| Load YouTube transcript | `python3 ~/.claude/scripts/youtube_transcript.py "URL"` via Bash |
| Load PDF | Read tool on the PDF file path directly |
| Load Instagram content | Rube MCP: RUBE_SEARCH_TOOLS then RUBE_MULTI_EXECUTE_TOOL |
| Load local file | Read tool on the file path |
| Save source to memory | Write to `~/.claude/projects/-Users-vishal-motion/memory/sources/` |
| List saved sources | Glob `~/.claude/projects/-Users-vishal-motion/memory/sources/*.md` |

## Source Loading Workflows

### YouTube Transcripts

```bash
python3 ~/.claude/scripts/youtube_transcript.py "https://youtube.com/watch?v=XXXXX"
```

The script returns JSON with:
- `video_id`: YouTube video ID
- `title`: Video title (from page metadata)
- `url`: Original URL
- `segments`: Array of `{text, start, duration}` timestamped segments
- `full_text`: Concatenated plain text of all segments

After loading, save to memory:

```
~/.claude/projects/-Users-vishal-motion/memory/sources/yt-<video_id>.md
```

Format:
```markdown
# [Video Title]
- **Source**: YouTube
- **URL**: https://youtube.com/watch?v=XXXXX
- **Loaded**: YYYY-MM-DD

## Transcript
[full transcript with timestamps as inline references]
```

### PDF Documents

Use the Read tool directly on any PDF path:

```
Read: /path/to/document.pdf
```

Claude natively reads PDFs. After loading, save key content to memory:

```
~/.claude/projects/-Users-vishal-motion/memory/sources/pdf-<slug>.md
```

Format:
```markdown
# [Document Title]
- **Source**: PDF
- **Path**: /path/to/document.pdf
- **Pages**: N
- **Loaded**: YYYY-MM-DD

## Key Content
[extracted content with page references]
```

### Instagram Content

Use Rube MCP to access Instagram data:

1. Search for tools:
```
RUBE_SEARCH_TOOLS -> queries: [{use_case: "fetch Instagram post content"}]
```

2. Execute with discovered tools:
```
RUBE_MULTI_EXECUTE_TOOL -> tool_slug from search results
```

3. Save to memory:
```
~/.claude/projects/-Users-vishal-motion/memory/sources/ig-<post_id>.md
```

### Local Files (Text, Markdown, etc.)

Use the Read tool on any local file. Save to memory if it will be referenced across sessions.

## Source Reference Format

ALL content outputs MUST include source references using these formats:

| Source Type | Reference Format |
|-------------|-----------------|
| YouTube | `[Source: "Video Title" @ MM:SS]` |
| PDF | `[Source: "document.pdf" p.N]` |
| Instagram | `[Source: @handle, post YYYY-MM-DD]` |
| Local file | `[Source: "filename.ext"]` |
| Memory | `[Source: memory/sources/slug.md]` |

When multiple sources inform a point, list all: `[Source: "Video A" @ 2:15; "doc.pdf" p.3]`

## Content Analysis Patterns

When analyzing any source content, identify and report on:

### Hook Analysis
- **Opening hook**: First 3-5 seconds (video) or first line (text)
- **Hook type**: Question, bold claim, pattern interrupt, story, statistic
- **Effectiveness**: Does it create curiosity gap? Immediate relevance?

### Structure Analysis
- **Framework**: What organizational pattern is used?
- **Transitions**: How does it move between sections?
- **Pacing**: Density of information vs. breathing room
- **Length**: Total duration/word count and per-section breakdown

### CTA (Call to Action) Analysis
- **Primary CTA**: What is the main ask?
- **CTA placement**: Where in the content? How introduced?
- **Soft CTAs**: Any embedded mid-content asks?
- **Urgency/scarcity**: Techniques used to drive action

### Engagement Signals
- **Retention hooks**: Questions, loops, teasers for what is next
- **Pattern interrupts**: Visual/tonal changes to recapture attention
- **Social proof**: Testimonials, numbers, authority signals
- **Emotional arc**: How does the emotional register shift?

## Output Formats

### Script Format
```markdown
## [Title]

**Hook** (0:00-0:05)
[Opening line/visual]

**Section 1: [Topic]** (0:05-0:30)
[Content with delivery notes]

**CTA** (end)
[Call to action]

---
Sources: [list all source references]
```

### Post Format (Social Media)
```markdown
[Hook line]

[Body - 3-5 short paragraphs]

[CTA]

---
Sources: [list all source references]
```

### Analysis Format
```markdown
## Content Analysis: [Title]

### Overview
- **Type**: [video/post/article]
- **Length**: [duration/word count]
- **Topic**: [main subject]

### Hook
[analysis with source refs]

### Structure
[analysis with source refs]

### CTA
[analysis with source refs]

### Key Takeaways
1. [takeaway] [Source: ...]
2. [takeaway] [Source: ...]

### Recommendations
- [actionable suggestion based on analysis]
```

## Knowledge Base

Sources are persisted in: `~/.claude/projects/-Users-vishal-motion/memory/sources/`

### Naming Convention
- YouTube: `yt-<video_id>.md`
- PDF: `pdf-<descriptive-slug>.md`
- Instagram: `ig-<post_id>.md`
- Other: `src-<descriptive-slug>.md`

### Index File
Maintain an index at: `~/.claude/projects/-Users-vishal-motion/memory/sources/INDEX.md`

Format:
```markdown
# Source Index

| Slug | Title | Type | Date | Tags |
|------|-------|------|------|------|
| yt-abc123 | Video Title | YouTube | 2025-01-15 | marketing, hooks |
```

### Workflow
1. Load source -> analyze -> save to memory with references
2. Before creating content, check INDEX.md for relevant prior sources
3. Cross-reference multiple sources when creating new content
4. Update INDEX.md when adding or removing sources
