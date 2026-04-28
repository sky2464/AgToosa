---
trigger: user_prompt
description: "AgToosa: research → 6 forcing questions → Executable Specification → STRIDE threat model"
---

When executing any specification or planning work, follow `Docs/AgToosa_Spec.md` precisely.

## Key constraints

- Never skip the 6 forcing questions (for `quick` sub-command: ask only questions 1, 2, and 6).
- Always verify dependency versions against live sources — never assume from memory.
- STRIDE threat model is mandatory for every spec (skip only for `quick`).
- Output: a single spec file in `Docs/` with embedded architectural blueprint and threat model.
- Update Linear and `Docs/Master-Plan.md` after the spec is written.
