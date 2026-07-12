# Solo-Developer Workflows

## Audience

Individual developers who want review separation and bounded delegation without paying for multiple concurrent agents or external async runners.

## Recommended Lifecycle Path

1. Approve a small spec with clear ACs.
2. Run build work in one primary session (the **Writer**).
3. Optionally partition into two lanes but execute them **sequentially** in the same or alternating chats.
4. Run `/agtoosa-import` yourself — treat your own returns like external evidence.
5. Switch persona or platform for cross-model review, or use documented fallbacks.

## Trust Boundary

| Control | Classification |
|---------|----------------|
| Sequential persona switches | agent-instructed |
| Same-session "reviewer" persona | virtual-persona-only confidence |
| Import verification | agent-instructed |
| Independent cross-model review | requires different model/platform or honest downgrade |

A same-writer persona is **not** an independent reviewer. Record `virtual-persona-only` or `writer-only` confidence when no second model participated.

## Fallback

When you cannot access a second model or subagent:

1. **Sequential fallback** — run reviewer lanes one after another; record `Cross-model lanes ran sequentially (platform does not support parallel subagents).`
2. **Cross-platform** — run `/agtoosa-review cross` (switch Cursor ↔ Copilot ↔ Claude Code).
3. **Virtual personas** — Security, EM, CEO, QA from [`docs/AgToosa_Review.md`](../AgToosa_Review.md) with documented rationale.
4. **Explicit skip** — document **Skip rationale** in the review report.

Never label a same-agent persona switch as `both-models` or independent cross-model review without disclosure.

## Sequential Persona Pattern

| Step | Persona | Role |
|------|---------|------|
| 1 | Build agent | **Writer** — implements and runs tests |
| 2 | Fresh chat or different model | **Independent reviewer** — read-only diff/spec/test review |
| 3 | Orchestrator (you) | Merge findings, authorize fixes |

If step 2 reuses the same model session as step 1, record confidence as `virtual-persona-only` or `writer-only` per [`docs/AgToosa_CrossModelReview.md`](../AgToosa_CrossModelReview.md).

## Low-Overhead Handoff

Even solo developers benefit from `/agtoosa-handoff` when context is tight:

- Export a pack for "future you" or a cheaper/smaller model.
- Keep Mapped ACs, Files in scope, and Return contract explicit.
- On return, run `/agtoosa-import` before marking tasks done.

Consult [`docs/AgToosa_AgentCapability.md`](../AgToosa_AgentCapability.md) for sequential defaults on your installed host — do not claim parallel lanes on sequential-only platforms.

## Canonical Workflow References

Follow the canonical workflow docs — do not duplicate command contracts:

- **Handoff packs:** [`docs/AgToosa_Handoff.md`](../AgToosa_Handoff.md)
- **Import gate:** [`docs/AgToosa_Import.md`](../AgToosa_Import.md)
- **Cross-model roles and fallbacks:** [`docs/AgToosa_CrossModelReview.md`](../AgToosa_CrossModelReview.md)
- **Platform capability routing:** [`docs/AgToosa_AgentCapability.md`](../AgToosa_AgentCapability.md)

## Related Guides

- [Subagent-heavy workflows](subagent-heavy-workflows.md)
- [Security-sensitive projects](security-sensitive-projects.md)
- [End-to-end walkthrough](../examples/subagent-handoff-review.md)
