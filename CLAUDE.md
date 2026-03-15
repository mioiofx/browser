# Claude Instructions

## Session Start

At the beginning of every session, read all files in the `/memory` directory to restore context:

```
memory/decisions.md   - past architectural and technical decisions
memory/people.md      - people involved in the project
memory/preferences.md - coding style, tooling, and workflow preferences
memory/user.md        - information about the user(s)
```

Use this context to inform responses, avoid re-asking known information, and maintain continuity across sessions.

## Session End

Before ending a session (when the user signals they are done, or when wrapping up a significant piece of work), update the relevant memory files with anything new learned:

- **decisions.md**: Any architectural or technical decisions made, with rationale
- **people.md**: Any new people mentioned or updated roles/context
- **preferences.md**: Any preferences stated or observed (style, tools, workflow, communication)
- **user.md**: Any new information about the user (goals, background, working style)

Only add information that is genuinely useful for future sessions. Avoid noise — quality over quantity.

## Memory Update Format

When updating memory files, append new entries under the existing content. Do not delete historical entries unless they are explicitly outdated or superseded. When replacing an entry, note what changed and why.

## Project Context

This is the `browser` repository. Refer to `README.md` for project overview.
