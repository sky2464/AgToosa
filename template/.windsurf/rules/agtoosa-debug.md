---
trigger: user_prompt
description: "AgToosa: disciplined 6-phase debugging loop — feedback-loop → reproduce → minimise → hypothesise → instrument → fix+regress"
---

When executing any debugging or diagnosis work, follow `Docs/AgToosa_Debug.md` precisely.

## Key constraints

- Never fix without first confirming a hypothesis through instrumentation.
- Establish a sub-5-second feedback loop before any other phase.
- Regression test is mandatory — no fix without a test that would have caught the bug.
- Remove all instrumentation before committing the fix.
- Document reproduction steps, hypotheses, and findings in Docs/Master-Plan.md.
