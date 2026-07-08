# Spec: DEV-048 — Agent Result Import Gate

> **Story ID:** DEV-048
> **Epic:** DEV-002
> **Status:** 🏁 Shipped (v5.3.3)
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-08
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

In-session TDD already requires RED/GREEN Terminal Evidence (DEV-067) and verifier WARNs on missing RED blocks (DEV-061). External/async agent returns have no import checklist, so “agent said done” can become a premature checkbox. DEV-048 adds an **agent-instructed** import gate paired with DEV-047 handoff packs.

### Brownfield Spec Drift Baseline

| Field | Value |
|-------|-------|
| User outcome / proof | Users can map PR/branch/log evidence to ACs before closure; bats prove Import doc + Build/Ship wiring |
| Repo evidence inventory | `docs/AgToosa_Build.md` RED/GREEN; `docs/AgToosa_Ship.md` Part 0; `docs/agtoosa-verify.sh` Gate 3; stub spec-DEV-048 |
| Current-state baseline | No `AgToosa_Import.md`; no IMPORT evidence schema; Roadmap lists DEV-047–048 backlog |
| Intended change deltas | Import workflow; Build external-task detection; Ship soft readiness row; IR bats |
| Drift evidence | Stub meta-ACs → functional EARS; “blocks closure” clarified as agent-instructed not runtime |
| Claim Boundary | agent-instructed checklist; verifier FAIL on import = roadmap; hosted ingestion = out of scope |
| Source of truth | `docs/Master-Plan.md` remains the repo-local source of truth |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Import PRs, branches, logs, screenshots, and test output back into AgToosa evidence. |
| User outcome | Users can review external agent output against ACs before marking tasks complete. |
| Success condition | Import workflow maps returned artifacts to task status and instructs agents not to close tasks on missing evidence. |
| Proof / evidence | Import checklist doc, Build/Ship wiring, IR bats, test-plan evidence. |
| Claim Boundary | Import gate is **agent-instructed**; not generator-enforced; CI/verifier FAIL for import evidence is **roadmap**. Controls classified as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap. |
| Non-goals | Does not trust external agent claims without repo-local verification; no hosted webhooks; no DEV-049 ledger schema. |
| Assumptions | DEV-047 handoff return contract fields are available or defined inline in Import doc. |
| Risks | Agents ignore checklist; overclaiming “blocks” as a runtime engine. |
| Unresolved questions | None |

### 1.2 User Stories

**As a** maintainer, **I want** an import checklist for async agent results **so that** I never tick tasks on unverified external claims.

**As a** build orchestrator, **I want** Build to detect out-of-band work **so that** I am directed to `/agtoosa-import` before Tracking update.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-import` runs THE SYSTEM SHALL require an Import Checklist mapping artifact type, pointer, tasks, ACs, verification command, exit code, and reviewer. | Must |
| AC-002 | WHEN import evidence is recorded THE SYSTEM SHALL use an `IMPORT evidence` section in the story test plan with a task↔AC↔artifact mapping table. | Must |
| AC-003 | WHEN enforcement is described THE SYSTEM SHALL classify the import gate as agent-instructed and state that imported claims are not evidence until repo-local verification passes. | Must |
| AC-004 | WHEN `/agtoosa-build` encounters out-of-band or async-completed work THE SYSTEM SHALL instruct running the Import Checklist (or `/agtoosa-import`) before Tracking update / checkbox ticks. | Must |
| AC-005 | WHEN `/agtoosa-ship check` runs and IMPORT evidence or imported tasks exist THE SYSTEM SHALL include a soft readiness row confirming verification commands were reviewed (informational, not verifier FAIL). | Should |
| AC-006 | WHEN the template pack ships THE SYSTEM SHALL register `Docs/AgToosa_Import.md` in `lib/config.sh` and provide thin native adapters on major platforms. | Must |

### 1.4 Out of Scope

- Verifier FAIL on missing IMPORT blocks (roadmap WARN later)
- Evidence ledger JSON index (DEV-049)
- Automatic PR polling or cloud agent APIs

### Failure modes (Must ACs)

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Incomplete checklist → false closure |
| FM-002 | AC-002 | No test-plan mapping → audit gap |
| FM-003 | AC-003 | Docs claim runtime engine → dishonest positioning |
| FM-004 | AC-004 | Build ticks without import → SoT lies |
| FM-005 | AC-006 | Missing adapters → undiscoverable gate |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:
- `template/Docs/AgToosa_Import.md`, `docs/AgToosa_Import.md`
- Platform adapters for `/agtoosa-import` (same platforms as handoff)

Files to change:
- `template/Docs/AgToosa_Build.md`, `docs/AgToosa_Build.md` — external/async detection before Tracking
- `template/Docs/AgToosa_Ship.md`, `docs/AgToosa_Ship.md` — soft Part 0 row
- `template/Docs/AgToosa_Agent.md`, `docs/AgToosa_Agent.md` — Commands
- `template/Docs/AgToosa_Quickref.md`, `docs/AgToosa_Quickref.md`
- Readiness + Team Trust Roadmap matrices
- `lib/config.sh`, `tests/agtoosa.bats` (IR-001–IR-005)
- Entry point command tables

### 2.2 Data Flow

```
External agent returns (PR/branch/logs)
        │
        ▼
 /agtoosa-import checklist + local verify
        │
        ▼
 Test plan IMPORT evidence
        │
        ▼
 /agtoosa-build Tracking update (checkboxes)
```

### 2.3 STRIDE Threat Model

| Threat | Risk | Mitigation |
|--------|------|------------|
| Spoofing | Forged “tests passed” logs | Require runnable verification commands with exit codes |
| Tampering | Checkbox without mapping | Closure gate forbids ticks until checklist green |
| Repudiation | No import record | IMPORT evidence + phase event `import` |
| Information Disclosure | Pasting secrets from agent logs | Redact; cite paths only |
| Denial of Service | — | — |
| Elevation of Privilege | Import merges hostile CI changes | Build Scope + existing pack denylist unchanged |

### 2.4 Build Scope

**In scope:** files in §2.1.
**Out of scope:** verifier FAIL implementation; hosted services; version bump unless shipping.

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED contract bats (IR-001–IR-005) — _Requirements: AC-001–AC-006_
- [x] **2.** Canonical Import doc + maintainer mirror — _Requirements: AC-001, AC-002, AC-003_
- [x] **3.** Wire Build, Ship, Agent, Quickref, Readiness, Roadmap — _Requirements: AC-003, AC-004, AC-005_
- [x] **4.** Register config + platform adapters + entry points — _Requirements: AC-006_
- [x] **5.** GREEN bats + test-plan evidence — _Requirements: AC-001–AC-006_

### Wave Plan

**Wave 1 (parallel):** 1, 2
**Wave 2 (sequential after Wave 1):** 3, 4
**Wave 3 (sequential after Wave 2):** 5

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Mapped to IR tests: yes
- Claim Boundary honest: yes
- SoT preserved: yes
- No TBD placeholders: yes

## ✅ Spec Approved

Approved: 2026-07-08 17:45
