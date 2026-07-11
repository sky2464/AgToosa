# Spec: DEV-080 — Official Registry Pack Pilot

> **Story ID:** DEV-080
> **Epic:** DEV-003 — Community Template Registry
> **Type:** Feature
> **Priority:** P2
> **Status:** ⬜ Backlog
> **Estimate:** L
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11
> **Depends on:** DEV-053 — Extension and Preset Catalog

## Context

The registry has install, integrity, preview, and provenance controls, but it does not yet have a small set of maintained packs that prove the catalog contract with realistic content. This pilot is intentionally limited to three domains: web applications, API/services, and infrastructure/security.

DEV-053 owns the catalog metadata and compatibility contract. DEV-080 may not freeze manifests or begin pack production until that contract is approved and implemented. This backlog spec records required future proof; it does not claim that any pack exists, has been installed, or has been accepted by an external registry.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Produce and prove three official, maintained registry packs—web, API/service, and infrastructure/security—against the DEV-053 catalog contract. |
| User outcome | A user can choose a relevant starter pack, understand its provenance and compatibility, inspect examples, and follow a reproducible installation path without mistaking the pilot for a marketplace. |
| Success condition | Exactly three pilot packs satisfy the catalog contract; each has an accountable maintainer, provenance, compatibility declaration, examples, maintenance policy, and recorded clean-install proof; external publication state is reported separately. |
| Proof / evidence | Required before completion: manifest-contract checks, content-policy review, controlled install/merge tests, example checks, and dated external-registry review records. No evidence has been collected. |
| Non-goals | Scaling beyond three packs, weakening registry safety controls, or implementing any parked roadmap item listed in §1.4. |
| Assumptions | DEV-053 defines stable required fields and compatibility semantics; existing registry integrity, preview, allowlist, denylist, and consent controls remain authoritative. |
| Risks | An “official” label may overstate support; pack examples may drift; external publication may be delayed; provenance fields may be confused with fail-closed signatures. |
| Unresolved questions | Final source-repository locations and named maintainers must be selected at enrollment after DEV-053 is complete. |

### 1.2 User Stories

**As an** AgToosa user, **I want** a maintained pack for web, API/service, or infrastructure/security work **so that** I can adopt a relevant workflow without assembling one from unrelated examples.

**As a** security-conscious adopter, **I want** provenance, compatibility, and reproducible install records for each pack **so that** I can review the trust boundary before queueing its instructions.

**As an** AgToosa maintainer, **I want** explicit ownership and deprecation rules **so that** an official pack cannot silently become stale.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the pilot inventory is published THE SYSTEM SHALL identify exactly three maintained packs covering web, API/service, and infrastructure/security, with one primary domain per pack | Must |
| AC-002 | WHEN a pilot pack manifest is authored THE SYSTEM SHALL conform to the completed DEV-053 catalog contract and record version, AgToosa compatibility, maintainer, source, release provenance, integrity metadata, and trust classification | Must |
| AC-003 | WHEN a user reads a pilot pack THE SYSTEM SHALL provide a runnable usage example, intended-use guidance, prerequisites, and pack-specific non-goals | Must |
| AC-004 | WHEN compatibility is declared THE SYSTEM SHALL name supported AgToosa versions and applicable platform surfaces and SHALL identify known incompatible or untested combinations | Must |
| AC-005 | WHEN a pilot pack is validated THE SYSTEM SHALL record reproducible fresh-install, queue/merge, and resulting-file assertions in an isolated fixture without treating planned commands as executed evidence | Must |
| AC-006 | WHEN pack content crosses the registry trust boundary THE SYSTEM SHALL retain existing integrity, archive, file-type, sensitive-path, preview, and consent controls and SHALL document which controls are generator-enforced versus manual | Must |
| AC-007 | WHEN a pilot pack is designated maintained THE SYSTEM SHALL record an owner, review cadence, compatibility-update policy, issue path, and deprecation process | Must |
| AC-008 | WHEN external-registry publication is requested THE SYSTEM SHALL treat submission and approval as manual external actions and SHALL NOT report a pack as externally published until the accepted registry record is independently confirmed | Must |

**Failure modes:**

| AC | Failure mode | Required response |
|----|--------------|-------------------|
| AC-001 | Two packs cover the same domain while one required domain is absent | Reject the pilot inventory as incomplete. |
| AC-002 | A manifest uses fields that predate or contradict DEV-053 | Block pack enrollment until the catalog contract is satisfied. |
| AC-003 | A README-only example is presented as runnable install proof | Keep evidence unexecuted until an isolated install run is recorded. |
| AC-004 | “Compatible” is stated without a version or platform boundary | Mark the combination untested; do not imply support. |
| AC-005 | A README command is presented as install proof | Keep evidence status unexecuted until an isolated run is recorded. |
| AC-006 | A pack bypasses preview or targets a denylisted path | Reject the pack; do not weaken the existing gate. |
| AC-007 | The named owner or review cadence is missing | Do not apply the maintained/official designation. |
| AC-008 | A submission exists but external review is pending | Report “submitted,” not “published” or “available.” |

### 1.4 Out of Scope

- Any SaaS or hosted control plane
- SSO or RBAC
- An MCP runtime
- An autonomous build runtime
- A federated registry
- A marketplace, billing, ratings, or paid distribution
- Silent telemetry or automatic usage reporting
- A Go or Rust rewrite
- More than the three named pilot packs
- Relaxing registry integrity, preview, consent, allowlist, or denylist behavior
- Automatic external-registry publication or approval
- Fail-closed signature requirements, which require separate validation under DEV-082

The parked roadmap items above are exclusions, not DEV-080 subtasks.

### 1.5 Claim Boundary

| Surface or claim | Classification | Boundary |
|------------------|----------------|----------|
| Pack manifest and compatibility schema | DEV-053-owned contract | DEV-080 consumes the completed contract; it does not redefine it. |
| Pack content, examples, and maintenance metadata | Maintainer-authored / reviewable | “Official” means curated under the documented policy, not guaranteed fit for every project. |
| Registry archive and destination controls | Generator-enforced existing behavior | The pilot must pass them; this story does not strengthen or replace them. |
| Focused fixture checks | CI-enforced-able after implementation | No pass claim exists until commands and outputs are recorded. |
| External registry submission and approval | Manual / external | A local artifact or open PR is not proof of publication. |
| Ongoing pack review cadence | Manual governance | No SLA or continuous compatibility guarantee is implied. |

## 2. Design

### 2.1 Architecture Blueprint

Proposed future surfaces:

| Surface | Responsibility |
|---------|----------------|
| Three dedicated pack source roots (locations fixed after DEV-053) | Canonical content, examples, manifest, changelog, and maintenance policy for web, API/service, and infrastructure/security |
| DEV-053 catalog validator | Validate required metadata, compatibility declarations, provenance, and trust classification |
| `tests/fixtures/registry-packs/official-*` | Deterministic install fixtures that do not depend on external-registry availability |
| `tests/agtoosa.bats` | OPP contract, install, merge, boundary, and regression checks |
| `docs/AgToosa_Registry.md` | User-facing pilot inventory and honest official/support boundary |
| External `agtoosa-registry` records | Manually reviewed discovery entries; not owned by automated local build |

Key interfaces:

- Catalog manifest: the final required-field and compatibility contract shipped by DEV-053.
- Registry install path: existing list/info/install, integrity, isolated staging, preview, queue, and merge behavior.
- Pilot evidence record: pack version, fixture, command, exit code, assertions, date, and reviewer.

### 2.2 Data Flow

1. Enrollment confirms DEV-053 is complete and pins the catalog-contract version used by the pilot.
2. A maintainer authors one pack in each required domain with manifest, examples, compatibility, provenance, and ownership metadata.
3. The catalog validator and content-policy review reject incomplete or unsafe candidates.
4. Accepted candidates are packaged into local deterministic fixtures with integrity metadata.
5. Focused tests install each fixture into an isolated generated project, inspect the preview/queue, merge it, and assert the expected file set.
6. Recorded results are linked to the exact pack release and compatibility declaration.
7. A maintainer prepares and submits external registry records as a manual action.
8. Documentation reports each pack as local candidate, submitted, or externally published based only on confirmed state.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A malicious source impersonates an official pack | Spoofing | Pin source ownership and release provenance in the DEV-053 manifest; require external review. |
| Pack content or archive changes after review | Tampering | Pin immutable release version and integrity metadata; rerun validation for each release. |
| A maintainer disputes which content was approved | Repudiation | Record reviewed commit/release, reviewer, date, and external registry state. |
| Examples expose credentials or local paths | Information Disclosure | Use synthetic fixtures and scan examples for secret-like values before publication. |
| Oversized or pathological pack stalls installation | Denial of Service | Apply existing archive and staging constraints; add bounded fixture checks. |
| Instruction content attempts unsafe actions | Elevation of Privilege | Preserve preview, consent, file allowlist, and sensitive-destination denylist; require human content review. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : three pack manifests/content/example sets, pilot inventory documentation, deterministic pack fixtures, focused OPP tests, and evidence records created during future execution
Directories in scope: the three selected pack source roots, `tests/fixtures/registry-packs/`, `tests/`, and the external registry records handled manually
Dependency gate     : DEV-053 approved and implemented before manifest freeze or pack production
Out of scope        : all §1.4 exclusions, unrelated generator behavior, registry federation/marketplace work, and release-wide version changes unless separately enrolled

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Catalog gate and pilot contract
  - [ ] 1.1 Confirm the implemented DEV-053 manifest and compatibility contract; record the consumed version — _Requirements: AC-002, AC-004_
  - [ ] 1.2 Define the shared pilot review and evidence checklist — _Requirements: AC-005, AC-006, AC-007_
- [ ] **2.** Author the three maintained candidates
  - [ ] 2.1 Author the web pack with manifest, examples, compatibility, and ownership — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-007_
  - [ ] 2.2 Author the API/service pack with manifest, examples, compatibility, and ownership — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-007_
  - [ ] 2.3 Author the infrastructure/security pack with manifest, examples, compatibility, and ownership — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-006, AC-007_
- [ ] **3.** Prove local install and safety boundaries
  - [ ] 3.1 Add OPP contract and deterministic fixture tests before implementation changes — _Requirements: AC-002, AC-004, AC-005, AC-006_
  - [ ] 3.2 Run each future candidate through isolated install, preview, queue, and merge checks; record actual results — _Requirements: AC-005, AC-006_
  - [ ] 3.3 Review maintenance and deprecation records for all three candidates — _Requirements: AC-007_
- [ ] **4.** Document and publish within the external boundary
  - [ ] 4.1 Publish the local pilot inventory with exact candidate state and evidence links — _Requirements: AC-001, AC-003, AC-005, AC-008_
  - [ ] 4.2 Submit the three registry entries and obtain external review — _Requirements: AC-002, AC-008_ `[manual]`
  - [ ] 4.3 Confirm accepted external records before changing state to published — _Requirements: AC-008_ `[manual]`

### 3.2 Wave Plan

**Wave 0 (dependency, sequential):** 1.1 after DEV-053 is approved and implemented  
**Wave 1 (parallel):** 1.2, 3.1  
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 2.3  
**Wave 3 (parallel after Wave 2):** 3.2, 3.3  
**Wave 4 (sequential after Wave 3):** 4.1, then 4.2, then 4.3

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-080.md`
AC coverage: 8 ACs mapped to 10 planned OPP test IDs
Smoke set: 4 planned tests tagged `@smoke`
Evidence state: RED and GREEN are unexecuted placeholders; no test or install evidence is claimed.
