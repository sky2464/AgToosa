---
description: AgToosa spec workflow (maintainer dogfood)
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-spec` in **Maintainer Dogfood Mode**. When the user invokes `/agtoosa-spec`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `docs/AgToosa_Spec.md` and execute the `/agtoosa-spec` workflow. See `docs/agtoosa-maintainer.md` for path conventions (`docs/` here; `template/Docs/` in the template pack).

**Plan-Mode Spec Interview:** follow `docs/AgToosa_Spec.md` → **Plan-Mode Spec Interview Contract** (canonical). Research before asking; interview before finalizing the spec; adaptive cap **8** (`quick` cap **2**); minimum validation floor **2** / **1**; **interview turn-stop** after Q1.

Dispatch based on any arguments after the command: `research`, `plan`, `quick`, `tasks`, `amend`, or `to-issues`.

**Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically — the user must invoke it after approval.

## Agent Mode Execution Contract

`docs/AgToosa_Spec.md` is the **canonical** workflow. This adapter is an execution contract — **not a routing summary** and not a shallow dispatcher.

**Full flow (no sub-command):** research → Plan-Mode Spec Interview (minimum floor + turn-stop) → executable spec with `### Plan-Mode Spec Interview (findings)` → architecture + STRIDE → task planning → test plan skeleton → approval gate.

**Forbidden for the full flow:**

- Skipping Plan-Mode Spec Interview or treating a detailed user prompt as interview-complete
- Writing `docs/archived/spec-*.md`, test plans, or Master-Plan story rows in the **same turn** as the first interview question
- Omitting `### Plan-Mode Spec Interview (findings)` from the spec file
- Implementing build artifacts (code, adapters, bats) before spec approval
- Auto-running `/agtoosa-build` or auto-approving the spec

## Host Mode Execution (IDE Host Mode Bridge)

Follow `docs/AgToosa_Spec.md` → **IDE Host Mode Bridge** and `docs/AgToosa_AgentCapability.md` → **IDE Host Mode Matrix** (Cursor row).

- **Enter plan:** `SwitchMode` → `plan` if not already in plan; user fallback: Shift+Tab
- **Plan window:** research, Plan-Mode Spec Interview, Goal Contract / architecture / STRIDE as plan artifact
- **Switch to agent:** when auto-switch trigger satisfied, print `HOST-MODE: plan complete → switching to agent for AgToosa artifacts`, then `SwitchMode` → `agent`
- **Forbidden in plan mode:** writing `docs/archived/spec-*.md`, test plans, or Master-Plan story rows; never queue plan→agent in the same turn
