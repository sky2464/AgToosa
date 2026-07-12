# Spec: DEV-053 — Extension and Preset Catalog

> **Story ID:** DEV-053
> **Epic:** DEV-003
> **Status:** 🏁 Shipped (v5.3.8)
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

AgToosa already has a pack registry and guarded `--registry install` flow. The registry owns install metadata such as pack name, version, URL, SHA-256, `verified`, and optional signature provenance. It is not yet a useful opinionated discovery experience for teams asking “which extensions belong together?” or “is this preset compatible with my AgToosa version and platforms?”

DEV-053 adds a **curated catalog** over existing packs:

- An **extension** describes one discoverable registry pack.
- A **preset** describes an ordered, pinned set of extension references plus compatibility and conflict guidance.
- The catalog can list, search, inspect, validate, and generate an install plan.
- Installation still runs through the existing registry path, including verification, preview, consent, allowlist, denylist, checksum, and optional provenance checks.

The catalog is not a registry source of truth. A catalog record is curated discovery metadata and a provenance snapshot; it cannot publish a pack, change registry verification state, or bypass current registry metadata. This document remains a backlog contract until explicit enrollment and implementation.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Add a versioned Extension and Preset Catalog that makes high-quality packs discoverable by use case while preserving registry install authority and explicit trust, compatibility, provenance, and ownership boundaries. |
| User outcome | Users can find an extension or team preset, understand whether it fits their AgToosa version and platforms, and receive a safe registry-backed install plan without bloating the default template. |
| Success condition | Catalog schema and CLI support `list`, `search`, `info`, `validate`, and `plan`; incompatible or stale entries fail safely; three maintained entries pass compatibility, registry-reference, install-fixture, and provenance validation; PC-001–PC-008 pass. |
| Proof / evidence | Schema fixtures, three maintained catalog-entry validation records, focused bats output, registry-gate delegation tests, and RED/GREEN blocks in `docs/AgToosa_TestPlan-DEV-053.md` after implementation. |
| Non-goals | Replacing `registry.json`, publishing packs, silently installing presets, introducing executable pack content, hosting a marketplace, ratings/reviews, payment, or claiming that curation equals cryptographic trust. |
| Assumptions | Existing registry install safety remains authoritative; catalog entries can pin registry name and version; AgToosa versions use comparable semantic versions; platform identifiers come from `lib/config.sh`. |
| Risks | Catalog metadata drifts from registry state, trust labels overpromise safety, presets hide conflicting files, compatibility ranges are interpreted inconsistently, or a catalog becomes an accidental second registry. |
| Unresolved questions | The first three maintained entry IDs are selected during enrollment from then-current registry packs; selection cannot weaken the validation gates in AC-008. |

### 1.2 User Stories

**As a** project maintainer, **I want** to search extensions by use case and platform **so that** I can evaluate a small relevant set instead of browsing raw registry JSON.

**As a** team lead, **I want** a preset to explain pinned components, order, conflicts, and ownership **so that** adoption is repeatable and reviewable.

**As a** security-conscious user, **I want** catalog curation, registry verification, and cryptographic provenance shown separately **so that** I do not mistake a recommendation for a trust guarantee.

**As an** AgToosa maintainer, **I want** catalog plans to delegate every install to `--registry install` **so that** the catalog never becomes a second installation authority.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a catalog document is validated THE SYSTEM SHALL require a schema version and, for every entry, a unique ID, kind (`extension` or `preset`), summary, use-case tags, maintenance owner, lifecycle state, compatibility object, trust object, provenance object, and at least one example. | Must |
| AC-002 | WHEN an extension references a pack THE SYSTEM SHALL require an exact registry pack name and version plus a provenance snapshot containing source URL, SHA-256, registry `verified` snapshot, signature state, and review timestamp or explicit `not-reviewed`. | Must |
| AC-003 | WHEN `--catalog info` or `--catalog plan` evaluates an entry THE SYSTEM SHALL compare its AgToosa semantic-version range, platform requirements, required capabilities, conflicts, and deprecation state with the current project and report `compatible`, `incompatible`, or `unknown` with reasons. | Must |
| AC-004 | WHEN trust is displayed THE SYSTEM SHALL show catalog curation tier, registry `verified` state, checksum provenance, and optional signature state as separate fields and SHALL NOT infer one from another or describe any tier as a security guarantee. | Must |
| AC-005 | WHEN catalog data differs from the current registry index THE SYSTEM SHALL treat the registry name, version, URL, SHA-256, `verified`, and signature metadata as authoritative for installation, mark the catalog entry stale, and refuse to emit a ready install plan until reconciled. | Must |
| AC-006 | WHEN a user runs `--catalog list`, `search`, or `info` THE SYSTEM SHALL return deterministic read-only results and SHALL NOT download, queue, merge, or execute pack content. | Must |
| AC-007 | WHEN a user runs `--catalog plan <preset>` THE SYSTEM SHALL resolve pinned extension references, dependency order, file/capability conflicts, compatibility, and registry install commands, require explicit per-pack registry consent later, and SHALL NOT install the preset itself. | Must |
| AC-008 | WHEN DEV-053 is eligible to ship THE SYSTEM SHALL have at least three maintained catalog entries with distinct owners or explicit shared ownership that pass schema, compatibility, registry-reference, offline install-fixture, provenance, and maintenance-contact checks. | Must |
| AC-009 | WHEN a catalog or preset contains unknown keys, executable command fields, traversal paths, duplicate IDs, dependency cycles, invalid semantic-version ranges, or unbounded text THE SYSTEM SHALL reject it with a field-specific diagnostic before generating a plan. | Must |
| AC-010 | WHEN the Catalog workflow is installed THE SYSTEM SHALL provide a canonical `Docs/AgToosa_Catalog.md`, thin platform adapters, Registry cross-links, and config inventory without duplicating registry safety rules outside the canonical Registry doc. | Must |
| AC-011 | WHEN implementation begins THE SYSTEM SHALL add PC-001–PC-008 as failing contract tests before changing catalog, generator, registry-documentation, or adapter behavior. | Must |
| AC-012 | WHEN DEV-053 is reviewed or shipped THE SYSTEM SHALL record executed evidence in the matching test plan and SHALL NOT claim marketplace hosting, automatic preset installation, mandatory signatures, or catalog authority over registry metadata. | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode | Required response |
|----|---------|--------------|-------------------|
| FM-001 | AC-001, AC-002 | An entry has attractive copy but no owner, pin, or provenance. | Schema validation fails; entry is not listed in production catalog output. |
| FM-002 | AC-003 | A preset marked compatible requires a platform not installed. | Report `incompatible` with the missing platform; do not emit ready commands. |
| FM-003 | AC-004 | “Official” or “reviewed” is presented as proof the content is safe. | Separate curation from registry/signature fields and block the overclaim in docs tests. |
| FM-004 | AC-005 | Catalog SHA-256 or version differs from registry metadata. | Mark stale and require catalog reconciliation; registry remains authoritative. |
| FM-005 | AC-007 | Preset hides conflicting destination files or queues packs immediately. | Plan reports conflicts and emits commands only; registry preview/consent remains mandatory. |
| FM-006 | AC-008 | Fixture-only examples are counted as maintained entries. | Shipping gate remains unmet until three production catalog entries have owners and evidence. |
| FM-007 | AC-009 | A malicious entry injects shell fragments into an install plan. | Reject executable fields; generate commands only from validated pack name/version tokens. |
| FM-008 | AC-010 | Catalog docs copy registry rules and drift from the actual installer. | Replace duplicate logic with a canonical Registry link and parity test. |
| FM-009 | AC-012 | Release notes call the catalog a marketplace or trusted registry. | Narrow the claim before ship and retain the catalog/registry distinction. |

### 1.5 Out of Scope

- Creating, approving, publishing, deleting, or yanking registry pack records
- Changing registry `verified`, SHA-256, signature, tar-slip, preview, denylist, or file-allowlist behavior
- Automatic `--catalog install` or atomic multi-pack transactions
- Executable scripts, binaries, hooks, or `.github/workflows/` delivered by catalog entries
- Hosted marketplace UI, user accounts, telemetry, ratings, reviews, downloads, billing, or recommendation models
- Organization-private catalog hosting or authentication
- Automatic dependency resolution beyond declared, pinned preset members
- Compatibility guarantees for untested future AgToosa or platform versions
- Treating catalog curation as a signature, compliance certification, or security audit

### 1.6 Claim Boundary

| Surface or control | Classification | Boundary |
|--------------------|----------------|----------|
| Catalog schema parsing, compatibility checks, cycle detection, and plan generation | generator-enforced after implementation | Validates local catalog data only |
| Catalog curation tier and maintenance ownership | manual governance | Human-reviewed metadata; not a security guarantee |
| Registry metadata and install safety gates | generator-enforced by existing Registry flow | Registry remains install source of truth |
| Registry `verified` value | registry-maintainer controlled | Catalog only displays a checked snapshot |
| SHA-256 and optional minisign behavior | generator-enforced according to Registry contract | Catalog cannot strengthen or weaken it |
| Preset selection and per-pack consent | manual | User reviews the plan and each registry preview |
| Catalog workflow recommendations | agent-instructed | Thin adapters delegate to canonical docs |
| Hosted marketplace, ratings, and automatic updates | roadmap / out of scope | Must not be claimed by DEV-053 |
| `docs/Master-Plan.md` | repo-local PM source of truth | Catalog data never controls story state |

## 2. Design

### 2.1 Architecture Blueprint

**Files to create:**

- `catalog/catalog.schema.json` — versioned schema for extension and preset entries
- `catalog/catalog.json` — reviewed production catalog containing at least three maintained entries before ship
- `lib/catalog.sh` — `list`, `search`, `info`, `validate`, and `plan` implementation
- `template/Docs/AgToosa_Catalog.md` — canonical discovery, compatibility, trust, provenance, and planning contract
- `docs/AgToosa_Catalog.md` — maintainer mirror
- Thin `agtoosa-catalog` adapters under existing platform command/prompt/workflow directories
- `tests/fixtures/catalog/` — valid, stale, incompatible, cyclic, conflicting, duplicate, injection, and oversized entries plus an offline registry fixture

**Files to change:**

- `agtoosa.sh` — route `--catalog list|search|info|validate|plan`
- `agtoosa.ps1` — native Windows parity for read-only catalog commands
- `lib/config.sh` — register Catalog docs and platform adapters
- `template/Docs/AgToosa_Registry.md` and `docs/AgToosa_Registry.md` — concise Catalog cross-link; Registry remains canonical for install safety
- `template/Docs/AgToosa_Agent.md`, `AgToosa_Quickref.md`, and maintainer mirrors — discoverability
- `tests/agtoosa.bats` — PC-001–PC-008
- `docs/AgToosa_TestPlan-DEV-053.md` — executed evidence only after build begins

**Key interfaces:**

- `catalog_validate(catalog_path, registry_index) -> diagnostics`
- `catalog_list(filters) -> ordered summaries`
- `catalog_info(entry_id, project_context) -> evaluated entry`
- `catalog_plan(preset_id, project_context, registry_index) -> non-executing plan`
- `evaluate_compatibility(entry, agtoosa_version, platforms, capabilities) -> compatible | incompatible | unknown`
- `compare_registry_snapshot(extension, registry_row) -> current | stale(reason)`

**Catalog entry model:**

- Identity: `id`, `kind`, `name`, `summary`, `tags`, `examples`
- Ownership: `maintainers[]`, `support`, `lifecycle`, `reviewed_at`
- Compatibility: `agtoosa`, `platforms[]`, `requires[]`, `conflicts[]`
- Trust: `curation_tier`, `registry_verified_snapshot`, `review_status`
- Provenance: `registry_name`, `version`, `source`, `sha256`, `signature`
- Preset-only: ordered `members[]` containing pinned extension IDs and rationale

### 2.2 Data Flow

1. The user invokes a read-only Catalog command.
2. The catalog parser loads `catalog/catalog.json`, validates size and schema, and sorts entries by stable ID.
3. `list` and `search` return summaries without contacting or installing from the registry.
4. `info` evaluates the selected entry against the current AgToosa version, installed platform sentinels, and declared capabilities.
5. For an extension, the evaluator compares its provenance snapshot with the current or explicitly supplied cached registry row.
6. For a preset, the planner resolves pinned members, checks cycles, orders dependencies, and reports file/capability conflicts.
7. If any member is incompatible, unknown where a definitive answer is required, deprecated, missing, or stale against registry metadata, the plan is not ready.
8. A ready plan prints exact `--registry install <name>@<version>` commands and trust/provenance facts; it does not execute them.
9. The user runs each registry command separately, receiving the existing verification, preview, and consent gates.
10. Catalog state never changes registry records, installed pack state, or `Master-Plan.md`.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A malicious author impersonates an official maintainer. | Spoofing | Named maintainer records and review commit; curation tier remains separate from registry verification. |
| Catalog pin or checksum is changed to point at different content. | Tampering | Compare every ready plan with current registry metadata; registry SHA-256 remains authoritative at install. |
| Maintainers cannot identify who reviewed a catalog entry. | Repudiation | Require owner, review status, timestamp, and review commit or explicit `not-reviewed`. |
| Private registry URLs or maintainer contact secrets leak in output. | Information Disclosure | Public metadata allowlist; reject credential-bearing URLs and secret-shaped fields. |
| Huge catalogs or cyclic presets exhaust the planner. | Denial of Service | Bound file/entry/member sizes and detect dependency cycles before expansion. |
| Stored shell text executes through generated install commands. | Elevation of Privilege | Disallow command fields and derive escaped commands only from validated registry name/version tokens. |

### 2.4 Build Scope

**Future scope boundary — enrollment required before implementation**

```text
Files in scope      : `catalog/catalog.json`, `catalog/catalog.schema.json`, `lib/catalog.sh`, `agtoosa.sh`, `agtoosa.ps1`, `lib/config.sh`, Catalog canonical/mirror docs, concise Registry cross-links, thin platform adapters, catalog fixtures, `tests/agtoosa.bats`, this spec, and its test plan
Directories in scope: `catalog/`, `lib/`, `template/Docs/`, `docs/`, existing platform adapter directories under `template/`, `tests/fixtures/catalog/`
Out of scope        : external registry repository mutation, installer safety-gate changes, hosted services, executable pack formats, automatic preset installation, release publication
```

Any proposal to let Catalog install directly or override registry metadata requires a spec amendment, a new authority analysis, and additional supply-chain tests.

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract and fixtures: establish catalog, registry, and trust boundaries first
  - [ ] 1.1 Add PC-001–PC-008 as RED tests and create offline catalog/registry fixtures — _Requirements: AC-001–AC-011_
  - [ ] 1.2 Add stale, incompatible, cyclic, conflict, injection, duplicate, and oversized negative fixtures — _Requirements: AC-003–AC-005, AC-009_
- [ ] **2.** Catalog core: implement schema, discovery, compatibility, and planning
  - [ ] 2.1 Implement schema validation plus deterministic `list`, `search`, and `info` — _Requirements: AC-001, AC-002, AC-006, AC-009_
  - [ ] 2.2 Implement compatibility evaluation and registry snapshot reconciliation — _Requirements: AC-003–AC-005_
  - [ ] 2.3 Implement non-executing preset plan, cycle/order/conflict checks, and Bash/PowerShell parity — _Requirements: AC-007, AC-009_
- [ ] **3.** Production catalog and workflow: make discovery useful without duplicating Registry
  - [ ] 3.1 Create canonical Catalog docs, thin adapters, config registration, and Registry/Quickref cross-links — _Requirements: AC-004, AC-010_
  - [ ] 3.2 Select and document at least three maintained production entries with ownership and examples — _Requirements: AC-001, AC-002, AC-008_
  - [ ] 3.3 Validate each production entry against offline install fixtures and current provenance metadata — _Requirements: AC-005, AC-008_
- [ ] **4.** Verification and evidence: prove catalog behavior and bounded claims
  - [ ] 4.1 Run focused and full regressions only after implementation is GREEN — _Requirements: AC-011_
  - [ ] 4.2 Record three-entry evidence, RED/GREEN output, and claim review in the test plan — _Requirements: AC-008, AC-012_

### 3.2 Wave Plan

- **Wave 1 (parallel):** 1.1, 1.2, 3.2
- **Wave 2 (parallel after Wave 1):** 2.1, 2.2, 3.1
- **Wave 3 (parallel after Wave 2):** 2.3, 3.3
- **Wave 4 (sequential after Wave 3):** 4.1, 4.2

### 3.3 Test Plan

- Test plan: `docs/AgToosa_TestPlan-DEV-053.md`
- AC coverage: 12 ACs mapped to 8 planned test IDs (PC-001–PC-008)
- Smoke set: 6 planned tests
- Evidence state: unexecuted backlog placeholders only

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Enforcement classified: yes
- Three maintained entries: select at enrollment from current registry packs

## ✅ Spec Approved

Approved: 2026-07-11 20:30
Enrollment: four-epic parallel build (DEV-003 next spec)
