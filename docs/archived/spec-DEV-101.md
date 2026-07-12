# Spec: DEV-101 — Docs: Verified vs Community Pack Labeling

> **Story ID:** DEV-101
> **Type:** Docs
> **Epic:** DEV-003 — Community Template Registry
> **Status:** ⬜ Backlog
> **Estimate:** XS
> **Priority:** P2
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

The registry supports community packs with integrity, preview, and consent controls, and DEV-080 introduced official pilot packs with honest `local-candidate` trust state. Rev4 treats the registry as a curated trust surface: a `verified` designation applies only to maintainer-reviewed packs; community packs remain possible but must be clearly labeled. DEV-101 documents verified versus community labeling rules in `docs/AgToosa_Registry.md` and the generated-project mirror without changing install semantics.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Document verified versus community pack labeling rules as the registry trust surface. |
| User outcome | A user can distinguish maintainer-reviewed packs from community submissions before queueing install instructions. |
| Success condition | `AgToosa_Registry.md` defines label meanings, allowed claims per label, manifest field mapping, and publication-state honesty; TRUST tests enforce vocabulary and forbid conflated claims. |
| Proof / evidence | TRUST tests cover label definitions, manifest field mapping, forbidden claim phrases, and cross-links to official pilot state machine. |
| Non-goals | New registry commands, automatic verification pipeline, or marketplace behavior. |
| Assumptions | Existing manifest trust fields (`review_status`, `registry_verified_snapshot`, etc.) remain authoritative; DEV-080 publication state machine still applies to official pilots. |
| Risks | Documentation overstates verification as security guarantee; community packs appear "official" by typography alone. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** registry user, **I want** clear verified versus community labels **so that** I know who reviewed a pack before installing it.

**As a** community pack author, **I want** honest labeling rules **so that** I do not accidentally claim maintainer verification.

**As an** AgToosa maintainer, **I want** trust-surface vocabulary enforced by tests **so that** registry docs cannot drift into marketing language.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a reader opens registry trust documentation THE SYSTEM SHALL define at minimum these pack classes: verified (maintainer-reviewed), community (submitted, not maintainer-verified), and official pilot (maintained local candidate per DEV-080/095 inventory) | Must |
| AC-002 | WHEN a label is defined THE SYSTEM SHALL list allowed user-facing claims and forbidden claims for that label | Must |
| AC-003 | WHEN trust documentation references manifest fields THE SYSTEM SHALL map each label to concrete manifest/metadata fields without inventing new schema keys | Must |
| AC-004 | WHEN publication state is described THE SYSTEM SHALL preserve the DEV-080 state machine (local candidate, submitted, published) and SHALL require independent confirmation before "published" or "available" claims | Must |
| AC-005 | WHEN install safety is described THE SYSTEM SHALL state that labeling does not bypass preview, consent, integrity, allowlist, or denylist controls | Must |
| AC-006 | WHEN trust documentation is updated THE SYSTEM SHALL fail focused checks if forbidden phrases equate community packs with maintainer verification or deterministic security enforcement | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Verified and community classes are undefined or conflated. |
| FM-002 | AC-002 | A community pack doc template says "official" or "maintainer-approved." |
| FM-003 | AC-003 | Documentation cites manifest fields that do not exist in DEV-053 schema. |
| FM-004 | AC-004 | "Submitted" is presented as externally published. |
| FM-005 | AC-005 | Labeling implies install skips preview or consent. |
| FM-006 | AC-006 | Registry doc claims verified packs are "security certified." |

### 1.5 Out of Scope

- Implementing automated verification or signature enforcement (DEV-082)
- Changing `--registry install` behavior or trust flags
- Federation, marketplace, or billing
- Rewriting pack manifests for existing pilots

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Trust label definitions | documentation |
| Manifest trust fields | DEV-053 schema + pack manifests |
| Install safety gates | generator-enforced existing behavior |
| Maintainer verification decision | manual review |
| External registry publication | manual / external |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `docs/AgToosa_Registry.md` — trust surface section: verified vs community vs official pilot
- `template/Docs/AgToosa_Registry.md` — generated-project mirror
- `docs/official-pack-pilot-checklist.md` — cross-link to trust labels (optional one-line pointer)
- `tests/agtoosa.bats` — TRUST vocabulary and mapping tests

### 2.2 Data Flow

1. Add "Trust surface" section to registry documentation with label table and forbidden-claim list.
2. Map labels to existing manifest fields (`review_status`, `registry_verified_snapshot`, maintainer block).
3. Cross-link DEV-080 publication state machine without duplicating full checklist.
4. TRUST tests grep for required vocabulary and forbidden phrases.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Community pack mislabeled as verified | Spoofing | Explicit label definitions and forbidden-claim tests. |
| User trusts label as security certification | Spoofing | Forbidden-claim list; install safety reminder. |
| Documentation invents schema fields | Tampering | Map only to DEV-053 manifest keys. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `docs/AgToosa_Registry.md`, template mirror, TRUST bats, optional checklist cross-link
Directories in scope: `docs/`, `template/Docs/`, `tests/`
Out of scope        : registry command changes, automatic verification, manifest schema changes

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED trust vocabulary
  - [ ] 1.1 Add TRUST label inventory and forbidden-claim fixtures — _Requirements: AC-001, AC-002, AC-006_
  - [ ] 1.2 Add manifest mapping and publication-state fixtures — _Requirements: AC-003, AC-004, AC-005_
- [ ] **2.** Registry documentation
  - [ ] 2.1 Author trust surface section in registry docs and template mirror — _Requirements: AC-001–AC-005_
- [ ] **3.** Evidence
  - [ ] 3.1 Record RED/GREEN TRUST evidence — _Requirements: AC-001–AC-006_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1  
**Wave 3 (sequential after Wave 2):** 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-101.md`
AC coverage: 6 ACs mapped to 6 TRUST test IDs
Smoke set: 2 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-101)
