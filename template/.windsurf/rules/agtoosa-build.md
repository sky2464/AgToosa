---
trigger: user_prompt
description: "AgToosa: TDD implementation — Red-Green-Refactor for every story"
---

When executing any build or implementation work, follow `Docs/AgToosa_Build.md` precisely.

## Key constraints

- Always write the failing test **before** any implementation code (Red).
- Implement the minimum code to make the test pass (Green).
- Refactor only after tests pass (Refactor).
- No file may exceed 500 lines — split before adding more code.
- Commit after each green test cycle, not at the end.
- Report **Terminal Evidence Contract** fields for every command and parallel subagent; unresolved exits or warnings block checkbox completion.
- If build prerequisites fail, **stop** and instruct the user — do **not** auto-run `/agtoosa-spec`.
- On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
