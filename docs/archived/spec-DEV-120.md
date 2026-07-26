# Spec: DEV-120 — Spike: Delivery Proof Fabric

> **Story ID:** DEV-120  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Spike  
> **Status:** 🏁 Shipped — v5.3.37  
> **Estimate:** L  
> **Clarity:** `ready`  
> **Priority:** P0  
> **Depends on:** DEV-087 (Delivery Evidence Contract) · DEV-089 (Gate 7) · DEV-049 (Evidence Ledger)  
> **Spec created:** 2026-07-26  
> **ADR:** `docs/adr/ADR-020-delivery-proof-fabric.md`  
> **Portfolio:** Competitive Proof Portfolio parent — DEV-121–124 depend on this spike

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Validate Evidence Provenance v2, derived delivery proof graph, fingerprinted links, generic proof-provider interface with executable pilot |
| Foundation | DEV-087 profiles declare artifact classes; Gate 7 checks presence; Evidence Ledger indexes pointers — none bind content to repo execution context |
| Portfolio role | Parent spike for DEV-121–124; must not absorb behavioral lab, drift, portable execution, or interchange scope |
| Non-goals | Replace `Master-Plan.md`, evidence ledgers, or profiles; NL formal proof; mandate Dafny/Nx/external providers; Gate 8 in this spike |
| Source of truth | `Master-Plan.md` remains repo-local SoT; proof graph is derived evidence |
| Security surface | Local file reads + SHA-256 only; no network; no secrets in graph JSON |
| Test evidence | DPF bats on fixtures with tamper cases; pilot graph built from DEV-119 ship artifacts |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Narrowest scope for DEV-120 spike? | **B** — contract + one in-repo pilot (hash-linked chain, `local-hash` provider, bats) |
| Q2 | Proof graph shape for v1? | **B** — typed node DAG (`story` · `ac` · `artifact` · `command-run` · `content-hash` · `repo-snapshot`; edges `references` · `verified-by` · `content-of`) |
| Q3 | Proof verification enforcement wiring? | **A** — standalone `agtoosa-proof-verify.sh`; Gate 8 deferred |

#### Documented assumptions

- Pilot reference story is **DEV-119** (recent ship with full ledger + test-plan evidence) — acceptable fixture without re-running ship.
- Graph assembly hooks into `/agtoosa-evidence` as agent-instructed documentation only; no generator auto-writer in spike.
- JSON schema version starts at `1`; breaking changes require ADR amendment.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ship Evidence Provenance v2 — a typed delivery proof graph, stable fingerprinted links, a generic proof-provider interface, and a `local-hash` pilot with standalone verification |
| User outcome | Teams can derive a per-story proof graph from evidence artifacts, verify link integrity locally, and extend with future providers without replacing existing ledgers or profiles |
| Success condition | Contract doc + JSON schema + provider interface + `agtoosa-proof-verify.sh` + maintainer/template parity + DPF bats green on valid and tampered fixtures |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-120.md`; bats `DPF-*`; pilot `proof-graph-DEV-119.json`; ADR-020 Accepted |
| Non-goals | Verifier Gate 8; hosted attestation; Dafny/Nx/mandatory external providers; NL formal proof claims; replacing Master-Plan/ledger/profiles; DEV-121 behavioral scenarios; semantic review enforcement |
| Assumptions | SHA-256 is sufficient for local content binding in v1; agents assemble graphs at review/ship; Gate 7 semantics unchanged |
| Risks | Graph drift vs live repo; agents omit graph assembly; over-claiming cryptographic proof; scope creep into DEV-121 |
| Unresolved questions | None |

### 1.1 User Stories

**As a** release engineer, **I want** evidence ledger pointers bound to content fingerprints and repo snapshot **so that** tampered artifacts are detectable before ship.

**As an** AgToosa maintainer, **I want** a pluggable proof-provider interface with one working pilot **so that** DEV-121–124 can add providers without redesigning the graph.

**As a** verifier operator, **I want** a standalone local script to validate proof graphs **so that** I can check integrity without expanding the Gate 7 chain in this spike.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN Evidence Provenance v2 is documented THE SYSTEM SHALL define node types `story`, `ac`, `artifact`, `command-run`, `content-hash`, `repo-snapshot` and edge types `references`, `verified-by`, `content-of` with claim boundaries distinguishing derived evidence from Master-Plan authority | Must |
| AC-002 | WHEN a proof graph is authored THE SYSTEM SHALL conform to a versioned JSON schema at `contracts/proof-graph-v1.schema.json` with one file per story at `docs/archived/proof-graph-<story-id>.json` (template: `Docs/archived/…`) | Must |
| AC-003 | WHEN the proof-provider interface is documented THE SYSTEM SHALL define provider identity, supported node/edge kinds, verification inputs/outputs, and exit codes without mandating external tools | Must |
| AC-004 | WHEN the `local-hash` provider runs THE SYSTEM SHALL verify `content-of` edges by SHA-256 of referenced artifact paths and `verified-by` edges for `command-run` nodes against recorded verification strings | Must |
| AC-005 | WHEN `agtoosa-proof-verify.sh` runs on a valid pilot graph THE SYSTEM SHALL exit `0` and report provider id, node count, edge count, and snapshot sha | Must |
| AC-006 | WHEN `agtoosa-proof-verify.sh` runs on a graph with missing files, hash mismatch, broken edges, or unknown node types THE SYSTEM SHALL exit non-zero with bounded diagnostics naming the first failure | Must |
| AC-007 | WHEN repo snapshot strict mode is requested THE SYSTEM SHALL compare `repo-snapshot` node sha to current `git rev-parse HEAD` and fail when they differ unless `--allow-stale-snapshot` is passed | Must |
| AC-008 | WHEN cross-linking docs THE SYSTEM SHALL reference Provenance v2 from `AgToosa_Evidence.md` and `AgToosa_Delivery_Evidence_Contract.md` without replacing Terminal Evidence or Gate 7 semantics | Must |
| AC-009 | WHEN Gate 7 or evidence profiles are described THE SYSTEM SHALL state that profile presence checks remain Gate 7 scope and content-link provenance is Provenance v2 / standalone script scope | Must |
| AC-010 | WHEN `lib/config.sh` installs workflow files THE SYSTEM SHALL include contract doc, schema, verify script, and example pilot graph paths in maintainer and template inventories | Must |
| AC-011 | WHEN `/agtoosa-evidence` workflow is updated THE SYSTEM SHALL document optional proof-graph assembly at review/ship as agent-instructed with pointer to verify script | Must |
| AC-012 | WHEN shipping DEV-120 THE SYSTEM SHALL record DPF bats RED/GREEN evidence and a pilot graph for DEV-119 that validates end-to-end | Must |

### 1.3 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Provenance doc claims to replace Master-Plan or evidence ledger authority |
| FM-002 | AC-004 | `local-hash` silently skips missing files |
| FM-003 | AC-006 | Script reports success on broken `content-of` edge |
| FM-004 | AC-007 | Stale snapshot passes without explicit flag — false confidence at ship |
| FM-005 | AC-009 | Gate 7 modified or absorbs content-hash checks — scope bleed |
| FM-006 | AC-011 | Generator auto-writes proof graphs — surprises agent-instructed boundary |
| FM-007 | AC-012 | Pilot graph references paths outside repo or omits DEV-119 ledger linkage |

### 1.4 Out of Scope

- Verifier Gate 8 integration (`agtoosa-verify.sh` changes)
- Hosted attestation, Sigstore, cosign, or minisign binding for proof graphs (registry provenance stays DEV-054)
- Dafny, Nx, or other mandatory proof providers
- Natural-language or formal proof claims
- DEV-121 scenario corpus, DEV-122 drift providers, DEV-123 execution capsules, DEV-124 interchange
- Automatic graph generation during `/agtoosa-build`
- Network calls from verify script
- Replacing or merging `.agtoosa/evidence.yml` profiles

### 1.5 Claim Boundary

| Control | Classification |
|---------|----------------|
| Provenance v2 contract + JSON schema | generator-enforced file inventory |
| `agtoosa-proof-verify.sh` | local machine check (content + edge integrity) |
| Proof graph assembly | agent-instructed (`/agtoosa-evidence`) |
| Gate 7 profile presence | unchanged — CI-enforced when opted in (DEV-089) |
| Master-Plan authority | repo-local SoT — graph is derived |
| Gate 8 verifier hook | roadmap — follow-up story |
| External attestor providers | roadmap — DEV-121+ |

## 2. Design

### 2.1 Architecture Blueprint

```
Files to create:
  docs/AgToosa_Evidence_Provenance.md          — v2 contract (maintainer)
  template/Docs/AgToosa_Evidence_Provenance.md — template mirror
  contracts/proof-graph-v1.schema.json       — JSON Schema for graph files
  docs/agtoosa-proof-verify.sh                 — standalone verifier CLI
  template/Docs/agtoosa-proof-verify.sh        — template mirror
  lib/proof.sh                                 — shared hash + graph parse helpers
  lib/proof-providers/local-hash.sh            — built-in provider implementation
  docs/archived/proof-graph-DEV-119.json       — pilot reference graph
  tests/fixtures/proof-graph/                  — valid + tampered fixtures

Files to change:
  docs/AgToosa_Evidence.md                     — optional graph assembly + verify pointer
  template/Docs/AgToosa_Evidence.md
  docs/AgToosa_Delivery_Evidence_Contract.md   — cross-link provenance v2 boundary
  template/Docs/AgToosa_Delivery_Evidence_Contract.md
  lib/config.sh                                — install inventories
  tests/agtoosa.bats                           — DPF-001–DPF-012
  docs/adr/ADR-020-delivery-proof-fabric.md    — Status → Accepted on ship

Key interfaces:
  proof_graph_validate(schema_path, graph_path) → exit code
  proof_provider_local_hash_verify(graph, root, opts) → exit code
  agtoosa-proof-verify.sh [--root PATH] [--graph PATH] [--provider local-hash] [--allow-stale-snapshot]
```

### 2.2 Data Flow

1. At `/agtoosa-review` or `/agtoosa-ship`, agent (optional) reads `evidence-<story-id>.md` and referenced artifact paths.
2. Agent assembles `proof-graph-<story-id>.json`: nodes for story, each Must AC, ledger artifacts, command-run verification strings, content-hash (SHA-256 per file), repo-snapshot (`git rev-parse HEAD`).
3. Agent writes edges: `artifact` → `content-hash` (`content-of`); `command-run` → `artifact` (`verified-by`); `ac` → `artifact` (`references`); `story` → `ac` (`references`).
4. Operator or CI runs `bash docs/agtoosa-proof-verify.sh --graph docs/archived/proof-graph-<id>.json`.
5. Script loads schema, delegates to `local-hash` provider, walks edges, hashes files, compares recorded digests, optionally checks repo snapshot.
6. Exit `0` → integrity OK; non-zero → first failure printed; graph remains non-authoritative index (Master-Plan unchanged).

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Forged proof graph accepted without file checks | Spoofing | `local-hash` verifies SHA-256 of referenced paths; tamper bats |
| Artifact swapped after graph generation | Tampering | `repo-snapshot` + strict HEAD check; document stale-snapshot flag |
| Operator denies verification was run | Repudiation | Graph records `generated_at`, provider id; evidence ledger row cites verify command + exit |
| Graph JSON embeds secrets or tokens | Information disclosure | Schema forbids secret fields; redaction rule in Evidence workflow |
| Large binary hashing DoS | Denial of service | Document size cap in provider (e.g. skip or warn > N MB); fixture-only in bats |
| Graph replaces Master-Plan ship authority | Elevation of privilege | Contract + AC-001 explicit SoT boundary; Gate 7 unchanged |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : docs/AgToosa_Evidence_Provenance.md, docs/agtoosa-proof-verify.sh,
                      contracts/proof-graph-v1.schema.json, lib/proof.sh,
                      lib/proof-providers/local-hash.sh, docs/archived/proof-graph-DEV-119.json,
                      docs/AgToosa_Evidence.md, docs/AgToosa_Delivery_Evidence_Contract.md,
                      lib/config.sh, tests/agtoosa.bats, tests/fixtures/proof-graph/*,
                      docs/adr/ADR-020-delivery-proof-fabric.md, template mirrors
Directories in scope: lib/proof-providers/, tests/fixtures/proof-graph/, contracts/
Out of scope        : docs/agtoosa-verify.sh Gate 8, Dafny/Nx providers, DEV-121–124 features,
                      automatic graph writers, network attestation, Master-Plan replacement
```

## 3. Tasks

### 3.1 Task tree

- [x] **1.** Contract + ADR
  - [x] 1.1 `AgToosa_Evidence_Provenance.md` + template mirror — _Requirements: AC-001, AC-003, AC-008, AC-009_
  - [x] 1.2 ADR-020 → Accepted — _Requirements: AC-001_
- [x] **2.** Schema + fixtures
  - [x] 2.1 `contracts/proof-graph-v1.schema.json` — _Requirements: AC-002_
  - [x] 2.2 `tests/fixtures/proof-graph/` valid + tampered graphs — _Requirements: AC-006_
- [x] **3.** Provider + library
  - [x] 3.1 `lib/proof.sh` helpers — _Requirements: AC-004_
  - [x] 3.2 `lib/proof-providers/local-hash.sh` — _Requirements: AC-004, AC-007_
- [x] **4.** Verify script
  - [x] 4.1 `docs/agtoosa-proof-verify.sh` + template mirror — _Requirements: AC-005, AC-006, AC-007_
- [x] **5.** Pilot graph
  - [x] 5.1 `docs/archived/proof-graph-DEV-119.json` from ship evidence — _Requirements: AC-012_
- [x] **6.** Docs integration
  - [x] 6.1 `AgToosa_Evidence.md` assembly guidance — _Requirements: AC-011_
  - [x] 6.2 Delivery Evidence Contract cross-link — _Requirements: AC-008, AC-009_
- [x] **7.** Install wiring
  - [x] 7.1 `lib/config.sh` inventories — _Requirements: AC-010_
- [x] **8.** Tests
  - [x] 8.1 Bats DPF-001–DPF-012 — _Requirements: AC-001–AC-012_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 3.1  
**Wave 2 (parallel):** 2.2, 3.2, 4.1  
**Wave 3 (sequential):** 5.1 (after 2–4)  
**Wave 4 (parallel):** 6.1, 6.2, 7.1  
**Wave 5 (sequential):** 8.1 (after all)

### 3.3 Test Plan

See `docs/AgToosa_TestPlan-DEV-120.md`.

### 3.4 Work Package DAG

| package_id | task | wave | depends_on | owned_files | verification |
|------------|------|------|------------|-------------|--------------|
| PKG-1.1 | Contract doc | 1 | — | `docs/AgToosa_Evidence_Provenance.md`, `template/Docs/…` | DPF-001 |
| PKG-2.1 | JSON schema | 1 | — | `contracts/proof-graph-v1.schema.json` | DPF-002 |
| PKG-3.1 | proof.sh | 1 | — | `lib/proof.sh` | DPF-004 |
| PKG-2.2 | Fixtures | 2 | PKG-2.1 | `tests/fixtures/proof-graph/*` | DPF-003 |
| PKG-3.2 | local-hash provider | 2 | PKG-3.1 | `lib/proof-providers/local-hash.sh` | DPF-005 |
| PKG-4.1 | Verify script | 2 | PKG-3.2 | `docs/agtoosa-proof-verify.sh`, template | DPF-006, DPF-007 |
| PKG-5.1 | Pilot graph | 3 | PKG-4.1 | `docs/archived/proof-graph-DEV-119.json` | DPF-012 |
| PKG-6.1 | Evidence workflow | 4 | PKG-1.1 | `docs/AgToosa_Evidence.md`, template | DPF-010 |
| PKG-6.2 | Delivery cross-link | 4 | PKG-1.1 | `docs/AgToosa_Delivery_Evidence_Contract.md` | DPF-009 |
| PKG-7.1 | config.sh | 4 | PKG-1.1, PKG-4.1 | `lib/config.sh` | DPF-011 |
| PKG-8.1 | Bats suite | 5 | PKG-5.1, PKG-7.1 | `tests/agtoosa.bats` | DPF-001–DPF-012 |

## 4. Definition of Done

- [x] All Must ACs mapped to passing DPF tests
- [x] Pilot `proof-graph-DEV-119.json` verifies with exit `0`
- [x] Tampered fixtures fail with non-zero exit
- [x] ADR-020 Accepted
- [x] No Gate 7 / `agtoosa-verify.sh` changes
- [x] Template parity via `lib/config.sh`
- [x] Spec Quality Analyzer gate passed
- [x] `## ✅ Spec Approved` appended (user gate)

---

## ✅ Spec Approved

Approved 2026-07-26 for `/agtoosa-build DEV-120`.