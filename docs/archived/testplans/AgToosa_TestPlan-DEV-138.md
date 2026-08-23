# Test Plan: DEV-138 — Main CI Health

> Spec reference: [spec-DEV-138.md](archived/spec-DEV-138.md)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | PTC-002, CIH-001 | Regression | Product truth inventory `20 commands x 6 targets` | yes |
| AC-002 | CIH-002 | Regression | No `Sanitize-` function names in agtoosa.ps1 | yes |
| AC-003 | CIH-003 | Integration | `ci.yml` validate job references product-truth bats | yes |
| AC-004 | CIH-004 | Regression | Bats grep-negative for unapproved verb pattern | yes |

## Bats Mapping

| Test ID | bats name |
|---------|-----------|
| CIH-001 | `CIH-001: product truth inventory reports 20 commands on six targets` |
| CIH-002 | `CIH-002: agtoosa.ps1 avoids Sanitize- unapproved verb` |
| CIH-003 | `CIH-003: ci.yml runs product-truth bats in validate job` |
| CIH-004 | `CIH-004: agtoosa.ps1 uses ConvertTo-PlatformMenuInput approved verb` |

## Manual / CI Evidence

| Step | Command | Expected |
|------|---------|----------|
| Product truth | `bats tests/product-truth.bats --filter PTC-002` | exit 0 |
| PSScriptAnalyzer | CI Windows job or local `Invoke-ScriptAnalyzer` | exit 0 |
| Full validate | `gh run list --workflow=ci.yml` after push | conclusion: success |
