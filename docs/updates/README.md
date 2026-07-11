# AgToosa Product Updates

`docs/updates/` is a strategy and intake layer for AgToosa maintainers. It is not the project-management source of truth and does not enroll work.

## Source-of-Truth Order

1. `docs/Master-Plan.md` — active cycle, backlog, tasks, blockers, and manual work.
2. `docs/archived/spec-DEV-*.md` — approved executable story contracts.
3. `docs/AgToosa_TestPlan-DEV-*.md` and archived evidence — proof.
4. `docs/AgToosa_Team_Trust_Roadmap.md` — enforcement posture and non-guarantees.
5. `docs/updates/agtoosa-plan-revised.md` — recommended execution sequence.
6. `docs/updates/AgToosa Strategic Improvement Roadmap.md` — non-authoritative opportunity map.

If an update document conflicts with Master-Plan, Master-Plan wins.

## Files

### `agtoosa-plan-revised.md`

The operating plan:

- Simplicity-first product tenets.
- AgToosa workflow for promoting roadmap ideas.
- Subagent fan-out/fan-in contract.
- Recommended DEV-story dependency order.
- Wave-specific acceptance and evidence gates.
- Validate-first criteria and explicit deferrals.

### `AgToosa Strategic Improvement Roadmap.md`

The opportunity map:

- Evidence baseline.
- Strategic theses.
- Commit, validate-first, parked, and rejected ideas.
- Product metrics and risks.
- Review cadence.

It must not contain authoritative backlog status, unsupported market claims, or invented product commands.

## Roadmap Workflow

### 1. Research

For material decisions, fan out read-only subagent lanes:

- Evidence auditor.
- Workflow architect.
- Subagent/orchestration architect.
- Product skeptic.

Each lane returns the canonical structured evidence block from `docs/AgToosa_Specialists.md`; `agtoosa-plan-revised.md` §5.1 applies it to roadmap research. The primary agent performs fan-in and owns the decision.

### 2. Classify

Classify every proposal as:

- Shipped.
- Active.
- Backlog.
- Manual/deferred.
- Validate first.
- Parked.
- Rejected.

Also classify every guarantee as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap.

### 3. Promote

- Small chore, fix, or spike → `/agtoosa-task`.
- Product uncertainty → `/agtoosa-spec research`.
- Decision-ready feature → `/agtoosa-spec`.
- Change to an approved contract → `/agtoosa-spec amend`.

Promotion updates Master-Plan through the workflow. Editing this folder alone does not.

### 4. Stop

`/agtoosa-spec` stops after explicit approval and enrollment. Do not chain automatically into Build.

### 5. Build, import, review, and ship

- Implement through `/agtoosa-build`.
- Export async work through `/agtoosa-handoff`.
- Verify returned work through `/agtoosa-import`.
- Run independent review through `/agtoosa-review`.
- Update shipped state through `/agtoosa-ship`.

Only the primary orchestrator updates lifecycle status.

## Maintenance Rules

1. Date every snapshot.
2. Check current version and Active Cycle before editing.
3. Link to DEV stories instead of duplicating their requirements.
4. Do not mark a proposal shipped without repo-local evidence.
5. Do not claim native parallel support where only sequential or manual fallback exists.
6. Keep Shell/PowerShell canonical unless an approved ADR changes the architecture.
7. Keep network access opt-in.
8. Review these files after a MINOR release or a completed three-story wave.
