# Subagent-Heavy Workflows

## Audience

Teams that routinely delegate waves or tasks to subagents, background agents, or external async runners (Cursor, Claude Code Task tool, Copilot cloud agents, Codex sessions, etc.).

## Entry algorithm

Before partitioning lanes or exporting handoff packs, run **Orchestration Brain step 0** in [`docs/AgToosa_Orchestration.md`](../AgToosa_Orchestration.md): Capability Inventory → lane plan → parallel or sequential fan-out → orchestrator merge. Platform routing detail stays in [`docs/AgToosa_AgentCapability.md`](../AgToosa_AgentCapability.md) — do not duplicate it here.

## Recommended Lifecycle Path

1. Approve spec and Active Tasks.
2. Partition work into bounded lanes with explicit file ownership.
3. Export one handoff pack per lane via `/agtoosa-handoff`.
4. Launch agents **manually**; collect returns under the Handoff return contract.
5. Run `/agtoosa-import` and local verification before ticking checkboxes.
6. Merge integration conflicts as the orchestrator.
7. Run `/agtoosa-review cross-model` when tier warrants it.

## Trust Boundary

| Control | Classification |
|---------|----------------|
| Handoff pack content | agent-instructed |
| Subagent launch | manual / host-dependent |
| Import closure gate | agent-instructed |
| Master-Plan as source of truth | repo-local |

External agents are evidence sources, not authorities. They must not mark tasks complete or edit Active Cycle status without import review.

## Fallback

When parallel subagents are unavailable, run lanes **sequentially** and record the sequential note from [`docs/AgToosa_AgentCapability.md`](../AgToosa_AgentCapability.md). When a single host cannot delegate at all, paste handoff packs into separate chats/sessions and still require `/agtoosa-import` before closure.

## Bounded Lane Checklist

Every delegated lane must name:

| Field | Purpose |
|-------|---------|
| **Mapped ACs** | Which Must ACs this lane may satisfy |
| **Files in scope** | Exclusive ownership list from spec build scope |
| **Allowed actions** | What the lane may run or edit |
| **Verification commands** | Runnable checks before return |
| **Return contract** | Fields `/agtoosa-import` expects |
| **Overlap resolution** | What happens when another lane needs the same file |

If two lanes would edit the same file without a documented merge rule, rewrite the partition before handoff.

## Canonical Workflow References

Do not duplicate these contracts — link and follow the canonical workflow docs:

- **Handoff packs:** [`docs/AgToosa_Handoff.md`](../AgToosa_Handoff.md)
- **Orchestration Brain:** [`docs/AgToosa_Orchestration.md`](../AgToosa_Orchestration.md)
- **Import and closure gate:** [`docs/AgToosa_Import.md`](../AgToosa_Import.md)
- **Cross-model review:** [`docs/AgToosa_CrossModelReview.md`](../AgToosa_CrossModelReview.md)
- **Platform routing and parallel vs sequential:** [`docs/AgToosa_AgentCapability.md`](../AgToosa_AgentCapability.md)

## End-to-End Example

See the [subagent handoff and review walkthrough](../examples/subagent-handoff-review.md) for a two-lane spec → handoff → import → cross-model review sequence.
