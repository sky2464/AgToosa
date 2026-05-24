# Spec: DEV-003 — Registry Prod-Readiness (Audit Closure)

> **Story ID:** DEV-003
> **Epic:** DEV-003 — Community Template Registry
> **Status:** 🏁 Shipped (v4.10.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

The Community Template Registry shipped in v3.x (`lib/registry.sh`, `agtoosa.ps1 --registry`, bats happy-path coverage). A v3.1.0 production-readiness audit (`docs/audit-v3.1.0-prod-readiness.md`) listed blocking issues CB-1–CB-4 and related security/UX gaps.

**Already resolved in tree (verify, do not re-implement):**
- CB-1: `KEEP_SHIP=true` in `registry_install` / `_install_local_pack`; bats `registry install local pack stages files and keeps ship/`
- CB-3 / SI-1: `jq --arg` for search/info/install pack lookup
- SI-3: `validate_pack_files` path-traversal guard + bats test
- SI-2: PS1 `Start-Process tar` (no `cmd /c`)
- CB-2 (partial): PS1 uses flat-array `ConvertFrom-Json` (not `.packs`)
- TG-1 (partial): list/search/info/local-install cache tests exist

**In scope for this story:** Close remaining audit items that affect registry trust and update-merge stability: CB-4 (`merge_platform_file` Case B version markers on `--update`), registry UX exit codes, safe `registry_publish` JSON, PS1 flat-array hardening, and focused bats regression suite **RG1–RG8**.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Close the remaining v3.1 registry audit blockers so bash and PowerShell registry flows are safe, predictable, and regression-tested. |
| User outcome | Maintainers can run `--registry` and `--update` without staged packs vanishing, jq/merge footguns, or silent failures on unknown packs. |
| Success condition | CB-4 fixed; registry info/search unknown-pack behavior correct; publish JSON safe; PS1 registry parses flat `registry.json`; RG1–RG8 bats green; full suite green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "RG[1-8]:"` + full `bats tests/agtoosa.bats`; manual spot-check `registry info nonexistent-pack` exits non-zero. |
| Non-goals | PS1 full platform-dir parity (MF-1–MF-5); GPG-signed registry index (SI-5); README/CONTRIBUTING doc sweep (DG-*); DEV-016 Gemini routing. |
| Assumptions | `tests/fixtures/registry.json` remains the flat-array schema ground truth. |
| Risks | Case B fix must not break existing DEV-172 merge test; update path uses `TEMPLATE_DIR` sources intentionally. |

### 1.2 User Stories

**As a** maintainer installing a community pack, **I want** staged files to remain in `ship/packs/` after `--registry install` **so that** a subsequent project install can merge them.

**As a** maintainer running `--update`, **I want** platform file merges to preserve AgToosa version markers **so that** re-running the updater does not duplicate content.

**As a** user searching the registry, **I want** clear errors when a pack does not exist **so that** automation can detect failure.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `merge_platform_file` handles Case B (existing START/END block) THE SYSTEM SHALL append injected AgToosa version markers, not raw template content without delimiters | Must |
| AC-002 | WHEN `--update` merges an older platform block THE SYSTEM SHALL leave exactly one AgToosa START block after two consecutive updates at the same AgToosa version | Must |
| AC-003 | WHEN `registry_info` is called for an unknown pack name THE SYSTEM SHALL print an error and exit non-zero | Must |
| AC-004 | WHEN `registry_search` finds no matches THE SYSTEM SHALL print an explicit no-results message | Should |
| AC-005 | WHEN `registry_publish` emits a pack manifest snippet THE SYSTEM SHALL build JSON with `jq` (no raw printf interpolation of user fields) | Must |
| AC-006 | WHEN PowerShell loads `registry.json` THE SYSTEM SHALL treat the document as a flat array using `@(ConvertFrom-Json)` so single-pack indexes do not collapse | Must |
| AC-007 | WHEN DEV-003 ships THE SYSTEM SHALL add bats tests RG1–RG8 covering jq injection safety, Case B re-run stability, registry UX, publish JSON safety, and PS1 array parsing | Must |
| AC-008 | WHEN `registry_search` receives a crafted jq probe string THE SYSTEM SHALL return safely without jq execution errors | Must |

### 1.4 Out of Scope

- Rewriting registry hosting or pack curation workflow
- PowerShell native platform directory install parity
- Changing `registry.json` schema to wrapped `{packs:[]}` format
- Full audit DG/MF/CI cleanup

## 2. Design

### 2.1 Architecture Blueprint

| Layer | Files | Change |
|-------|-------|--------|
| Merge | `lib/copy.sh` | Case B: `inject_version` temp file before append |
| Registry bash | `lib/registry.sh` | `registry_info` not-found exit 1; `registry_search` no-results message; `registry_publish` via `jq -n` |
| Registry PS1 | `agtoosa.ps1` | `@(ConvertFrom-Json)` on all registry list/search/info/install paths |
| Tests | `tests/agtoosa.bats` | RG1–RG8 regression suite |
| Docs (minimal) | `template/Docs/AgToosa_Registry.md` | Clarify staging survives install (if still inaccurate) |

### 2.2 Data Flow

1. User runs `bash agtoosa.sh --registry install ./tests/fixtures/mock-pack` → `KEEP_SHIP=true` → files remain under `ship/packs/`.
2. User runs `bash agtoosa.sh --update ./project` with older AgToosa block in `CLAUDE.md` → Case B strips block, appends **injected** template content.
3. Second `--update` at same version → single START block (no duplicate append).
4. User runs `--registry info missing` → stderr message, exit 1.
5. User runs publish wizard → `jq -n` emits valid JSON for any pack name containing quotes.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| jq filter injection via search/info | Tampering | AC-008 + existing `--arg` (RG1) |
| Path traversal in pack tarballs | Elevation | Existing `validate_pack_files` (RG7, unchanged) |
| Malformed publish JSON from crafted pack name | Tampering | AC-005 `jq -n` |
| Update merge duplicates unmarked blocks | Denial of Service | AC-001/002 inject_version in Case B |
| Silent success on unknown pack lookup | Repudiation | AC-003 exit 1 |
| PS1 single-element JSON array mishandled | Spoofing | AC-006 `@()` wrap |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `lib/copy.sh`, `lib/registry.sh`, `agtoosa.ps1`, `tests/agtoosa.bats`, `template/Docs/AgToosa_Registry.md` (only if Step 5 text is wrong)
Directories in scope: `lib/`, `tests/`, `template/Docs/`
Out of scope        : `agtoosa.sh` (unless registry dispatch tweak needed), MF-* PS1 parity, `docs/audit-v3.1.0-prod-readiness.md` edits, DEV-016

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Case B merge fix
  - [x] 1.1 Update `merge_platform_file` Case B to append via `inject_version` — _Requirements: AC-001_
  - [x] 1.2 Add RG3: Case B second `--update` leaves one START block — _Requirements: AC-002, AC-007_
- [x] **2.** Registry bash UX and safety
  - [x] 2.1 `registry_info`: exit 1 when jq returns empty — _Requirements: AC-003_
  - [x] 2.2 `registry_search`: explicit no-results message — _Requirements: AC-004_
  - [x] 2.3 `registry_publish`: emit manifest with `jq -n` — _Requirements: AC-005_
  - [x] 2.4 Add RG2, RG4, RG5, RG8 — _Requirements: AC-003, AC-004, AC-005, AC-007, AC-008_
- [x] **3.** PowerShell registry hardening
  - [x] 3.1 Wrap all registry `ConvertFrom-Json` results with `@()` — _Requirements: AC-006_
  - [x] 3.2 Add RG6: PS1 parses single-entry fixture array — _Requirements: AC-006, AC-007_
- [x] **4.** Verification
  - [x] 4.1 Add RG1 (jq injection), RG7 (path traversal unchanged) — _Requirements: AC-007, AC-008_
  - [x] 4.2 Run RG filter + full bats; record evidence — _Requirements: AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2, 2.3, 3.1  
**Wave 2 (parallel after Wave 1):** 1.2, 2.4, 3.2, 4.1  
**Wave 3 (sequential):** 4.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-003.md`  
AC coverage: 8 ACs → 8 RG tests  
Smoke set: RG1–RG8 @smoke

## ✅ Spec Approved

Approved: 2026-05-24
