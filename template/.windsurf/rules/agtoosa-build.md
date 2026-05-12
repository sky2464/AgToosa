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
- On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
