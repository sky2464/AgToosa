---
trigger: user_prompt
description: "AgToosa: comprehensive QA — coverage gates, security scan, regression suite"
---

When executing any QA or testing work, follow `Docs/AgToosa_QA.md` precisely.

## Key constraints

- Run the full test suite; confirm zero regressions before proceeding.
- Coverage must meet or exceed the threshold defined in `Docs/AgToosa_QA.md`.
- Run an OWASP Top 10 security scan before marking QA complete.
- Document any defects found in `Docs/Master-Plan.md` before fixing them.
