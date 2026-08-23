# Test Plan: DEV-021 — E2E Pinned Registry Install Test

> **Spec:** `docs/archived/spec-DEV-021.md`
> **Coverage target:** 80%
> **Smoke filter:** `bats tests/agtoosa.bats -f "RV6:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (RV6) | Integration | Pinned install downloads `file://` tarball, verifies SHA-256, queues pack with correct `.pack-meta.json` version | yes |
| AC-002 | T-001 (RV6) | Integration | RV6 exists and runs in CI | yes |
| AC-003 | T-001 (RV6) | Integration | Uses isolated `AGTOOSA_REGISTRY_CACHE_DIR` + `AGTOOSA_PACK_QUEUE_DIR` | yes |

## Negative / Edge Scenarios

| ID | Scenario |
|----|----------|
| T-001-N | Wrong SHA-256 in fixture registry → install fails before queue write |
| T-002-N | `file://` unsupported → curl stub on PATH serves tarball (or documented skip) |

## Commands

```bash
bats tests/agtoosa.bats -f "RV6:"
bats tests/agtoosa.bats -f "RV[1-6]:"
```
