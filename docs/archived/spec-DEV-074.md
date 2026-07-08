# Spec: DEV-074 — PS1 non-interactive install parity + Pester suite

> **Story ID:** DEV-074
> **Epic:** DEV-001 — Core Generator Engine
> **Status:** 🟦 Todo
> **Estimate:** M
> **Spec created:** 2026-07-08

## Context

Bash `agtoosa.sh` supports non-interactive installs via `--path`, `--platforms`, and `--yes` (DEV-071). Windows `agtoosa.ps1` still prompts for project path and platform selection and has no `-Yes` switch — CI, devcontainers, and scripted rollouts cannot mirror bash parity on native PowerShell.

**Root cause:** DEV-071 wired non-interactive flags in bash only; PS1 param block exposes registry/update switches but not install CLI parity.

**Fix direction:** Add `-Path`, `-Platforms`, and `-Yes` to `agtoosa.ps1`, reuse bash validation semantics (unknown platform rejection, path required with `-Yes`), and add Pester tests plus bats greps for parity.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | PowerShell install path matches bash non-interactive contract. |
| User outcome | `pwsh agtoosa.ps1 -Path .\myapp -Platforms cursor,claude -Yes` installs without prompts on Windows. |
| Success condition | All Must ACs pass; bats NI parity greps green; Pester suite covers happy path and validation failures. |
| Proof / evidence | `bats tests/agtoosa.bats -f "DEV-074"`; `Invoke-Pester` on `tests/pester/agtoosa-install.Tests.ps1` when pwsh available. |
| Non-goals | Rewriting entire PS1 install engine; bash changes; npm wrapper changes |
| Assumptions | Platform list parsing matches bash comma-split + trim; `-Yes` implies consent for overwrite prompts where bash `ASSUME_YES` does. |
| Risks | Interactive code paths regress — mitigated by existing NI bats + new Pester cases. |

### 1.2 User Stories

**As an** AgToosa maintainer on Windows, **I want** PS1 non-interactive install flags **so that** CI and scripts can scaffold projects without TTY prompts.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa.ps1` is invoked with `-Path`, `-Platforms`, and `-Yes` THE SYSTEM SHALL install AgToosa without reading from stdin | Must |
| AC-002 | WHEN `-Platforms` contains an unknown platform name THE SYSTEM SHALL exit non-zero with an error message matching bash semantics | Must |
| AC-003 | WHEN `-Yes` is set without `-Path` THE SYSTEM SHALL exit non-zero (path required) | Must |
| AC-004 | WHEN install completes THE SYSTEM SHALL write `Docs\.agtoosa-version` matching `$AGTOOSA_VERSION` | Must |
| AC-005 | WHEN `tests/agtoosa.bats` runs DEV-074 coverage THE SYSTEM SHALL grep PS1 for `-Path`, `-Platforms`, and `-Yes` parameters | Must |
| AC-006 | WHEN Pester tests run THE SYSTEM SHALL cover AC-001 and AC-002 with isolated temp directories | Should |

### 1.4 Out of Scope

- PS1 `--doctor` / `--verify` dispatch (separate stories)
- Extracting PS1 into `lib/*.ps1` modules (noted in DEV-061 review)

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `agtoosa.ps1` | Add `[string]$Path`, `[string]$Platforms`, `[switch]$Yes` params; skip `Read-Host` when `$Yes`; parse platforms like bash |
| `tests/agtoosa.bats` | DEV-074 PS-001–PS-003 grep + optional pwsh smoke |
| `tests/pester/agtoosa-install.Tests.ps1` | New Pester file for non-interactive install |

### 2.2 STRIDE Threat Model

| Threat | Mitigation |
|--------|------------|
| Spoofing | No auth surface |
| Tampering | `-Path` resolved to full path; no arbitrary code execution from flags |
| Repudiation | N/A |
| Information disclosure | Temp install dirs only |
| Denial of service | Invalid flags fail fast |
| Elevation | User must already have write access to target path |

### 2.3 Build Scope

```
Files in scope      : agtoosa.ps1, tests/agtoosa.bats, tests/pester/agtoosa-install.Tests.ps1
Out of scope        : agtoosa.sh, lib/*.sh, npm/, template/
```

## 3. Tasks

### 3.1 Task tree

- [ ] **1.** PS1 CLI parameters
  - [ ] 1.1 Add `-Path`, `-Platforms`, `-Yes` to `param()` and `Show-Usage` — _AC-001, AC-005_
  - [ ] 1.2 Skip interactive prompts when `-Yes` — _AC-001_
  - [ ] 1.3 Validate platform tokens; error on unknown — _AC-002_
- [ ] **2.** Tests
  - [ ] 2.1 DEV-074 bats greps (PS-001–PS-003) — _AC-005_
  - [ ] 2.2 Pester happy path + unknown platform — _AC-006_
- [ ] **3.** Verify
  - [ ] 3.1 `bats -f DEV-074` and focused NI regression — _AC-001–AC-004_

### 3.2 Wave Plan

**Wave 1:** 1.1–1.3 (PS1 flags)  
**Wave 2:** 2.1–2.2 (tests)  
**Wave 3:** 3.1 (verification)

## ✅ Spec Approved

Approved 2026-07-08 — enrollment from backlog; assumptions documented under Goal Contract.
