# Test Plan: DEV-022 — Registry Publish Parity & Offline Cache

> **Spec:** `docs/archived/spec-DEV-022.md`
> **Coverage target:** 80%
> **Smoke filter:** `bats tests/agtoosa.bats -f "RC[1-3]:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (RC1) | Integration | PS1 `--registry publish` prints Bash redirect, not unknown command | yes |
| AC-002 | T-002 (RC2) | Unit | Registry docs mention cache dir + HTTPS trust + SHA-256 verification | yes |
| AC-003 | T-003 (RC3) | Integration | `AGTOOSA_REGISTRY_CACHE_DIR` with fixture index serves list/info without network | yes |
| AC-004 | T-001–T-003 | Meta | RC1–RC3 exist | yes |

## Commands

```bash
bats tests/agtoosa.bats -f "RC[1-3]:"
```
