# Roadmap-to-Spec Index

> **Purpose:** Coverage map from `docs/updates/` strategy into executable AgToosa work.
> **Snapshot:** 2026-07-11.
> **Authority:** `docs/Master-Plan.md` remains the source of truth for status and priority.

## Coverage Contract

Every actionable proposal in the update documents is represented by one of:

1. A shipped DEV story.
2. An existing Manual / Deferred task.
3. An executable backlog spec and matching test plan.
4. An explicit parked or rejected decision.

Editing this index does not enroll a story. Backlog stories still require `/agtoosa-spec`, explicit approval, and a separate `/agtoosa-build` invocation.

## Active Stories (four-epic parallel build — 2026-07-11)

| ID | Story | Epic | Spec | Role |
|---|---|---|---|---|
| DEV-075 | Subagent and Persona Guide Suite | DEV-002 | `docs/archived/spec-DEV-075.md` | Active — workflow adoption docs |
| DEV-053 | Extension and Preset Catalog | DEV-003 | `docs/archived/spec-DEV-053.md` | Active — registry catalog layer |
| DEV-078 | First-15-Minutes Maintenance Gate | DEV-004 | `docs/archived/spec-DEV-078.md` | Active — release-pin drift gate |
| DEV-081 | Optional Local DX Add-on Validation | DEV-001 | `docs/archived/spec-DEV-081.md` | Active — spike evidence only |

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

## Dependency Order

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
| Safe subagent routing and fan-out | DEV-055, DEV-045, DEV-046 |
| Policy, hooks, and learning | DEV-059, DEV-052, DEV-056 |
| Visibility and integrations | DEV-058, DEV-051, DEV-057 |
| Catalog and maintained packs | DEV-053, DEV-077, DEV-080 |
| Subagent/persona adoption docs | DEV-075 |
| Static docs distribution | DEV-076 |
| First-15 maintenance | DEV-078 |
| Verifier/CI adoption | DEV-079 |
| Optional wrapper/editor/CI validation | DEV-081 |
| Fail-closed signature validation | DEV-082 |
| Voluntary metrics/case studies | DEV-083 |
| Sponsors/support boundary | DEV-084 |
| Sponsored educational content and optional support disclosure | DEV-084 |
| OpenTelemetry export and usage analytics | Parked |
| Distribution publication tasks | Existing Manual / Deferred rows |
| SaaS/identity/runtime expansion | Parked |
| Core rewrite/silent telemetry/SoT replacement | Rejected |

All actionable items in `docs/updates/` are covered by the rows above.
