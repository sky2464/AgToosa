# Test Plan: DEV-110 — AgToosa Project Intake

> **Spec:** `docs/archived/spec-DEV-110.md`  
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-110\\|INT-"`  
> **Status:** ✅ Spec approved — build complete (INT GREEN)  
> **Coverage target:** 80% focused contract tests (docs + alwaysApply + Standing Corrections greps)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | INT-001 | Integration | Agent.md defines Project Intake for freeform asks without `/agtoosa-*` | yes |
| AC-002 | INT-002 | Integration | Soft path + expedite + quiet one-liner documented | yes |
| AC-003 | INT-003 | Integration | Hard gate: no product code until confirm; benefit-framed Project Intake message | yes |
| AC-004 | INT-004 | Integration | Destination map includes task / review / build / spec / factor-out | yes |
| AC-005 | INT-005 | Integration | `workflow.md` has `## Standing Corrections`; Agent requires read-before-classify | yes |
| AC-006 | INT-006 | Integration | Tiered Master-Plan logging (soft vs hard) documented | yes |
| AC-007 | INT-007 | Integration | `agtoosa-core.mdc` has `alwaysApply: true`; slash bypasses intake ceremony | yes |
| AC-008 | INT-008 | Integration | Phase Stop preserved — intake never auto-chains Spec→Build→Ship | yes |
| AC-009 | INT-009 | Docs | Claim Boundary uses agent-instructed / CI-enforced / manual / roadmap labels | yes |
| AC-010 | INT-010 | Docs | Master-Plan / roadmap place DEV-110 after DEV-109; expedite-when-capacity-free | yes |
| AC-011 | INT-001–INT-010 | Bats | Full DEV-110 / INT filter green | yes |
| AC-012 | INT-001–INT-010 | Bats | RED then GREEN evidence recorded below | yes |
| AC-013 | INT-011 | Integration | Spec-First soft/hard split documented in core rule | no |
| AC-014 | INT-012 | Integration | Help or Quickref one-line Project Intake pointer | no |

## Negative / edge (Must ACs)

| AC | Negative scenario | Test ID |
|----|-------------------|---------|
| AC-003 | Soft-only wording without hard-gate stop — forbidden | INT-003 |
| AC-005 | Standing Corrections section missing from shipped workflow.md template | INT-005 |
| AC-007 | `alwaysApply: false` remains on core rule — fail | INT-007 |
| AC-008 | Intake documents auto-run `/agtoosa-build` after Spec confirm — forbidden | INT-008 |
| AC-010 | DEV-110 backlog row appears before DEV-109 without enrollment note | INT-010 |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-110"
bats tests/agtoosa.bats -f "INT-"
git diff --check
```

## Evidence

### RED evidence

2026-07-12 — Before implementation, INT section absent; `alwaysApply: false` on core rule; no Project Intake section in Agent.md. Expected failures on first `bats -f DEV-110` run.

### GREEN evidence

2026-07-12 — `bats tests/agtoosa.bats -f "DEV-110"` — exit 0, 12/12 pass (INT-001–INT-012).

```
1..12
ok 1 DEV-110 @smoke INT-001
...
ok 12 DEV-110 INT-012: Quickref Project Intake pointer
```
