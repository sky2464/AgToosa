---
name: agtoosa-build
mode: agent
description: "AgToosa: TDD Red-Green-Refactor against the planned task list → tests + SAST/DAST"
tools: [codebase, terminal]
---

Read Docs/AgToosa_Build.md and execute the build workflow. If prerequisites fail, **stop** and instruct the user — do **not** auto-run `/agtoosa-spec`. Report **Terminal Evidence Contract** fields for every command and parallel subagent.

Sub-command dispatch:
- No argument → full TDD build workflow (Red-Green-Refactor + comprehensive testing + tracking)
- `scope` → task planning has moved to /agtoosa-spec; run `/agtoosa-spec tasks` instead
- `tdd` → TDD Red-Green-Refactor cycle for the current task list
- `test` → testing and quality-gate phase only

On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
