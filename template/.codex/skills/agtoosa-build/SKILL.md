---
name: agtoosa-build
description: Implement an approved spec with TDD Red-Green-Refactor and comprehensive testing per the active task list.
---

# agtoosa-build

Use when the user asks for `/agtoosa-build`, `$agtoosa-build`, or wants to implement tasks from an approved spec.

## Execute

1. Read `Docs/AgToosa_Build.md` in full and **run** its workflow precisely.
2. Verify the active spec has `## ✅ Spec Approved` and tasks under `Docs/Master-Plan.md` → `## Active Tasks`.
3. **Dispatch** `tdd` (Part 1 only) or `test` (Parts 2–3) when requested; otherwise run the full flow.
4. Respect scope boundary, manual-task gates, and discovery triage from the workflow doc.
5. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
