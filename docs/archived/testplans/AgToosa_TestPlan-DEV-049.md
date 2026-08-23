# Test Plan: DEV-049 - Evidence Ledger

> **Spec:** `docs/archived/spec-DEV-049.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-049"`
> **Status:** ✅ Done

## Coverage Target

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | EL-001 | Docs | Review workflow requires evidence-[story-id].md update | yes @smoke |
| AC-002 | EL-002 | Docs | Ship workflow finalizes evidence ledger | yes @smoke |
| AC-003 | EL-003 | Docs | Schema fields present in AgToosa_Evidence.md (dual-path) | yes @smoke |
| AC-004 | EL-003 | Docs | agent-instructed Claim Boundary + Master-Plan SoT | yes @smoke |
| AC-005 | EL-004 | Docs | Optional JSONL mirror schema + seed file registered | yes |
| AC-006 | EL-005 | Integration | DOCS_FILES / adapters registered | yes @smoke |
| AC-007 | EL-001–EL-005 | Evidence | This evidence section | yes |

Negative / edge: EL-003 asserts docs do **not** claim generator-enforced or CI-enforced ledger checks.

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-049"
bats tests/agtoosa.bats -f "DEV-042-060"
git diff --check
```

## Evidence

### RED evidence — DEV-049

Command: `bats tests/agtoosa.bats -f "DEV-049 EL"` (contract assertions before full wiring)
Expected: FAIL on missing Evidence docs / Review-Ship wiring (pre-implementation).

### GREEN evidence — DEV-049

| Field | Value |
|-------|--------|
| Command | `bats tests/agtoosa.bats -f "DEV-049"` |
| Exit code | 0 |
| Pass/fail | PASS — 6/6 (EL-001–EL-005, CW-012) |
| Verifier | `bash docs/agtoosa-verify.sh` → PASS |
| Recorded | 2026-07-08 |
| Next | `/agtoosa-review` |
