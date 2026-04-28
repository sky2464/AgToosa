Read @Docs/AgToosa_Build.md and execute the build workflow.

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → execute the full TDD build workflow: scope breakdown, Red-Green-Refactor cycles, full test suite, SAST/DAST scanning.
- `scope` → execute the task scoping phase only: break the active spec into atomic tasks and update the task list.
- `tdd` → execute the TDD Red-Green-Refactor cycle only for the current task.
- `test` → execute the testing and quality-gate phase only: run all tests, check coverage thresholds, run SAST/DAST.

If no arguments were given, run the full flow from Docs/AgToosa_Build.md.
