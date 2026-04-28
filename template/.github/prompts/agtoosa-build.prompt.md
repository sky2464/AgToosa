---
mode: agent
description: "AgToosa: break spec into atomic tasks → TDD Red-Green-Refactor → tests + SAST/DAST"
tools: [codebase, terminal]
---

Read Docs/AgToosa_Build.md and execute the build workflow.

Sub-command dispatch:
- No argument → full TDD build workflow
- `scope` → task scoping phase only
- `tdd` → TDD Red-Green-Refactor cycle for current task
- `test` → testing and quality-gate phase only
