# AgToosa Governance: Phase-Gate Protocol & Linear Workflow

> **Reference doc.** Read this to understand how AgToosa enforces phase order, what gets written to Linear and Master-Plan.md, and the exact comment strings to post at each phase event.

## Phase-Gate Overview

| Phase | Entry Command | Gate Condition | Linear Update | Master-Plan.md Update |
|-------|--------------|----------------|---------------|-----------------------|
| Backlog → Todo | `/agtoosa-spec` | Spec approved by user | Status → Todo; post `Spec ✅ Approved` | Story added to Active Cycle table |
| Todo → In Progress | `/agtoosa-build` | Story exists in Master-Plan.md with a spec | Status → In Progress; post `Build 🏗️ Started` | Active Cycle row updated |
| In Progress → In Review | `/agtoosa-review` | Story status is `In Progress` | Status → In Review; post `Review 🔍 Started` | Active Cycle row updated |
| In Review → Done | `/agtoosa-ship` | Linear comment `Review ✅ Approved` exists | Status → Done; post `Ship 🚀 Deployed to <env>` | Story moved to Completed This Cycle |
| Done ← rollback | `/agtoosa-revert` | Any state | Post `Rollback 🔙 Triggered: <reason>` | Update Log entry added |

## Phase-Order Rules

Invoke commands in the order above. Out-of-order invocations warn and abort:

- Running `/agtoosa-review` when story is still `Todo` (not yet `In Progress`): warn and abort.
  Print: `⚠️ Story [ID] is in 'Todo' state. Run /agtoosa-build first.`

- Running `/agtoosa-ship` when story is `In Review` but no `Review ✅ Approved` comment exists on the Linear issue: warn and abort.
  Print: `⚠️ Story [ID] has not been approved. Run /agtoosa-review and obtain approval before shipping.`

- Running `/agtoosa-build` when no spec exists for the story in Master-Plan.md: warn and prompt.
  Print: `⚠️ No spec found for [ID]. Run /agtoosa-spec first.`

## Linear Comment Protocol

Post these exact strings as Linear issue comments at the corresponding phase events:

| Event | Comment string |
|-------|---------------|
| Spec approved | `Spec ✅ Approved` |
| Build begins | `Build 🏗️ Started` |
| Each task completes during build | `Task 🟢 N/M complete` |
| Review begins | `Review 🔍 Started` |
| Review passes | `Review ✅ Approved` |
| Review blocked | `Review 🔴 Blocked: <reason>` |
| Deployment complete | `Ship 🚀 Deployed to <env>` |
| Rollback triggered | `Rollback 🔙 Triggered: <reason>` |

Replace `<reason>`, `<env>`, and `N/M` with the actual values at runtime.

## Master-Plan.md Update Rules

Every AgToosa command must read and write Master-Plan.md as follows:

1. Read Master-Plan.md at the start of every command run.
2. Write a timestamped entry to the `## Update Log` section at the end of every command run. Format: `YYYY-MM-DD HH:MM — [command] — [summary of action taken]`.
3. Keep the Active Cycle table in sync with Linear status at all times. Never let them diverge.
4. When a story reaches `Done`, move its row from the Active Cycle table to the `## Completed This Cycle` section.

## Breaking Change & Deprecation Policy

Breaking changes must have a one-minor-release deprecation notice before removal. Announce the deprecation in a minor release with a runtime warning; remove in the next minor or major release. See `CONTRIBUTING.md` for the full deprecation procedure and timeline example.
