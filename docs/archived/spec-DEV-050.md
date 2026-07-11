# Spec: DEV-050 — Cross-Model Review Gate

> **Story ID:** DEV-050
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🟦 Todo
> **Estimate:** S
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11

## Context

AgToosa ships four **virtual** review personas in `/agtoosa-review` (Security, Engineering Manager, CEO, QA) and a manual **cross-platform** second-opinion path (`/agtoosa-review cross`). DEV-031 added **project-specific specialist subagents** with `phase_hooks` for `spec` only; review orchestration was explicitly deferred. DEV-006 established the **Status Guide** sub-agent pattern: thin native agent + canonical workflow doc + read-only audit + user authorization.

The competitive gap for DEV-050 is a **structured cross-model review gate**: optional writer/reviewer separation across different agents or models, with subagent delegation when the host supports it, deterministic evidence merge, and honest fallbacks when a second model is unavailable — without requiring paid APIs or claiming runtime enforcement AgToosa does not have.

**User-selected scope (recorded as findings):**

| Decision | Choice |
|----------|--------|
| Story ID | DEV-050 — Cross-Model Review Gate |
| User preference | Subagent-friendly — parallel reviewer lanes when native delegation exists |
| Relationship to `/agtoosa-review cross` | **Keep** cross-platform manual workflow; add **`cross-model`** sub-command for structured writer/reviewer separation and evidence merge |
| DEV-031 follow-up | Extend specialist `phase_hooks` to include **`review`** with same evidence block contract |
| Enforcement | Agent-instructed gate + optional ship/readiness nudge; no new CLI flags |
| Estimate | **S** — canonical docs, thin agent, config registration, focused bats |

**Smart interview findings (gaps covered without additional questions):**

| Checklist area | Finding |
|----------------|---------|
| Status quo | `/agtoosa-review cross` is manual platform switch; personas run on same orchestrator; specialists lack `review` hook; no cross-model evidence schema in `AgToosa_Evidence.md` |
| Narrowest v1 | New `AgToosa_CrossModelReview.md` contract; Review Part 5 + `cross-model` sub-command; Specialists review orchestration; optional `.github/agents/agtoosa-cross-model-reviewer.agent.md`; bats CM-001–CM-006 |
| Urgency | Maintainer dogfood after v5.3.5; user explicitly requested subagent-oriented spec enrollment |
| Failure modes | Reviewer subagent mutates files; orchestrator skips fallback note; ship claims cross-model without evidence row; specialist review lanes run without trigger match |
| Security | Read-only reviewer persona; no secret paste in handoff packs; user authorizes dispatch |
| Test evidence | Bats grep canonical + adapter routing + config inventory; no live multi-model API calls in CI |
| Rollout | Template + maintainer mirrors; existing projects gain gate on next `--update` |
| Non-goals | Paid model routing service; mandatory second model; replacing virtual personas; auto-run `/agtoosa-ship` |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Add an optional **cross-model review gate** that separates writer (build) from independent reviewer (different agent/model/subagent) for higher-assurance stories, with structured evidence merge and platform fallbacks. |
| User outcome | Users reduce single-agent blind spots on security, architecture, and quality reviews by delegating an independent reviewer subagent or second model, without AgToosa pretending to enforce model APIs it does not control. |
| Success condition | Canonical `AgToosa_CrossModelReview.md` defines triggers, writer/reviewer roles, evidence format, merge rules, and fallbacks; `/agtoosa-review cross-model` and Review Part 5 implement the gate; `AgToosa_Specialists.md` documents `review` phase orchestration; ship/readiness reference the gate honestly; bats CM-001–CM-006 green. |
| Proof / evidence | Focused bats filter green; test plan `docs/AgToosa_TestPlan-DEV-050.md`; review report includes cross-model section when gate ran or documented skip. |
| Non-goals | Hosted model router; mandatory paid second model; replacing four virtual personas; specialist marketplace; verifier FAIL on missing cross-model (v1 agent-instructed only). |
| Assumptions | Hosts with Task/Agent/subagent tools run reviewer lanes in parallel when safe; sequential fallback uses identical evidence schema; `/agtoosa-review cross` remains valid when cross-model delegation unavailable. |
| Risks | Terminology collision with `cross` (platform) vs `cross-model` (writer/reviewer); adapter drift; overclaiming enforcement. Mitigate with glossary, parity bats, Claim Boundary tables. |
| Unresolved questions | None — user preference for subagents recorded; enrollment inferred from empty-cycle `/agtoosa-spec` request. |

### 1.2 User Stories

**As an** AgToosa user completing `/agtoosa-build`, **I want** the review phase to optionally delegate an independent reviewer subagent or second model **so that** security and architecture findings are not limited to the same agent that wrote the code.

**As an** AgToosa user with approved project specialists (DEV-031), **I want** specialists whose `phase_hooks` includes `review` to run during `/agtoosa-review` **so that** domain experts contribute structured evidence without duplicating virtual personas.

**As an** AgToosa maintainer, **I want** bats and `lib/config.sh` to install and lock the cross-model review contract **so that** generator releases keep template and maintainer mirrors aligned.

**As an** AgToosa user without a second model available, **I want** documented fallbacks (`/agtoosa-review cross`, sequential virtual personas, or explicit skip with rationale) **so that** the gate never blocks ship with impossible requirements.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `Docs/AgToosa_CrossModelReview.md` is installed THE SYSTEM SHALL define writer role, independent reviewer role, risk-tier triggers (recommended vs strongly recommended), evidence block schema, merge/confidence rules, and fallback paths | Must |
| AC-002 | WHEN `/agtoosa-review cross-model` runs THE SYSTEM SHALL require the build agent to act as read-only orchestrator for the reviewer lane and SHALL NOT allow the reviewer to modify files or git state without explicit user authorization | Must |
| AC-003 | WHEN a reviewer lane completes THE SYSTEM SHALL emit a structured evidence block matching `AgToosa_Specialists.md` (`Findings:`, `Files read:`, `Commands:`, `Warnings/errors:`, `Recommendations:`, `Spec sections affected:`) plus cross-model fields: `Reviewer identity`, `Model/platform`, `Confidence tier` | Must |
| AC-004 | WHEN the host supports native parallel subagent delegation THE SYSTEM SHALL run independent reviewer persona(s) and matching `review`-phase specialists in parallel; OTHERWISE THE SYSTEM SHALL run the same lanes sequentially and record `Cross-model lanes ran sequentially (platform does not support parallel subagents).` | Must |
| AC-005 | WHEN `/agtoosa-review` completes for a story whose spec or threat model flags security/registry/auth surfaces THE SYSTEM SHALL strongly recommend `/agtoosa-review cross-model` or document an explicit skip rationale in the review report | Must |
| AC-006 | WHEN `Docs/Context/specialists.md` lists specialists with `phase_hooks` including `review` THE SYSTEM SHALL run only specialists whose `trigger` matches the active story during `/agtoosa-review` orchestration | Must |
| AC-007 | WHEN cross-model findings are merged THE SYSTEM SHALL tag each finding with confidence: `both-models`, `reviewer-only`, `writer-only`, or `virtual-persona-only` before the Part 3 verdict table | Must |
| AC-008 | WHEN no second model or subagent is available THE SYSTEM SHALL offer fallbacks in order: `/agtoosa-review cross` (cross-platform), sequential virtual personas, or documented skip — and SHALL NOT mark the gate as passed without one of these outcomes recorded | Must |
| AC-009 | WHEN `agtoosa.sh` installs or updates workflow docs THE SYSTEM SHALL include `Docs/AgToosa_CrossModelReview.md` via `lib/config.sh` and register optional `.github/agents/agtoosa-cross-model-reviewer.agent.md` for GitHub platform installs | Must |
| AC-010 | WHEN a reader opens `Docs/AgToosa_Review.md` THE SYSTEM SHALL list `/agtoosa-review cross-model` in Sub-Commands and delegate gate logic to `Docs/AgToosa_CrossModelReview.md` without duplicating the full contract | Must |
| AC-011 | WHEN `Docs/AgToosa_Evidence.md` review phase is populated THE SYSTEM SHALL allow a `cross-model` evidence row linking reviewer identity, merge outcome, and skip rationale when applicable | Should |
| AC-012 | WHEN `tests/agtoosa.bats` runs DEV-050 coverage THE SYSTEM SHALL assert canonical doc inventory, Review/Specialists cross-links, adapter routing, reserved-name guardrails, and sequential-fallback wording | Must |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-002 | Reviewer subagent applies fixes during review → corrupts build branch |
| AC-003 | Reviewer returns prose only → orchestrator cannot merge into verdict table |
| AC-004 | Cursor host claims parallel without fallback note when only sequential possible |
| AC-005 | Security story ships with no cross-model section and no skip rationale |
| AC-006 | All specialists run regardless of trigger → noise and token waste |
| AC-007 | Duplicate findings counted twice without confidence tier |
| AC-008 | Gate documented as "passed" when user never ran reviewer or fallback |
| AC-009 | Maintainer mirror missing after template change |
| AC-010 | Adapters embed divergent gate rules instead of routing to canonical doc |

### 1.4 Out of Scope

- Model API routing, billing, or hosted reviewer services
- Mandatory cross-model review for every story (v1: risk-tier nudges only)
- Replacing virtual Security/EM/CEO/QA personas
- Verifier FAIL gate for missing cross-model evidence (roadmap)
- Specialist orchestration for `/agtoosa-build` or `/agtoosa-qa` (separate stories)

### 1.5 Claim Boundary

| Control | Classification |
|---------|----------------|
| Cross-model gate workflow and evidence schema | agent-instructed |
| Specialist `review` phase orchestration | agent-instructed |
| Optional `.github/agents/agtoosa-cross-model-reviewer.agent.md` install | generator-enforced (file inventory) |
| Parallel subagent execution | agent-instructed (host-dependent) |
| Verifier FAIL when cross-model skipped | roadmap |
| Paid second model requirement | out of scope |

## 2. Design

### 2.1 Architecture Blueprint

```
/agtoosa-build (writer agent)
        │
        ▼
/agtoosa-review (orchestrator)
        │
        ├── Part 1–3: virtual personas (existing)
        │
        └── Part 5: Cross-Model Review Gate (NEW)
                 │
                 ├── Risk-tier check (spec STRIDE / AC tags)
                 ├── /agtoosa-review cross-model
                 │        ├── Delegate reviewer subagent(s)
                 │        ├── Run review-phase specialists (DEV-031)
                 │        └── Collect evidence blocks (parallel or sequential)
                 ├── Merge findings + confidence tiers
                 └── Fallback: cross-platform / skip rationale
        │
        ▼
docs/archived/review-[id].md + evidence cross-model row
```

**New / updated surfaces:**

| Surface | Action |
|---------|--------|
| `template/Docs/AgToosa_CrossModelReview.md` | **Create** — canonical gate contract |
| `docs/AgToosa_CrossModelReview.md` | **Mirror** |
| `template/Docs/AgToosa_Review.md` | **Update** — Sub-Commands + Part 5 |
| `docs/AgToosa_Review.md` | **Mirror** |
| `template/Docs/AgToosa_Specialists.md` | **Update** — `review` phase_hook orchestration |
| `docs/AgToosa_Specialists.md` | **Mirror** |
| `template/Docs/AgToosa_Evidence.md` | **Update** — cross-model evidence row |
| `docs/AgToosa_Evidence.md` | **Mirror** |
| `template/.github/agents/agtoosa-cross-model-reviewer.agent.md` | **Create** — thin GitHub agent |
| `template/Docs/AgToosa_Agent.md`, `AgToosa_Skills.md`, `AgToosa_Quickref.md` | **Update** — list sub-command |
| Maintainer mirrors under `docs/` | **Sync** |
| Platform review adapters | **Update** — route to canonical doc |
| `lib/config.sh` | **Register** new files |
| `tests/agtoosa.bats` | **Add** CM-001–CM-006 |

### 2.2 Data Flow

1. Orchestrator reads active spec threat model and Must ACs → computes risk tier.
2. If tier ≥ `recommended`, prompt user to run `/agtoosa-review cross-model` (or proceed with documented skip).
3. Reviewer subagent(s) receive read-only scope: diff, spec, test results, threat model — no write tools unless user authorizes a fix command.
4. Evidence blocks return to orchestrator → merge into review report with confidence tiers.
5. `docs/archived/review-[id].md` gains `## Cross-Model Review` section; evidence ledger updated.

### 2.3 STRIDE Threat Model

| Threat | Risk | Mitigation |
|--------|------|------------|
| Spoofing | Fake “independent” review from same model without disclosure | Evidence block requires `Reviewer identity` + `Model/platform` |
| Tampering | Reviewer modifies code during read-only gate | AC-002 read-only guarantee; authorization gate before fixes |
| Repudiation | No record that cross-model ran or was skipped | Review report section + evidence row + Update Log |
| Information Disclosure | Handoff pack leaks secrets to external reviewer | Paths/process only; reuse DEV-047 pack rules |
| Denial of Service | Mandatory second model blocks ship | Fallback chain + explicit skip rationale (AC-008) |
| Elevation of Privilege | Reviewer subagent runs destructive git commands | Read-only tool allowlist in agent definition |

### 2.4 Build Scope

**Files in scope:**

- `template/Docs/AgToosa_CrossModelReview.md`, `docs/AgToosa_CrossModelReview.md`
- `template/Docs/AgToosa_Review.md`, `docs/AgToosa_Review.md`
- `template/Docs/AgToosa_Specialists.md`, `docs/AgToosa_Specialists.md`
- `template/Docs/AgToosa_Evidence.md`, `docs/AgToosa_Evidence.md`
- `template/Docs/AgToosa_Agent.md`, `docs/AgToosa_Agent.md`
- `template/Docs/AgToosa_Skills.md`, `docs/AgToosa_Skills.md`
- `template/Docs/AgToosa_Quickref.md`, `docs/AgToosa_Quickref.md`
- `template/.github/agents/agtoosa-cross-model-reviewer.agent.md`
- Review platform adapters under `template/.cursor/`, `.claude/`, `.windsurf/`, `.gemini/`, `.github/prompts/`, `.codex/`
- `lib/config.sh`
- `tests/agtoosa.bats` (DEV-050 CM section)

**Out of scope:**

- `agtoosa.sh` / `agtoosa.ps1` behavior changes beyond config file lists
- Version bumps and release publication (ship story)
- Verifier gate changes (`docs/agtoosa-verify.sh`)
- Default specialist roster in `template/`

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED contract bats (CM-001–CM-006) — _Requirements: AC-001, AC-009, AC-012_
- [x] **2.** Canonical `AgToosa_CrossModelReview.md` + maintainer mirror — _Requirements: AC-001, AC-003, AC-007, AC-008_
- [ ] **3.** Wire Review Part 5 + `cross-model` sub-command; Specialists `review` hook — _Requirements: AC-004, AC-005, AC-006, AC-010_
- [ ] **4.** Evidence doc row + GitHub agent + config registration + platform adapters — _Requirements: AC-002, AC-009, AC-011_
- [ ] **5.** GREEN bats + test-plan evidence + Agent/Skills/Quickref cross-links — _Requirements: AC-012_

### Wave Plan

**Wave 1 (parallel):** 1, 2
**Wave 2 (sequential after Wave 1):** 3, 4
**Wave 3 (sequential after Wave 2):** 5

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- No contradiction with Non-goals / Claim Boundary: yes
- Every Must AC maps to test-plan row: yes (CM-001–CM-006)
- Enforcement classified: yes (§1.5)
- SoT preserved: yes (`docs/Master-Plan.md`)
- No TBD/TODO placeholders: yes

## ✅ Spec Approved

Approved: 2026-07-11 12:58
