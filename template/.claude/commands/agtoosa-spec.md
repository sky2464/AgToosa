Read @Docs/AgToosa_Spec.md and execute the specification workflow.

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → execute the full workflow (Parts 1 + 2 + 3): research, Q&A, specification, architecture blueprint, and STRIDE threat model.
- `research <topic>` → execute Part 1 only: context gathering, domain language alignment, external research, and 6 forcing questions. Output findings; do not write a spec file yet.
- `plan` → execute Part 2 only: architecture blueprint and threat model against an already-written spec file.
- `quick <description>` → abbreviated flow: 2–3 targeted questions + spec + skip full threat model. Use for small bugs or chores.
- `to-issues` → break the active spec or PRD into vertical-slice GitHub issues (one issue per user-facing behaviour change).

If no arguments were given, run the full flow from Docs/AgToosa_Spec.md.
