# Roadmap-to-Spec Index

> **Purpose:** Coverage map from `docs/updates/` strategy into executable AgToosa work.
> **Snapshot:** 2026-07-12 (Rev4 wave promoted).
> **Authority:** `docs/Master-Plan.md` remains the source of truth for status and priority.

## Coverage Contract

Every actionable proposal in the update documents is represented by one of:

1. A shipped DEV story.
2. An existing Manual / Deferred task.
3. An executable backlog spec and matching test plan.
4. An explicit parked or rejected decision.

Editing this index does not enroll a story. Backlog stories still require `/agtoosa-spec`, explicit approval, and a separate `/agtoosa-build` invocation.

## Active Stories

| ID | Story | Wave | Status |
|---|---|---|---|
| DEV-096 | Pack Validation CI | 3 | 🟩 Built — unlocks 095 |
| DEV-095 | Official Pack Expansion (5-pack max) | 3 | 🟦 Todo — unblocked (096 GREEN) |
| DEV-098 | Navigation by User Job | 3 | 🟦 Todo — enrolled |
| DEV-099 | Core vs Optional Pack Boundary | 3 | 🟦 Todo — enrolled |
| DEV-101 | Verified vs Community Pack Labeling | 3 | 🟦 Todo — enrolled |
| DEV-102 | Offline and Network-Dependency Matrix | 3 | 🟦 Todo — enrolled |
| DEV-103 | External Registry Publication Runbook | 3 | 🟦 Todo — enrolled |
| DEV-104 | `--reinstall --clean` (ADR-004 Option C) | 3 | 🟦 Todo — enrolled (DEV-090 shipped) |
| DEV-106 | Built with AgToosa Showcase | 3 | 🟦 Todo — enrolled |

> **Enrollment note (2026-07-12):** Wave 3 enrolled after v5.3.18. Soft capacity overrun (~14 SP vs 8). Build: parallel docs **098 · 099 · 101 · 102 · 103 · 106** (soft file locks); **096 → 095**; **104** ready. Shipped through v5.3.19: **DEV-107** (Orchestration Brain). Waves 1a/1b/2 through v5.3.18. Demand-gated: **DEV-057**. Post-Rev4 drafts (not enrolled): **DEV-110**. Spec Approved backlog: **DEV-109**.

## Rev4 Wave — Spec Approved (2026-07-12)

Source: `docs/updates/Rev4-*.md`, `docs/updates/rev4-conflict-resolutions.md`.

### Wave 1a (active cycle)

| ID | Story | Type | Est | Epic | Pri | Spec | Test plan |
|---|---|---|---:|---|---:|---|---|
| DEV-086 | Canonical Proof Product Experience | Chore | S | DEV-004 | P0 | `docs/archived/spec-DEV-086.md` | `docs/AgToosa_TestPlan-DEV-086.md` |
| DEV-090 | Unified Install/Update Plan Engine | Feature | M | DEV-001 | P0 | `docs/archived/spec-DEV-090.md` | `docs/AgToosa_TestPlan-DEV-090.md` |
| DEV-105 | PowerShell Maintain + Update Parity | Feature | M | DEV-001 | P0 | `docs/archived/spec-DEV-105.md` | `docs/AgToosa_TestPlan-DEV-105.md` |

### Wave 1b

| ID | Story | Type | Est | Epic | Pri | Spec | Test plan |
|---|---|---|---:|---|---:|---|---|
| DEV-087 | Delivery Evidence Contract + Profiles | Feature | M | DEV-002 | P0 | `docs/archived/spec-DEV-087.md` | `docs/AgToosa_TestPlan-DEV-087.md` |
| DEV-088 | Verifier and Doctor Machine Output | Feature | M | DEV-004 | P0 | `docs/archived/spec-DEV-088.md` | `docs/AgToosa_TestPlan-DEV-088.md` |
| DEV-089 | Evidence-Profile Verifier Gates | Feature | M | DEV-004 | P1 | `docs/archived/spec-DEV-089.md` | `docs/AgToosa_TestPlan-DEV-089.md` |
| DEV-091 | Migration Wizard + Rollback Manifest | Feature | L | DEV-001 | P0 | `docs/archived/spec-DEV-091.md` | `docs/AgToosa_TestPlan-DEV-091.md` |

> **Enrollment note (2026-07-12):** DEV-087 + DEV-088 enrolled Active Cycle (Wave 1b partial). DEV-091 remains backlog until DEV-090 ships — then Cycle C.

### Wave 2

| ID | Story | Type | Est | Epic | Pri | Spec | Test plan |
|---|---|---|---:|---|---:|---|---|
| DEV-092 | Transactional Apply + Idempotency | Chore | M | DEV-001 | P1 | `docs/archived/spec-DEV-092.md` | `docs/AgToosa_TestPlan-DEV-092.md` |
| DEV-093 | Install State File + Lock Reconciliation | Feature | M | DEV-001 | P1 | `docs/archived/spec-DEV-093.md` | `docs/AgToosa_TestPlan-DEV-093.md` |
| DEV-094 | Assistant Compatibility Contract | Feature | M | DEV-004 | P1 | `docs/archived/spec-DEV-094.md` | `docs/AgToosa_TestPlan-DEV-094.md` |
| DEV-097 | Framework Supply-Chain Threat Model | Docs | S | DEV-004 | P1 | `docs/archived/spec-DEV-097.md` | `docs/AgToosa_TestPlan-DEV-097.md` |
| DEV-100 | Shared JSON Output for Install/Registry | Feature | S | DEV-001 | P2 | `docs/archived/spec-DEV-100.md` | `docs/AgToosa_TestPlan-DEV-100.md` |

> **Enrollment note (2026-07-12):** Wave 2 A+B enroll — all five into Active Cycle; Wave 1a retained through ship. Build after Wave 1a ship: parallel **092 · 094 · 097**; **100** sequential vs 092 (shared dry-run/CLI); **093** blocked until 092 GREEN. DEV-100 R1 amend aligns Must ACs to `--format json` (pending amendment approval). Capacity soft overrun accepted.

### Wave 3

| ID | Story | Type | Est | Epic | Pri | Spec | Test plan |
|---|---|---|---:|---|---:|---|---|
| DEV-095 | Official Pack Expansion (5-pack max) | Feature | M | DEV-003 | P1 | `docs/archived/spec-DEV-095.md` | `docs/AgToosa_TestPlan-DEV-095.md` |
| DEV-096 | Pack Validation CI | Chore | S | DEV-003 | P1 | `docs/archived/spec-DEV-096.md` | `docs/AgToosa_TestPlan-DEV-096.md` |
| DEV-098 | Navigation by User Job | Docs | XS | DEV-004 | P2 | `docs/archived/spec-DEV-098.md` | `docs/AgToosa_TestPlan-DEV-098.md` |
| DEV-099 | Core vs Optional Pack Boundary | Docs | XS | DEV-002 | P2 | `docs/archived/spec-DEV-099.md` | `docs/AgToosa_TestPlan-DEV-099.md` |
| DEV-101 | Verified vs Community Pack Labeling | Docs | XS | DEV-003 | P2 | `docs/archived/spec-DEV-101.md` | `docs/AgToosa_TestPlan-DEV-101.md` |
| DEV-102 | Offline and Network-Dependency Matrix | Docs | XS | DEV-001 | P2 | `docs/archived/spec-DEV-102.md` | `docs/AgToosa_TestPlan-DEV-102.md` |
| DEV-103 | External Registry Publication Runbook | Chore | S | DEV-003 | P2 | `docs/archived/spec-DEV-103.md` | `docs/AgToosa_TestPlan-DEV-103.md` |
| DEV-104 | `--reinstall --clean` (ADR-004 Option C) | Feature | S | DEV-001 | P2 | `docs/archived/spec-DEV-104.md` | `docs/AgToosa_TestPlan-DEV-104.md` |
| DEV-106 | Built with AgToosa Showcase | Docs | XS | DEV-004 | P2 | `docs/archived/spec-DEV-106.md` | `docs/AgToosa_TestPlan-DEV-106.md` |

> **Enrollment note (2026-07-12):** Wave 3 A enroll after v5.3.18 — all nine into Active Cycle; **095** blocked on **096**; soft capacity overrun (~14 SP); docs parallel with soft file locks; **104** ready (090 shipped).

### Post-Rev4 enrollments (Spec Approved)

| ID | Story | Type | Est | Epic | Pri | Spec | Test plan |
|---|---|---|---:|---|---:|---|---|
| DEV-107 | Agent-Instructed Orchestration Brain | Feature | M | DEV-002 | P1 | `docs/archived/spec-DEV-107.md` | `docs/AgToosa_TestPlan-DEV-107.md` |
| DEV-109 | Lifecycle Next-Step Sync + Multi-Spec Clarity | Feature | L | DEV-002 / DEV-001 | P0 | `docs/archived/spec-DEV-109.md` | `docs/AgToosa_TestPlan-DEV-109.md` | 🏁 Shipped v5.3.21 |
| DEV-110 | AgToosa Project Intake | Feature | M | DEV-002 | P0 | `docs/archived/spec-DEV-110.md` | `docs/AgToosa_TestPlan-DEV-110.md` | 🏁 Shipped v5.3.22 |

> **Enrollment note (2026-07-12):** DEV-107 Spec Approved; remains Backlog until after Wave 1a capacity frees. Build must not displace DEV-086 / DEV-090 / DEV-105.
>
> **Enrollment note (2026-07-12):** DEV-109 shipped v5.3.21 — dual-line lifecycle closure + SYNC CLI + multi-spec clarity tags.
>
> **Enrollment note (2026-07-12):** DEV-110 shipped v5.3.22 — dual-mode Project Intake + always-on core rule + Standing Corrections.

## Recently shipped (v5.3.14 — 2026-07-11)

| ID | Story | Type | Spec |
|---|---|---|---|
| DEV-051 | Tracker Sync Bridge | Feature | `docs/archived/spec-DEV-051.md` |

## Recently shipped (v5.3.13 — 2026-07-11)

| ID | Story | Type | Spec |
|---|---|---|---|
| DEV-085 | Post-v5.3.12 release hygiene (bats restore + Master-Plan reconciliation) | Chore | `docs/archived/spec-DEV-085.md` |

## Recently shipped (v5.3.12 — 2026-07-11)

| ID | Story | Epic | Spec |
|---|---|---|---|
| DEV-058 | Local Dashboard | DEV-004 | `docs/archived/spec-DEV-058.md` |

## Recently shipped (v5.3.9 — 2026-07-11)

| ID | Story | Epic | Spec |
|---|---|---|---|
| DEV-045 | Work Package Wave DAG | DEV-002 | `docs/archived/spec-DEV-045.md` |
| DEV-076 | Static Documentation Site Proof | DEV-004 | `docs/archived/spec-DEV-076.md` |
| DEV-077 | Authoring Guide and Onboarding Surface | DEV-003 | `docs/archived/spec-DEV-077.md` |
| DEV-079 | Verifier and CI Adoption Examples | DEV-004 | `docs/archived/spec-DEV-079.md` |
| DEV-080 | Official Registry Pack Pilot | DEV-003 | `docs/archived/spec-DEV-080.md` |
| DEV-082 | High-Assurance Signature Mode Validation | DEV-003 | `docs/archived/spec-DEV-082.md` |
| DEV-083 | Voluntary Workflow Metrics Kit | DEV-004 | `docs/archived/spec-DEV-083.md` |
| DEV-084 | Open-Source Sustainability Boundary | DEV-004 | `docs/archived/spec-DEV-084.md` |

## Recently shipped (v5.3.8 — 2026-07-11)

| ID | Story | Epic | Spec |
|---|---|---|---|
| DEV-075 | Subagent and Persona Guide Suite | DEV-002 | `docs/archived/spec-DEV-075.md` |
| DEV-053 | Extension and Preset Catalog | DEV-003 | `docs/archived/spec-DEV-053.md` |
| DEV-078 | First-15-Minutes Maintenance Gate | DEV-004 | `docs/archived/spec-DEV-078.md` |
| DEV-081 | Optional Local DX Add-on Validation | DEV-001 | `docs/archived/spec-DEV-081.md` |

## Shipped prerequisite

| ID | Story | Spec | Role |
|---|---|---|---|
| DEV-055 | Agent Capability Matrix | `docs/archived/spec-DEV-055.md` | Shipped v5.3.7 — lifecycle routing prerequisite |

## Existing Future Stories — Deepened

These competitive-wave placeholders now contain functional EARS criteria, failure modes, concrete design and scope, task trees, Wave Plans, and mapped test plans.

| ID | Story | Estimate | Priority | Dependency / enrollment gate | Spec | Test plan |
|---|---|---:|---:|---|---|---|
| DEV-045 | Work Package Wave DAG | M | P1 | DEV-055 shipped | `docs/archived/spec-DEV-045.md` | `docs/AgToosa_TestPlan-DEV-045.md` |
| DEV-046 | Optional Worktree Isolation | M | P1 | DEV-045 shipped | `docs/archived/spec-DEV-046.md` | `docs/AgToosa_TestPlan-DEV-046.md` |
| DEV-051 | Tracker Sync Bridge | M | P1 | Explicit tracker demand; proposal-import only | `docs/archived/spec-DEV-051.md` | `docs/AgToosa_TestPlan-DEV-051.md` |
| DEV-052 | Hook Automation Pack | M | P1 | DEV-059 shipped | `docs/archived/spec-DEV-052.md` | `docs/AgToosa_TestPlan-DEV-052.md` |
| DEV-053 | Extension and Preset Catalog | M | P1 | Three catalog candidates identified | `docs/archived/spec-DEV-053.md` | `docs/AgToosa_TestPlan-DEV-053.md` |
| DEV-056 | Retrospective Learning Loop | S | P2 | Stable evidence artifacts; DEV-059 recommended | `docs/archived/spec-DEV-056.md` | `docs/AgToosa_TestPlan-DEV-056.md` |
| DEV-057 | Multi-Repo Story Overlay | L | P2 | Real multi-repo demand record plus DEV-045 | `docs/archived/spec-DEV-057.md` | `docs/AgToosa_TestPlan-DEV-057.md` |
| DEV-058 | Local Dashboard | M | P2 | Stable retro/evidence inputs | `docs/archived/spec-DEV-058.md` | `docs/AgToosa_TestPlan-DEV-058.md` |
| DEV-059 | Governance Policy-as-Code | M | P1 | DEV-045 recommended | `docs/archived/spec-DEV-059.md` | `docs/AgToosa_TestPlan-DEV-059.md` |

## New Adoption and Documentation Stories

| ID | Story | Type | Estimate | Epic | Priority | Spec | Test plan |
|---|---|---|---:|---|---:|---|---|
| DEV-075 | Subagent and Persona Guide Suite | Docs | M | DEV-002 | P1 | `docs/archived/spec-DEV-075.md` | `docs/AgToosa_TestPlan-DEV-075.md` |
| DEV-076 | Static Documentation Site Proof | Spike | S | DEV-004 | P2 | `docs/archived/spec-DEV-076.md` | `docs/AgToosa_TestPlan-DEV-076.md` |
| DEV-077 | Authoring Guide and Onboarding Surface | Chore | S | DEV-003 | P2 | `docs/archived/spec-DEV-077.md` | `docs/AgToosa_TestPlan-DEV-077.md` |
| DEV-078 | First-15-Minutes Maintenance Gate | Chore | XS | DEV-004 | P1 | `docs/archived/spec-DEV-078.md` | `docs/AgToosa_TestPlan-DEV-078.md` |
| DEV-079 | Verifier and CI Adoption Examples | Docs | S | DEV-004 | P2 | `docs/archived/spec-DEV-079.md` | `docs/AgToosa_TestPlan-DEV-079.md` |

## New Validation and Sustainability Stories

| ID | Story | Type | Estimate | Epic | Priority | Spec | Test plan |
|---|---|---|---:|---|---:|---|---|
| DEV-080 | Official Registry Pack Pilot | Feature | L | DEV-003 | P2 | `docs/archived/spec-DEV-080.md` | `docs/AgToosa_TestPlan-DEV-080.md` |
| DEV-081 | Optional Local DX Add-on Validation | Spike | M | DEV-001 | P2 | `docs/archived/spec-DEV-081.md` | `docs/AgToosa_TestPlan-DEV-081.md` |
| DEV-082 | High-Assurance Signature Mode Validation | Spike | S | DEV-003 | P2 | `docs/archived/spec-DEV-082.md` | `docs/AgToosa_TestPlan-DEV-082.md` |
| DEV-083 | Voluntary Workflow Metrics and Case Study Kit | Docs | S | DEV-004 | P2 | `docs/archived/spec-DEV-083.md` | `docs/AgToosa_TestPlan-DEV-083.md` |
| DEV-084 | Open-Source Sustainability and Support Boundary | Chore | XS | DEV-004 | P2 | `docs/archived/spec-DEV-084.md` | `docs/AgToosa_TestPlan-DEV-084.md` |

## Rev4 Dependency Order

```text
Wave 1a (parallel): DEV-086, DEV-090, DEV-105
  DEV-087 ──► DEV-089
  DEV-088 ──► DEV-091 (soft)
  DEV-090 ──► DEV-091, DEV-092, DEV-100, DEV-104
  DEV-092 ──► DEV-093
  DEV-086 ──► DEV-094 (scenario tier)
  DEV-096 ──► DEV-095
  DEV-057 (demand-gated, independent)
```

## Dependency Order (competitive wave — shipped)

```text
DEV-055
  ├─ DEV-075
  └─ DEV-045
       ├─ DEV-046
       ├─ DEV-059
       │    ├─ DEV-052
       │    └─ DEV-056
       │         ├─ DEV-058
       │         └─ DEV-051
       │              └─ DEV-057 (demand-gated)

DEV-053 ──► DEV-080
DEV-054 ──► DEV-082

Independent validation/adoption:
DEV-076, DEV-077, DEV-078, DEV-079, DEV-081, DEV-083, DEV-084
```

This graph is sequencing guidance. Only `docs/Master-Plan.md` can mark a story active.

## Manual / Deferred Coverage

These proposals already have authoritative Manual / Deferred rows and do not need duplicate specs:

| Work | Existing owner |
|---|---|
| Publish the npm wrapper | DEV-071 M-1 |
| Publish benchmark runs against Spec Kit, OpenSpec, and BMAD | DEV-060 M-1 |
| Configure release-environment reviewers | DEV-066 M-1 |
| Mirror the pinned Homebrew formula to the tap | DEV-066 M-2 |
| Optionally publish the CI gate to GitHub Marketplace | DEV-062 M-1 |
| Case study / tutorial publish | REV4-M-1 |
| Paid workshop pilot | REV4-M-2 |
| Proof terminal video | REV4-M-3 |
| Monthly progress note | REV4-M-4 |

## Shipped Coverage

The update documents also reference already-delivered foundations:

- DEV-031 — specialist subagents.
- DEV-039 — first-15-minutes proof.
- DEV-040 — team trust roadmap.
- DEV-044/061/067 — EARS, AC-to-test, and RED/GREEN proof.
- DEV-047/048 — handoff and import.
- DEV-049 — evidence ledger.
- DEV-050 — cross-model review.
- DEV-054 — signed provenance soft-warning mode.
- DEV-061/062 — verifier and CI gate.
- DEV-063/072 — events and living specs.
- DEV-064–066 — supply-chain hardening.
- DEV-071/074 — non-interactive installation and PowerShell parity.

## Parked — No Build Spec

These remain hypotheses until a documented user segment, security model, operating cost, and proof plan exist:

- Hosted AgToosa Cloud or real-time collaboration.
- SSO, SAML, RBAC, and compliance certification programs.
- MCP/A2A runtime server.
- Autonomous build-agent runtime.
- Federated registry and dependency solver.
- Commercial marketplace and revenue sharing.
- OpenTelemetry export and usage analytics.
- Voluntary scorecard instrumentation (DEV-108).
- Python CLI sixth official pack.
- Pro tier / SaaS / marketplace / federation.

If evidence appears, start with `/agtoosa-spec research`; do not promote directly to implementation.

## Rejected Under Current Tenets

- Replacing the canonical Shell/PowerShell core with Go or Rust.
- Silent telemetry or phone-home behavior.
- Automatic writes to protected CI workflow paths.
- External trackers, agents, or dashboards becoming more authoritative than `docs/Master-Plan.md`.
- Marketing unmeasured outcomes as facts.
- Duplicating canonical product logic in an optional wrapper.
- Revenue, hiring, or funding projections as product commitments.

## Completeness Check

| Update area | Story or disposition |
|---|---|
| Rev4 proof + verify CTA | DEV-086 (+ DEV-078 shipped) |
| Delivery evidence contract | DEV-087, DEV-089 |
| Verifier JSON flagship | DEV-088 |
| Safe upgrade / plan engine | DEV-090, DEV-091, DEV-092, DEV-093 |
| PS maintain parity | DEV-105 |
| Compatibility Install/Render/Scenario | DEV-094 (+ DEV-055 shipped) |
| Pack expansion (5 max) | DEV-095 (supersedes DEV-080 cap), DEV-096 |
| Docs by user job | DEV-098 (+ DEV-076 shipped) |
| Core vs pack boundary | DEV-099 |
| Framework threat model | DEV-097 |
| Install/registry JSON | DEV-100 |
| Pack trust labeling | DEV-101 |
| Offline/network matrix | DEV-102 |
| External registry runbook | DEV-103 (+ DEV-080 manual) |
| `--reinstall --clean` | DEV-104 |
| Community showcase | DEV-106 |
| Orchestration Brain (agent-instructed fan-out) | DEV-107 |
| Safe subagent routing and fan-out | DEV-055, DEV-045, DEV-046 (shipped) |
| Policy, hooks, and learning | DEV-059, DEV-052, DEV-056 (shipped) |
| Visibility and integrations | DEV-058, DEV-051, DEV-057 (demand-gated) |
| Catalog and maintained packs | DEV-053, DEV-077, DEV-080 (shipped) |
| Subagent/persona adoption docs | DEV-075 (shipped) |
| Static docs distribution | DEV-076 (shipped) |
| First-15 maintenance | DEV-078 (shipped) |
| Verifier/CI adoption | DEV-079 (shipped) |
| Optional wrapper/editor/CI validation | DEV-081 (shipped) |
| Fail-closed signature validation | DEV-082 (shipped, Defer) |
| Voluntary metrics/case studies | DEV-083 (shipped) |
| Sponsors/support boundary | DEV-084 (shipped) |
| OpenTelemetry / scorecard / Pro tier | Parked |
| Distribution publication tasks | Manual / Deferred rows |
| SaaS/identity/runtime expansion | Parked |
| Core rewrite/silent telemetry/SoT replacement | Rejected |

All actionable items in `docs/updates/` including Rev4 (`Rev4-*.md`) are covered by the rows above.
