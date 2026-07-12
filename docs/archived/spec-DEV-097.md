# Spec: DEV-097 — Docs: Framework Supply-Chain Threat Model

> **Story ID:** DEV-097
> **Type:** Docs
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** 🏁 Shipped (v5.3.16)
> **Estimate:** S
> **Priority:** P1
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

`docs/security/template-injection-threat-model.md` covers community pack tarball injection (DEV-064/065 mitigations). AgToosa's supply-chain surface is broader: pinned `bootstrap.sh` / `agtoosa.sh` install chain, catalog/registry metadata, maintainer release artifacts, minisign sidecars (DEV-054), template generator outputs, and maintainer CI that publishes versions.

DEV-097 extends `docs/security/` with a **framework-level** supply-chain threat model STRIDE analysis, explicit claim boundaries, and cross-links to existing mitigations — without duplicating the pack-injection doc wholesale.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Document AgToosa framework supply-chain threats beyond community pack injection. |
| User outcome | Maintainers and security reviewers understand install-chain, release, registry, and generator risks with honest mitigation status. |
| Success condition | New `docs/security/framework-supply-chain-threat-model.md` ships with STRIDE table, attack surfaces, mitigations, residual risks, and cross-links; README index updated; FST bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-097.md`; FST-001–FST-006 bats; security doc review checklist. |
| Non-goals | New runtime enforcement; fail-closed signing; replacing pack-injection doc; cosign/SLSA certification claims. |
| Assumptions | Existing mitigations (SHA-256, tar-slip scan, minisign soft-warn) remain accurately described; docs-only story. |
| Risks | Doc overclaims enforcement; stale mitigation status; overlap/conflict with pack-injection doc. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** security reviewer, **I want** a framework supply-chain threat model **so that** I can assess AgToosa beyond pack tarball content.

**As a** maintainer, **I want** cross-linked security docs **so that** pack injection and install-chain risks stay separated but discoverable.

**As an** adopter, **I want** honest residual-risk language **so that** I know what pinned installs and signatures do not guarantee.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `docs/security/framework-supply-chain-threat-model.md` is published THE SYSTEM SHALL document attack surfaces for pinned install chain, release artifacts, catalog/registry metadata, generator template outputs, and maintainer CI publish path | Must |
| AC-002 | WHEN threats are listed THE SYSTEM SHALL use STRIDE categories and map each to existing mitigations, partial mitigations, or accepted residual risk | Must |
| AC-003 | WHEN pack tarball injection is in scope THE SYSTEM SHALL cross-link `template-injection-threat-model.md` and SHALL NOT duplicate its full attack-vector catalog | Must |
| AC-004 | WHEN signing is discussed THE SYSTEM SHALL describe DEV-054 minisign as optional soft-warn and SHALL NOT claim fail-closed or cosign enforcement | Must |
| AC-005 | WHEN `docs/security/README.md` is updated THE SYSTEM SHALL index both threat models with one-line scope summaries | Must |
| AC-006 | WHEN shipping THE SYSTEM SHALL record FST bats evidence and a manual security-doc review pointer | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-004 | Doc claims unsigned installs are blocked. |
| FM-002 | AC-003 | Two divergent pack injection narratives. |
| FM-003 | AC-002 | Threat listed with no mitigation or residual-risk label. |
| FM-004 | AC-001 | Omits bootstrap curl pipe risk surface. |
| FM-005 | AC-005 | Security README still pack-only index. |

### 1.5 Out of Scope

- Implementing new generator enforcement
- DEV-054 fail-closed mode
- Pack content sanitization engine
- Hosted vulnerability database
- Replacing or shrinking pack-injection doc

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Framework threat model doc | manual / documentation |
| SHA-256 pack verify | generator-enforced (existing) |
| Tar-slip pre-scan | generator-enforced (existing) |
| Minisign verify | optional soft-warn (DEV-054) |
| Pinned `--ref` install | user/manual policy |
| Deterministic enforcement of doc mitigations | only where already implemented — no new claims |

## 2. Design

### 2.1 Architecture Blueprint

Files to create/change:

- `docs/security/framework-supply-chain-threat-model.md` — new canonical doc
- `docs/security/README.md` — index both models
- `docs/security/template-injection-threat-model.md` — additive cross-link back to framework doc
- `tests/agtoosa.bats` — FST documentation contract tests

No template/Docs copy required unless security index is installed to projects (out of scope — maintainer docs only).

### 2.2 Data Flow

Documentation-only. Readers: security reviewers → README index → framework model → pack injection deep-dive.

### 2.3 Threat Model (STRIDE) — meta

| Threat | Category | Mitigation |
|--------|----------|------------|
| Security doc overclaims enforcement | Spoofing | FST bats on forbidden phrases; claim boundary table |
| Doc drift from implemented behavior | Tampering | Cross-link to ADR-011, DEV-054, registry code paths |
| Reviewer cannot find pack vs framework scope | Information Disclosure | README index with scope lines |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `docs/security/framework-supply-chain-threat-model.md`, `docs/security/README.md`, cross-link line in pack doc, FST bats
Out of scope        : generator changes, new signing modes, Master-Plan edits

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED doc contract tests
  - [x] 1.1 FST bats for required sections and cross-links — _Requirements: AC-001, AC-003, AC-005_
  - [x] 1.2 Forbidden enforcement claim grep — _Requirements: AC-004_
- [x] **2.** Author threat model
  - [x] 2.1 Write framework STRIDE doc with surfaces and residual risks — _Requirements: AC-001, AC-002_
  - [x] 2.2 Update README index and pack doc cross-link — _Requirements: AC-003, AC-005_
- [x] **3.** Evidence
  - [x] 3.1 FST GREEN + security review pointer — _Requirements: AC-006_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential):** 2.1 → 2.2 → 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-097.md`
AC coverage: 6 ACs mapped to 6 planned FST test IDs
Smoke set: 3 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes (documentation contracts)
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12 09:56
Enrollment: Rev4 Wave 2 Active Cycle (2026-07-12) — parallel with DEV-092 · DEV-094 after Wave 1a ship
