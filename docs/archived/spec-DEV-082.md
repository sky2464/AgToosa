# Spec: DEV-082 — High-Assurance Signature Mode Validation

> **Story ID:** DEV-082
> **Epic:** DEV-003 — Community Template Registry
> **Type:** Spike
> **Priority:** P2
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11
> **Prerequisite:** DEV-054 — Signed Registry Provenance (shipped v5.3.5)

## Context

DEV-054 established optional minisign verification that warns and continues when signature verification cannot complete, while SHA-256 and registry verification rules remain authoritative. A fail-closed mode would create a materially different availability, trust-anchor, key-operations, and recovery contract.

DEV-082 validates demand and operational feasibility before any `AGTOOSA_REQUIRE_SIGNATURES` behavior is designed or implemented. The spike may use synthetic tabletop or disposable observations, but it does not change defaults, add a flag or environment variable, provision production keys, or claim high-assurance mode exists.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Decide whether a fail-closed signature mode is justified and operationally supportable by validating demand, key lifecycle operations, compatibility, failure behavior, and rollback. |
| User outcome | High-assurance users receive an evidence-based decision and explicit operational prerequisites before AgToosa risks blocking installs or updates on signature failures. |
| Success condition | Demand criteria, trust model, key-operations runbook, failure matrix, migration analysis, rollback exercise, and adopt/defer/reject decision are complete without production implementation. |
| Proof / evidence | Required before spike closure: source-cited demand records, synthetic key-lifecycle observations, failure-tabletop results, rollback timing/steps, and reviewed decision rationale. No evidence has been collected. |
| Non-goals | Implementing `AGTOOSA_REQUIRE_SIGNATURES`, changing soft-warn defaults, automating production private keys, or implementing any parked roadmap item in §1.4. |
| Assumptions | DEV-054/ADR-011 remains the current contract; minisign is the primary evaluated algorithm; SHA-256 and verified-pack gates remain separate controls. |
| Risks | Fail-closed behavior can cause lockout or denial of service; weak key operations can reduce trust; synthetic demand can be overstated; rollback can become an undocumented bypass. |
| Unresolved questions | Enrollment must identify representative high-assurance users and an authorized security reviewer; absent those inputs, the decision cannot be “adopt.” |

### 1.2 User Stories

**As a** high-assurance adopter, **I want** signature failures to block only under a documented and operable policy **so that** stronger provenance does not create an unrecoverable install path.

**As a** release or registry maintainer, **I want** generation, custody, rotation, revocation, recovery, and audit duties mapped before fail-closed enforcement **so that** the trust anchor can be operated safely.

**As an** AgToosa maintainer, **I want** a demand and rollback gate before implementation **so that** an environment variable is not added for a hypothetical use case.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN demand is evaluated THE SYSTEM SHALL record representative high-assurance scenarios, current workaround, required protected surfaces, blocking semantics, adoption constraints, and evidence source, then apply predefined adopt/defer/reject criteria | Must |
| AC-002 | WHEN the proposed mode is described THE SYSTEM SHALL distinguish SHA-256 integrity, registry review status, DEV-054 optional soft-warn verification, and proposed fail-closed signature policy for registry packs and release assets | Must |
| AC-003 | WHEN key operations are validated THE SYSTEM SHALL cover authorized generation, offline custody, signer separation, public-key distribution, rotation, revocation, expiry, recovery, audit, and private-key nonretention using synthetic material only | Must |
| AC-004 | WHEN failure behavior is evaluated THE SYSTEM SHALL define expected fail-closed outcomes for absent, unreadable, invalid, stale, or revoked signatures/keys; unavailable verifier tooling; offline operation; cache use; and interrupted rotation | Must |
| AC-005 | WHEN compatibility is evaluated THE SYSTEM SHALL classify existing unsigned and soft-warn-signed artifacts and define an opt-in migration path that does not silently change default behavior | Must |
| AC-006 | WHEN rollback is exercised THE SYSTEM SHALL document authorization, break-glass entry, trusted recovery material, audit record, restoration steps, and a testable return to the prior safe default without treating bypass as normal operation | Must |
| AC-007 | WHEN the spike concludes THE SYSTEM SHALL issue an adopt, defer, or reject decision with prerequisites and SHALL NOT add or wire `AGTOOSA_REQUIRE_SIGNATURES` before a separate implementation spec is approved | Must |
| AC-008 | WHEN findings are published THE SYSTEM SHALL label observed, tabletop, assumed, and untested statements and SHALL NOT claim production key operations or fail-closed enforcement exist | Must |

**Failure modes:**

| AC | Failure mode | Required response |
|----|--------------|-------------------|
| AC-001 | Demand consists only of maintainer preference or hypothetical personas | Defer; do not treat it as an adoption signal. |
| AC-002 | Signature verification is described as replacing SHA-256 or registry review | Correct the layered trust model before deciding. |
| AC-003 | A real private key is committed, logged, or retained in spike artifacts | Stop the exercise, remove/expose through the incident process, and invalidate the result. |
| AC-004 | Missing verifier tooling has no defined result | Mark fail-closed behavior operationally incomplete. |
| AC-005 | Existing unsigned installs would begin failing by default | Reject that migration design. |
| AC-006 | Recovery depends on the same unavailable key or channel | Treat rollback as unproven and block an adopt decision. |
| AC-007 | Implementation starts before decision and approval | Stop and move implementation to a separate approved story. |
| AC-008 | A tabletop outcome is reported as production proof | Correct the claim and confidence level. |

### 1.4 Out of Scope

- Any SaaS or hosted control plane
- SSO or RBAC
- An MCP runtime
- An autonomous build runtime
- A federated registry
- A marketplace
- Silent telemetry or automatic security-event reporting
- A Go or Rust rewrite
- Implementing or wiring `AGTOOSA_REQUIRE_SIGNATURES`
- Changing the current DEV-054 optional soft-warn default
- Production key generation, custody, signing, rotation, revocation, or recovery
- Committing private keys or production trust material
- Implementing cosign/Sigstore, hardware-security-module integration, PKI, or certificate services
- Claiming compliance certification or a high-assurance SLA

The parked roadmap and implementation items above are exclusions, not DEV-082 subtasks.

### 1.5 Claim Boundary

| Surface or claim | Classification | Boundary |
|------------------|----------------|----------|
| DEV-054 optional minisign soft-warn | Existing product behavior | Continues unchanged throughout the spike. |
| Proposed fail-closed policy | Roadmap / validation only | No flag, environment variable, exit behavior, or enforcement exists from this story. |
| Demand records | Manual research evidence | Valid only for documented sources and scenarios; not equivalent to market-wide demand. |
| Key-operation observations | Synthetic/tabletop | Use disposable non-production material; no production readiness claim. |
| Rollback runbook | Proposed manual control | Unimplemented until a separate approved story proves it. |
| Adopt/defer/reject decision | Human-reviewed planning decision | “Adopt” authorizes writing a future proposal, not shipping functionality. |

## 2. Design

### 2.1 Architecture Blueprint

Future spike artifacts:

| Surface | Responsibility |
|---------|----------------|
| `docs/spikes/DEV-082/demand.md` | Representative scenarios, evidence sources, constraints, and decision thresholds |
| `docs/spikes/DEV-082/trust-model.md` | Integrity, review, soft-warn, and proposed fail-closed layer boundaries across both protected surfaces |
| `docs/spikes/DEV-082/key-operations.md` | Synthetic lifecycle roles, custody, distribution, rotation, revocation, recovery, and audit observations |
| `docs/spikes/DEV-082/failure-matrix.md` | Expected outcomes and recovery prerequisites for signature, key, tool, network, cache, and rotation failures |
| `docs/spikes/DEV-082/rollback-runbook.md` | Break-glass authorization and restoration tabletop |
| `docs/spikes/DEV-082/decision.md` | Adopt/defer/reject result, confidence, prerequisites, and follow-on trigger |
| Ephemeral isolated directory outside the repository | Disposable synthetic key material; destroyed after observation |

Key interfaces:

- Current baseline: DEV-054 and ADR-011 optional minisign soft-warn behavior.
- Proposed policy input: protected surface, trust anchor, verification result, operational state, and explicitly selected mode.
- Decision output: outcome, evidence links, prerequisites, rejected alternatives, rollback viability, and confidence.

### 2.2 Data Flow

1. Record the current layered trust baseline and predefined demand/operability decision criteria.
2. Gather representative demand records without collecting silent usage data.
3. Model registry-pack and release-asset behavior under each relevant signature, key, verifier, network, and cache state.
4. Exercise the key lifecycle with disposable synthetic material outside the repository; retain observations, never private keys.
5. Classify migration impact for unsigned, validly signed, and soft-warn-failing existing artifacts.
6. Conduct an authorized rollback tabletop and identify independent trusted recovery material.
7. Review demand, security, availability, maintenance burden, migration, and rollback evidence.
8. Issue adopt, defer, or reject; an adopt outcome produces only a separately scoped proposal.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| An attacker substitutes a public key or signer identity | Spoofing | Require authenticated trust-anchor distribution and signer-role separation in the evaluated design. |
| Signature, trust anchor, or rollback record is altered | Tampering | Model immutable provenance and auditable, reviewed changes. |
| A signer or operator denies a key action | Repudiation | Require key-operation and break-glass audit records with actor, time, artifact, and reason. |
| Private key or sensitive recovery material leaks | Information Disclosure | Use synthetic disposable keys only; never commit or quote private material. |
| Missing tool, key service, or rotated key blocks all installs | Denial of Service | Evaluate explicit failure matrix, offline policy, staged migration, and independent rollback path. |
| Break-glass path disables policy without authorization | Elevation of Privilege | Require least-privilege authorization, dual review where appropriate, bounded duration, and post-event restoration. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : future DEV-082 demand, trust-model, key-operations, failure-matrix, rollback, and decision records
Directories in scope: `docs/spikes/DEV-082/` and an ephemeral external directory for disposable synthetic material
Production changes  : none
Out of scope        : all §1.4 exclusions, changes to `lib/provenance.sh`, registry/bootstrap behavior, defaults, environment variables, release keys, and shipped trust anchors

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Define baseline and decision gates
  - [ ] 1.1 Document the current layered trust model for both protected surfaces — _Requirements: AC-002_
  - [ ] 1.2 Define demand, operability, security, and rollback criteria before gathering findings — _Requirements: AC-001, AC-007, AC-008_
- [ ] **2.** Gather validation inputs
  - [ ] 2.1 Record representative demand scenarios and constraints without telemetry — _Requirements: AC-001, AC-008_
  - [ ] 2.2 Exercise synthetic key lifecycle roles and operations outside the repository — _Requirements: AC-003, AC-008_
  - [ ] 2.3 Complete the signature/key/tool/network/cache/rotation failure matrix — _Requirements: AC-004_
  - [ ] 2.4 Classify existing artifact compatibility and opt-in migration paths — _Requirements: AC-005_
- [ ] **3.** Validate recovery and decide
  - [ ] 3.1 Conduct and record the authorized rollback/break-glass tabletop — _Requirements: AC-006, AC-008_
  - [ ] 3.2 Review demand, key operations, availability, migration, and rollback findings — _Requirements: AC-001, AC-003, AC-004, AC-005, AC-006_
  - [ ] 3.3 Issue the adopt/defer/reject decision with confidence and prerequisites — _Requirements: AC-007, AC-008_
- [ ] **4.** Preserve the pre-implementation gate
  - [ ] 4.1 If adopted, draft a separate future implementation proposal without changing production behavior — _Requirements: AC-007_
  - [ ] 4.2 Confirm no `AGTOOSA_REQUIRE_SIGNATURES` implementation, production key material, or shipped claim entered the spike — _Requirements: AC-003, AC-007, AC-008_

### 3.2 Wave Plan

**Wave 1 (sequential foundation):** 1.1, then 1.2  
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 2.3, 2.4  
**Wave 3 (sequential after Wave 2):** 3.1, then 3.2  
**Wave 4 (sequential after Wave 3):** 3.3, 4.1, 4.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-082.md`
AC coverage: 8 ACs mapped to 9 planned HSV test IDs
Smoke set: 4 planned tests tagged `@smoke`
Evidence state: RED and GREEN are unexecuted placeholders; no signature-mode evidence is claimed.
