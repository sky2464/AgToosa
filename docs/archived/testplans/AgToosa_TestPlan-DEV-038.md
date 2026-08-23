# Test Plan: DEV-038 - Distribution hardening and release readiness gate

> **Spec:** `docs/archived/spec-DEV-038.md`
> **Coverage target:** Homebrew readiness, release workflow modernization, public launch gate coverage
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-038"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001, AC-002 | DH-001 | Docs/Static | Homebrew is either verified with public release source/SHA or clearly gated as unavailable before tap publication | yes |
| AC-003, AC-004 | DH-002 | Workflow | Release workflows do not use deprecated `actions/create-release@v1` and include private-staging dry-run path | yes |
| AC-005 | DH-003 | Integration | Public launch readiness mode checks all advertised public surfaces | yes |
| AC-006 | DH-004 | Docs | Release docs explain permissions and recovery steps | no |
| AC-001-AC-006 | DH-005 | Regression | Focused checks, shellcheck, and `git diff --check` pass | no |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-038"
rg -n "actions/create-release|gh release|Homebrew|SHA|launch readiness" .github README.md Formula docs scripts tests
git diff --check
```

## Validation Evidence

```text
bats tests/agtoosa.bats -f "DEV-038"
=> 5/5 passing
```
