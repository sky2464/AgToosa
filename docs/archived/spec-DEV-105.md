# Spec: DEV-105 — Feature: PowerShell Maintain + Update Parity

> **Story ID:** DEV-105
> **Type:** Feature
> **Epic:** DEV-001 — Core Generator Engine
> **Status:** 🟩 Built
> **Estimate:** M
> **Priority:** P0
> **Spec created:** 2026-07-12
> **Extends:** DEV-074

## Context

DEV-074 shipped PowerShell non-interactive **install** parity (`-Path`, `-Platforms`, `-Yes`). `agtoosa.ps1` still lacks `-Verify`, `-Doctor`, and `-Uninstall` switches, and `-Update` reimplements a subset of update logic inline instead of delegating to the bash `run_update` equivalent. Bash `agtoosa.sh` exposes `--verify`, `--doctor`, `--uninstall`, and `run_update` via `lib/maintain.sh` and `lib/update.sh`. Rev4 Wave 1 requires maintain/update parity so Windows-native users can diagnose, verify, remove, and update installs without guessing bash-only paths.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Add PowerShell maintain switches and align `-Update` with the bash update engine so Windows users have parity for verify, doctor, uninstall, and update. |
| User outcome | `pwsh agtoosa.ps1 -Verify`, `-Doctor`, `-Uninstall`, and `-Update` behave like bash `--verify`, `--doctor`, `--uninstall`, and `run_update` for generated projects. |
| Success condition | PS1 dispatches maintain operations; `-Update` uses bash `run_update` (or a extracted shared contract tested against bash); Pester tests cover happy paths and validation failures; bats greps document parity. |
| Proof / evidence | PSP Pester suite + bats parity greps; test-plan RED/GREEN. |
| Non-goals | Full PS1 rewrite of verifier logic; JSON verify output (DEV-088 bash first); unified plan engine in PS1 (DEV-090 bash first). |
| Assumptions | Git Bash or WSL may be invoked for maintain scripts where PS1 ports are impractical; dispatch must be explicit and documented. |
| Risks | Silent bash dependency on Windows without Git Bash; update path diverges from `run_update` again; uninstall deletes user data. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** Windows developer, **I want** `-Verify` on `agtoosa.ps1` **so that** I can run the lifecycle verifier without switching shells.

**As a** Windows developer, **I want** `-Doctor` and `-Uninstall` **so that** I can diagnose and cleanly remove AgToosa like bash users.

**As an** AgToosa maintainer, **I want** `-Update` to call the same update engine as bash **so that** lock files, platform merge, and version markers stay consistent.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa.ps1` is invoked with `-Verify` and `-UpdatePath <project>` THE SYSTEM SHALL run the repo-local verifier for that project and SHALL preserve verifier exit codes | Must |
| AC-002 | WHEN `agtoosa.ps1` is invoked with `-Doctor` and `-UpdatePath <project>` THE SYSTEM SHALL run doctor diagnostics equivalent to `agtoosa.sh --doctor` for that project | Must |
| AC-003 | WHEN `agtoosa.ps1` is invoked with `-Uninstall` and `-UpdatePath <project>` THE SYSTEM SHALL remove AgToosa-owned files while preserving Master-Plan, Context, archived content, and merged entry points per DEV-073 preserve rules | Must |
| AC-004 | WHEN `agtoosa.ps1` is invoked with `-Update` and `-UpdatePath <project>` THE SYSTEM SHALL delegate to the bash `run_update` implementation (via `bash agtoosa.sh --update`) rather than the inline `Install-Files`-only path | Must |
| AC-005 | WHEN maintain switches are used without a project path THE SYSTEM SHALL exit non-zero with an actionable error requiring `-UpdatePath` (or documented alias) | Must |
| AC-006 | WHEN `-Update` completes successfully THE SYSTEM SHALL bump `Docs\.agtoosa-version` and update `Docs\agtoosa-lock.json` when packs are present using the same rules as bash `run_update` | Must |
| AC-007 | WHEN `tests/pester/agtoosa-maintain.Tests.ps1` runs THE SYSTEM SHALL cover verify, doctor, uninstall, and update dispatch with isolated temp project directories | Must |
| AC-008 | WHEN `tests/agtoosa.bats` runs DEV-105 coverage THE SYSTEM SHALL grep `agtoosa.ps1` for `-Verify`, `-Doctor`, `-Uninstall`, and bash-backed `-Update` dispatch | Must |
| AC-009 | WHEN help text is printed THE SYSTEM SHALL document the new switches alongside existing install and registry parameters | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | `-Verify` runs wrong script path (`docs` vs `Docs`) and always fails. |
| FM-002 | AC-002 | Doctor omits version skew or lock metadata present in bash output. |
| FM-003 | AC-003 | Uninstall deletes `Docs/Master-Plan.md` or user Context files. |
| FM-004 | AC-004 | `-Update` skips lock bump or pack merge steps present in `run_update`. |
| FM-005 | AC-005 | Silent default to cwd causes accidental maintainer-repo targeting. |
| FM-006 | AC-006 | PS1 update writes different lock JSON shape than bash. |
| FM-007 | AC-007 | Pester tests mock dispatch and do not catch regression. |

### 1.5 Out of Scope

- Native PowerShell port of `agtoosa-verify.sh` logic.
- `-Verify -Format Json` / `-Doctor -Format Json` (DEV-088 bash surfaces first).
- PS1 unified plan dry-run JSON (DEV-090).
- npm wrapper changes.
- Non-interactive `-Uninstall` without confirmation unless `-Yes` explicitly extended in a follow-up.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| PS1 switch inventory and dispatch | generator-enforced via bats greps |
| Verifier/doctor truth | bash scripts remain authoritative implementation |
| Update file mutations | bash `run_update` authoritative when delegated |
| Git Bash availability on Windows | manual prerequisite when dispatch uses bash |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `tests/pester/agtoosa-maintain.Tests.ps1` — verify, doctor, uninstall, update tests.

Files to change:

- `agtoosa.ps1` — add `[switch]$Verify`, `[switch]$Doctor`, `[switch]$Uninstall`; refactor `-Update` to invoke `bash agtoosa.sh --update "$UpdatePath"` (with path normalization and bash discovery).
- `tests/agtoosa.bats` — PSP-001–PSP-008 grep and optional pwsh smoke.
- `bootstrap.ps1` help text — mention maintain switches if applicable.

Key interfaces:

- `Invoke-AgToosaMaintain([string]$Operation, [string]$ProjectPath)` — resolves bash, sets working directory, forwards exit code.
- `-Update` → `bash "$AgToosaRoot/agtoosa.sh" --update "$UpdatePath"` (non-interactive when combined with future `-Yes` if present).

### 2.2 Data Flow

1. User runs `pwsh agtoosa.ps1 -Doctor -UpdatePath C:\proj`.
2. PS1 validates path, locates bash (`bash`, `git bash`, or env override).
3. PS1 invokes `agtoosa.sh --doctor` with project root env or `--root` equivalent.
4. Exit code propagated to `$LASTEXITCODE`; human output streamed to host.
5. `-Update` delegates entire update transaction to bash `run_update` path.
6. Pester tests create temp dirs with minimal `Docs/` tree, invoke PS1 switches, assert exit codes and side effects.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Uninstall removes user project sources | Tampering | Reuse DEV-073 preserve list; confirmation prompt unless documented otherwise. |
| Malicious `-UpdatePath` targets wrong drive | Elevation of Privilege | Resolve full path; refuse maintainer generator self-target. |
| Bash invocation with injected path | Elevation of Privilege | Quote paths; no string concatenation into shell eval. |
| Doctor prints secrets from `.agtoosa/state.json` | Information Disclosure | Mirror bash doctor redaction/summary rules. |
| Missing bash on Windows | Denial of Service | Fail with actionable install Git Bash message (AC-005). |
| False parity claims in docs | Spoofing | PSP bats + Pester assert dispatch strings. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `agtoosa.ps1`, `tests/pester/agtoosa-maintain.Tests.ps1`, `tests/agtoosa.bats`
Directories in scope: `tests/pester/`, repository root
Out of scope        : PS1 verifier port, plan JSON, npm wrapper, DEV-088 JSON flags on PS1

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Parity contract RED coverage
  - [ ] 1.1 Add bats PSP greps for new switches and bash update dispatch — _Requirements: AC-004, AC-008, AC-009_
  - [ ] 1.2 Add Pester skeleton tests failing before implementation — _Requirements: AC-007_
- [x] **2.** PowerShell maintain switches
  - [ ] 2.1 Implement `-Verify`, `-Doctor`, `-Uninstall` dispatch — _Requirements: AC-001, AC-002, AC-003, AC-005_
  - [ ] 2.2 Refactor `-Update` to delegate to bash `run_update` — _Requirements: AC-004, AC-006_
  - [ ] 2.3 Update help text — _Requirements: AC-009_
- [x] **3.** Pester implementation
  - [ ] 3.1 Complete Pester happy-path and validation tests — _Requirements: AC-007_
- [x] **4.** Evidence
  - [ ] 4.1 Record PSP RED/GREEN evidence — _Requirements: AC-001–AC-009_

### Wave Plan

### 3.2 Wave Plan detail

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential within story — shared `agtoosa.ps1`):** 2.1 → 2.2
**Wave 3 (parallel after Wave 2):** 2.3, 3.1
**Wave 4 (sequential after Wave 3):** 4.1

> Cross-story: Wave 1a fan-out allows DEV-086 · DEV-090 · DEV-105 in parallel; owned files are disjoint across stories.

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-105.md`
AC coverage: 9 ACs mapped to 9 PSP test IDs (AC-007 → PSP-001–005 + suite file)
Smoke set: 3 tests tagged `@smoke`

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `tests/agtoosa.bats` (PSP greps) | — | PSP-006–008 stubs | 1 | `bats tests/agtoosa.bats -f "DEV-105\|PSP-"` |
| PKG-1.2 | 1 | — | `tests/pester/agtoosa-maintain.Tests.ps1` | — | failing Pester skeleton | 2 | `test -f tests/pester/agtoosa-maintain.Tests.ps1` |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2 | `agtoosa.ps1` (maintain switches) | Wave 1 RED | `-Verify`/`-Doctor`/`-Uninstall` | 3 | `bats tests/agtoosa.bats -f "PSP-006"` |
| PKG-2.2 | 2 | PKG-1.1 | `agtoosa.ps1` (Update path) | Wave 1 RED | bash `--update` delegation | 4 | `bats tests/agtoosa.bats -f "PSP-004\|PSP-008"` |
| PKG-2.3 | 3 | PKG-2.1, PKG-2.2 | `agtoosa.ps1` (help text) | Wave 2 switches | documented maintain help | 5 | `bats tests/agtoosa.bats -f "PSP-007"` |
| PKG-3.1 | 3 | PKG-2.1, PKG-2.2 | `tests/pester/agtoosa-maintain.Tests.ps1` | Wave 2 impl | Pester GREEN | 6 | `pwsh -Command "Invoke-Pester -Path tests/pester/agtoosa-maintain.Tests.ps1 -PassThru"` |
| PKG-4.1 | 4 | PKG-2.3, PKG-3.1 | `docs/AgToosa_TestPlan-DEV-105.md` | GREEN evidence | RED/GREEN recorded | 7 | `grep -q GREEN docs/AgToosa_TestPlan-DEV-105.md` |

> Wave 2 note: PKG-2.1 and PKG-2.2 both own `agtoosa.ps1` — run **sequentially** (2.1 then 2.2). Wave 1 PKG-1.1 / PKG-1.2 are file-disjoint and may run in parallel.

## ✅ Spec Approved

Approved: 2026-07-12 09:00
Enrollment: Rev4 Wave 1 — PowerShell maintain parity
