# Spec: DEV-089 — Feature: Evidence-Profile Verifier Gates

> **Story ID:** DEV-089
> **Type:** Feature
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** 🟦 Todo — Rev4 Wave 2 (approved)
> **Estimate:** M
> **Priority:** P1
> **Depends on:** DEV-087 (delivery evidence profiles), DEV-061 (verifier foundation)
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

DEV-059 added optional governance policy as verifier **Gate 6** (WARN on invalid present policy; missing policy is never a finding). DEV-087 introduces `.agtoosa/evidence.yml` delivery evidence profiles and `Docs/AgToosa_Delivery_Evidence_Contract.md` with guided/evidenced/enforced labels. DEV-061 established the deterministic verifier and lifecycle gates.

The remaining gap is a **Gate 7** that validates profile-selected evidence artifacts without pretending semantic review or SAST output equals deterministic security enforcement. DEV-049 shipped the evidence ledger as agent-instructed; this story adds an optional **WARN** when a profile requires ledger rows that are absent at review/ship time.

Per `docs/updates/rev4-conflict-resolutions.md`, verifier gate order is: policy (Gate 6) → evidence profile (Gate 7) → lifecycle gates.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Add verifier Gate 7 for optional delivery evidence profiles with honest guided/evidenced/enforced classification and ledger WARN integration. |
| User outcome | Teams opt into a profile and receive deterministic presence/outcome checks for required evidence without false SAST or semantic-security claims. |
| Success condition | Gate 7 runs after Gate 6; absent `evidence.yml` is healthy; invalid profile WARNs; profile-required artifacts checked deterministically; missing ledger WARNs per DEV-049 boundary; EPV bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-089.md`; EPV-001–EPV-009 bats; verifier self-run on maintainer repo with and without profiles. |
| Non-goals | LLM semantic review; claiming SAST/dependency-scan exit codes prove vulnerability absence; FAIL on missing optional profile; hosted evidence service; merging DEV-087 doc into this story. |
| Assumptions | DEV-087 ships profile schema and contract doc; DEV-061 verifier remains bash-only and network-free; profiles are opt-in. |
| Risks | Over-enforcement drives false FAILs; SAST wording overclaims; Gate order regression breaks DEV-059 behavior. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** security-conscious maintainer, **I want** verifier Gate 7 to check my selected evidence profile **so that** release gaps are caught before ship without pretending agents ran SAST.

**As a** release engineer, **I want** missing optional ledger files to WARN rather than block **so that** DEV-049 agent-instructed boundaries stay honest while profiles nudge completeness.

**As an** AgToosa maintainer, **I want** Gate 7 bats and fixtures **so that** profile opt-in, WARN semantics, and no-false-SAST-claims language cannot regress.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `docs/agtoosa-verify.sh` runs THE SYSTEM SHALL execute Gate 6 before Gate 7 and Gate 7 before lifecycle story/spec gates | Must |
| AC-002 | WHEN no `.agtoosa/evidence.yml` is present THE SYSTEM SHALL report Gate 7 as healthy with an explicit no-profile result and SHALL NOT emit a finding | Must |
| AC-003 | WHEN `.agtoosa/evidence.yml` is present and valid THE SYSTEM SHALL resolve the selected profile and check each `required` entry using only deterministic presence, path, and documented command exit-code rules from `AgToosa_Delivery_Evidence_Contract.md` | Must |
| AC-004 | WHEN a profile entry is classified `enforced` THE SYSTEM SHALL require a wired local or CI command with a recorded exit code; WHEN classified `guided` or `evidenced` THE SYSTEM SHALL NOT upgrade it to enforced without an implemented checker | Must |
| AC-005 | WHEN a profile references SAST, dependency-scan, or similar security tooling THE SYSTEM SHALL verify artifact presence and command exit code only and SHALL NOT claim vulnerability absence, coverage completeness, or deterministic security posture | Must |
| AC-006 | WHEN a profile requires `review` or ship-phase ledger rows and `docs/archived/evidence-[story-id].md` is absent for an active Done-boundary story THE SYSTEM SHALL emit a Gate 7 WARN referencing DEV-049 agent-instructed classification | Must |
| AC-007 | WHEN `.agtoosa/evidence.yml` is present but invalid THE SYSTEM SHALL emit Gate 7 WARN with bounded diagnostics and SHALL NOT treat a missing file as invalid | Must |
| AC-008 | WHEN verifier strict mode is enabled THE SYSTEM SHALL promote Gate 7 WARN findings to FAIL consistent with existing strict semantics | Should |
| AC-009 | WHEN shipping THE SYSTEM SHALL record EPV bats RED/GREEN evidence without claiming hosted audit or CI-mandatory profiles | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Gate 7 runs before policy check, breaking DEV-059 contract. |
| FM-002 | AC-002 | Missing profile blocks install or fails verification. |
| FM-003 | AC-004 | Guided STRIDE prose treated as enforced security control. |
| FM-004 | AC-005 | Verifier output states "SAST clean" or "no vulnerabilities." |
| FM-005 | AC-006 | Missing ledger FAILs verification despite DEV-049 boundary. |
| FM-006 | AC-007 | Invalid YAML crashes verifier instead of WARN. |
| FM-007 | AC-003 | Profile checks perform network calls or invoke LLMs. |

### 1.5 Out of Scope

- Authoring DEV-087 contract doc or base `evidence.yml` schema (DEV-087)
- Replacing lifecycle gates (spec approval, EARS, threat model, TDD evidence)
- Mandatory evidence profiles for all projects
- Hosted evidence collection or SaaS audit log
- Semantic correctness of review findings or spec content
- FAIL-closed ledger enforcement (roadmap beyond WARN)

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Gate 7 profile resolution and deterministic checks | generator-enforced when verifier runs |
| Optional profile file | manual / opt-in |
| Missing profile | healthy — no finding |
| Invalid profile | WARN (FAIL in strict mode) |
| Missing evidence ledger per profile | WARN — agent-instructed (DEV-049) |
| SAST/scan artifact presence + exit code | evidenced / enforced per profile row only |
| Vulnerability absence or security guarantee | not claimed — explicit non-goal |
| Semantic review quality | guided — not verifier-enforced |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `template/Docs/agtoosa-verify.sh` — add Gate 7 block after Gate 6; profile resolver; deterministic artifact checks; ledger WARN hook
- `docs/agtoosa-verify.sh` — maintainer mirror
- `template/Docs/AgToosa_Delivery_Evidence_Contract.md` — cross-link Gate 7 semantics (owned by DEV-087; this story wires checks only)
- `template/.agtoosa/README.md` — document `evidence.yml` opt-in and Gate 7 behavior (DEV-087 index extended)
- `tests/agtoosa.bats` — EPV fixture tests
- `tests/fixtures/evidence-profile/` — valid, invalid, security-sensitive, and no-profile fixtures

No new CLI command. Gate 7 is invoked only through existing `agtoosa.sh --verify` / `docs/agtoosa-verify.sh` paths.

### 2.2 Data Flow

1. Verifier completes Gates 1–6 unchanged.
2. Gate 7 resolves `.agtoosa/evidence.yml` from project root; if absent → pass with `no evidence profile configured`.
3. If present, parse YAML subset: `profiles`, active profile name, `required` list with `id`, `kind`, `classification`, optional `path_glob`, optional `command`.
4. For each required entry, run deterministic check per contract: file exists, archived path matches story, or command exit code recorded in test plan / ledger pointer.
5. Security-tool rows verify stdout/log artifact exists and last recorded exit code only; emit classification label in finding text.
6. If profile requires ledger and `evidence-*.md` missing for active story → WARN with DEV-049 citation.
7. Accumulate WARN/FAIL; print Gate 7 summary; continue to lifecycle gates.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Crafted `evidence.yml` executes arbitrary shell via `command` field | Elevation of Privilege | Allowlist command prefixes; never eval YAML values; fixture tests for injection |
| Verifier claims SAST PASS means secure | Spoofing | AC-005 explicit wording ban; EPV negative fixtures on output text |
| Missing profile interpreted as waiver of all evidence | Repudiation | Gate 7 labels opt-in; contract doc states default lifecycle gates still apply |
| Profile paths leak secrets into verifier output | Information Disclosure | Print rule id and path basename only on failure |
| Invalid profile crashes verifier | Denial of Service | Bounded parse; WARN not abort |
| Gate order swap bypasses policy | Tampering | EPV-001 asserts Gate 6 before Gate 7 in output order |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `template/Docs/agtoosa-verify.sh`, `docs/agtoosa-verify.sh`, evidence-profile fixtures, EPV bats
Directories in scope: `template/.agtoosa/`, `tests/fixtures/evidence-profile/`, `tests/`
Depends on          : DEV-087 (schema + contract), DEV-061 (verifier), DEV-049 (ledger WARN semantics)
Out of scope        : DEV-087 authorship, hosted evidence, semantic SAST, mandatory profiles, Master-Plan enrollment edits

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Fixture-based RED coverage
  - [ ] 1.1 Add no-profile healthy and gate-order fixtures — _Requirements: AC-001, AC-002_
  - [ ] 1.2 Add valid profile presence checks and invalid-YAML WARN fixtures — _Requirements: AC-003, AC-007_
  - [ ] 1.3 Add SAST no-false-claim and ledger WARN fixtures — _Requirements: AC-005, AC-006_
- [ ] **2.** Implement Gate 7
  - [ ] 2.1 Insert Gate 7 after Gate 6 with profile resolver — _Requirements: AC-001, AC-002, AC-007_
  - [ ] 2.2 Wire deterministic required-entry checks per contract classifications — _Requirements: AC-003, AC-004_
  - [ ] 2.3 Add ledger WARN integration and strict-mode promotion — _Requirements: AC-006, AC-008_
- [ ] **3.** Sync mirrors and contract cross-links
  - [ ] 3.1 Mirror verifier to maintainer `docs/` and update `.agtoosa/README.md` index — _Requirements: AC-002, AC-005_
- [ ] **4.** Evidence
  - [ ] 4.1 Record EPV RED/GREEN in test plan — _Requirements: AC-009_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3
**Wave 2 (sequential after Wave 1):** 2.1, 2.2, 2.3
**Wave 3 (sequential after Wave 2):** 3.1, 4.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-089.md`
AC coverage: 9 ACs mapped to 9 planned EPV test IDs
Smoke set: 4 tests tagged `@smoke`
Evidence state: RED/GREEN unexecuted — spec promotion only

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none
- Dependency stories documented: DEV-087, DEV-061, DEV-049

## ✅ Spec Approved

Approved: 2026-07-12 09:56
Enrollment: Rev4 Wave 2 (DEV-004 delivery evidence enforcement)
