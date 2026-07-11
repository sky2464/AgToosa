# Spec: DEV-078 — Chore: First-15-Minutes Maintenance Gate

> **Story ID:** DEV-078
> **Type:** Chore
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** ⬜ Backlog
> **Estimate:** XS
> **Priority:** P1
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11

## Context

`docs/examples/first-15-minutes.md` and `docs/examples/public-launch-proof.md` contain release-pinned commands and proof links. Those values can drift after a release even while the walkthrough structure remains valid. `scripts/check-launch-readiness.sh` already has deterministic private checks and optional network-backed public checks, making it the narrow owner for a first-15 maintenance gate. This story adds no onboarding flow.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Fail deterministically when first-15 documentation carries stale release pins or stale/inconsistent proof links. |
| User outcome | Maintainers discover first-run documentation drift before release instead of after users copy an obsolete command. |
| Success condition | Private launch-readiness checks derive the canonical release version, validate scoped pins and local/proof links without network access, and emit actionable non-zero failures. |
| Proof / evidence | F15 tests mutate isolated fixtures to prove stale pins, missing local links, and inconsistent proof URLs fail; unchanged fixtures pass after repair. |
| Non-goals | A new first-run walkthrough, live browser testing, automatic doc rewrites, or a replacement for public URL availability checks. |
| Assumptions | `AGTOOSA_VERSION` in `agtoosa.sh` is the canonical release version; public-mode URL checks remain separately network-dependent. |
| Risks | Over-broad version matching flags historical changelog text, private mode accidentally calls the network, or the checker rewrites docs. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** release maintainer, **I want** stale first-15 pins to fail a local gate **so that** release documentation stays synchronized with the canonical version.

**As a** documentation contributor, **I want** missing or inconsistent proof links reported with exact locations **so that** I can repair them without changing the onboarding flow.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN private launch readiness runs THE SYSTEM SHALL derive the expected `vX.Y.Z` pin from `AGTOOSA_VERSION` and fail if a release pin in the scoped first-15 or public-proof commands uses another version | Must |
| AC-002 | WHEN scoped markdown contains a relative proof link THE SYSTEM SHALL resolve it from the containing file and fail if the target does not exist | Must |
| AC-003 | WHEN README, first-15 documentation, public-launch proof, and the public checker reference the first-15 proof repository THE SYSTEM SHALL require one canonical URL across those surfaces | Must |
| AC-004 | WHEN a pin or proof-link check fails THE SYSTEM SHALL exit non-zero and report the file, observed value, and expected value or missing target | Must |
| AC-005 | WHILE private mode is selected WHEN the maintenance gate runs THE SYSTEM SHALL perform no network request; WHILE public mode is selected THE SYSTEM SHALL retain the existing anonymous URL availability checks after deterministic checks pass | Must |
| AC-006 | WHEN the maintenance gate runs THE SYSTEM SHALL inspect files without modifying them and SHALL NOT add, replace, or reorder first-15 onboarding steps | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | A newly released version leaves `--ref v5.x.y` examples stale. |
| FM-002 | AC-002 | A renamed public-proof document leaves a dead relative link. |
| FM-003 | AC-003 | README and the checker point to different proof repositories. |
| FM-004 | AC-004 | The gate says only “failed,” forcing a manual search for the stale value. |
| FM-005 | AC-005 | Private CI becomes flaky because it performs HTTP requests. |
| FM-006 | AC-006 | A maintenance command silently rewrites user-facing docs or changes their sequence. |

### 1.5 Out of Scope

- Creating a new onboarding flow, tutorial, proof repository, or demo application.
- Revalidating all historical version strings in the repository.
- Replacing public-mode HTTP availability checks with deterministic claims.
- Automatically editing stale pins or links.
- Running a browser, external link crawler, or hosted monitoring service.
- Changing release-version ownership away from `agtoosa.sh`.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Scoped release-pin and local-link consistency | deterministic repository check |
| Private-mode gate in CI | CI-enforced when the existing readiness/focused tests run |
| Public URL availability | network-dependent public-mode evidence |
| Proof repository content correctness | manual / separate repository evidence |
| Automatic documentation repair | out of scope |
| First-15 user completion | not measured by this gate |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `scripts/check-launch-readiness.sh` — derive canonical version; check scoped pins, relative links, and canonical proof URL before the private/public split.
- `docs/examples/first-15-minutes.md` — repair stale scoped pin or proof links found by RED tests; do not add steps.
- `docs/examples/public-launch-proof.md` — repair stale scoped pins or proof links found by RED tests; do not add steps.
- `README.md` — repair only the canonical proof link if inconsistent.
- `tests/agtoosa.bats` — F15 fixture-based positive and negative coverage.

No new command, workflow document, or onboarding artifact is created.

### 2.2 Data Flow

1. The checker reads `AGTOOSA_VERSION` from `agtoosa.sh` and formats the expected release tag.
2. It extracts release pins only from the scoped command/URL locations in the two first-15 proof documents and public checker.
3. It resolves relative markdown links from each containing document.
4. It compares the first-15 proof repository URL across README, both proof docs, and the public checker.
5. Any mismatch is accumulated and printed with observed and expected values; the checker exits non-zero.
6. If deterministic checks pass, private mode exits without network access; public mode continues to existing anonymous URL checks.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A noncanonical version variable is presented as release truth | Spoofing | Read the existing `AGTOOSA_VERSION` assignment from `agtoosa.sh` only. |
| The gate rewrites documentation while checking it | Tampering | Read-only implementation and fixture assertion that source hashes do not change. |
| A failure omits which source drifted | Repudiation | Report file, observed value, and expected value/target. |
| Public URL checks leak credentials | Information Disclosure | Use anonymous URLs only; private mode performs no network calls. |
| Network outages block deterministic release checks | Denial of Service | Keep network checks behind explicit public mode after local checks. |
| Crafted markdown causes arbitrary command execution | Elevation of Privilege | Parse text and resolve paths; never evaluate extracted shell or URL content. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)
Files in scope      : `scripts/check-launch-readiness.sh`, `docs/examples/first-15-minutes.md`, `docs/examples/public-launch-proof.md`, `README.md`, `tests/agtoosa.bats`
Directories in scope: `scripts/`, `docs/examples/`, `tests/`
Out of scope        : new onboarding docs, automatic rewrites, browser tests, hosted monitoring, unrelated release documentation

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Fixture-based RED coverage
  - [ ] 1.1 Add stale-version and actionable-error fixtures — _Requirements: AC-001, AC-004_
  - [ ] 1.2 Add missing-relative-link and inconsistent-proof-URL fixtures — _Requirements: AC-002, AC-003, AC-004_
  - [ ] 1.3 Add private no-network and source-unchanged assertions — _Requirements: AC-005, AC-006_
- [ ] **2.** Deterministic maintenance checks
  - [ ] 2.1 Derive the canonical release tag and validate scoped pins — _Requirements: AC-001, AC-004_
  - [ ] 2.2 Resolve relative links and compare proof repository URLs — _Requirements: AC-002, AC-003, AC-004_
  - [ ] 2.3 Preserve private/public mode ordering and read-only behavior — _Requirements: AC-005, AC-006_
- [ ] **3.** Repair current drift only
  - [ ] 3.1 Align scoped first-15 and public-proof pins with the canonical release — _Requirements: AC-001_
  - [ ] 3.2 Align proof links without changing onboarding steps — _Requirements: AC-002, AC-003, AC-006_
- [ ] **4.** Evidence
  - [ ] 4.1 Run focused F15 checks and record RED/GREEN evidence — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2, 2.3  
**Wave 3 (sequential after Wave 2):** 3.1, 3.2  
**Wave 4 (sequential after Wave 3):** 4.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-078.md`
AC coverage: 6 ACs mapped to 8 F15 test IDs
Smoke set: 3 tests tagged `@smoke`
