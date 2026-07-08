# Test Plan: DEV-047 - Async Agent Handoff Packs

> **Spec:** `docs/archived/spec-DEV-047.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-047"`
> **Status:** ✅ Done

## Coverage Target

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | HO-001 | Docs | Pack template sections present in dual-path Handoff docs | yes @smoke |
| AC-002 | HO-002 | Docs | Claim boundary agent-instructed + manual; SoT strings | yes @smoke |
| AC-003 | HO-002 | Docs | No checkbox ticks; Master-Plan SoT | yes @smoke |
| AC-004 | HO-004, HO-005 | Integration | Adapters route to Docs/AgToosa_Handoff.md; registered in config | yes @smoke |
| AC-005 | HO-003 | Docs | Build references handoff / async wave export | yes @smoke |
| AC-006 | HO-001–HO-005 | Evidence | This evidence section | yes |

Negative / edge: HO-004 asserts adapters do **not** duplicate Pack Template body.

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-047"
bats tests/agtoosa.bats -f "DEV-042-060"
git diff --check
```

## Evidence

### RED evidence — DEV-047

Command: `bats tests/agtoosa.bats -f "DEV-047 HO"` (contract assertions before implementation)
Expected: FAIL on missing Handoff docs / adapters (pre-implementation).

### GREEN evidence — DEV-047

Command: `bats tests/agtoosa.bats -f "DEV-047"`
Recorded: 2026-07-08 — HO-001–HO-005 + CW-010 green after docs-first implementation.
