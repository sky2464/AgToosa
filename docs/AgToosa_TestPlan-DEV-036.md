# Test Plan: DEV-036 - Windows and registry parity

> **Spec:** `docs/archived/spec-DEV-036.md`
> **Coverage target:** PowerShell update parity, registry archive shape, PowerShell registry help consistency
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-036"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001, AC-002, AC-003 | WP-001 | Integration | PowerShell update detects installed platforms, preserves old user content, updates managed files, and writes `Docs/.agtoosa-version` | yes |
| AC-004, AC-005 | WP-002 | Integration | Bash publish-to-install registry smoke produces no duplicate nested pack path | yes |
| AC-004, AC-005 | WP-003 | Integration | PowerShell registry install consumes canonical pack layout equivalently | yes |
| AC-006, AC-007 | WP-004 | Static/CLI | PowerShell registry help, parameter comments, README, and runtime behavior agree on publish support | no |
| AC-001-AC-007 | WP-005 | Regression | Full Bats and PowerShell parser/analyzer checks pass after parity changes | no |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-036"
bats tests/agtoosa.bats -f "registry|PowerShell"
pwsh -NoProfile -Command '$null = [scriptblock]::Create((Get-Content -Raw ./agtoosa.ps1)); ./agtoosa.ps1 -Version'
git diff --check
```

## Validation Evidence

```text
bats tests/agtoosa.bats -f "DEV-036"
=> 5/5 passing

pwsh Invoke-ScriptAnalyzer PSUseApprovedVerbs on agtoosa.ps1
=> exit 0
```
