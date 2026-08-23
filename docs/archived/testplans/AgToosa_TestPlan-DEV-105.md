# Test Plan: DEV-105 — PowerShell Maintain + Update Parity

> **Spec:** `docs/archived/spec-DEV-105.md`
> **Status:** 🟩 Done — GREEN evidence recorded 2026-07-12
> **Created:** 2026-07-12
> **Test prefix:** `PSP`

## Scope

PowerShell `-Verify`, `-Doctor`, `-Uninstall`, and bash-delegated `-Update` parity with `agtoosa.sh`. Pester tests run when `pwsh` is available; bats provide grep contracts regardless of platform.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | PSP-001 | PS1 Verify dispatches repo verifier | Pester/integration | `-Verify -UpdatePath` runs verifier; exit code preserved | 🟩 GREEN |
| AC-002 | PSP-002 | PS1 Doctor matches bash doctor | Pester/integration | Doctor output includes version/lock/context signals | 🟩 GREEN |
| AC-003 | PSP-003 | PS1 Uninstall preserves user data | Pester/integration | Master-Plan and Context remain; owned files removed | 🟩 GREEN |
| AC-004, AC-006 | PSP-004 | PS1 Update delegates to bash run_update | Pester/grep | Update invokes `agtoosa.sh --update`; lock/version updated | 🟩 GREEN |
| AC-005 | PSP-005 | Missing UpdatePath fails fast | Pester/negative | Non-zero error when path omitted | 🟩 GREEN |
| AC-007 | PSP-001–PSP-005 | Pester suite covers verify/doctor/uninstall/update + validation | Pester suite | `tests/pester/agtoosa-maintain.Tests.ps1` exercises AC-001–AC-006 paths in isolated temp dirs | 🟩 GREEN |
| AC-008 | PSP-006 | agtoosa.ps1 declares maintain switches | Grep contract | `-Verify`, `-Doctor`, `-Uninstall` in param block | 🟩 GREEN |
| AC-009 | PSP-007 | Help documents maintain switches | Docs/grep | Help text lists verify/doctor/uninstall/update parity | 🟩 GREEN |
| AC-004 | PSP-008 | Inline Install-Files-only update path removed | Grep contract | `-Update` block calls bash update engine | 🟩 GREEN |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Verify on project without Docs/agtoosa-verify.sh | PSP-001 | Non-zero with actionable message |
| Uninstall on path without AgToosa install | PSP-003 | Safe failure or no-op per bash parity |
| Bash not found on Windows | PSP-004 | Non-zero with Git Bash guidance |
| UpdatePath points at generator repo root | PSP-004 | Self-target guard consistent with bash |
| Doctor on skewed version install | PSP-002 | Reports version skew finding |

## Smoke Set

- `@smoke PSP-006` — maintain switches declared in PS1.
- `@smoke PSP-004` — update delegates to bash.
- `@smoke PSP-001` — verify dispatch smoke (skip when pwsh absent).

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-105|PSP-"`

Pester command (when pwsh available): `Invoke-Pester -Path tests/pester/agtoosa-maintain.Tests.ps1`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Parity contract RED coverage | `bats tests/agtoosa.bats -f "DEV-105\|PSP-"` | 1 | `grep -q '\[switch\]\$Verify'` / `Invoke-AgToosaMaintain` not found (pre-impl) |
| 1. Parity contract RED coverage | `Invoke-Pester -Path tests/pester/agtoosa-maintain.Tests.ps1` | 1 | File not found / switches missing (pre-impl) |
| 2. PowerShell maintain switches | `bats tests/agtoosa.bats -f "PSP-006\|PSP-007\|PSP-008"` | 1 | PSP-006–008 grep failures before `agtoosa.ps1` changes |
| 3. Pester implementation | `Invoke-Pester -Path tests/pester/agtoosa-maintain.Tests.ps1` | 1 | Missing `-Verify`/dispatch helpers (pre-impl) |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-105\|PSP-"` | 1 | PSP-004 bash install failed without `mkdir -p` nested fixture |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Parity contract RED coverage | `bats tests/agtoosa.bats -f "DEV-105\|PSP-"` | 0 | `ok 1..5` DEV-105 section |
| 2. PowerShell maintain switches | `bats tests/agtoosa.bats -f "PSP-006\|PSP-007\|PSP-008"` | 0 | PSP-006–008 grep + PSP-004 integration |
| 3. Pester implementation | `Invoke-Pester -Path tests/pester/agtoosa-maintain.Tests.ps1` | 0 | `Passed 6, Failed 0` |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-105\|PSP-"` | 0 | All PSP bats + Pester GREEN |
