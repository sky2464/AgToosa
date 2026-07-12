# Test Plan — DEV-113 Cursor Intake Hardening + Fixture Parity

> **Story:** DEV-113  
> **Spec:** `docs/archived/spec-DEV-113.md`  
> **Coverage target:** 80% (workflow default)

## AC Coverage

| Test ID | AC | Category | Description | Smoke |
|---------|-----|----------|-------------|-------|
| FIX-001 | AC-001, AC-002 | Integration | `cursor-intake-fixture.sh` installs + asserts Cursor wiring | @smoke |
| CIT-002 | AC-006 | Security | Fixture rejects generator root (self-target) | @smoke |
| CIT-003 | AC-002 | Integration | Installed `agtoosa-core.mdc` has Project Intake | @smoke |
| CIT-004 | AC-003 | Unit | `template/CLAUDE.md` NL Intent Map parity with `.cursorrules` | @smoke |
| NLM-001–006 | AC-007 | Unit | Regression — NL map + maintainer wiring (existing) | @smoke |
| CIT-005 | AC-004, AC-005 | Integration | Full bats 3× — manual/CI stability gate | — |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| CIT-002 | Pass generator repo path → non-zero exit, self-target message |
| FIX-001 | Missing fixture script or non-executable → bats fail at setup |

## Commands

```bash
# Focused (build phase)
bats tests/agtoosa.bats -f "FIX-001|CIT-|NLM-"

# Stability gate (AC-005)
for i in 1 2 3; do bats tests/agtoosa.bats || exit 1; done
```

## RED / GREEN Evidence

| Phase | Date | Result | Notes |
|-------|------|--------|-------|
| RED | 2026-07-12 | FIX-001 called agtoosa.sh directly | Pre-build baseline |
| GREEN | 2026-07-12 | PASS | `bats -f "FIX-001|CIT-|NLM-"` 10/10; full suite 950/950 × 3 runs |

```bash
bats tests/agtoosa.bats -f "FIX-001|CIT-|NLM-"
# 10/10 PASS (2026-07-12)

for i in 1 2 3; do bats tests/agtoosa.bats || exit 1; done
# 950/950 PASS × 3 (2026-07-12)
```
