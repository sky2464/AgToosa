# Spec: DEV-124 — Spike: Cross-Framework Interchange

> **Story ID:** DEV-124  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Spike  
> **Status:** 🏁 Shipped — v5.3.40  
> **Estimate:** M  
> **Clarity:** `ready`  
> **Priority:** P2  
> **Depends on:** DEV-120 (Delivery Proof Fabric)  
> **Extends:** DEV-048 (Agent Result Import Gate) · DEV-118 (Product Truth & Adapter Contract)  
> **Spec created:** 2026-07-26  
> **ADR:** `docs/adr/ADR-024-cross-framework-interchange.md` (Proposed)  
> **Portfolio:** Competitive Proof Portfolio child — follows DEV-120; must not absorb DEV-123 capsules

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Loss-aware import/export between AgToosa and Spec Kit, OpenSpec, Kiro-style specs, and BMAD — preserving source IDs and authority boundaries |
| Foundation | DEV-120 proof graphs optional integrity binding; DEV-048 import gate defines evidence mapping; `SPEC-FORMAT.md` is the Kiro-style canonical; `enforcement-comparison.md` documents honest framework boundaries |
| Portfolio role | Interchange child; must not absorb portable execution, drift, or behavioral lab scope |
| Non-goals | Perfect round-trip claims; replacing source frameworks; required network access; live framework installs in spike |
| Narrowest scope | Contract + interchange manifest + loss-report schemas + four fixture-based providers + export/import/assess CLIs + CFI bats — **no** network, **no** hosted registries |
| Security surface | Local file reads on fixture paths; network-free; path traversal blocked; imported artifacts are derived — Master-Plan remains SoT |
| Test evidence | CFI bats on golden manifests, per-framework fixtures, loss-report cases, authority preservation |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Proceed with full `/agtoosa-spec` for DEV-124 now? | User: **"Next"** — proceed with documented assumptions (portfolio momentum opt-in) |
| Q2 | Narrowest spike deliverable? | **Inferred + accepted:** fixture-based providers for Spec Kit, OpenSpec, BMAD, Kiro-style; normalized interchange manifest + explicit loss report — **no** live `uvx`/`npx` installs |
| Q3 | Authority on import? | **Inferred + accepted:** `docs/Master-Plan.md` remains SoT; imports emit derived manifests only — no checkbox or protected-workflow writes |

#### Documented assumptions

- **Kiro** interchange profile maps AgToosa `SPEC-FORMAT.md` single-file specs — not AWS Kiro IDE remote APIs.
- Framework fixtures under `tests/fixtures/interchange/` are **frozen representatives** — not live framework telemetry.
- Loss severity uses fixture-labeled cases (`low` · `high`) — assess script documents gaps; default **suggest-only**; `--strict` opt-in for high-severity unmappable authority fields.
- User **"Next"** after DEV-123 ship satisfies minimum validation floor per documented-assumptions exception.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ship a cross-framework interchange spike: normalized manifest + loss-report formats, fixture-based providers for Spec Kit, OpenSpec, BMAD, and Kiro-style specs, and export/import/assess CLIs — all local and network-free |
| User outcome | Maintainers can export an AgToosa story to framework-shaped artifacts, import external framework fixtures with an explicit loss report, and preserve source IDs without claiming perfect round-trip fidelity |
| Success condition | Contract doc + two JSON schemas + four providers + `agtoosa-interchange-export.sh` + `agtoosa-interchange-import.sh` + `agtoosa-interchange-assess.sh` + pilot fixtures + cross-links + CFI bats green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-124.md`; bats `CFI-*`; fixtures under `tests/fixtures/interchange/` |
| Non-goals | Perfect round-trip claims; replacing source frameworks; required network access; live framework installs; Gate 8; auto-editing Master-Plan; DEV-123 capsules |
| Assumptions | DEV-120 proof graphs optional on export; fixtures represent framework shapes honestly; git available for repo root resolution |
| Risks | Imports mistaken for SoT replacement; loss report ignored; framework fixtures drift from real tools |
| Unresolved questions | None |

### 1.1 User Stories

**As a** maintainer evaluating Spec Kit or OpenSpec, **I want** loss-aware export/import **so that** I can compare frameworks without false equivalence claims.

**As a** release engineer, **I want** source IDs preserved in interchange manifests **so that** traceability survives cross-framework moves.

**As a** portfolio owner, **I want** explicit loss reports **so that** interchange honesty is machine-readable — not implied perfect fidelity.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN Cross-Framework Interchange v1 is documented THE SYSTEM SHALL define manifest schema, loss-report semantics, source-id preservation, authority boundaries, and claim boundaries separating derived interchange from Master-Plan SoT | Must |
| AC-002 | WHEN an interchange manifest is authored THE SYSTEM SHALL conform to `contracts/interchange-manifest-v1.schema.json` with `story_id`, `source_framework`, `source_ids`, `authority`, and normalized requirements/tasks | Must |
| AC-003 | WHEN `agtoosa-interchange-export.sh` runs with `--story` and `--target` THE SYSTEM SHALL emit a manifest JSON and framework-shaped artifact from the archived AgToosa spec without network I/O | Must |
| AC-004 | WHEN `agtoosa-interchange-import.sh` runs on a framework fixture THE SYSTEM SHALL emit a normalized manifest and companion loss report conforming to `contracts/interchange-loss-report-v1.schema.json` | Must |
| AC-005 | WHEN loss is assessed THE SYSTEM SHALL record unmappable fields with severity and reason — fixture-labeled only; SHALL NOT claim perfect round-trip | Must |
| AC-006 | WHEN `agtoosa-interchange-assess.sh` runs without `--strict` THE SYSTEM SHALL exit zero on low-severity loss warnings — suggest-only; non-zero only on schema/authority failures | Must |
| AC-007 | WHEN `--strict` is passed THE SYSTEM SHALL exit non-zero when any high-severity loss or authority violation is detected — opt-in maintainer gate only | Must |
| AC-008 | WHEN export references a proof graph THE SYSTEM SHALL document separate `agtoosa-proof-verify.sh` requirement and SHALL NOT auto-mark graph valid | Must |
| AC-009 | WHEN `AgToosa_Import.md` and `AgToosa_Spec.md` are updated THE SYSTEM SHALL cross-link interchange export/import as optional steps without making them verifier gates | Must |
| AC-010 | WHEN interchange scripts run THE SYSTEM SHALL NOT mutate `docs/Master-Plan.md` checkboxes or protected workflow files | Must |
| AC-011 | WHEN `lib/config.sh` installs workflow files THE SYSTEM SHALL register contract doc, schemas, scripts, and fixture paths | Must |
| AC-012 | WHEN shipping DEV-124 THE SYSTEM SHALL record CFI bats RED/GREEN evidence and pilot interchange manifest for DEV-120 fixture story | Must |

### 1.3 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Docs claim perfect round-trip or framework replacement |
| FM-002 | AC-003 | Export drops source IDs |
| FM-003 | AC-006 | Default assess exits non-zero on low-severity loss |
| FM-004 | AC-005 | Loss report omits high-severity authority gaps |
| FM-005 | AC-004 | Import overwrites Master-Plan |
| FM-006 | AC-008 | Broken proof graph marks export valid |
| FM-007 | AC-010 | Import ticks Master-Plan checkboxes |
| FM-008 | AC-009 | Interchange wired into Gate 7/8 without ADR |

### 1.4 Out of Scope

- Perfect round-trip fidelity claims
- Replacing Spec Kit, OpenSpec, BMAD, or Kiro tooling
- Required network access or live framework installs (`uvx`, `npx`, remote APIs)
- Protected-workflow writes
- DEV-123 execution capsules
- Hosted interchange registries
- Verifier Gate 8 integration
- Auto-editing `docs/Master-Plan.md`

### 1.5 Claim Boundary

| Control | Classification |
|---------|----------------|
| Interchange contract + schemas | generator-enforced file inventory |
| `agtoosa-interchange-export.sh` | local machine check — derived export |
| `agtoosa-interchange-import.sh` | local machine check — derived manifest |
| `agtoosa-interchange-assess.sh` | local machine check — suggest by default |
| `--strict` non-zero exit | opt-in maintainer gate |
| Loss entries | fixture-labeled — not live framework telemetry |
| Master-Plan authority | repo-local SoT — interchange is derived |
| Proof graph integrity | DEV-120 separate verify |

## 2. Design

### 2.1 Architecture Blueprint

```
Files to create:
  docs/AgToosa_Cross_Framework_Interchange.md
  template/Docs/AgToosa_Cross_Framework_Interchange.md
  contracts/interchange-manifest-v1.schema.json
  contracts/interchange-loss-report-v1.schema.json
  lib/interchange.sh
  lib/interchange-providers/{speckit,openspec,bmad,kiro}.sh
  docs/agtoosa-interchange-export.sh
  docs/agtoosa-interchange-import.sh
  docs/agtoosa-interchange-assess.sh
  template/Docs/agtoosa-interchange-*.sh
  tests/fixtures/interchange/**
  docs/adr/ADR-024-cross-framework-interchange.md

Files to change:
  docs/AgToosa_Import.md, template mirror
  docs/AgToosa_Spec.md, template mirror
  lib/config.sh
  tests/agtoosa.bats — CFI-001–CFI-012
```

### 2.2 Data Flow

1. Export: `agtoosa-interchange-export.sh --story DEV-124 --target speckit --output …` reads `docs/archived/spec-DEV-124.md` → manifest + framework artifact.
2. Import: `agtoosa-interchange-import.sh --fixture tests/fixtures/interchange/openspec/minimal.json --output …` → manifest + loss report.
3. Assess: `agtoosa-interchange-assess.sh --loss-report …` validates severity — suggest by default.
4. Optional proof graph pointer on export; verify via DEV-120 script separately.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Import treated as SoT | Spoofing | AC-001/AC-010 authority boundaries |
| Silent loss hiding | Tampering | AC-005 explicit loss report |
| Path traversal via fixture paths | Tampering | Reject `..` and absolute paths |
| Network exfiltration | Information disclosure | Network-free scripts; bats grep |
| Strict gate blocks all imports | DoS | AC-006 default exit 0; strict opt-in |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : docs/AgToosa_Cross_Framework_Interchange.md, docs/agtoosa-interchange-*.sh,
                      contracts/interchange-*.schema.json, lib/interchange.sh,
                      lib/interchange-providers/*, tests/fixtures/interchange/*,
                      docs/AgToosa_Import.md, docs/AgToosa_Spec.md, lib/config.sh,
                      tests/agtoosa.bats, ADR-024, template mirrors
Out of scope        : Gate 8, DEV-123, hosted registries, live framework installs,
                      perfect round-trip claims, protected-workflow writers
```

## 3. Tasks

### 3.1 Task tree

- [x] **1.** Contract + ADR
  - [x] 1.1 `AgToosa_Cross_Framework_Interchange.md` + template mirror — _Requirements: AC-001, AC-005, AC-006_
  - [x] 1.2 ADR-024 draft → Accepted on ship — _Requirements: AC-001_
- [x] **2.** Schemas + fixtures
  - [x] 2.1 Two JSON schemas — _Requirements: AC-002, AC-004_
  - [x] 2.2 Per-framework fixtures + loss cases — _Requirements: AC-003, AC-005, AC-007_
- [x] **3.** Library + providers
  - [x] 3.1 `lib/interchange.sh` + four providers — _Requirements: AC-003, AC-004, AC-005_
- [x] **4.** CLIs
  - [x] 4.1 `docs/agtoosa-interchange-export.sh` + template — _Requirements: AC-003, AC-008_
  - [x] 4.2 `docs/agtoosa-interchange-import.sh` + template — _Requirements: AC-004, AC-010_
  - [x] 4.3 `docs/agtoosa-interchange-assess.sh` + template — _Requirements: AC-006, AC-007_
- [x] **5.** Integration
  - [x] 5.1 Import + Spec cross-links — _Requirements: AC-009_
  - [x] 5.2 `lib/config.sh` registration — _Requirements: AC-011_
- [x] **6.** Bats + pilot
  - [x] 6.1 CFI-001–CFI-012 — _Requirements: AC-001–AC-012_
  - [x] 6.2 Pilot `interchange-manifest-DEV-120.json` — _Requirements: AC-012_

### Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2  
**Wave 2 (sequential):** 3.1, 4.1  
**Wave 3 (parallel):** 4.2, 4.3, 5.1  
**Wave 4 (sequential):** 5.2, 6.1, 6.2  

## ✅ Spec Approved

Approved: 2026-07-26 15:40

## 🏁 Shipped v5.3.40

Shipped: 2026-07-26 — CFI-001–CFI-012 green; ADR-024 Accepted.
