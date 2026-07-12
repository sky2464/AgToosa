# Spec: DEV-087 — Feature: Delivery Evidence Contract + Profiles

> **Story ID:** DEV-087
> **Type:** Feature
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🟦 Todo
> **Estimate:** M
> **Priority:** P0
> **Spec created:** 2026-07-12
> **Extends:** DEV-049, DEV-055

## Context

DEV-049 shipped the per-story Evidence Ledger (`AgToosa_Evidence.md`); DEV-055 shipped lifecycle agent routing. Rev4 requires a **Delivery Evidence Contract** that defines minimum evidence per delivery class using Guided / Evidenced / Enforced labels. This is distinct from the **Terminal Evidence Contract** in `AgToosa_Agent.md` (per-task command/exit output for orchestrators). Binding resolutions in `docs/updates/rev4-conflict-resolutions.md` §3–§4 name the doc `AgToosa_Delivery_Evidence_Contract.md`, ship `.agtoosa/evidence.yml` profiles, and add `template/.agtoosa/README.md` as the config index alongside `policy.yaml` (DEV-059). Full verifier gate enforcement for profiles is DEV-089; this story delivers schema, documentation, and schema-only validation.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a Delivery Evidence Contract with optional YAML profiles and a config index so teams declare minimum delivery evidence by class without conflating terminal task output with delivery assurance. |
| User outcome | Users configure `standard`, `security-sensitive`, and `release` evidence profiles; docs distinguish Guided vs Evidenced vs Enforced; optional schema check validates YAML shape locally. |
| Success condition | `Docs/AgToosa_Delivery_Evidence_Contract.md` ships with taxonomy and profile semantics; `template/.agtoosa/evidence.yml.example` and `template/.agtoosa/README.md` install; `agtoosa-evidence-profile-check.sh` validates schema only; cross-links from Terminal Evidence and Evidence Ledger docs. |
| Proof / evidence | DEC bats for doc inventory, example YAML, config index, schema validator, and cross-links; test-plan RED/GREEN. |
| Non-goals | Replacing Terminal Evidence Contract; verifier Gate 7 enforcement (DEV-089); hosted audit log; semantic correctness judging by scripts. |
| Assumptions | Markdown contract is canonical; YAML is optional project config; ledger consolidation at review/ship remains agent-instructed (DEV-049). |
| Risks | Naming collision with Terminal Evidence; users expect full enforcement when only schema ships; profile drift from contract doc. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** team lead, **I want** delivery-class evidence profiles in `.agtoosa/evidence.yml` **so that** security-sensitive work requires threat-model and scan artifacts by policy declaration.

**As an** AgToosa user, **I want** Guided/Evidenced/Enforced labels in one contract **so that** I do not mistake LLM review for deterministic enforcement.

**As a** maintainer, **I want** a `.agtoosa/` config index **so that** `policy.yaml` and `evidence.yml` purposes and gate order are documented without overlap.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `Docs/AgToosa_Delivery_Evidence_Contract.md` is installed THE SYSTEM SHALL define Guided, Evidenced, and Enforced assurance levels with examples and SHALL state that semantic review remains Guided/Evidenced while presence and command outcomes may be Enforced | Must |
| AC-002 | WHEN delivery profiles are documented THE SYSTEM SHALL define at least `standard`, `security-sensitive`, and `release` profile names with required artifact classes (e.g. spec, tests, review, threat-model, changelog) | Must |
| AC-003 | WHEN `template/.agtoosa/evidence.yml.example` ships THE SYSTEM SHALL provide commented example profiles matching the contract and SHALL register the example in `lib/config.sh` for install/update | Must |
| AC-004 | WHEN `template/.agtoosa/README.md` ships THE SYSTEM SHALL index `policy.yaml` (agent governance, DEV-059) and `evidence.yml` (delivery profiles, DEV-087) and SHALL document verifier gate order: policy (Gate 6) → evidence profile (Gate 7, DEV-089) → lifecycle gates | Must |
| AC-005 | WHEN `Docs/agtoosa-evidence-profile-check.sh` runs on a project THE SYSTEM SHALL validate `.agtoosa/evidence.yml` against the documented schema only (structure, known profile keys, required artifact tokens) and SHALL exit non-zero on invalid YAML without claiming full delivery compliance | Must |
| AC-006 | WHEN the contract is described THE SYSTEM SHALL cross-link from `Docs/AgToosa_Agent.md` Terminal Evidence section and `Docs/AgToosa_Evidence.md` and SHALL NOT replace or rename Terminal Evidence Contract | Must |
| AC-007 | WHEN enforcement is described THE SYSTEM SHALL classify profile checking in this story as schema-only local validation; full profile gate enforcement is roadmap/DEV-089 | Must |
| AC-008 | WHEN `agtoosa.sh --update` installs workflow files THE SYSTEM SHALL include the Delivery Evidence Contract doc and `.agtoosa/` config index via `lib/config.sh` | Must |
| AC-009 | WHEN `tests/agtoosa.bats` runs DEV-087 coverage THE SYSTEM SHALL assert doc registration, example YAML validity, config index content, schema checker behavior, and Terminal Evidence cross-link | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Contract omits Enforced boundary; users believe LLM review is CI-gated. |
| FM-002 | AC-002 | Profiles lack security-sensitive requirements; teams under-document threat models. |
| FM-003 | AC-003 | Example YAML drifts from contract artifact names. |
| FM-004 | AC-004 | Config index missing; `policy.yaml` and `evidence.yml` purposes collide. |
| FM-005 | AC-005 | Schema checker claims full delivery compliance or executes network calls. |
| FM-006 | AC-006 | Terminal Evidence section removed or renamed; orchestrator contract breaks. |
| FM-007 | AC-007 | Docs claim DEV-087 enforces Gate 7; false CI enforcement positioning. |

### 1.5 Out of Scope

- Replacing or merging Terminal Evidence Contract (`AgToosa_Agent.md` § Terminal Evidence).
- Verifier Gate 7 profile enforcement (DEV-089).
- Hosted evidence audit log or telemetry.
- Judging semantic correctness of specs, reviews, or threat models.
- Automatic creation of missing evidence artifacts.
- Changing Evidence Ledger row schema (DEV-049).

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Delivery Evidence Contract doc + example YAML | generator-enforced file inventory |
| `.agtoosa/README.md` config index | generator-enforced file inventory |
| `agtoosa-evidence-profile-check.sh` schema validation | local machine check (schema only) |
| Profile artifact presence at ship | agent-instructed / DEV-089 enforced |
| Terminal Evidence per-task blocks | agent-instructed (unchanged) |
| Semantic review quality | guided — not machine-enforced |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `template/Docs/AgToosa_Delivery_Evidence_Contract.md` — canonical contract; mirror to `docs/`.
- `template/.agtoosa/evidence.yml.example` — commented profile examples.
- `template/.agtoosa/README.md` — config index for `policy.yaml` and `evidence.yml`.
- `template/Docs/agtoosa-evidence-profile-check.sh` — schema-only YAML validator; mirror to `docs/`.

Files to change:

- `lib/config.sh` — register contract, example YAML, config index, schema checker script.
- `template/Docs/AgToosa_Agent.md` and `docs/AgToosa_Agent.md` — cross-link Delivery vs Terminal Evidence.
- `template/Docs/AgToosa_Evidence.md` and `docs/AgToosa_Evidence.md` — cross-link delivery profiles to ledger rows.
- `tests/agtoosa.bats` — DEC-001–DEC-009 coverage.

Key interfaces:

- `agtoosa-evidence-profile-check.sh [--root PATH]` — exit `0` valid / `1` invalid schema; no artifact existence checks in v1.
- Evidence profile schema — `profiles.<name>.required: [artifact-class, ...]` documented in contract.

### 2.2 Data Flow

1. User reads Delivery Evidence Contract for assurance taxonomy and profile semantics.
2. User copies `evidence.yml.example` to `.agtoosa/evidence.yml` and selects a profile.
3. Config index explains relationship to `policy.yaml` and future Gate 7 order.
4. Schema checker reads YAML, validates structure against documented tokens, prints actionable errors.
5. Review/ship workflows reference contract for what to collect; ledger still consolidates at review/ship (DEV-049).
6. Terminal Evidence Contract remains the per-task orchestrator output format unchanged.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Malicious YAML executes code during validation | Elevation of Privilege | Parse YAML structurally only; no eval; use safe parser (python/yq) with size limits. |
| Contract claims CI enforces profiles before DEV-089 | Spoofing | Explicit schema-only and Claim Boundary labels (AC-007). |
| Secrets embedded in evidence.yml | Information Disclosure | Schema checker rejects unexpected secret-like keys; document no secrets in profiles. |
| Terminal Evidence confused with delivery profiles | Repudiation | Distinct doc titles and cross-links (rev4-conflict-resolutions §3). |
| Oversized YAML denies local checks | Denial of Service | Size cap in checker; fail fast on parse errors. |
| policy.yaml and evidence.yml gate order tampered in docs | Tampering | Config index owned in template; DEC bats lock gate order text. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `template/Docs/AgToosa_Delivery_Evidence_Contract.md`, `template/.agtoosa/evidence.yml.example`, `template/.agtoosa/README.md`, `template/Docs/agtoosa-evidence-profile-check.sh`, `lib/config.sh`, `AgToosa_Agent.md`, `AgToosa_Evidence.md`, `tests/agtoosa.bats`
Directories in scope: `template/Docs/`, `template/.agtoosa/`, `docs/`, `tests/`
Out of scope        : Gate 7 enforcement, ledger schema changes, hosted audit, Terminal Evidence rewrite

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract and schema RED coverage
  - [ ] 1.1 Add DEC bats for doc title, taxonomy, profiles, and cross-links — _Requirements: AC-001, AC-002, AC-006, AC-009_
  - [ ] 1.2 Add DEC bats for example YAML, config index, and schema checker invalid fixtures — _Requirements: AC-003, AC-004, AC-005, AC-009_
- [ ] **2.** Delivery Evidence Contract surfaces
  - [ ] 2.1 Author `AgToosa_Delivery_Evidence_Contract.md` with profiles and assurance levels — _Requirements: AC-001, AC-002, AC-007_
  - [ ] 2.2 Ship `evidence.yml.example` and `.agtoosa/README.md` config index — _Requirements: AC-003, AC-004_
  - [ ] 2.3 Implement `agtoosa-evidence-profile-check.sh` schema-only validation — _Requirements: AC-005, AC-007_
- [ ] **3.** Wiring and registration
  - [ ] 3.1 Register files in `lib/config.sh` and add Agent/Evidence cross-links — _Requirements: AC-006, AC-008_
  - [ ] 3.2 Mirror maintainer `docs/` copies — _Requirements: AC-008_
- [ ] **4.** Evidence
  - [ ] 4.1 Record DEC RED/GREEN evidence in test plan — _Requirements: AC-001–AC-009_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential after Wave 1):** 2.1, 2.2, 2.3
**Wave 3 (sequential after Wave 2):** 3.1, 3.2
**Wave 4 (sequential after Wave 3):** 4.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-087.md`
AC coverage: 9 ACs mapped to 9 DEC test IDs
Smoke set: 3 tests tagged `@smoke`

## ✅ Spec Approved

Approved: 2026-07-12 09:00
Enrollment: Rev4 Wave 1 — delivery evidence contract
