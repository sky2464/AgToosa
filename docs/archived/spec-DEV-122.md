# Spec: DEV-122 — Spike: Change-Aware Adaptive Delivery

> **Story ID:** DEV-122  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Spike  
> **Status:** 🏁 Shipped — v5.3.38  
> **Estimate:** L  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Depends on:** DEV-120 (Delivery Proof Fabric)  
> **Extends:** DEV-107 (Orchestration Brain) · DEV-087 (Delivery Evidence Contract)  
> **Spec created:** 2026-07-26  
> **ADR:** `docs/adr/ADR-022-change-aware-adaptive-delivery.md` (Proposed)  
> **Portfolio:** Competitive Proof Portfolio child — follows DEV-120/DEV-121; DEV-123–124 remain separate

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Drift/impact providers, measured error behavior, adaptive rigor selection, provenance-aware task context compilation — per portfolio row |
| Foundation | DEV-120 proof graphs bind artifact integrity; DEV-121 scenario evidence is separate; DEV-107 orchestration already compiles lane context agent-instructed |
| Portfolio role | Drift/adaptive rigor child; must not absorb DEV-123 portable execution or DEV-124 interchange |
| Non-goals | Default strict drift blocking before measured accuracy; mandatory language ecosystem (Nx, etc.); machine claims about semantic quality |
| Narrowest scope | Contract + baseline/report schemas + `git-inventory` drift provider + `agtoosa-drift-assess.sh` + `agtoosa-context-compile.sh` + fixture-measured error table + bats — **no** auto-block in default CI |
| Security surface | Local git + file reads on allowlisted paths; network-free; path traversal blocked |
| Test evidence | DIA bats on golden baselines, drift fixtures, rigor matrix, context compilation output |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Proceed with full `/agtoosa-spec` for DEV-122 now? | User: **"do it"** — proceed with documented assumptions (momentum opt-in) |
| Q2 | Narrowest spike deliverable? | **Inferred + accepted:** git-inventory drift provider + impact report + adaptive rigor **suggestions** (inform/warn/suggest-block) — default **inform** only; blocking remains manual/explicit |
| Q3 | Context compilation binding? | **Inferred + accepted:** optional `proof_graph_path` + `drift_report_path` inputs; output `context-compilation-<story>.json` for agent-instructed `/agtoosa-build` consumption — does not auto-edit Master-Plan |

#### Documented assumptions

- Pilot baseline is a **frozen allowlist** of repo-relative paths + SHA-256 under `tests/fixtures/drift-assess/baseline-v1.json` — not full-repo semantic analysis.
- Measured error behavior uses **fixture-labeled** false-positive/negative cases in the report schema (`measurement` block) — not live accuracy claims.
- Adaptive rigor maps drift `impact_level` → `suggested_rigor` (`light` · `standard` · `elevated`); never upgrades to `block` without explicit `--strict` maintainer flag.
- User opt-in **"do it"** satisfies minimum validation floor per `AgToosa_Spec.md` documented-assumptions exception.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ship a change-aware adaptive delivery spike: drift baseline + impact report format, measured error fixtures, adaptive rigor suggestions, and provenance-aware context compilation — all local and network-free |
| User outcome | Maintainers and agents can assess repo drift against a frozen baseline, see honest impact/rigor guidance, and compile task context that cites proof-graph and drift evidence without silent scope creep |
| Success condition | Contract doc + JSON schemas + `git-inventory` provider + `agtoosa-drift-assess.sh` + `agtoosa-context-compile.sh` + pilot fixtures + cross-links + DIA bats green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-122.md`; bats `DIA-*`; fixtures under `tests/fixtures/drift-assess/` |
| Non-goals | Default strict drift blocking; mandatory language ecosystem; semantic-quality ML claims; DEV-123 capsules; DEV-124 interchange; Gate 8; auto-editing Master-Plan |
| Assumptions | DEV-120 graphs optional input; DEV-121 scenario evidence out of scope; git available for inventory provider |
| Risks | Over-blocking workflows; false precision on impact scores; context compilation mistaken for PM authority |
| Unresolved questions | None |

### 1.1 User Stories

**As a** maintainer running `/agtoosa-build`, **I want** drift impact and suggested rigor before implementation **so that** I can adapt testing depth without mandatory blocking.

**As a** release engineer, **I want** provenance-aware context compilation **so that** build agents see proof-graph and drift pointers in one artifact.

**As a** portfolio owner, **I want** measured error fixtures **so that** rigor suggestions are calibrated against known false-positive/negative cases — not claimed live accuracy.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN Change-Aware Adaptive Delivery v1 is documented THE SYSTEM SHALL define drift baseline, drift report, impact levels, adaptive rigor suggestions, measured-error fixture semantics, and claim boundaries separating suggestions from enforcement | Must |
| AC-002 | WHEN a drift baseline is authored THE SYSTEM SHALL conform to `contracts/drift-baseline-v1.schema.json` with allowlisted repo-relative paths and recorded content hashes | Must |
| AC-003 | WHEN `agtoosa-drift-assess.sh` runs against a baseline and repo root THE SYSTEM SHALL emit a drift report conforming to `contracts/drift-report-v1.schema.json` listing added, removed, modified, and unchanged allowlisted paths with impact_level per change set | Must |
| AC-004 | WHEN drift is detected THE SYSTEM SHALL include `suggested_rigor` (`light` · `standard` · `elevated`) derived from a documented matrix and SHALL default to `light` when impact is `none` or `low` | Must |
| AC-005 | WHEN `agtoosa-drift-assess.sh` runs without `--strict` THE SYSTEM SHALL NOT exit non-zero solely due to drift detection — suggestions only | Must |
| AC-006 | WHEN `--strict` is passed THE SYSTEM SHALL exit non-zero when impact_level is `high` for any allowlisted path — opt-in maintainer gate only | Must |
| AC-007 | WHEN measured-error fixtures are evaluated THE SYSTEM SHALL record `measurement.false_positive_rate` and `measurement.false_negative_rate` from labeled fixture cases only and SHALL NOT claim live production accuracy | Must |
| AC-008 | WHEN `agtoosa-context-compile.sh` runs with `--story`, optional `--proof-graph`, and optional `--drift-report` THE SYSTEM SHALL emit `context-compilation-v1` JSON listing task-relevant paths, provenance pointers, and drift summary for agent-instructed consumption | Must |
| AC-009 | WHEN context compilation references a proof graph THE SYSTEM SHALL document that graph validity requires separate `agtoosa-proof-verify.sh` invocation | Must |
| AC-010 | WHEN `AgToosa_Build.md` and `AgToosa_Orchestration.md` are updated THE SYSTEM SHALL cross-link drift assess and context compile as optional pre-build steps without making them verifier gates | Must |
| AC-011 | WHEN `lib/config.sh` installs workflow files THE SYSTEM SHALL register contract doc, schemas, scripts, and fixture paths in maintainer and template inventories | Must |
| AC-012 | WHEN shipping DEV-122 THE SYSTEM SHALL record DIA bats RED/GREEN evidence and a pilot context-compilation JSON for DEV-121 or DEV-120 fixture story | Must |

### 1.3 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Docs claim automatic drift blocking in default CI |
| FM-002 | AC-003 | Non-allowlisted paths included in drift report |
| FM-003 | AC-005 | Default assess exits non-zero on any drift |
| FM-004 | AC-007 | Report claims live semantic accuracy without fixture label |
| FM-005 | AC-008 | Context compilation overwrites or mutates Master-Plan |
| FM-006 | AC-009 | Broken proof graph still marks compilation valid |
| FM-007 | AC-006 | `--strict` becomes default in bats or workflow copy |
| FM-008 | AC-010 | Drift assess wired into Gate 7/8 without ADR |

### 1.4 Out of Scope

- Default strict drift blocking before measured accuracy exists
- Mandatory Nx/language-ecosystem providers
- Semantic quality or NL understanding claims
- DEV-123 portable execution capsules, DEV-124 interchange
- Hosted drift services or network probes
- Auto-editing `docs/Master-Plan.md` or task trees
- Verifier Gate 8 integration
- Replacing DEV-043 brownfield baseline (complementary; drift assess is allowlist inventory)

### 1.5 Claim Boundary

| Control | Classification |
|---------|----------------|
| Drift contract + schemas | generator-enforced file inventory |
| `agtoosa-drift-assess.sh` | local machine check — suggest by default |
| `--strict` non-zero exit | opt-in maintainer gate |
| `agtoosa-context-compile.sh` | agent-instructed — output JSON only |
| Measured error rates | fixture-labeled only — not production metrics |
| Proof graph integrity | DEV-120 separate verify |
| Master-Plan authority | repo-local SoT — compilation is derived |

## 2. Design

### 2.1 Architecture Blueprint

```
Files to create:
  docs/AgToosa_Change_Aware_Delivery.md           — v1 contract (maintainer)
  template/Docs/AgToosa_Change_Aware_Delivery.md
  contracts/drift-baseline-v1.schema.json
  contracts/drift-report-v1.schema.json
  contracts/context-compilation-v1.schema.json
  lib/drift-providers/git-inventory.sh            — baseline compare provider
  lib/drift.sh                                    — shared helpers
  docs/agtoosa-drift-assess.sh
  docs/agtoosa-context-compile.sh
  template/Docs/agtoosa-drift-assess.sh
  template/Docs/agtoosa-context-compile.sh
  tests/fixtures/drift-assess/baseline-v1.json
  tests/fixtures/drift-assess/*                   — modified/added/removed cases
  docs/adr/ADR-022-change-aware-adaptive-delivery.md

Files to change:
  docs/AgToosa_Build.md, template/Docs/AgToosa_Build.md — optional pre-build cross-link
  docs/AgToosa_Orchestration.md, template mirror — context compile pointer
  docs/AgToosa_Evidence_Provenance.md — drift node reference (optional edge type note)
  lib/config.sh
  tests/agtoosa.bats — DIA-001–DIA-012

Key interfaces:
  drift_assess(baseline, root, [--strict]) → drift-report JSON + exit code
  context_compile(story, [--proof-graph] [--drift-report]) → context-compilation JSON
```

### 2.2 Data Flow

1. Maintainer freezes allowlist baseline (`drift-baseline-v1.json`) with path → sha256 for AgToosa-owned surfaces.
2. Before `/agtoosa-build`, agent or maintainer runs `agtoosa-drift-assess.sh --baseline … --root .` → `drift-report.json`.
3. Report lists changes, assigns `impact_level`, `suggested_rigor`, and fixture-derived `measurement` block.
4. Optional: `agtoosa-context-compile.sh --story DEV-122 --drift-report drift-report.json --proof-graph docs/archived/proof-graph-DEV-120.json` → `context-compilation-DEV-122.json`.
5. Build agent reads compilation JSON as context — does not auto-mutate Master-Plan.
6. Strict mode (`--strict`) for maintainer CI opt-in only.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Drift gate blocks all builds by default | Spoofing / DoS | AC-005 default exit 0; strict opt-in |
| Baseline tampered to hide changes | Tampering | Baseline versioned; bats on fixture tamper |
| False accuracy claims | Spoofing | AC-007 fixture-only measurement language |
| Context compilation replaces PM SoT | Elevation | Contract + AC-008 derived-only |
| Path traversal via baseline paths | Tampering | Reject `..` and absolute paths |
| Leak secrets in compilation JSON | Information disclosure | Allowlist only; redaction rules in contract |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : docs/AgToosa_Change_Aware_Delivery.md, docs/agtoosa-drift-assess.sh,
                      docs/agtoosa-context-compile.sh, contracts/drift-*.schema.json,
                      contracts/context-compilation-v1.schema.json, lib/drift.sh,
                      lib/drift-providers/git-inventory.sh, tests/fixtures/drift-assess/*,
                      docs/AgToosa_Build.md, docs/AgToosa_Orchestration.md,
                      lib/config.sh, tests/agtoosa.bats, ADR-022, template mirrors
Directories in scope: lib/drift-providers/, tests/fixtures/drift-assess/, contracts/
Out of scope        : Gate 8, DEV-123/124, hosted drift, semantic ML, Master-Plan writers,
                      mandatory language providers, default strict blocking
```

## 3. Tasks

### 3.1 Task tree

- [x] **1.** Contract + ADR
  - [x] 1.1 `AgToosa_Change_Aware_Delivery.md` + template mirror — _Requirements: AC-001, AC-004, AC-007_
  - [x] 1.2 ADR-022 draft → Accepted on ship — _Requirements: AC-001_
- [x] **2.** Schemas + baseline fixture
  - [x] 2.1 Three JSON schemas — _Requirements: AC-002, AC-003, AC-008_
  - [x] 2.2 `tests/fixtures/drift-assess/baseline-v1.json` + change fixtures — _Requirements: AC-003, AC-007_
- [x] **3.** Provider + library
  - [x] 3.1 `lib/drift.sh` + `lib/drift-providers/git-inventory.sh` — _Requirements: AC-003, AC-005, AC-006_
- [x] **4.** CLIs
  - [x] 4.1 `docs/agtoosa-drift-assess.sh` + template mirror — _Requirements: AC-003–AC-007_
  - [x] 4.2 `docs/agtoosa-context-compile.sh` + template mirror — _Requirements: AC-008, AC-009_
- [x] **5.** Integration + cross-links
  - [x] 5.1 Build + Orchestration + Provenance cross-links — _Requirements: AC-010, AC-009_
  - [x] 5.2 `lib/config.sh` registration — _Requirements: AC-011_
- [x] **6.** Bats + pilot compilation
  - [x] 6.1 DIA-001–DIA-012 in `tests/agtoosa.bats` — _Requirements: AC-001–AC-012_
  - [x] 6.2 Pilot `context-compilation-DEV-120.json` fixture — _Requirements: AC-012_

### Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2  
**Wave 2 (sequential):** 3.1, 4.1  
**Wave 3 (parallel):** 4.2, 5.1  
**Wave 4 (sequential):** 5.2, 6.1, 6.2  

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | verification |
|------------|------|------------|-------------|--------------|
| PKG-1.1 | 1 | — | `docs/AgToosa_Change_Aware_Delivery.md`, template | DIA-001 |
| PKG-2.1 | 1 | — | `contracts/drift-*.schema.json`, `contracts/context-compilation-v1.schema.json` | DIA-002 |
| PKG-2.2 | 1 | PKG-2.1 | `tests/fixtures/drift-assess/**` | DIA-003, DIA-007 |
| PKG-3.1 | 2 | PKG-2.1 | `lib/drift.sh`, `lib/drift-providers/git-inventory.sh` | DIA-004 |
| PKG-4.1 | 2 | PKG-3.1, PKG-2.2 | `docs/agtoosa-drift-assess.sh`, template | DIA-005, DIA-006 |
| PKG-4.2 | 3 | PKG-4.1 | `docs/agtoosa-context-compile.sh`, template | DIA-008, DIA-009 |
| PKG-5.1 | 3 | PKG-1.1 | Build + Orchestration + Provenance docs | DIA-010 |
| PKG-5.2 | 4 | PKG-5.1 | `lib/config.sh` | DIA-011 |
| PKG-6.1 | 4 | PKG-4.2, PKG-5.2 | `tests/agtoosa.bats` | `bats -f DIA` |
| PKG-6.2 | 4 | PKG-4.2 | pilot context-compilation JSON | DIA-012 |

### Story Skill Synthesis

| Skill name | Trigger | Purpose | Decision |
|------------|---------|---------|----------|
| _(none proposed)_ | — | Drift assess covered by workflow docs | **Do not generate** |

## ✅ Spec Approved

Approved: 2026-07-26 15:15
