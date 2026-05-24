---
trigger: user_prompt
description: "AgToosa: research → forcing questions → Executable Specification → STRIDE threat model"
---

When executing any specification or planning work, follow `Docs/AgToosa_Spec.md` precisely.

**Generated Project Mode** — see `Docs/AgToosa_Agent.md` → **Operating Contexts**.

## Key constraints

- Follow the **Smart Interview Protocol** (`Docs/AgToosa_Agent.md`): max **4** questions for full flow; max **2** for `quick`. Ask only genuine gaps from the six forcing-question pool.
- Always verify dependency versions against live sources — never assume from memory.
- STRIDE threat model is mandatory for every spec (skip only for `quick`).
- Output: a single spec file at `Docs/archived/spec-[story-id].md` with embedded architectural blueprint and threat model.
- **Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically. Approval marks readiness only.
- Update `Docs/Master-Plan.md` after the spec is written.
- Domain language alignment (read `Docs/Context/CONTEXT.md`, update terminology, create ADRs) is built into Part 1.
- For `to-issues`: use vertical slices only — each issue must deliver one complete user-facing behaviour change.
- On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
