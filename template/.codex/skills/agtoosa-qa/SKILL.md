---
name: agtoosa-qa
description: Plan, run, report, and triage QA tests mapped to spec acceptance criteria for the active story.
---

# agtoosa-qa

Use when the user asks for `/agtoosa-qa`, `$agtoosa-qa`, or dedicated QA planning and execution.

## Execute

1. Read `Docs/AgToosa_QA.md` in full and **run** its workflow precisely.
2. **Dispatch** `plan`, `run`, `report`, or `triage` when provided; otherwise run the full QA flow.
3. Map work to `AC-NNN` items from the active spec and update `Docs/Master-Plan.md` for triaged defects.
4. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
