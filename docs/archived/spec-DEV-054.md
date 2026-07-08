# Spec: DEV-054 — Signed Registry Provenance

> **Story ID:** DEV-054
> **Epic:** DEV-003
> **Status:** 🏁 Shipped (v5.3.5)
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-08
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

AgToosa already ships pack integrity (SHA-256 + `verified` flag — DEV-065) and release checksums (`SHA256SUMS` — DEV-066). Cryptographic signatures on the registry index, pack tarballs, and release assets remain open. This enrollment deepens the wave placeholder into an executable contract: **schema + optional minisign verify (soft warn)** for both registry packs and release assets, without fail-closed defaults or private-key automation.

### Brownfield Spec Drift Baseline

| Field | Value |
|-------|-------|
| User outcome / proof | Users can optionally verify minisign signatures when present; docs classify enforcement honestly; bats prove soft-warn + schema without claiming fail-closed or SBOM |
| Repo evidence inventory | `lib/registry.sh` (sha256 + verified); `bootstrap.sh --sha256`; release `SHA256SUMS`; `docs/AgToosa_Registry.md`; Team Trust Roadmap; Manual/Deferred `DEV-054 M-1`; ADR-002 GPG-index deferral; stub `spec-DEV-054.md` |
| Current-state baseline | No signature fields; no minisign verify path; no bundled pubkey; M-1 keygen deferred; Roadmap states signed metadata is not a current guarantee |
| Intended change deltas | Provenance schema (packs + releases); optional soft-warn minisign verify; bundled pubkey path + `AGTOOSA_MINISIGN_PUBKEY`; docs/Readiness/Roadmap claim updates; focused bats with fixture keys; cosign documented as future alternate |
| Drift evidence | Stub meta-ACs → functional EARS; Goal Contract “SBOM / high-assurance trust levels” narrowed per interview (SBOM + require-signatures out); ADR-002 “GPG index” superseded for v1 by minisign-primary (see ADR-011) |
| Claim Boundary | Optional verify = **generator-enforced soft warn** when sig present; unsigned path unchanged (checksum + verified). Private-key generation = **manual**. Fail-closed require-signatures / cosign verify / SBOM = **roadmap**. Agent-instructed docs for human verify steps. |
| Source of truth | `docs/Master-Plan.md` remains the repo-local source of truth |

### Interview decisions (2026-07-08)

| Q | Decision |
|---|----------|
| Shape | **B** — schema + optional verify when signature artifact present; unsigned still allowed |
| Surfaces | **C** — both registry packs and release assets |
| Tooling | **C** — document minisign + cosign; implement minisign verify first |
| Present-but-invalid | **A** — soft warn only; install continues if SHA-256 + verified pass |
| Trust anchor | **B** — bundled in-repo pubkey + `AGTOOSA_MINISIGN_PUBKEY` override; missing `minisign` binary → warn and continue |
| Non-goals | **A** — no SBOM; no `AGTOOSA_REQUIRE_SIGNATURES`; M-1 keygen stays Manual/Deferred; no cosign verify in v1 |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Add signed provenance schema and optional minisign verification for registry packs and release assets. |
| User outcome | Users can distinguish unsigned (checksum + verified) installs from installs that also attempted signature verification, with clear warnings when signatures are present but unverifiable. |
| Success condition | Schema documented for both surfaces; optional soft-warn verify wired for minisign when a `.minisig` (or declared signature field) is present; bats prove warn-and-continue; claim boundaries honest. |
| Proof / evidence | Spec + ADR-011, Registry/Release/Trust docs, generator soft-warn path, SP bats, test-plan evidence. |
| Claim Boundary | Soft-warn optional verify is generator-enforced when a signature artifact is present. Unsigned installs remain valid under SHA-256 + verified. Private keys = manual (M-1). Fail-closed mode, SBOM, and cosign verify = roadmap. |
| Non-goals | SBOM generation; `AGTOOSA_REQUIRE_SIGNATURES` / fail-closed absent-sig mode; private-key generation or CI signing automation; cosign/Sigstore verify implementation; hosted attestation services; enterprise compliance claims. |
| Assumptions | AgToosa stays repo-native; SHA-256 and verified-flag gates remain authoritative for integrity and curation; community pack count may still be low (ADR-002). |
| Risks | Soft-warn under-assures users who expect fail-closed; missing pubkey or tool silently weakens optional path; overclaiming “signed provenance” as mandatory; fixture private keys leaking into docs. |
| Unresolved questions | None |

### 1.2 User Stories

**As a** pack consumer, **I want** optional minisign verification when a pack ships a signature **so that** I get an extra trust signal without breaking unsigned packs.

**As a** release consumer, **I want** the same provenance contract for release assets beside `SHA256SUMS` **so that** bootstrap/tarball trust can grow without a second mental model.

**As a** maintainer, **I want** honest claim boundaries and a Manual/Deferred keygen task **so that** we never pretend signatures exist before keys are created.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN provenance schema is documented THE SYSTEM SHALL define optional signature fields for **both** registry pack entries and release assets (algorithm, signature URL or sidecar path, pubkey id/path), with minisign as the primary algorithm and cosign named as a future alternate. | Must |
| AC-002 | WHEN a signature artifact is present during registry install or release/bootstrap verify THE SYSTEM SHALL attempt minisign verification using the bundled pubkey path or `AGTOOSA_MINISIGN_PUBKEY`, and on failure (invalid sig, unreadable sig, missing tool, missing pubkey) SHALL emit a clear warning and **continue** if SHA-256 (and verified-flag rules) still pass. | Must |
| AC-003 | WHEN no signature artifact is present THE SYSTEM SHALL leave install/bootstrap behavior unchanged (SHA-256 + verified flag / `--sha256` as today) without requiring signatures. | Must |
| AC-004 | WHEN enforcement is described THE SYSTEM SHALL classify optional soft-warn verify as generator-enforced, private-key generation as manual, and fail-closed require-signatures / SBOM / cosign verify as roadmap; Master-Plan remains the repo-local source of truth. | Must |
| AC-005 | WHEN implementation begins THE SYSTEM SHALL add focused bats (fixture pubkey + valid/invalid `.minisig`) proving soft-warn-and-continue before changing generator behavior. | Must |
| AC-006 | WHEN the template/docs pack ships THE SYSTEM SHALL update Registry, Team Trust Roadmap, Readiness (or equivalent), SECURITY/release notes as needed, and register any new pubkey/docs paths in `lib/config.sh` without claiming signed installs are mandatory. | Must |
| AC-007 | WHEN shipping THE SYSTEM SHALL record evidence without claiming SBOM, fail-closed signatures, or that M-1 keygen is complete. | Should |

### 1.4 Out of Scope

- SBOM (CycloneDX/SPDX) generation or mandatory SBOM fields
- `AGTOOSA_REQUIRE_SIGNATURES` / fail-closed when signature absent
- Generating or storing minisign/cosign **private** keys in-repo or CI (remains `DEV-054 M-1` Manual/Deferred)
- Cosign/Sigstore verify implementation (document only)
- Changing the default `verified: false` gate or SHA-256 fail-closed behavior
- Hosted attestation / Rekor / enterprise compliance certifications

### Failure modes (Must ACs)

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Schema covers only one surface → dual-contract gap |
| FM-002 | AC-002 | Invalid signature silently ignored with no warning → false assurance |
| FM-003 | AC-002 | Soft-warn path refuses install → breaks unsigned-compatible contract |
| FM-004 | AC-003 | Absent signature blocks install → accidental fail-closed |
| FM-005 | AC-004 | Docs claim mandatory signed provenance → dishonest positioning |
| FM-006 | AC-005 | Behavior change without RED bats → unverified soft-warn semantics |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:
- `docs/adr/ADR-011-minisign-primary-provenance.md` — decide minisign-primary, cosign alternate; soft-warn posture
- `docs/security/agtoosa.minisign.pub` (or `docs/security/minisign.pub`) — **placeholder or fixture public key** for verify path; real maintainer key may replace after M-1 (never commit private keys)
- `tests/fixtures/minisign/` — fixture pubkey + sample signed/unsigned artifacts for bats (test-only; no production secrets)

Files to change:
- `lib/registry.sh` — optional soft-warn minisign verify after SHA-256 when signature sidecar/field present
- `bootstrap.sh` (and `bootstrap.ps1` if parity is in-scope for warn path) — optional soft-warn when `.minisig` accompanies downloaded assets
- `docs/AgToosa_Registry.md` (+ template mirror if present) — schema fields + verify behavior
- `docs/AgToosa_Team_Trust_Roadmap.md` — update “not yet” → partial optional soft-warn; keep fail-closed/SBOM roadmap
- `docs/AgToosa_Readiness.md` / `template/Docs/AgToosa_Readiness.md` — enforcement classification row
- `SECURITY.md` (if present) — point to pubkey + soft-warn semantics
- `.github/RELEASE.md` and/or release workflow docs — how to attach `.minisig` beside `SHA256SUMS` (manual until M-1)
- `docs/adr/ADR-002-community-template-registry.md` — note ADR-011 supersedes GPG-index deferral for the chosen primary algorithm (index signing still optional/roadmap for fail-closed)
- `lib/config.sh` — register pubkey/docs paths if shipped to installs
- `tests/agtoosa.bats` — SP-001+ soft-warn contract tests (keep existing CW-017 / PS-* as adjacent)
- `docs/AgToosa_TestPlan-DEV-054.md` — map ACs to SP tests
- `docs/Master-Plan.md` — Active Cycle / tasks / Update Log

PowerShell: prefer bash-first soft-warn with PS1 parity if low-cost; if PS1 parity slips, document as Should follow-up without blocking Must ACs on bash path.

### 2.2 Data Flow

```
Registry install / bootstrap download
        │
        ├─ SHA-256 match? ──no──► FAIL (unchanged)
        │
        ├─ verified flag? ──no + no opt-in──► FAIL (unchanged)
        │
        ├─ signature artifact present?
        │         │
        │        no ──► proceed (unchanged)
        │         │
        │        yes
        │         ▼
        │   minisign available + pubkey resolvable?
        │         │
        │        no ──► WARN → proceed
        │         │
        │        yes → minisign -Vm …
        │                 │
        │            ok ──► info/ok → proceed
        │           fail ──► WARN → proceed
        ▼
   preview / extract / install (unchanged gates)
```

### 2.3 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Spoofing | Attacker publishes pack with fake `verified: true` | Unchanged: index curation + SHA-256; signatures optional extra; soft-warn does not replace verified gate |
| Tampering | Tarball modified after sign | SHA-256 still fail-closed; invalid `.minisig` → warn (user may still install — accepted risk of soft-warn posture) |
| Repudiation | No record of verify attempt | Warn/info messages; optional evidence in test plan / ship notes |
| Information Disclosure | Private key in repo/CI logs | Never commit `minisign.key`; M-1 manual; fixtures use disposable test keys only |
| Denial of Service | Malicious huge `.minisig` or hung verify | Soft-warn path should bound runtime; missing tool skips verify |
| Elevation of Privilege | Soft-warn treated as mandatory trust | Claim Boundary + Readiness language; unsigned path remains first-class |

### 2.4 Build Scope

**In scope:** files in §2.1 needed for AC-001–AC-006 on bash path; docs dual-path where Registry/Readiness/Trust are mirrored.

**Out of scope:** version bump until `/agtoosa-ship`; private key generation; fail-closed flag; SBOM tooling; cosign verify binary integration.

### Provenance schema (draft)

**Registry pack entry (optional fields):**

```json
{
  "name": "example-pack",
  "sha256": "…",
  "verified": true,
  "signature": {
    "alg": "minisign",
    "url": "https://…/pack.tar.gz.minisig",
    "pubkey_id": "agtoosa-release"
  }
}
```

**Release assets:** sidecar `asset.minisig` next to the asset (and/or next to `SHA256SUMS`); document `minisign -Vm <asset> -p docs/security/agtoosa.minisign.pub`.

**Pubkey resolution order:** `AGTOOSA_MINISIGN_PUBKEY` → bundled `docs/security/agtoosa.minisign.pub` (maintainer) / installed equivalent if registered.

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED contract bats (SP-001–SP-005) — _Requirements: AC-002, AC-003, AC-005_
- [x] **2.** Provenance schema docs + ADR-011 + Trust/Readiness/Registry claim updates — _Requirements: AC-001, AC-004, AC-006_
- [x] **3.** Optional soft-warn minisign verify in registry (+ bootstrap if in wave) — _Requirements: AC-002, AC-003_
- [x] **4.** Bundled pubkey path + config registration + fixture keys for tests — _Requirements: AC-002, AC-006_
- [x] **5.** GREEN bats + test-plan evidence; keep M-1 Manual/Deferred — _Requirements: AC-007_

### Wave Plan

**Wave 1 (parallel):** 1, 2
**Wave 2 (sequential after Wave 1):** 4, 3
**Wave 3 (sequential after Wave 2):** 5

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-054.md`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Every Must AC maps to test-plan rows: yes (see test plan)
- Claim Boundary honest (soft-warn / manual / roadmap): yes
- SoT preserved: yes
- No TBD placeholders in requirements: yes (estimate pending enrollment only)

## Story Skill Opportunity

| Skill | Decision |
|-------|----------|
| `minisign-provenance-verifier` | **Do not generate** — overlaps generator `lib/registry.sh` / bootstrap; reserved `agtoosa-*` |
| Update existing registry skill | **N/A** — no project skill for registry |

## Spec Revision Log

| Rev | Date | Change | Why | Approved |
|-----|------|--------|-----|----------|
| R0 | 2026-06-08 | Wave placeholder meta-ACs | Competitive wave backlog | backlog |
| R1 | 2026-07-08 | Deepened executable spec (shape B, dual surface, minisign soft-warn) | `/agtoosa-spec` enrollment from empty Active Cycle + P0 | approved |

## ✅ Spec Approved

Approved: 2026-07-08 18:28
