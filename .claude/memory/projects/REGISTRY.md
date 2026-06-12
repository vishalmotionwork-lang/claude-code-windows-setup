# Project Registry

> One row per project, newest-touched first. Each project owns a folder under
> `~/.claude/memory/projects/<name>/` with CONTEXT.md (stack/URLs/commands),
> SESSION.md (last state + next steps), and DECISIONS.md (architecture choices).

| Project | Last touched | One-line status |
|---------|--------------|-----------------|
| _(your first project will go here)_ | | |

## How this works
- When you start work, I ask which project (top 5 by last-touched).
- New project not listed? I create `projects/<name>/` with CONTEXT.md + SESSION.md and add a row here.
- Session end: I update the project's SESSION.md and bump its last-touched date here.
