---
name: agtoosa-ship
mode: agent
description: "AgToosa: readiness gate → deploy → archive spec → update changelog → suggest next story"
tools: [codebase, terminal, githubRepo]
---

Read Docs/AgToosa_Ship.md and execute the ship workflow.

Sub-command dispatch:
- No argument → full ship workflow (Part 0, then deploy approval and release steps)
- `check` → read-only readiness audit: `Docs/AgToosa_Ship.md` Part 0 only (no deploy, archive, or file mutation)
- `docs` → archive spec + update changelog + update Master-Plan.md
- `retro` → retrospective summary + suggest next story

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
