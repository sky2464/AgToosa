# Subagent Handoff and Cross-Model Review Walkthrough

This walkthrough shows how an approved spec becomes **exactly two bounded lanes**, separate handoff packs, imported results, and a cross-model review outcome — in that order. It links to canonical workflow docs rather than copying them.

**References:** [`docs/AgToosa_Handoff.md`](../AgToosa_Handoff.md) · [`docs/AgToosa_Import.md`](../AgToosa_Import.md) · [`docs/AgToosa_CrossModelReview.md`](../AgToosa_CrossModelReview.md) · [`docs/AgToosa_AgentCapability.md`](../AgToosa_AgentCapability.md)

> **Claim boundary:** Handoff export, import gating, and cross-model review are **agent-instructed**. Launching external or subagents is **manual** and **host-dependent**. Consult the Agent Capability Matrix before claiming parallel lanes.

## 1. Start From An Approved Spec

Pick a small story with Must ACs already approved — for example, a docs-only feature with a clear file boundary.

| Field | Example |
|-------|---------|
| Story | `DEV-EXAMPLE` — Add a health-check endpoint |
| Must ACs | AC-001 (route exists), AC-002 (tests pass) |
| Build scope | `src/health.ts`, `tests/health.test.ts` |

Do not partition lanes until the spec has `## ✅ Spec Approved` and tasks appear under `docs/Master-Plan.md` → `## Active Tasks`.

## 2. Partition Into Two Bounded Lanes

Split work into **Lane A** and **Lane B** with explicit file ownership. Neither lane may edit `docs/Master-Plan.md` Active Cycle status directly.

### Lane A — Implementation

| Contract field | Value |
|----------------|-------|
| **Mapped ACs** | AC-001 |
| **Files in scope** | `src/health.ts` |
| **Allowed actions** | Implement the route; run verification in §5 of the handoff pack; do not tick Master-Plan checkboxes |
| **Verification commands** | `npm test -- health` |
| **Return contract** | Branch name, changed-file list, test log (command + exit code), mapped AC-001 evidence |
| **Overlap resolution** | Lane A owns `src/health.ts` exclusively. Lane B must not edit this file. |

### Lane B — Tests

| Contract field | Value |
|----------------|-------|
| **Mapped ACs** | AC-002 |
| **Files in scope** | `tests/health.test.ts` |
| **Allowed actions** | Add tests only; import types from `src/health.ts` but do not modify implementation |
| **Verification commands** | `npm test -- health` |
| **Return contract** | Branch name, changed-file list, test log (command + exit code), mapped AC-002 evidence |
| **Overlap resolution** | Lane B owns `tests/health.test.ts` exclusively. If a test requires an implementation change, stop and return a gap note — the orchestrator resolves via Lane A, not silent cross-lane edits. |

If both lanes would touch the same file, stop and rewrite the partition or document a single-writer merge rule before exporting packs.

## 3. Export Handoff Packs

Run `/agtoosa-handoff` (see the canonical [`docs/AgToosa_Handoff.md`](../AgToosa_Handoff.md) contract) once per lane:

1. `/agtoosa-handoff task` for Lane A — pack includes §3–§6 from the Handoff template.
2. `/agtoosa-handoff task` for Lane B — separate pack with its own return contract.

Before dispatch, consult [`docs/AgToosa_AgentCapability.md`](../AgToosa_AgentCapability.md) for an installed-surface routing recommendation and documented fallbacks.

**Launch is manual.** On hosts that support parallel subagents, you may run both lanes concurrently only when file ownership does not overlap. On sequential-only hosts, run Lane A then Lane B and record the sequential note from the capability matrix.

Do **not** mark tasks complete when a lane returns — agent completion is not closure.

## 4. Import And Verify Locally

When each lane returns, run `/agtoosa-import` per the canonical [`docs/AgToosa_Import.md`](../AgToosa_Import.md) checklist **before** any task or story is marked complete.

For each return:

1. Map artifacts to tasks and Must ACs in the Evidence Mapping table.
2. Run verification commands locally in this repo.
3. Capture Terminal Evidence (command, exit code, changed files).
4. Resolve integration conflicts as the orchestrator — neither lane has authority over `docs/Master-Plan.md`.

**Closure gate:** Imported claims are not evidence until repo-local verification passes. Never mark an imported task complete without recorded verification commands and mapped ACs.

Do not mark `- [x]` on Active Tasks **before import mapping** and green verification exits. "Agent done" is not task closure.

## 5. Cross-Model Review

After import and local verification, run `/agtoosa-review cross-model` per [`docs/AgToosa_CrossModelReview.md`](../AgToosa_CrossModelReview.md).

| Role | Responsibility |
|------|----------------|
| **Writer** | The agent that ran `/agtoosa-build` and merged lane results |
| **Independent reviewer** | A different subagent, model, or platform instance — **read-only** during the gate |

Record the review path actually used:

- **Parallel** — when the host supports native parallel subagent delegation (confirm via Agent Capability Matrix).
- **Sequential fallback** — when parallel is unavailable, run reviewer lanes sequentially and record: `Cross-model lanes ran sequentially (platform does not support parallel subagents).`
- **Explicit skip** — when no second model is available, document **Skip rationale** in the review report; never claim an independent review without disclosure.

The independent reviewer must remain read-only — no edits to implementation files, git state, or `docs/Master-Plan.md` during the gate.

## Related Audience Guides

- [Subagent-heavy workflows](../guides/subagent-heavy-workflows.md) — delegation, ownership, merge guidance
- [Security-sensitive projects](../guides/security-sensitive-projects.md) — least-privilege and evidence boundaries
- [Solo-developer workflows](../guides/solo-developer-workflows.md) — sequential personas without multiple paid agents
