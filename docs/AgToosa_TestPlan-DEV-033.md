# Test Plan: DEV-033 — agtoosa.ps1 approved PowerShell verbs

> **Spec:** `docs/archived/spec-DEV-033.md`
> **Coverage target:** structural grep + existing install smoke
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-033"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-003, AC-004 | PV-001 | Integration | `agtoosa.ps1` defines `Copy-StageFiles`, `Initialize-PackQueueDir`, `Move-ShipPacksToQueue` | yes |
| AC-003, AC-004 | PV-002 | Integration | `agtoosa.ps1` does not contain legacy names `Stage-Files`, `Ensure-PackQueueDir`, `Salvage-ShipPacksToQueue` | yes |
| AC-002 | PV-003 | Integration | Existing PK* / install bats still pass (no regression from rename) | yes |
| AC-001 | — | Manual | PSScriptAnalyzer / IDE: zero `PSUseApprovedVerbs` on renamed functions | no |
| AC-005 | — | Manual | Audit doc cites `Copy-StageFiles` if updated | no |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-033"
bats tests/agtoosa.bats -f "PK"
```

Optional (when PSScriptAnalyzer module installed):

```powershell
Invoke-ScriptAnalyzer -Path agtoosa.ps1 -IncludeRule PSUseApprovedVerbs
```

## Validation Evidence

```text
bats tests/agtoosa.bats -f "DEV-033"                         # 3/3 passing
bats tests/agtoosa.bats -f "PK"                              # 5/5 passing
pwsh parser check for agtoosa.ps1                            # PowerShell parse ok
Invoke-ScriptAnalyzer -Path ./agtoosa.ps1 -IncludeRule PSUseApprovedVerbs
                                                              # 0 findings, exit 0
bats tests/agtoosa.bats                                      # 352/352 passing
```
