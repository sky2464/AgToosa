# Spec: DEV-020 — Registry Install Version Pinning

> **Story ID:** DEV-020
> **Epic:** DEV-003 — Community Template Registry
> **Status:** 🟦 Todo
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

The community registry documents `pack-name@version` installs (`docs/specs/v3-community-registry.md`, `docs/AgToosa_Registry.md`, ADR-002). Both `lib/registry.sh` and `agtoosa.ps1` parse the `@version` suffix into a `pack_version` variable.

Today that parsed version is not enforced on the registry install path:

- **Bash (`registry_install`)** selects the registry entry with `select(.name == $n)` only. `pack_version` is never compared to the resolved entry's `.version`. A user running `--registry install ml-pipeline@1.1.0` when the index lists `1.2.0` silently stages `1.2.0` and writes that version into `.pack-meta.json`.
- **PowerShell (`Invoke-RegistryInstall`)** detects a mismatch but only prints a warning and proceeds with the registry version — still a silent wrong-version install from the user's perspective.

This violates the registry trust model: version pinning is advertised for reproducible setups, and SHA-256 pins are per tarball version. Installing the wrong version without an explicit error is a supply-chain UX failure (wrong docs, wrong templates, false confidence in reproducibility).

The flat `registry.json` index currently has one row per pack name (ADR-002). This story enforces exact version match for `@version` installs against that row, and fails closed when no matching name+version entry exists. Multi-row indexes (same name, different versions) are supported in selection logic if the index evolves later.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make `pack-name@version` registry installs fail unless the resolved registry entry matches the requested version. |
| User outcome | A developer who pins `ml-pipeline@1.1.0` either gets exactly that version staged or a clear non-zero error — never a different version without notice. |
| Success condition | Bash and PowerShell install paths enforce version equality when `@version` is present; unpinned installs behave as today; focused bats prove match, mismatch failure, and parity. |
| Proof / evidence | `bats tests/agtoosa.bats -f "RV[1-5]:"` green; manual smoke: `ml-pipeline@wrong` exits non-zero with actionable message. |
| Non-goals | `agtoosa-lock.json` auto-pinning (deferred per ADR-002); registry index schema changes; multi-version index curation policy; changing SHA-256 or download flow. |
| Assumptions | Registry continues to expose `.version` as a semver-like string comparable with `==` string equality; offline `./local-pack` installs remain version-agnostic (`local` meta). |
| Risks | Users who relied on silent "latest" override via `@wrong` will now see errors — intentional breaking fix for documented contract. |

### 1.2 User Stories

**As a** developer installing a community pack, **I want** `agtoosa --registry install my-pack@1.0.0` to install only version `1.0.0` **so that** my project setup matches the version I audited and documented.

**As an** AgToosa maintainer, **I want** Bash and PowerShell registry installers to behave the same on version mismatch **so that** cross-platform docs and tests stay trustworthy.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the user runs `--registry install <name>@<version>` and the registry entry for `<name>` has `.version` equal to `<version>` THE SYSTEM SHALL download, verify SHA-256, and stage that entry | Must |
| AC-002 | WHEN the user runs `--registry install <name>@<version>` and no registry entry matches both name and version THE SYSTEM SHALL exit non-zero with an error naming requested version and available version(s) | Must |
| AC-003 | WHEN the user runs `--registry install <name>` without `@version` THE SYSTEM SHALL install the registry entry selected by name only (current latest-in-index behavior) | Must |
| AC-004 | WHEN PowerShell registry install receives `<name>@<version>` THE SYSTEM SHALL apply the same match-or-fail rules as Bash and SHALL NOT proceed after a version mismatch | Must |
| AC-005 | WHEN DEV-020 ships THE SYSTEM SHALL add bats coverage for version match, version mismatch failure, unpinned install, PS1 parity signal, and regression guard that `pack_version` is enforced in Bash | Must |

### 1.4 Out of Scope

- Recording installed pack versions in `Docs/agtoosa-lock.json` (separate story)
- Resolving semver ranges (`^1.0.0`, `>=1.0.0`)
- Fetching historical tarball URLs when an old version is requested but absent from the index
- Changes to `registry list`, `search`, or `info` output beyond optional version hints

## 2. Design

### 2.1 Architecture Blueprint

| Layer | Files | Change |
|-------|-------|--------|
| Bash registry install | `lib/registry.sh` (`registry_install`) | After parsing `pack_spec`, resolve entry with `name` + optional `version` filter; compare `pack_version` to resolved `.version` when set; abort before download on mismatch; show resolved version in confirmation prompt. |
| PowerShell registry install | `agtoosa.ps1` (`Invoke-RegistryInstall`) | Replace warn-and-proceed with hard failure on mismatch; align jq/selection logic with Bash (name-only vs name+version). |
| Docs | `docs/AgToosa_Registry.md`, `template/Docs/AgToosa_Registry.md` | Document fail-closed pinning; remove any implication that wrong `@version` installs anyway. |
| Tests | `tests/agtoosa.bats`, optional `tests/fixtures/registry-multi-version.json` | RV1–RV5 using cached registry fixtures and non-interactive install (stdin `Y` only when install proceeds). |

**Selection logic (jq):**

```bash
# Unpinned: .[] | select(.name == $n) | ...
# Pinned:   .[] | select(.name == $n and .version == $v) | ...
```

If pinned query returns empty, error: `Pack 'foo' version '1.0.0' not found (registry has 1.2.0 for this name).`

### 2.2 Data Flow

1. User runs `bash agtoosa.sh --registry install ml-pipeline@1.1.0`.
2. `registry_install` parses `pack_name=ml-pipeline`, `pack_version=1.1.0`.
3. Cached `registry.json` loads; jq selects entry where `name` and `version` match.
4. If no row matches → stderr message, exit `1` (no download).
5. If match → show `Installing: ml-pipeline v1.1.0`, confirm, download URL from entry, verify SHA-256, stage to `ship/packs/ml-pipeline/`, write `.pack-meta.json` with requested version.
6. PS1 path mirrors steps 2–5.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| User believes they pinned v1.1.0 but receives v1.2.0 templates | Spoofing / Tampering | AC-001, AC-002 fail closed before download |
| Attacker tricks user into installing "latest" while docs say pinned | Repudiation | Error messages include requested vs available version; `.pack-meta.json` matches resolved entry |
| Silent cross-version install bypasses SHA pin intent | Information Disclosure | SHA is per URL/version; wrong version = wrong hash expectation; enforcement keeps pin meaningful |
| Registry install denied when old version removed from index | Denial of Service | Explicit error tells user to drop `@version` or pick listed version — acceptable for curated index |
| PS1-only bypass of pinning | Elevation of Privilege | AC-004 aligns PS1 with Bash |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary

Files in scope      : `lib/registry.sh`, `agtoosa.ps1`, `docs/AgToosa_Registry.md`, `template/Docs/AgToosa_Registry.md`, `tests/agtoosa.bats`, `tests/fixtures/` (if new fixture needed)

Directories in scope: `lib/`, `tests/`, `docs/`, `template/Docs/`

Out of scope        : `agtoosa-lock.json` implementation; remote `sky2464/agtoosa-registry` content; GPG signing (ADR Phase 3)

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Bash version enforcement
  - [ ] 1.1 Resolve registry entry by `name` only when `pack_version` is empty — _Requirements: AC-003_
  - [ ] 1.2 Resolve registry entry by `name` and `version` when `pack_version` is set — _Requirements: AC-001, AC-002_
  - [ ] 1.3 Exit non-zero with actionable message on mismatch or missing version; do not download — _Requirements: AC-002_
  - [ ] 1.4 Include resolved version in install confirmation and `.pack-meta.json` — _Requirements: AC-001_
- [ ] **2.** PowerShell parity
  - [ ] 2.1 Fail closed on version mismatch (remove warn-and-proceed) — _Requirements: AC-004_
  - [ ] 2.2 Use name+version selection when `$packVersion` is set — _Requirements: AC-001, AC-004_
- [ ] **3.** Documentation
  - [ ] 3.1 Update maintainer and template registry docs for fail-closed `@version` behavior — _Requirements: AC-002_
- [ ] **4.** Tests
  - [ ] 4.1 Add RV1: pinned install succeeds when fixture version matches (mock download path or dry helper) — _Requirements: AC-001, AC-005_
  - [ ] 4.2 Add RV2: pinned install fails when requested version ≠ fixture version — _Requirements: AC-002, AC-005_
  - [ ] 4.3 Add RV3: unpinned install still selects by name — _Requirements: AC-003, AC-005_
  - [ ] 4.4 Add RV4: Bash source enforces `pack_version` (grep/static guard) — _Requirements: AC-005_
  - [ ] 4.5 Add RV5: PS1 install rejects version mismatch (script block test) — _Requirements: AC-004, AC-005_
  - [ ] 4.6 Run RV filter + full bats; record evidence — _Requirements: AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3, 2.1, 2.2  
**Wave 2 (parallel after Wave 1):** 1.4, 3.1, 4.1, 4.2, 4.3, 4.4, 4.5  
**Wave 3 (sequential):** 4.6

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-020.md`  
AC coverage: 5 ACs mapped to 5 test IDs  
Smoke set: 5 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-05-24
