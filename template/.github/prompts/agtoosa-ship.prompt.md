---
mode: agent
description: "AgToosa: pre-flight → deploy → archive spec → update changelog → suggest next story"
tools: [codebase, terminal, githubRepo]
---

Read Docs/AgToosa_Ship.md and execute the ship workflow.

Sub-command dispatch:
- No argument → full ship workflow
- `check` → pre-flight checks only
- `docs` → archive spec + update changelog + update Master-Plan.md
- `retro` → retrospective summary + suggest next story
