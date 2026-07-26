# Spec: DEV-123 — Spike: Guarded Portable Execution

> **Story ID:** DEV-123  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Spike  
> **Status:** 🏁 Shipped — v5.3.39  
> **Estimate:** M  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Depends on:** DEV-120 (Delivery Proof Fabric) · DEV-122 (Change-Aware Adaptive Delivery)  
> **Extends:** DEV-107 (Orchestration Brain) · DEV-047 (Async Agent Handoff Packs)  
> **Spec created:** 2026-07-26  
> **ADR:** `docs/adr/ADR-023-guarded-portable-execution.md` (Accepted)  
> **Portfolio:** Competitive Proof Portfolio child — follows DEV-120/DEV-122; DEV-124 interchange remains separate

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Portable execution capsules with approved scope, policy, ownership, budgets, verification, and safe evidence return via manual handoff exporter — per portfolio row |
| Foundation | DEV-120 proof graphs bind artifact integrity; DEV-122 drift/context compilation supplies task provenance; DEV-047 handoff packs define export/return contract; DEV-107 orchestration compiles lane context agent-instructed |
| Portfolio role | Execution-capsule child; must not absorb DEV-124 interchange or bounded autonomous runner |
| Non-goals | Secret values; default network; protected-workflow writes; native sandbox claims; agent launch/supervision; bounded autonomous runner |
| Narrowest scope | Contract + capsule/evidence schemas + `local-guarded` provider + `agtoosa-capsule-pack.sh` + `agtoosa-capsule-verify.sh` + `agtoosa-capsule-export.sh` + fixture-measured policy cases + bats — **no** agent launch, **no** default network |
| Security surface | Local file reads on allowlisted paths; network-free; path traversal blocked; evidence export redacts secret-shaped patterns |
| Test evidence | GPE bats on golden capsules, policy violation fixtures, handoff export shape, verify strict/suggest behavior |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Proceed with full `/agtoosa-spec` for DEV-123 now? | User: **"do it"** — proceed with documented assumptions (momentum opt-in) |
| Q2 | Narrowest spike deliverable? | **Inferred + accepted:** capsule pack/verify/export CLIs + `local-guarded` provider — policy **suggest** by default; `--strict` opt-in for high-severity violations only |
| Q3 | Handoff binding? | **Inferred + accepted:** `agtoosa-capsule-export.sh` emits handoff-compatible markdown under `docs/archived/handoff-*` with capsule manifest pointer and return contract — does not launch agents or auto-edit Master-Plan |

#### Documented assumptions

- Pilot capsule is a **frozen fixture** under `tests/fixtures/capsule/capsule-v1.json` — not a live agent execution environment.
- Policy enforcement uses **fixture-labeled** violation cases in the capsule schema (`policy_checks` block) — not live sandbox telemetry.
- Budget fields (`max_files`, `max_bytes`, `timeout_hint_seconds`) are **declarative hints** for handoff readers — not enforced runtime limits in v1.
- User opt-in **"do it"** satisfies minimum validation floor per `AgToosa_Spec.md` documented-assumptions exception.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ship a guarded portable execution spike: execution capsule + evidence-return formats, policy/ownership/budget metadata, pack/verify/export CLIs, and handoff-compatible manual export — all local and network-free |
| User outcome | Maintainers and agents can pack bounded execution capsules with scope and policy guardrails, verify integrity before handoff, and export safe evidence-return briefs for manual async agents without secret leakage or protected-workflow writes |
| Success condition | Contract doc + JSON schemas + `local-guarded` provider + `agtoosa-capsule-pack.sh` + `agtoosa-capsule-verify.sh` + `agtoosa-capsule-export.sh` + pilot fixtures + cross-links + GPE bats green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-123.md`; bats `GPE-*`; fixtures under `tests/fixtures/capsule/` |
| Non-goals | Secret values in capsules; default network access; protected-workflow writes; native sandbox claims; agent launch/supervision; bounded autonomous runner; DEV-124 interchange; Gate 8; auto-editing Master-Plan |
| Assumptions | DEV-120 proof graphs optional input; DEV-122 drift/context optional input; DEV-047 handoff export shape reused; git available for snapshot provider |
| Risks | Capsules mistaken for enforced sandboxes; policy hints treated as runtime limits; export leaks sensitive patterns; handoff export overwrites Master-Plan |
| Unresolved questions | None |

### 1.1 User Stories

**As a** maintainer running `/agtoosa-handoff`, **I want** a portable execution capsule with scope and policy metadata **so that** async agents receive bounded, verifiable briefs.

**As a** release engineer, **I want** capsule verify and safe evidence export **so that** returned artifacts can be checked against proof-graph bindings before import.

**As a** portfolio owner, **I want** fixture-labeled policy cases **so that** guardrail semantics are honest — not claimed as native sandbox enforcement.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN Guarded Portable Execution v1 is documented THE SYSTEM SHALL define execution capsule scope, policy rules, ownership, budgets, verification bindings, evidence-return semantics, and claim boundaries separating capsule metadata from runtime enforcement | Must |
| AC-002 | WHEN an execution capsule is authored THE SYSTEM SHALL conform to `contracts/execution-capsule-v1.schema.json` with allowlisted repo-relative paths, policy block, ownership, and budget hints | Must |
| AC-003 | WHEN `agtoosa-capsule-pack.sh` runs with `--story`, optional `--proof-graph`, and optional `--drift-report` THE SYSTEM SHALL emit an execution capsule JSON listing scoped paths, policy defaults (no secrets, no default network, no protected-workflow writes), and provenance pointers | Must |
| AC-004 | WHEN a capsule policy block is evaluated THE SYSTEM SHALL record `policy_checks` results from fixture-labeled cases only and SHALL NOT claim native sandbox or network isolation | Must |
| AC-005 | WHEN `agtoosa-capsule-verify.sh` runs without `--strict` THE SYSTEM SHALL exit zero on policy warnings — suggest-only; non-zero only on schema/tamper failures | Must |
| AC-006 | WHEN `--strict` is passed THE SYSTEM SHALL exit non-zero when any high-severity policy violation is detected in the capsule manifest — opt-in maintainer gate only | Must |
| AC-007 | WHEN `agtoosa-capsule-export.sh` runs with a verified capsule THE SYSTEM SHALL emit handoff-compatible markdown under `docs/archived/handoff-<story>-capsule.md` including return contract, verification commands, and redacted evidence pointers conforming to `contracts/capsule-evidence-v1.schema.json` | Must |
| AC-008 | WHEN evidence export references a proof graph THE SYSTEM SHALL document that graph validity requires separate `agtoosa-proof-verify.sh` invocation and SHALL redact secret-shaped patterns from exported content | Must |
| AC-009 | WHEN `AgToosa_Handoff.md` and `AgToosa_Orchestration.md` are updated THE SYSTEM SHALL cross-link capsule pack/verify/export as optional pre-handoff steps without making them verifier gates | Must |
| AC-010 | WHEN capsule export runs THE SYSTEM SHALL NOT mutate `docs/Master-Plan.md` checkboxes or protected workflow files — export is derived evidence only | Must |
| AC-011 | WHEN `lib/config.sh` installs workflow files THE SYSTEM SHALL register contract doc, schemas, scripts, and fixture paths in maintainer and template inventories | Must |
| AC-012 | WHEN shipping DEV-123 THE SYSTEM SHALL record GPE bats RED/GREEN evidence and a pilot execution capsule for DEV-120 or DEV-122 fixture story | Must |

### 1.3 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Docs claim native sandbox or default network isolation |
| FM-002 | AC-003 | Non-allowlisted paths included in capsule scope |
| FM-003 | AC-005 | Default verify exits non-zero on policy warnings |
| FM-004 | AC-004 | Policy block claims live sandbox telemetry |
| FM-005 | AC-007 | Export missing return contract → import cannot map evidence |
| FM-006 | AC-008 | Broken proof graph still marks export valid |
| FM-007 | AC-010 | Export ticks Master-Plan checkboxes → SoT corruption |
| FM-008 | AC-009 | Capsule verify wired into Gate 7/8 without ADR |

### 1.4 Out of Scope

- Secret values or credential injection in capsules
- Default network access or remote execution hosts
- Protected-workflow writes (Master-Plan, verifier config, release gates)
- Native OS sandbox, container, or VM isolation claims
- Agent launch, polling, or supervision
- Bounded autonomous runner or scheduled execution
- DEV-124 cross-framework interchange
- Hosted capsule registries or network probes
- Auto-editing `docs/Master-Plan.md` or task trees
- Verifier Gate 8 integration

### 1.5 Claim Boundary

| Control | Classification |
|---------|----------------|
| Capsule contract + schemas | generator-enforced file inventory |
| `agtoosa-capsule-pack.sh` | local machine check — metadata assembly |
| `agtoosa-capsule-verify.sh` | local machine check — suggest by default |
| `--strict` non-zero exit | opt-in maintainer gate |
| `agtoosa-capsule-export.sh` | agent-instructed — handoff markdown only |
| Policy checks | fixture-labeled only — not runtime enforcement |
| Budget hints | declarative — not enforced limits in v1 |
| Proof graph integrity | DEV-120 separate verify |
| Master-Plan authority | repo-local SoT — capsule/export is derived |
| Agent execution | manual — extends DEV-047 handoff |

## 2. Design

### 2.1 Architecture Blueprint

```
Files to create:
  docs/AgToosa_Guarded_Portable_Execution.md           — v1 contract (maintainer)
  template/Docs/AgToosa_Guarded_Portable_Execution.md
  contracts/execution-capsule-v1.schema.json
  contracts/capsule-evidence-v1.schema.json
  lib/capsule-providers/local-guarded.sh               — scope + policy provider
  lib/capsule.sh                                       — shared helpers
  docs/agtoosa-capsule-pack.sh
  docs/agtoosa-capsule-verify.sh
  docs/agtoosa-capsule-export.sh
  template/Docs/agtoosa-capsule-pack.sh
  template/Docs/agtoosa-capsule-verify.sh
  template/Docs/agtoosa-capsule-export.sh
  tests/fixtures/capsule/capsule-v1.json
  tests/fixtures/capsule/*                             — policy violation cases
  docs/adr/ADR-023-guarded-portable-execution.md

Files to change:
  docs/AgToosa_Handoff.md, template mirror — optional pre-handoff cross-link
  docs/AgToosa_Orchestration.md, template mirror — capsule pack pointer
  docs/AgToosa_Evidence_Provenance.md — capsule node reference (optional edge type note)
  lib/config.sh
  tests/agtoosa.bats — GPE-001–GPE-012

Key interfaces:
  capsule_pack(story, [--proof-graph] [--drift-report]) → execution-capsule JSON
  capsule_verify(capsule, [--strict]) → exit code + policy summary
  capsule_export(capsule, [--output]) → handoff-compatible markdown
```

### 2.2 Data Flow

1. Maintainer or agent runs `agtoosa-capsule-pack.sh --story DEV-123 --proof-graph … --drift-report …` → `execution-capsule-DEV-123.json`.
2. Capsule lists scoped paths, policy defaults, ownership, budget hints, and provenance pointers.
3. `agtoosa-capsule-verify.sh --capsule …` validates schema, path allowlist, and fixture-derived `policy_checks` — suggest by default.
4. Optional: `agtoosa-capsule-export.sh --capsule …` → `docs/archived/handoff-DEV-123-capsule.md` for manual async agent handoff (DEV-047 return contract).
5. Agent executes manually; evidence return validated separately via DEV-120 proof verify + DEV-048 import.
6. Strict mode (`--strict`) for maintainer CI opt-in only.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Capsule treated as enforced sandbox | Spoofing | AC-001/AC-004 claim boundaries; no native sandbox language |
| Secret leakage in export | Information disclosure | AC-008 redaction rules; no secrets in schema |
| Default network in capsule | Tampering | AC-003 policy default `network: deny`; bats on violation fixtures |
| Export mutates Master-Plan | Elevation | AC-010 derived-only; bats guard protected paths |
| Path traversal via scope paths | Tampering | Reject `..` and absolute paths |
| Policy gate blocks all handoffs | DoS | AC-005 default exit 0; strict opt-in |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : docs/AgToosa_Guarded_Portable_Execution.md, docs/agtoosa-capsule-*.sh,
                      contracts/execution-capsule-v1.schema.json,
                      contracts/capsule-evidence-v1.schema.json, lib/capsule.sh,
                      lib/capsule-providers/local-guarded.sh, tests/fixtures/capsule/*,
                      docs/AgToosa_Handoff.md, docs/AgToosa_Orchestration.md,
                      lib/config.sh, tests/agtoosa.bats, ADR-023, template mirrors
Directories in scope: lib/capsule-providers/, tests/fixtures/capsule/, contracts/
Out of scope        : Gate 8, DEV-124, hosted execution, native sandbox, agent launch,
                      secret injection, default network, protected-workflow writers,
                      bounded autonomous runner
```

## 3. Tasks

### 3.1 Task tree

- [x] **1.** Contract + ADR
  - [x] 1.1 `AgToosa_Guarded_Portable_Execution.md` + template mirror — _Requirements: AC-001, AC-004, AC-005_
  - [x] 1.2 ADR-023 draft → Accepted on ship — _Requirements: AC-001_
- [x] **2.** Schemas + baseline fixture
  - [x] 2.1 Two JSON schemas — _Requirements: AC-002, AC-007_
  - [x] 2.2 `tests/fixtures/capsule/capsule-v1.json` + policy violation fixtures — _Requirements: AC-003, AC-004, AC-006_
- [x] **3.** Provider + library
  - [x] 3.1 `lib/capsule.sh` + `lib/capsule-exporters/manual-handoff.sh` — _Requirements: AC-003, AC-005, AC-006_
- [x] **4.** CLIs
  - [x] 4.1 `docs/agtoosa-capsule-pack.sh` + template mirror — _Requirements: AC-003, AC-004_
  - [x] 4.2 `docs/agtoosa-capsule-verify.sh` + template mirror — _Requirements: AC-005, AC-006_
  - [x] 4.3 `docs/agtoosa-capsule-return.sh` + template mirror — _Requirements: AC-007, AC-008, AC-010_
- [x] **5.** Integration + cross-links
  - [x] 5.1 Handoff + Orchestration + Provenance cross-links — _Requirements: AC-009, AC-008_
  - [x] 5.2 `lib/config.sh` registration — _Requirements: AC-011_
- [x] **6.** Bats + pilot capsule
  - [x] 6.1 GPE-001–GPE-012 in `tests/agtoosa.bats` — _Requirements: AC-001–AC-012_
  - [x] 6.2 Pilot `execution-capsule-DEV-120.json` fixture — _Requirements: AC-012_

### Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2  
**Wave 2 (sequential):** 3.1, 4.1  
**Wave 3 (parallel):** 4.2, 4.3, 5.1  
**Wave 4 (sequential):** 5.2, 6.1, 6.2  

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | verification |
|------------|------|------------|-------------|--------------|
| PKG-1.1 | 1 | — | `docs/AgToosa_Guarded_Portable_Execution.md`, template | GPE-001 |
| PKG-2.1 | 1 | — | `contracts/execution-capsule-v1.schema.json`, `contracts/capsule-evidence-v1.schema.json` | GPE-002 |
| PKG-2.2 | 1 | PKG-2.1 | `tests/fixtures/capsule/**` | GPE-003, GPE-004 |
| PKG-3.1 | 2 | PKG-2.1 | `lib/capsule.sh`, `lib/capsule-providers/local-guarded.sh` | GPE-005 |
| PKG-4.1 | 2 | PKG-3.1, PKG-2.2 | `docs/agtoosa-capsule-pack.sh`, template | GPE-003, GPE-004 |
| PKG-4.2 | 3 | PKG-4.1 | `docs/agtoosa-capsule-verify.sh`, template | GPE-005, GPE-006 |
| PKG-4.3 | 3 | PKG-4.1 | `docs/agtoosa-capsule-export.sh`, template | GPE-007, GPE-008 |
| PKG-5.1 | 3 | PKG-1.1 | Handoff + Orchestration + Provenance docs | GPE-009, GPE-010 |
| PKG-5.2 | 4 | PKG-5.1 | `lib/config.sh` | GPE-011 |
| PKG-6.1 | 4 | PKG-4.3, PKG-5.2 | `tests/agtoosa.bats` | `bats -f GPE` |
| PKG-6.2 | 4 | PKG-4.1 | pilot execution-capsule JSON | GPE-012 |

### Story Skill Synthesis

| Skill name | Trigger | Purpose | Decision |
|------------|---------|---------|----------|
| _(none proposed)_ | — | Capsule pack/export covered by Handoff + Orchestration docs | **Do not generate** |

## ✅ Spec Approved

Approved: 2026-07-26 15:30

## 🏁 Shipped v5.3.39

Shipped: 2026-07-26 — GPE-001–GPE-012 green; ADR-023 Accepted.
