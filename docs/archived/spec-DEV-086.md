# Spec: DEV-086 — Chore: Canonical Proof Product Experience

> **Story ID:** DEV-086
> **Type:** Chore
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** 🟩 Built
> **Estimate:** S
> **Priority:** P0
> **Spec created:** 2026-07-12
> **Extends:** DEV-039, DEV-041, DEV-078

## Context

DEV-039 shipped the first-15-minutes walkthrough; DEV-041 proved public launch surfaces; DEV-078 added a deterministic maintenance gate for release pins and proof links. Rev4 positions one canonical proof journey as the primary product experience. README still presents multiple competing install CTAs, the walkthrough does not end on a verifier success condition, and there is no golden fixture suite that locks the proof narrative against drift. Binding conflict resolutions in `docs/updates/rev4-conflict-resolutions.md` require one canonical proof-repository URL across README, walkthrough, and checker surfaces.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make the canonical 15-minute proof journey the single primary README experience with a verifier success step and fixture-backed drift detection. |
| User outcome | A new visitor follows one CTA, completes install → proof repo → init → spec → build → verify, and sees passing verification without hunting alternate paths. |
| Success condition | README has one primary proof CTA; first-15 documentation includes an explicit verify step and success condition; `tests/fixtures/proof-journey/` golden fixtures pass; `check-launch-readiness` extends DEV-078 checks to proof-journey surfaces. |
| Proof / evidence | PRF bats against golden fixtures; extended F15/launch-readiness checks; unchanged fixtures pass after repair. |
| Non-goals | New proof repository creation, video production, browser automation, automatic doc rewrites, or replacing public-mode URL checks. |
| Assumptions | `AGTOOSA_VERSION` in `agtoosa.sh` remains canonical; existing proof repo URL from DEV-041/078 stays authoritative unless intentionally updated with checker alignment. |
| Risks | Over-narrowing README hides valid install paths; golden fixtures become brittle on intentional copy changes; maintenance gate flags historical changelog text. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** first-time visitor, **I want** one obvious proof CTA in the README **so that** I understand how to see AgToosa value in 15 minutes.

**As a** release maintainer, **I want** golden proof-journey fixtures and an extended launch gate **so that** proof documentation drift is caught before users copy stale commands.

**As a** documentation contributor, **I want** the walkthrough to end on `agtoosa verify` passing **so that** success is measurable, not implied.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN README is read THE SYSTEM SHALL present exactly one primary proof CTA above the fold that routes to the canonical proof journey (`install → open proof repo → init → spec → build → verify`) and SHALL demote alternate install paths to secondary sections without competing primary buttons | Must |
| AC-002 | WHEN `docs/examples/first-15-minutes.md` is followed THE SYSTEM SHALL include an explicit final step that runs the repo-local verifier (`bash Docs/agtoosa-verify.sh` or `agtoosa.sh --verify`) and states that exit code `0` is the success condition | Must |
| AC-003 | WHEN golden fixtures under `tests/fixtures/proof-journey/` are exercised THE SYSTEM SHALL assert expected command sequence markers, artifact names (spec, test plan, review, ship-check), and verifier invocation without network access | Must |
| AC-004 | WHEN `scripts/check-launch-readiness.sh` runs in private mode THE SYSTEM SHALL extend DEV-078 scoped checks to proof-journey README CTA text, first-15 verify step presence, and canonical proof-repository URL consistency per `docs/updates/rev4-conflict-resolutions.md` §3 | Must |
| AC-005 | WHEN a proof-journey or maintenance check fails THE SYSTEM SHALL exit non-zero and report file, observed value, and expected value or missing target | Must |
| AC-006 | WHILE private mode is selected WHEN the extended maintenance gate runs THE SYSTEM SHALL perform no network request | Must |
| AC-007 | WHEN the maintenance gate or fixture tests run THE SYSTEM SHALL inspect files without modifying them and SHALL NOT add, replace, or reorder first-15 onboarding steps beyond the verify success step | Must |
| AC-008 | WHEN secondary install paths remain in README THE SYSTEM SHALL label them as alternatives (Homebrew, npm, clone-and-run) and SHALL NOT present them as equal primary CTAs | Should |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | README still shows three equal install heroes; visitors cannot find the proof path. |
| FM-002 | AC-002 | Walkthrough ends at ship without verifier; users assume completion without machine proof. |
| FM-003 | AC-003 | Golden fixtures missing; proof narrative drifts silently between releases. |
| FM-004 | AC-004 | Proof CTA text changes but checker still only validates DEV-078 scoped pins. |
| FM-005 | AC-005 | Gate prints generic "failed" without file/observed/expected diagnostics. |
| FM-006 | AC-006 | Private CI becomes flaky because HTTP checks run during proof maintenance. |
| FM-007 | AC-007 | Maintenance command rewrites walkthrough step order or adds onboarding steps. |

### 1.5 Out of Scope

- Recording or hosting a terminal video (separate marketing task).
- Creating a new public proof repository (use existing `sky2464/agtoosa-first-15-proof`).
- Live browser or hosted demo application testing.
- Replacing public-mode anonymous URL availability checks.
- Automatic editing of stale pins, links, or README copy.
- Changing release-version ownership away from `agtoosa.sh`.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Golden fixture command/artifact markers | CI-enforced when PRF bats run |
| Private-mode launch-readiness extension | CI-enforced when existing readiness tests run |
| Proof repository content correctness | manual / separate repository evidence |
| User completes proof in under 15 minutes | not measured by this gate |
| Video/screenshot assets | out of scope |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `tests/fixtures/proof-journey/` — golden markdown snippets and expected marker manifests for README CTA, walkthrough verify step, and artifact checklist.
- `tests/fixtures/proof-journey/expected-manifest.json` — canonical strings the checker and bats assert.

Files to change:

- `README.md` — single primary proof CTA; secondary install paths demoted and labeled.
- `docs/examples/first-15-minutes.md` — add explicit verify step and success condition; align pins with canonical release.
- `scripts/check-launch-readiness.sh` — extend DEV-078 deterministic checks for proof CTA, verify step, and canonical proof URL.
- `tests/agtoosa.bats` — PRF fixture tests and integration with extended maintenance gate.

Key interfaces:

- `check_proof_journey_consistency()` — private, read-only; accumulates actionable findings.
- PRF bats — load fixtures, invoke checker functions or grep contracts against golden files.

### 2.2 Data Flow

1. Maintainer updates README and first-15 walkthrough to single CTA + verify step.
2. Golden fixtures capture expected markers (commands, artifact filenames, proof URL).
3. PRF bats copy or reference fixtures and assert checker/grep contracts.
4. `check-launch-readiness.sh` reads `AGTOOSA_VERSION`, validates scoped pins, proof URL, README CTA marker, and verify-step presence.
5. Findings accumulate with file/observed/expected; non-zero exit on any mismatch.
6. Private mode exits without network; public mode continues existing URL checks after deterministic pass.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A noncanonical proof URL is presented as official | Spoofing | Single normalized URL compared across README, walkthrough, checker (rev4-conflict-resolutions §3). |
| Maintenance gate rewrites documentation | Tampering | Read-only checker; fixture assertion that source hashes do not change during check. |
| Failure omits which surface drifted | Repudiation | Report file, observed, and expected values (AC-005). |
| Public URL checks leak credentials | Information Disclosure | Anonymous URLs only; private mode performs no network calls. |
| Network outages block deterministic proof checks | Denial of Service | Network checks remain behind explicit public mode. |
| Crafted markdown triggers shell evaluation | Elevation of Privilege | Parse text and resolve paths; never evaluate extracted shell content. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `README.md`, `docs/examples/first-15-minutes.md`, `scripts/check-launch-readiness.sh`, `tests/fixtures/proof-journey/`, `tests/agtoosa.bats`
Directories in scope: `docs/examples/`, `scripts/`, `tests/`
Out of scope        : new proof repo, video, browser tests, automatic rewrites, unrelated release documentation

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Golden fixture RED coverage
  - [ ] 1.1 Add `tests/fixtures/proof-journey/` manifests and stale/missing negative fixtures — _Requirements: AC-003, AC-005_
  - [ ] 1.2 Add PRF bats for README CTA, verify step, and artifact markers — _Requirements: AC-001, AC-002, AC-003_
  - [ ] 1.3 Add read-only and private no-network assertions — _Requirements: AC-006, AC-007_
- [x] **2.** Proof product surfaces
  - [ ] 2.1 Restructure README with single primary proof CTA and labeled secondary paths — _Requirements: AC-001, AC-008_
  - [ ] 2.2 Add verifier success step to first-15 walkthrough — _Requirements: AC-002, AC-007_
- [x] **3.** Extended maintenance gate
  - [ ] 3.1 Extend `check-launch-readiness.sh` for proof-journey checks per rev4-conflict-resolutions — _Requirements: AC-004, AC-005, AC-006_
  - [ ] 3.2 Align scoped pins and proof links found by RED tests — _Requirements: AC-004, AC-007_
- [x] **4.** Evidence
  - [ ] 4.1 Record PRF RED/GREEN evidence in test plan — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_

### Wave Plan

### 3.2 Wave Plan detail

**Wave 1 (sequential within story — shared bats file):** 1.1 → 1.2 → 1.3
**Wave 2 (sequential after Wave 1):** 2.1, 2.2
**Wave 3 (sequential after Wave 2):** 3.1, 3.2
**Wave 4 (sequential after Wave 3):** 4.1

> Cross-story: Wave 1a fan-out allows DEV-086 · DEV-090 · DEV-105 in parallel; owned files are disjoint across stories.

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-086.md`
AC coverage: 8 ACs mapped to 9 PRF test IDs
Smoke set: 3 tests tagged `@smoke`

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `tests/fixtures/proof-journey/` | — | `tests/fixtures/proof-journey/expected-manifest.json` | 1 | `test -f tests/fixtures/proof-journey/expected-manifest.json` |
| PKG-1.2 | 1 | — | `tests/agtoosa.bats` (PRF section) | PKG-1.1 fixtures | PRF bats stubs | 2 | `bats tests/agtoosa.bats -f "DEV-086\|PRF-"` |
| PKG-1.3 | 1 | — | `tests/agtoosa.bats` (PRF integrity) | — | AC-006/007 assertions | 3 | `bats tests/agtoosa.bats -f "PRF-008\|PRF-009"` |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2 | `README.md` | Wave 1 RED | single primary CTA | 4 | `bats tests/agtoosa.bats -f "PRF-001\|PRF-002"` |
| PKG-2.2 | 2 | PKG-1.2 | `docs/examples/first-15-minutes.md` | Wave 1 RED | verify success step | 5 | `bats tests/agtoosa.bats -f "PRF-003"` |
| PKG-3.1 | 3 | PKG-2.1, PKG-2.2 | `scripts/check-launch-readiness.sh` | Wave 2 surfaces | proof-journey checks | 6 | `bats tests/agtoosa.bats -f "PRF-006\|PRF-007\|PRF-008"` |
| PKG-3.2 | 3 | PKG-3.1 | `docs/examples/first-15-minutes.md`, `README.md` (pin align only) | PKG-3.1 findings | pin/link alignment | 7 | `bash scripts/check-launch-readiness.sh --mode private` |
| PKG-4.1 | 4 | PKG-3.2 | `docs/AgToosa_TestPlan-DEV-086.md` | GREEN bats | RED/GREEN evidence | 8 | `grep -q GREEN docs/AgToosa_TestPlan-DEV-086.md` |

> Wave 1 note: PKG-1.2 and PKG-1.3 both touch `tests/agtoosa.bats` — run **sequentially within Wave 1** (1.2 then 1.3) despite same wave label; do not parallel-edit the bats file.

## ✅ Spec Approved

Approved: 2026-07-12 09:00
Enrollment: Rev4 Wave 1 — canonical proof product experience
