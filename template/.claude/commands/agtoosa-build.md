Read @Docs/AgToosa_Build.md and execute the build workflow.

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → execute the full TDD build workflow: Red-Green-Refactor cycles, full test suite, SAST/DAST scanning. Task planning is done in /agtoosa-spec — run that first if tasks are missing.
- `scope` → task planning has moved to /agtoosa-spec. Run `/agtoosa-spec tasks` instead to generate or regenerate the task breakdown from an approved spec.
- `tdd` → execute the TDD Red-Green-Refactor cycle only for the current task list.
- `test` → execute the testing and quality-gate phase only: run all tests, check coverage thresholds, run SAST/DAST.

If no arguments were given, run the full flow from Docs/AgToosa_Build.md.
