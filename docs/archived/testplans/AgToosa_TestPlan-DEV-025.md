# Test Plan: DEV-025 — Maintainer Docs Path Normalization

> **Spec:** `docs/archived/spec-DEV-025.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (PN2, PN3, PN4) | Integration | Core maintainer workflow mirrors use `docs/` not `Docs/` for repo-local paths | yes |
| AC-002 | T-002 (PN1) | Integration | `docs/agtoosa-maintainer.md` documents Generated `Docs/` vs Maintainer `docs/` conventions | yes |
| AC-003 | T-003 (PN4) | Integration | Maintainer docs that cite template pack use `template/Docs/` explicitly | yes |
| AC-004 | T-004 (PN1–PN5) | Integration | Bats PN suite passes; template parity (R4 or B1) unchanged | yes |
| AC-005 | T-005 | Manual | `docs/Master-Plan.md` shows DEV-025 in Active Cycle under milestone v5.0.0 | no |

## Negative / Edge Scenarios

| ID | Scenario | Expected |
|----|----------|----------|
| T-001-N | Reintroduce `Docs/Master-Plan.md` in `docs/AgToosa_Status.md` → PN3 fails |
| T-002-N | Remove path conventions from maintainer guide → PN1 fails |
| T-003-N | Change `template/Docs/AgToosa_Status.md` to lowercase → PN5 fails |

## Smoke Set

PN1, PN2, PN3, PN4 (one per Must AC-001–AC-004)
