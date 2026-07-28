# Test Plan: DEV-137 — Security Scanning CI Health

> Spec reference: [spec-DEV-137.md](archived/spec-DEV-137.md)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | SSC-003 | Integration | Security Scanning workflow completes green on `main` | yes |
| AC-002 | SSC-001, SSC-002 | Regression | ShellCheck passes locally with project exclusions | yes |
| AC-003 | SSC-003 | Evidence | Workflow run URL + exit codes recorded in evidence ledger | yes |
| AC-004 | SSC-004 | Regression | Bats guard prevents SC2207/SC2178 anti-patterns | yes |

## Bats Mapping

| Test ID | bats name |
|---------|-----------|
| SSC-001 | `SSC-001: local ShellCheck passes with project exclusions` |
| SSC-002 | `SSC-002: security-scan workflow uses ShellCheck with project exclusions` |
| SSC-003 | `SSC-003: security-scan workflow is dispatchable and documents weekly schedule` |
| SSC-004 | `SSC-004: apply and catalog avoid ShellCheck SC2207 SC2178 anti-patterns` |

## Manual / CI Evidence

| Step | Command | Expected |
|------|---------|----------|
| ShellCheck local | `shellcheck -x -S warning --exclude=SC2002,SC2046,SC2086,SC1091,SC2034 agtoosa.sh lib/*.sh` | exit 0 |
| Workflow dispatch | `gh workflow run security-scan.yml --ref main` | run queued |
| Workflow result | `gh run view <id> --json conclusion,jobs` | conclusion: success |

## Regression

- DEV-041 PL-007 unchanged (dependency-check workflow args)
- Existing `lib/apply.sh` and `lib/catalog.sh` ShellCheck clean
