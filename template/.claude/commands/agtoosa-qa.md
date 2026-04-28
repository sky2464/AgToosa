Read @Docs/AgToosa_QA.md and execute the QA workflow.

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → execute the full QA workflow: plan, run, report, and triage.
- `plan` → create the QA test plan for the active spec: enumerate test scenarios, coverage targets, and browser matrix.
- `run` → execute the QA test suite: unit, integration, E2E, browser, accessibility, and performance checks.
- `report` → generate the QA report: summarise pass/fail, coverage gaps, and flagged regressions.
- `triage` → triage failing tests: apply Iron Law root-cause protocol, assign severity, and update the task list.

If no arguments were given, run the full flow from Docs/AgToosa_QA.md.
