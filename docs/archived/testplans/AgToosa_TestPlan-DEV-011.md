# Test Plan: DEV-011 — Product vs Dogfood Boundary

> **Spec:** `docs/archived/spec-DEV-011.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`)
> **Generated:** 2026-05-23

## AC Coverage

| AC ID | Test ID | Category | Description | @smoke |
|-------|---------|----------|-------------|--------|
| AC-001 | T-001 (B1) | Integration | Maintainer guide defines Generated Project Mode + Maintainer Dogfood Mode | yes |
| AC-002 | T-002 (B2) | Integration | `AgToosa_Agent.md` Operating Contexts; project/product language | yes |
| AC-003 | T-003 (B3) | Integration | `AgToosa_Status.md` + `AgToosa_Spec.md` project-scoped PM/identity | yes |
| AC-004 | T-004 (B4) | Integration | Spec/status adapters consistent with canonical wording | yes |
| AC-005 | T-005 (B5) | Integration | `--list-template-files` includes touched docs | yes |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| T-002-N | Remove Operating Contexts from `AgToosa_Agent.md` → B2 fails |
| T-003-N | Status doc claims "AgToosa is the product under development" in generated template → B3 fails |
| T-004-N | Cursor spec rule contradicts canonical mode names → B4 fails |

## Execution Commands

```bash
# Narrow DEV-011 filter first
bats tests/agtoosa.bats -f "B[1-5]:"

# Full suite when environment allows
bats tests/agtoosa.bats
```

**Evidence note:** If full install-style tests fail from known sandbox/TTY issues, record B1–B5 pass separately from full-suite residual failures (same pattern as DEV-009 ship evidence).
