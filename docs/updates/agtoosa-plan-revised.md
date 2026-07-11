# AgToosa Executable Product Plan

> **Strategy:** Simplicity-first and subagent-first.
> **Snapshot:** 2026-07-11, v5.3.6 shipped; DEV-055 active but awaiting explicit spec approval for v5.3.7.
> **Status:** Planning guidance only. `docs/Master-Plan.md` is the execution source of truth.

## 1. Goal Contract

| Field | Plan |
|---|---|
| Goal | Make AgToosa the clearest local-first framework for coordinating AI-assisted software delivery with bounded subagents and verifiable evidence. |
| User outcome | A developer can move from approved spec to safely divided agent work, import results, review independently, and ship without losing scope or repository authority. |
| Success condition | The active capability matrix ships; parallel work packages declare dependencies and ownership; returned work is verified before closure; adoption work improves reach without adding a mandatory runtime. |
| Proof | Story-specific Bats/Pester evidence, verifier results, handoff/import evidence, review reports, published benchmarks, and voluntary user case studies. |
| Non-goals | Hosted agent runtime, silent telemetry, Go/Rust rewrite, automatic external-agent launch, or enterprise claims without evidence. |
| Source of truth | Active cycle and backlog status live only in `docs/Master-Plan.md`. |

## 2. Product Tenets

1. **Shell and PowerShell stay canonical.** Optional wrappers may call the same core; they do not fork product logic.
2. **Markdown contracts are a feature.** Specs, plans, handoffs, reviews, and evidence remain inspectable in the repository.
3. **Local-first and no silent network use.** Network access is explicit and optional.
4. **Subagents are bounded workers, not authorities.** The primary agent owns synthesis and lifecycle state.
5. **Parallelism is conditional.** Use it only for independent lanes on a host that supports native delegation; otherwise use the same contract sequentially.
6. **Claims require enforcement labels.** Use generator-enforced, CI-enforced, agent-instructed, manual, or roadmap.
7. **Evidence precedes completion.** Imported claims do not close tasks until repo-local verification passes.
8. **Master-Plan remains authoritative.** Trackers, dashboards, and hosted agents are integrations.
9. **Small releases beat speculative rewrites.** Follow ADR-005 PATCH-first cadence unless a coherent multi-story wave warrants a MINOR.
10. **No critical open-source workflow is gated for monetization.**

## 3. Source-of-Truth Hierarchy

| Rank | File | Responsibility |
|---|---|---|
| 1 | `docs/Master-Plan.md` | Active Cycle, Backlog, Active Tasks, blockers, manual work, Update Log |
| 2 | `docs/archived/spec-DEV-*.md` | Approved executable story contracts |
| 3 | `docs/AgToosa_TestPlan-DEV-*.md` and archived evidence | AC-to-test and completion proof |
| 4 | `docs/AgToosa_Team_Trust_Roadmap.md` | Trust posture and enforcement boundaries |
| 5 | This file | Recommended order and evidence gates |
| 6 | `docs/updates/AgToosa Strategic Improvement Roadmap.md` | Non-authoritative opportunity map |

If this plan conflicts with Master-Plan, the plan is stale.

## 4. Current Baseline

### 4.1 Shipped

- Deterministic lifecycle verifier and copy-in CI gate.
- EARS, AC-to-test, threat-model, Wave Plan, and RED/GREEN evidence checks.
- Specialist subagent contract and structured evidence block.
- Async handoff packs and result import gate.
- Evidence ledger and phase-event log.
- Cross-model review with sequential and cross-platform fallbacks.
- Safe registry extraction, containment, pinned installs, release checksums, and optional minisign soft-warning verification.
- Non-interactive Bash and PowerShell installation paths.
- First-15-minutes proof and public benchmark harness scaffold; competitor result runs remain manual-deferred.

### 4.2 Active

DEV-055, Agent Capability Matrix, is the only active story in this snapshot. It is enrolled but still awaits `## ✅ Spec Approved`; `/agtoosa-build` must not start before explicit approval. Its purpose is lifecycle routing: detect installed agent surfaces and recommend honest build, handoff, review, cross-model, and specialist paths without duplicating the Specialists native-file-target matrix.

### 4.3 Important limits

- AgToosa does not auto-launch external agents.
- Most agent orchestration is agent-instructed, not generator-enforced.
- Parallel delegation depends on the host platform.
- Imported output is not trusted until verified in the target repository.
- Minisign is soft-warning, not fail-closed.
- The CI gate is a user-adopted example; AgToosa does not silently create protected workflows.
- There is no hosted service, identity layer, telemetry service, or autonomous build runtime.

## 5. AgToosa Workflow for Roadmap Work

Roadmap work uses the same phase discipline as product work.

### 5.1 Research and fan-out

For a material roadmap refresh, the primary agent fans out read-only lanes:

| Lane | Question | Required output |
|---|---|---|
| Evidence auditor | What is shipped, active, backlog, manual, stale, or contradicted? | Structured evidence block with paths and story IDs |
| Workflow architect | Does the proposal fit Spec → Build → Review → Ship and the phase-stop contract? | Scope and workflow changes |
| Subagent architect | What can run in parallel, what needs a fallback, and what needs runtime support? | Dependency and capability map |
| Product skeptic | What should be rejected, validated first, or delayed because of opportunity cost? | Ranked recommendation and proof gates |

Each lane returns:

- `Findings:`
- `Files read:`
- `Commands:`
- `Warnings/errors:`
- `Recommendations:`
- `Spec sections affected:`

The primary agent performs fan-in, resolves contradictions against repository evidence, and owns the final recommendation. Subagents do not edit Master-Plan or mark work complete.

### 5.2 Intake and promotion

Use the smallest matching workflow:

1. Raw idea or small chore → `/agtoosa-task`.
2. Uncertain product bet → `/agtoosa-spec research`.
3. Decision-ready feature or fix → `/agtoosa-spec`.
4. Existing approved contract changed → `/agtoosa-spec amend`.

Before promotion, confirm:

- Epic fit.
- Goal, user outcome, success condition, and proof.
- Narrowest valuable scope.
- Enforcement class for every guarantee.
- Failure modes and trust boundaries.
- Test evidence.
- No duplicate shipped or backlog story.
- Compatibility with the Product Tenets.

### 5.3 Phase stops

- `/agtoosa-spec` stops after explicit approval and enrollment.
- Do not start `/agtoosa-build` automatically.
- `/agtoosa-build` may use local subagents or `/agtoosa-handoff`, but external results return through `/agtoosa-import`.
- `/agtoosa-review` uses independent read-only review lanes; fixes return to Build.
- `/agtoosa-ship` updates release state only after approval and evidence gates pass.

Roadmap checkboxes never substitute for these phase transitions.

## 6. Subagent Operating Contract

### 6.1 Fan-out prerequisites

A task may be delegated when all are true:

- The active spec is approved.
- The lane maps to explicit acceptance criteria.
- Allowed files and actions are bounded.
- Verification commands are known.
- Inputs, expected outputs, and dependencies are explicit.
- Concurrent lanes have disjoint owned files and no unresolved data dependency.
- The selected host actually supports the requested delegation mode.

If any condition fails, keep the task with the primary agent or run lanes sequentially.

### 6.2 Lane contract

Every implementation or review lane receives:

1. Story Goal Contract.
2. Relevant Must and Should acceptance criteria.
3. Owned files or read-only scope.
4. Allowed and forbidden actions.
5. Verification commands.
6. Return format with changed files, command, exit code, and AC evidence.
7. A prohibition on updating lifecycle state.

For async agents, `/agtoosa-handoff` is the canonical export and `/agtoosa-import` is the canonical fan-in gate.

### 6.3 Fan-in contract

The primary agent:

1. Collects every lane result.
2. Rejects missing or unverifiable evidence.
3. Deduplicates and confidence-ranks findings.
4. Runs repo-local verification.
5. Maps accepted evidence to tasks and acceptance criteria.
6. Updates the evidence ledger.
7. Alone updates Master-Plan status and checkboxes.

### 6.4 Fallback chain

Use this order:

1. Native parallel subagents when the host and work-package schema support them.
2. Sequential subagent lanes on the same host.
3. Manual external handoff followed by import.
4. Cross-platform second opinion.
5. Virtual review personas with a documented limitation.
6. Documented skip when no independent path is available.

Never describe a fallback as native parallel support.

## 7. Recommended Story Sequence

This is a dependency recommendation, not enrollment. Re-check Master-Plan before each selection.

```text
DEV-055
  └─ DEV-045
       ├─ DEV-046
       └─ DEV-059
            ├─ DEV-052
            └─ DEV-056
                 ├─ DEV-058
                 ├─ DEV-053
                 └─ DEV-051
                      └─ DEV-057 (demand-gated)
```

Why this order:

- Capability routing must be truthful before recommending subagent paths.
- Work packages need ownership and dependencies before concurrent execution is safe.
- Worktrees isolate lanes only after lane boundaries are known.
- Policy declares allowed behavior before hooks automate it.
- Retrospectives should learn from stable evidence and guardrails.
- Dashboards and external trackers should render or exchange stable state, never define it.
- Multi-repo orchestration is the largest scope and should follow proven single-repo fan-out.

## 8. Delivery Waves

### Wave 0 — Finish the active contract

**Story:** DEV-055 — Agent Capability Matrix.

Required evidence:

- Explicit `## ✅ Spec Approved` marker and matching Master-Plan phase entry before Build.
- AM contract tests green.
- Canonical template doc and maintainer mirror.
- Build, Handoff, Review, Help, and Specialists cross-links.
- `lib/config.sh` inventory parity.
- Honest parallel/sequential/manual fallback language.
- Review approval and v5.3.7 ship evidence.

Do not enroll another implementation story until DEV-055 is reviewed or explicitly paused.

### Wave 1 — Safe fan-out

#### DEV-045 — Work Package Wave DAG

Deepen the backlog spec before enrollment. The narrow v1 should add:

- `depends_on`
- `owned_files`
- `inputs`
- `outputs`
- `merge_order`
- verification command per work package

Evidence gate:

- Two independent packages can run in parallel without shared-file ambiguity.
- A dependent package waits for its inputs.
- Handoff packs preserve the same ownership and dependency data.
- Import and merge order are visible in the final evidence.

#### DEV-046 — Optional Worktree Isolation

Build only after DEV-045 proves package boundaries.

Evidence gate:

- Two package branches/worktrees are created or documented using existing Git primitives.
- Each lane is confined to its owned files.
- Import verifies both before integration.
- Sequential same-branch fallback remains supported.
- No new mandatory runtime is introduced.

### Wave 2 — Guardrails and learning

#### DEV-059 — Governance Policy-as-Code

Start with a repo-local schema for paths, tools, network, secrets, approvals, and risky actions. Every rule must state whether it is generator-enforced, CI-enforced, agent-instructed, manual, or roadmap.

Evidence gate:

- Example policy parses or is deterministically checked.
- Spec, Build, Review, Handoff, and Import describe violation behavior.
- Unsupported runtime enforcement is not claimed.

#### DEV-052 — Hook Automation Pack

Hooks are optional adapters over existing workflow gates.

Evidence gate:

- Installation is explicit and previewed.
- No hook is installed silently.
- Secret values are never logged.
- Hook absence does not make a project unhealthy.
- Platform-specific behavior has a documented fallback.

#### DEV-056 — Retrospective Learning Loop

Turn ship evidence into proposals, not automatic mutations.

Evidence gate:

- A retro identifies keep/stop/start findings.
- Repeated evidence can propose a specialist, policy rule, test, or workflow amendment.
- Material changes still enter through `/agtoosa-task`, `/agtoosa-spec`, or `/agtoosa-spec amend`.

### Wave 3 — Visibility and ecosystem

#### DEV-058 — Local Dashboard

Render Master-Plan, blockers, evidence, and next actions read-only. No accounts or hosted state.

#### DEV-053 — Extension and Preset Catalog

Define compatibility, trust level, provenance, examples, and maintenance ownership. Validate three high-quality packs before scaling the catalog.

#### DEV-051 — Tracker Sync Bridge

Begin with one-way export or proposal-based import. Master-Plan stays authoritative; no silent overwrite.

#### DEV-057 — Multi-Repo Story Overlay

Keep demand-gated until a real user story demonstrates that separate per-repo handoff/import packs are insufficient.

Wave 3 evidence gates:

- Dashboard mutation tests confirm read-only behavior.
- At least three maintained catalog entries pass install and provenance checks.
- Tracker round-trip proposes changes without replacing Master-Plan authority.
- Multi-repo work has a primary evidence index and per-repo verification.

## 9. Parallel Adoption Track

These tasks can proceed without changing the generator architecture:

1. Publish the npm wrapper when account/2FA access is available.
2. Publish at least one full competitor benchmark result before stronger comparative claims.
3. Keep `docs/examples/first-15-minutes.md` and its proof repository on the current release.
4. Add guides for subagent workflows, security-sensitive projects, and solo developers.
5. Test a minimal static documentation site built from existing markdown.
6. Surface the extension/pack authoring guide.
7. Validate three official-quality packs before targeting five or more.
8. Add GitHub Sponsors only with support expectations the maintainer can meet.

These items still need an enrolled chore or recorded manual task when they change repository state.

## 10. Validate-First Gates for Optional Add-ons

| Add-on | Evidence needed |
|---|---|
| Native wrapper | Repeated user failures not solvable in canonical Bash/PowerShell paths |
| VS Code extension | Repeated demand for command discovery or local state navigation |
| Fail-closed signatures | Users willing to manage keys and reject unsigned assets |
| Additional CI platforms | A user maintaining and exercising the platform template |
| Paid support | Sustained support volume plus a credible response commitment |
| Hosted dashboard or SaaS | Multiple organizations requesting shared state, with a funded security and operations model |
| SSO/RBAC | Hosted identity boundary and real enterprise design partners |
| MCP/A2A runtime | A concrete workflow impossible through existing platform adapters and handoff/import |

Until a gate is met, the item remains `roadmap`.

## 11. Explicitly Deferred

- Rewriting the core in Go or Rust.
- AgToosa Cloud and real-time collaboration.
- SSO/SAML/RBAC and compliance certification programs.
- Autonomous build-agent runtime.
- Silent analytics or phone-home telemetry.
- Federated registry and package dependency solver.
- Commercial marketplace mechanics.
- Revenue, hiring, or funding projections presented as product commitments.

## 12. Selection Rule After Each Ship

After shipping a story:

1. Run `/agtoosa-status plan`.
2. Correct roadmap drift against Master-Plan.
3. Close applicable manual evidence tasks.
4. Fan out evidence, workflow, orchestration, and product-skeptic lanes for the top candidate when the decision is material.
5. Select the smallest dependency-ready story with the strongest user/evidence signal.
6. Deepen its backlog spec to the current executable standard.
7. Run `/agtoosa-spec` and stop at explicit approval.

For the current snapshot, the next recommendation is:

1. Obtain explicit DEV-055 spec approval, then build, review, and ship it.
2. Publish pending benchmark/distribution evidence in parallel where manual access permits.
3. Deepen and enroll DEV-045.
4. Reassess DEV-046 versus DEV-059 using the evidence from the first two-lane dogfood story.
