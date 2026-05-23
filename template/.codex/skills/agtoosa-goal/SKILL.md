---
name: agtoosa-goal
description: Clarify project or story outcomes into a Goal Contract with measurable success and proof.
---

# agtoosa-goal

Use when the user asks for `/agtoosa-goal`, `$agtoosa-goal`, or goal/outcome clarity is missing before init/spec/review/ship.

## Execute

1. Read `Docs/AgToosa_Goal.md` in full and **run** its workflow precisely.
2. **Dispatch** `project`, `story`, `check`, or `revise` when provided; otherwise infer the appropriate mode from context.
3. Store story goals in the active spec, not in `Docs/Context/`.
4. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
