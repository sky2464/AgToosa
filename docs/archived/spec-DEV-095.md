# Spec: DEV-095 — Feature: Official Pack Expansion

> **Story ID:** DEV-095
> **Type:** Feature
> **Epic:** DEV-003 — Community Template Registry
> **Status:** 🚫 Blocked — Wave 3 enrolled (wait DEV-096 GREEN)
> **Estimate:** M
> **Priority:** P1
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12
> **Depends on:** DEV-080 (shipped three-pack pilot), DEV-096 (pack validation CI green on existing pilots)
> **Supersedes:** DEV-080 AC-001 three-pack inventory cap — official pilot maximum is five packs per `docs/updates/rev4-conflict-resolutions.md`

## Context

DEV-080 shipped three maintained local-candidate packs (`official-web`, `official-api`, `official-infra`) under the DEV-053 catalog contract. Rev4 requires a five-pack maximum with React-specific and security-sensitive domains added without renaming `official-web` (stack-agnostic SPA) or overloading existing pilots. DEV-095 authors `official-react` and `official-security`, each with a per-pack example repository reference, and updates inventory documentation to reflect the five-pack ceiling. Expansion does not begin until DEV-096 pack validation CI is green on the three shipped pilots.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Expand the official pack pilot from three to five maintained packs by adding `official-react` and `official-security` with per-pack example repos and honest inventory state. |
| User outcome | A user can choose a React-specific or security-sensitive starter pack with the same provenance, compatibility, and install safety boundaries as the existing three pilots. |
| Success condition | Five official packs (`official-api`, `official-web`, `official-infra`, `official-react`, `official-security`) satisfy the DEV-053 contract; each has a linked example repo; inventory and OPP tests reflect the five-pack maximum without conflating `official-web` and `official-react`. |
| Proof / evidence | OPE tests cover inventory, manifest conformance, examples, compatibility, isolated install fixtures, and publication honesty for both new packs; existing OPP tests remain green. |
| Non-goals | A sixth pack, renaming `official-web`, marketplace behavior, automatic external publication, or weakening registry safety controls. |
| Assumptions | DEV-096 pack validation CI is green on existing pilots before new pack authoring; `official-web` stays stack-agnostic per conflict resolution §2. |
| Risks | React and web domains overlap in user perception; example repos drift; expansion ships before CI gates are ready. |
| Unresolved questions | Final example-repository URLs and named maintainers for the two new packs are selected at enrollment. |

### 1.2 User Stories

**As an** AgToosa user building a React or Next/Vite frontend, **I want** an `official-react` pack with explicit tooling hooks **so that** I do not mistake the generic `official-web` pack for React-specific guidance.

**As a** security-conscious adopter, **I want** an `official-security` pack with threat-model and evidence expectations **so that** I can adopt a security-sensitive workflow with documented boundaries.

**As an** AgToosa maintainer, **I want** the five-pack inventory enforced by tests and docs **so that** pilot scope cannot silently grow beyond Rev4 limits.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the official pilot inventory is published THE SYSTEM SHALL identify exactly five maintained packs (`official-api`, `official-web`, `official-infra`, `official-react`, `official-security`) with one primary domain per pack and SHALL NOT treat `official-web` and `official-react` as overlapping inventory rows | Must |
| AC-002 | WHEN `official-react` and `official-security` manifests are authored THE SYSTEM SHALL conform to the DEV-053 catalog contract and record version, AgToosa compatibility, maintainer, source, release provenance, integrity metadata, and trust classification | Must |
| AC-003 | WHEN a reader inspects either new pack THE SYSTEM SHALL provide a runnable usage example, intended-use guidance, prerequisites, explicit non-goals, and a linked per-pack example repository URL | Must |
| AC-004 | WHEN `official-react` compatibility is declared THE SYSTEM SHALL name React/Next/Vite conventions explicitly and SHALL state that `official-web` remains the stack-agnostic SPA pack | Must |
| AC-005 | WHEN `official-security` compatibility is declared THE SYSTEM SHALL name supported AgToosa versions, platform surfaces, and security-evidence expectations without implying deterministic SAST enforcement | Must |
| AC-006 | WHEN each new pack is validated THE SYSTEM SHALL record reproducible fresh-install, queue/merge, and resulting-file assertions in isolated fixtures without treating planned commands as executed evidence | Must |
| AC-007 | WHEN pack content crosses the registry trust boundary THE SYSTEM SHALL retain existing integrity, archive, file-type, sensitive-path, preview, and consent controls | Must |
| AC-008 | WHEN a new pack is designated maintained THE SYSTEM SHALL record an owner, review cadence, compatibility-update policy, issue path, and deprecation process | Must |
| AC-009 | WHEN external-registry publication is requested THE SYSTEM SHALL treat submission and approval as manual external actions and SHALL NOT report a pack as externally published until the accepted registry record is independently confirmed | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | A sixth pack appears or `official-web` is renamed to `official-react`. |
| FM-002 | AC-002 | A new manifest omits required DEV-053 fields or uses stale schema version. |
| FM-003 | AC-003 | An example repo link is missing, private, or presented as install proof without a recorded fixture run. |
| FM-004 | AC-004 | React guidance is folded into `official-web`, blurring stack-agnostic boundaries. |
| FM-005 | AC-005 | Security pack implies CI-enforced SAST without deterministic command evidence. |
| FM-006 | AC-006 | README commands substitute for isolated install fixture proof. |
| FM-007 | AC-007 | A new pack bypasses preview or targets a denylisted path. |
| FM-008 | AC-008 | Owner or review cadence is missing for either new pack. |
| FM-009 | AC-009 | Inventory claims external publication before manual confirmation. |

### 1.5 Out of Scope

- More than five official pilot packs
- Renaming `official-web` or merging web and react domains
- Marketplace, federation, billing, or ratings
- Automatic external-registry publication
- Relaxing registry integrity, preview, consent, allowlist, or denylist behavior
- Fail-closed signature requirements (DEV-082 scope)

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Five-pack inventory cap | documentation + CI-enforced when OPE/OPP tests run |
| Pack manifests and examples | maintainer-authored / reviewable |
| Registry archive and destination controls | generator-enforced existing behavior |
| Focused fixture install checks | CI-enforced after implementation |
| Example repository content | external / manual evidence |
| External registry submission and approval | manual / external |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `packs/official-react/` — manifest, EXAMPLES, COMPATIBILITY, MAINTENANCE, content, changelog
- `packs/official-security/` — manifest, EXAMPLES, COMPATIBILITY, MAINTENANCE, content, changelog
- `tests/fixtures/registry-packs/official-react/` — deterministic install fixture
- `tests/fixtures/registry-packs/official-security/` — deterministic install fixture
- `tests/agtoosa.bats` — OPE contract and install tests for both new packs; OPP inventory update for five-pack ceiling
- `docs/AgToosa_Registry.md` — five-pack pilot inventory and domain boundaries
- `docs/official-pack-pilot-checklist.md` — inventory table and review rows for new packs
- `template/Docs/AgToosa_Registry.md` — generated-project mirror of inventory changes

Key interfaces:

- DEV-053 catalog manifest contract (`schema_version` 1.0)
- Existing registry install path: list/info/install, integrity, preview, queue, merge
- Per-pack example repository URL recorded in EXAMPLES.md and inventory table

### 2.2 Data Flow

1. Confirm DEV-096 pack validation CI is green on the three existing pilots.
2. Author `official-react` and `official-security` with manifests, examples, compatibility, provenance, and ownership metadata.
3. Package each pack into local deterministic fixtures with integrity metadata.
4. Run focused OPE tests: manifest validation, isolated install/preview/queue/merge, and inventory assertions.
5. Update registry documentation and checklist with five-pack inventory and example-repo links.
6. External submission remains manual per DEV-080 tasks 4.2/4.3 and DEV-103 runbook.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A malicious source impersonates an official react or security pack | Spoofing | Pin source ownership and release provenance; require external review before published state. |
| Pack content changes after review | Tampering | Pin immutable release version and SHA-256; DEV-096 CI detects drift. |
| Security pack overclaims deterministic enforcement | Spoofing | Distinguish guided/evidenced/enforced controls in COMPATIBILITY and EXAMPLES. |
| Example repos expose credentials or local paths | Information Disclosure | Use synthetic fixtures; scan examples before publication. |
| Oversized pack stalls installation | Denial of Service | Apply existing archive and staging constraints. |
| Instruction content attempts unsafe actions | Elevation of Privilege | Preserve preview, consent, allowlist, and denylist; require human content review. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `packs/official-react/`, `packs/official-security/`, new fixtures, OPE/OPP test updates, registry inventory docs, pilot checklist
Directories in scope: `packs/`, `tests/fixtures/registry-packs/`, `tests/`, `docs/`, `template/Docs/`
Dependency gate     : DEV-096 green on existing three pilots before pack authoring
Out of scope        : sixth pack, `official-web` rename, marketplace, automatic external publish, registry control weakening

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Expansion contract and RED coverage
  - [ ] 1.1 Add OPE inventory and manifest fixtures for five-pack ceiling — _Requirements: AC-001, AC-002_
  - [ ] 1.2 Add negative fixtures for web/react domain overlap and sixth-pack rejection — _Requirements: AC-001, AC-004_
- [ ] **2.** Author `official-react`
  - [ ] 2.1 Author manifest, examples with example-repo link, compatibility, and ownership — _Requirements: AC-002, AC-003, AC-004, AC-008_
  - [ ] 2.2 Add fixture and isolated install/preview/queue/merge proof — _Requirements: AC-006, AC-007_
- [ ] **3.** Author `official-security`
  - [ ] 3.1 Author manifest, examples with example-repo link, compatibility, and ownership — _Requirements: AC-002, AC-003, AC-005, AC-008_
  - [ ] 3.2 Add fixture and isolated install/preview/queue/merge proof — _Requirements: AC-006, AC-007_
- [ ] **4.** Inventory and evidence
  - [ ] 4.1 Update registry docs and checklist to five-pack inventory with honest publication state — _Requirements: AC-001, AC-009_
  - [ ] 4.2 Record RED/GREEN OPE evidence — _Requirements: AC-001–AC-009_

### 3.2 Wave Plan

**Wave 0 (dependency, sequential):** DEV-096 green on existing pilots  
**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (parallel after Wave 1):** 2.1, 3.1  
**Wave 3 (parallel after Wave 2):** 2.2, 3.2  
**Wave 4 (sequential after Wave 3):** 4.1, 4.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-095.md`
AC coverage: 9 ACs mapped to 10 planned OPE test IDs
Smoke set: 4 planned tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: example-repo URLs and named maintainers at enrollment

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-095)
