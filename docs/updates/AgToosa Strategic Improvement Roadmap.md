# AgToosa Strategic Improvement Roadmap

> **Role:** Non-authoritative strategy and opportunity analysis.
> **Snapshot:** 2026-07-11, after v5.3.6; DEV-055 is In Progress with build Wave 1 complete.
> **Execution source of truth:** `docs/Master-Plan.md`.
> **Operating plan:** `docs/updates/agtoosa-plan-revised.md`.

## 1. Strategic Decision

AgToosa should deepen its current advantage rather than become a hosted agent runtime.

The advantage is a local, inspectable workflow layer that lets developers coordinate AI assistants through executable specifications, bounded subagent work, deterministic verification, and explicit evidence. The near-term strategy is therefore:

1. Make subagent fan-out and fan-in safer and easier to route.
2. Strengthen proof, policy, and supply-chain boundaries without overstating enforcement.
3. Improve distribution, onboarding, documentation, and registry quality.
4. Keep Shell and PowerShell canonical.
5. Treat binaries, editor extensions, hosted services, and enterprise identity as optional hypotheses that require demand evidence before implementation.

The previous assumptions that a Go/Rust rewrite, SaaS platform, SSO, or a large commercial organization were immediate critical-path work are rejected. They do not match the repository architecture, current maintainer capacity, or shipped product boundary.

## 2. Authority and Claim Boundaries

This file does not enroll stories or declare features shipped.

| Authority | Canonical file | Meaning |
|---|---|---|
| Current execution | `docs/Master-Plan.md` | Active cycle, backlog priority, tasks, blockers, and manual work |
| Story contract | `docs/archived/spec-DEV-*.md` | Approved Goal Contract, acceptance criteria, design, tasks, and evidence plan |
| Trust posture | `docs/AgToosa_Team_Trust_Roadmap.md` | Shipped enforcement boundaries and explicit non-guarantees |
| Product operating plan | `docs/updates/agtoosa-plan-revised.md` | Recommended sequencing and evidence gates |
| Roadmap spec coverage | `docs/updates/roadmap-spec-index.md` | Actionable proposals mapped to executable DEV specs |
| Strategic options | This file | Hypotheses awaiting validation or enrollment |

Every capability claim must use one of AgToosa's enforcement classes:

- **generator-enforced**
- **CI-enforced**
- **agent-instructed**
- **manual**
- **roadmap**

If no repo-local evidence exists, the claim is `roadmap`.

## 3. Evidence Baseline

### 3.1 Shipped foundation

AgToosa already has more of the strategic foundation than the prior roadmap acknowledged:

- A four-phase Spec → Build → Review → Ship lifecycle across supported platform adapters.
- A deterministic lifecycle verifier and copy-in CI gate template (DEV-061 and DEV-062).
- EARS acceptance-criteria checks, AC-to-test mapping, and RED/GREEN evidence gates (DEV-044 via DEV-061 and DEV-067).
- Phase-event logging, Update Log rotation, spec amendments, and living-spec guidance (DEV-063 and DEV-072).
- Async handoff packs, result import, evidence ledger, and cross-model review (DEV-047 through DEV-050).
- Tar-slip screening, pack containment, pinned installs, SHA256 release assets, and optional minisign soft-warning provenance (DEV-054 and DEV-064 through DEV-066).
- Non-interactive Bash and PowerShell installation paths plus an in-repo npm wrapper scaffold (DEV-071 and DEV-074); npm registry publication remains manual-deferred.
- A first-15-minutes proof, launch-readiness checks, benchmark harness scaffold, and team-trust roadmap (DEV-035 through DEV-041 and DEV-060); competitor benchmark runs remain manual-deferred.

These controls are not equivalent:

- The verifier is generator-provided and can be CI-enforced when a project adopts the gate.
- Handoff, import, evidence, and cross-model review are agent-instructed; external-agent launch remains manual.
- Minisign verification currently soft-warns; fail-closed signature policy remains roadmap.
- `docs/Master-Plan.md` remains the repo-local project-management source of truth.

### 3.2 Active and backlog evidence

- **Now:** DEV-055, Agent Capability Matrix, is approved and In Progress for the v5.3.7 target.
- **Subagent safety backlog:** DEV-045 Work Package Wave DAG and DEV-046 Optional Worktree Isolation.
- **Guardrail backlog:** DEV-052 Hook Automation Pack and DEV-059 Governance Policy-as-Code.
- **Learning and visibility backlog:** DEV-056 Retrospective Learning Loop and DEV-058 Local Dashboard.
- **Ecosystem backlog:** DEV-051 Tracker Sync Bridge and DEV-053 Extension and Preset Catalog.
- **Deferred scale:** DEV-057 Multi-Repo Story Overlay.
- **Adoption and validation backlog:** DEV-075 through DEV-084 have executable, unapproved future specs indexed in `docs/updates/roadmap-spec-index.md`.

The status and order above are a snapshot. `docs/Master-Plan.md` wins if they drift.

### 3.3 Manual work with high leverage

Before creating large new product surfaces, close or deliberately defer the manual items already recorded in `docs/Master-Plan.md`:

- Publish the npm wrapper.
- Run and publish competitor benchmark evidence.
- Mirror the pinned Homebrew formula to the tap.
- Configure release-environment reviewers if required.
- Optionally publish the CI gate to GitHub Marketplace.

These actions improve reach and credibility without expanding the runtime.

## 4. Strategic Thesis: Subagent-First Workflows

### 4.1 Product hypothesis

Developers need a reliable way to divide work among agents without surrendering scope control, evidence quality, or repository authority.

AgToosa should solve this with workflow contracts rather than a proprietary orchestrator:

1. The primary agent remains the orchestrator.
2. The approved spec defines the Goal Contract, acceptance criteria, Build Scope, and Wave Plan.
3. Each subagent receives a bounded lane with owned files, allowed actions, verification commands, and a return contract.
4. Parallel execution is used only when the host supports it and lanes do not share files or unresolved dependencies.
5. Otherwise, the same lanes run sequentially with an explicit fallback note.
6. Returned work is untrusted until `/agtoosa-import` maps it to acceptance criteria and repo-local verification passes.
7. Only the orchestrator updates tasks, evidence, review verdicts, and lifecycle state.

### 4.2 Strategic sequence

The safest sequence is:

1. **Route honestly** — finish DEV-055 so the workflow recommends only capabilities installed on the current platform.
2. **Partition explicitly** — deepen DEV-045 with `depends_on`, `owned_files`, `inputs`, `outputs`, and `merge_order`.
3. **Isolate risky lanes** — use DEV-046 for optional worktree guidance after work packages are explicit.
4. **Declare boundaries** — use DEV-059 for repo-local path, tool, network, secret, and approval policies with an enforcement class per rule.
5. **Automate transparently** — use DEV-052 for opt-in hooks; never install hooks silently.
6. **Learn from evidence** — use DEV-056 to turn retrospectives into proposed specialists, guardrails, or workflow changes.
7. **Render, do not replace, state** — use DEV-058 for a read-only local dashboard sourced from Master-Plan and evidence artifacts.

### 4.3 Success evidence

The subagent thesis is validated when AgToosa can show:

- A two-lane story with disjoint owned files.
- A generated handoff pack per lane.
- Parallel execution on a capable host and documented sequential fallback on another.
- Import evidence mapped to Must acceptance criteria.
- Repo-local verification with command, exit code, and changed-file evidence.
- A review report that merges independent findings without allowing reviewers to mutate code during the gate.
- No task completion or ship claim made by an external lane.

## 5. Strategic Opportunity Portfolio

### 5.1 Commit: evidence-backed direction

| Opportunity | Why it fits | Next proof |
|---|---|---|
| Safe subagent orchestration | Extends shipped specialists, handoff/import, evidence, and cross-model review | DEV-055, then DEV-045/046 |
| Repo-local policy and optional hooks | Strengthens boundaries without a hosted control plane | DEV-059, then DEV-052 |
| Verifier and CI adoption | Already shipped; needs usage evidence and documentation | DEV-079 plus manual benchmark evidence |
| High-quality registry presets | Uses the current registry instead of inventing a plugin runtime | DEV-053, DEV-077, and DEV-080 |
| Read-only local visibility | Preserves Master-Plan authority | DEV-058 after evidence sources stabilize |
| Documentation and onboarding | Reduces adoption friction without runtime complexity | DEV-075, DEV-076, and DEV-078 |

### 5.2 Validate first

| Opportunity | Evidence required before enrollment |
|---|---|
| Thin native wrapper | DEV-081 validates repeated installation failures that Bash/PowerShell parity cannot solve |
| Editor extension | DEV-081 validates demand for command discovery or Master-Plan navigation |
| Tracker bridge | DEV-051 requires teams requesting proposal-based import while accepting Master-Plan as source of truth |
| Fail-closed signatures | DEV-082 validates key rotation, rollback, and rejection of unsigned assets |
| Multi-repo overlay | DEV-057 requires a real story that cannot be handled with separate handoff packs |
| Official pack expansion | DEV-080 proves the first three packs before expansion |
| Lightweight paid support | DEV-084 defines a support boundary the maintainer can meet |

Validation should create a `/agtoosa-task` spike or `/agtoosa-spec research` artifact. It must not silently become committed work.

### 5.3 Park

The following ideas remain market hypotheses, not implementation commitments:

- Hosted AgToosa Cloud.
- Real-time collaborative Master-Plan editing.
- SSO, SAML, and RBAC.
- Compliance dashboards or certification programs.
- MCP/A2A runtime server.
- Autonomous build-agent runtime.
- Federated registries and pack dependency resolution.
- OpenTelemetry export and usage analytics.
- Commercial marketplace and revenue-share mechanics.

Reconsider only when a documented user segment, maintainer capacity, security model, operating cost, and proof plan exist.

### 5.4 Reject under the current product thesis

- Replacing the canonical Shell/PowerShell core with Go or Rust.
- Silent telemetry or phone-home behavior.
- Automatic writes to protected CI workflow paths.
- Treating external agents, trackers, or dashboards as more authoritative than `docs/Master-Plan.md`.
- Marketing unmeasured velocity, quality, security, adoption, or revenue outcomes as facts.

An additive wrapper may be validated later; duplicated product logic is not acceptable.

## 6. Developer Experience and Ecosystem Strategy

### 6.1 Onboarding

The first-15-minutes walkthrough already exists at `docs/examples/first-15-minutes.md`. The next work is maintenance and proof:

- Keep release pins current.
- Show generator-created artifacts separately from agent-created artifacts.
- Link a small public proof repository.
- Add a subagent walkthrough: spec → two handoff lanes → import → review (DEV-075).

DEV-078 owns the release-pin and proof-link maintenance gate.

### 6.2 Documentation

A static docs site is a distribution surface, not a new runtime. DEV-076 validates it with a minimal GitHub Pages build from existing markdown. Do not add accounts, a backend, or a second source of documentation truth.

Priority guide topics:

1. AgToosa for subagent-heavy workflows — DEV-075.
2. AgToosa for security-sensitive projects — DEV-075.
3. AgToosa for solo developers — DEV-075.
4. Writing and verifying registry packs — DEV-077 and DEV-053.

### 6.3 Registry

DEV-053 defines the catalog contract and DEV-080 proves three maintained packs, not a marketplace:

- One web application stack.
- One API/service stack.
- One infrastructure or security stack.

Each pack needs a scoped spec template, test guidance, threat-model notes, version compatibility, provenance, an example, and a named maintenance owner. Scale only after install and maintenance evidence exists.

### 6.4 Sustainability

DEV-084 defines the support boundary for low-complexity options that can proceed independently of product architecture:

- GitHub Sponsors.
- Consulting and onboarding.
- Sponsored educational content with clear disclosure.
- Optional support plans without gating critical workflow features.

Pricing, revenue forecasts, hiring plans, and funding rounds require separate business evidence. They are intentionally absent from the execution plan.

## 7. Metrics That Match the Product

Prefer evidence of successful workflows over vanity projections:

- Install/update success by supported path, measured from tests and voluntary reports.
- Verifier and CI gate adoption reported by users or public repositories.
- Handoff packs successfully imported with acceptance-criteria evidence.
- Cross-model reviews that produced a fixed or accepted finding.
- Median spec-to-ship cycle time from opt-in case studies.
- Registry pack installs, update success, and maintenance age.
- First-15-minute completion and documentation support questions.
- External contributors and independently maintained packs.

DEV-083 provides the voluntary metrics and case-study kit. AgToosa does not need telemetry to collect initial evidence. Public repositories, voluntary surveys, support issues, benchmark runs, and case studies are sufficient until users explicitly request more.

## 8. Risks and Countermeasures

| Risk | Countermeasure |
|---|---|
| Subagents edit overlapping files | Work-package owned-file declarations and optional worktree isolation |
| Agents overclaim completion | Import gate, evidence ledger, and orchestrator-only lifecycle updates |
| Platform capability drift | DEV-055 matrix plus parity tests and explicit fallbacks |
| Workflow text grows too large | Quickref, scoped adapters, and link-to-canonical contracts |
| Registry content injects instructions | Existing allowlist/denylist, preview, provenance, and future fail-closed option |
| Roadmap becomes a second backlog | Promote work only through `/agtoosa-task` or `/agtoosa-spec`; Master-Plan remains authoritative |
| Maintainer burnout | Small PATCH stories, manual work visibility, strict validation gates, and no speculative platform build |

## 9. Review Cadence

Review this opportunity map after:

- A MINOR release.
- Completion of a three-story roadmap wave.
- A material platform-capability change.
- New external benchmark evidence.
- Repeated user demand that crosses a validation gate.

At review time:

1. Fan out read-only evidence, workflow, product, and orchestration lanes.
2. Merge their structured findings in the primary agent.
3. Correct shipped/backlog drift against `docs/Master-Plan.md`.
4. Promote at most the next decision-ready item through the AgToosa workflow.
5. Leave all other ideas classified as validate-first, parked, or rejected.

## 10. Immediate Strategic Recommendation

Finish DEV-055 before enrolling another implementation story. DEV-045 is the next subagent-safety contract. The remaining actionable roadmap has been split into executable future specs through DEV-084 and indexed in `docs/updates/roadmap-spec-index.md`. In parallel, close the high-leverage manual distribution and benchmark tasks already recorded in Master-Plan.

The detailed phase order, evidence gates, and fallback contract are in `docs/updates/agtoosa-plan-revised.md`.
