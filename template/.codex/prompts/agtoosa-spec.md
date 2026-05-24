## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-spec`. When the user invokes `/agtoosa-spec`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Spec.md` and execute the `/agtoosa-spec` workflow. **Generated Project Mode** — see `Docs/AgToosa_Agent.md` → **Operating Contexts**.

**Plan-Mode Spec Interview:** follow `Docs/AgToosa_Spec.md` → **Plan-Mode Spec Interview Contract** (canonical). Research before asking; adaptive cap **8** (`quick` cap **2**).

Dispatch based on any arguments after the command: `research`, `plan`, `quick`, `tasks`, or `to-issues`. With no argument, run Parts 1–4.

## Agent Mode Execution Contract

`Docs/AgToosa_Spec.md` is the **canonical** workflow. This prompt is an execution contract for Codex agent mode — **not a routing summary** and not a shallow dispatcher.

**Before any outputs:** read `Docs/AgToosa_Spec.md` in full.

**Full flow (no sub-command):** execute Parts 1–4 and produce visible evidence for each obligation. Do **not** skip:

- **Research** — context gathering and external research before user questions; verify live sources when required
- **Goal Contract** — Story Goal Contract synthesis
- **Plan-Mode Spec Interview** — follow `Docs/AgToosa_Spec.md` → **Plan-Mode Spec Interview Contract**; adaptive cap **8** (`quick` cap **2**); infer before asking; Decision-complete checklist or documented assumptions
- **Executable spec** — requirements, design, architecture, and STRIDE threat model
- **Task planning** — task tree in the spec and `Docs/Master-Plan.md` → `## Active Tasks`
- **Test plan skeleton** — `Docs/AgToosa_TestPlan-[story-id].md`
- **Approval gate** — stop for user approval; never auto-approve

**Forbidden for the full flow:** skipping Plan-Mode Spec Interview or research, Goal Contract, task planning, or the test plan skeleton; copying divergent Part 1 / Part 2 workflow section bodies from `Docs/AgToosa_Spec.md` into this prompt.

**Sub-commands:** `research`, `plan`, `quick`, `tasks`, and `to-issues` each run their canonical slice with the same stop conditions from `Docs/AgToosa_Spec.md`.

**Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically — the user must invoke it after approval.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
