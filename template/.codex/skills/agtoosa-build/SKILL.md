---
name: agtoosa-build
description: Implement an approved spec with TDD Red-Green-Refactor and comprehensive testing per the active task list.
---

# agtoosa-build

Use when the user asks for `/agtoosa-build`, `$agtoosa-build`, or wants to implement tasks from an approved spec.

## Execute

1. Read `Docs/AgToosa_Build.md` in full and **run** its workflow precisely.
2. Verify the active spec has `## ✅ Spec Approved` and tasks under `Docs/Master-Plan.md` → `## Active Tasks`. If prerequisites fail, **stop** and instruct the user — do **not** auto-run `/agtoosa-spec` or `/agtoosa-spec tasks`.
3. **Dispatch** `tdd` (Part 1 only) or `test` (Parts 2–3) when requested; otherwise run the full flow.
4. Respect scope boundary, manual-task gates, discovery triage, and the **Terminal Evidence Contract** (`Docs/AgToosa_Agent.md`) for every command and parallel subagent.
5. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
