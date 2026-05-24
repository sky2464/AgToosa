Read @Docs/AgToosa_Spec.md and execute the specification workflow. **Generated Project Mode** — see @Docs/AgToosa_Agent.md → **Operating Contexts** (scope to **the project/product**).

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → execute the full workflow (Parts 1 + 2 + 3 + 4): research, Q&A, specification, architecture blueprint, STRIDE threat model, and task planning (atomic task breakdown + test plan skeleton).
- `research <topic>` → execute Part 1 only: context gathering, domain language alignment, external research, and 6 forcing questions. Output findings; do not write a spec file yet.
- `plan` → execute Part 2 only: architecture blueprint and threat model against an already-written spec file.
- `quick <description>` → abbreviated flow: 2–3 targeted questions + spec + skip full threat model. Use for small bugs or chores.
- `tasks` → execute Part 4 only: derive atomic tasks from an already-approved spec, generate the test plan skeleton, and update Master-Plan.md. Use this when you need to regenerate the task list without re-running the full spec.
- `to-issues` → break the active spec or PRD into vertical-slice GitHub issues (one issue per user-facing behaviour change).

If no arguments were given, run the full flow from Docs/AgToosa_Spec.md.

**Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically — the user must invoke it after approval.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
