---
mode: agent
description: "AgToosa: TDD Red-Green-Refactor against the planned task list → tests + SAST/DAST"
tools: [codebase, terminal]
---

Read Docs/AgToosa_Build.md and execute the build workflow. Task planning is done in /agtoosa-spec — run that first if tasks are missing from Master-Plan.md.

Sub-command dispatch:
- No argument → full TDD build workflow (Red-Green-Refactor + comprehensive testing + tracking)
- `scope` → task planning has moved to /agtoosa-spec; run `/agtoosa-spec tasks` instead
- `tdd` → TDD Red-Green-Refactor cycle for the current task list
- `test` → testing and quality-gate phase only
