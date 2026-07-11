# Test Plan: DEV-055 — Agent Capability Matrix

> **Spec:** `docs/archived/spec-DEV-055.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-055"`
> **Status:** 🟦 Todo

## Coverage Target

80% — focused contract tests on docs, config inventory, and workflow cross-links.

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | AM-001 | Integration | `AgToosa_AgentCapability.md` exists in template + docs; defines detection, matrix columns, routing algorithm, fallbacks | yes @smoke |
| AC-002 | AM-001 | Integration | Claim Boundary table classifies enforcement per row | yes |
| AC-003 | AM-002 | Bats | `lib/config.sh` / `--list-template-files` registers `AgToosa_AgentCapability.md` | yes @smoke |
| AC-004 | AM-003 | Integration | Handoff doc references matrix for target-agent recommendation | yes @smoke |
| AC-005 | AM-004 | Integration | Review + CrossModelReview reference matrix for parallel vs sequential | yes @smoke |
| AC-006 | AM-005 | Integration | Help `next` mode may reference matrix (read-only hint) | yes |
| AC-007 | AM-006 | Integration | Specialists cross-links AgentCapability; does not duplicate full routing table | yes |
| AC-008 | AM-001 | Integration | SoT boundary preserved for external agents | yes |
| AC-009 | AM-007 | Bats | Matrix includes rows aligned with platform sentinels in `lib/config.sh` | yes @smoke |
| AC-010 | AM-001–AM-007 | Bats | Full DEV-055 filter green | yes @smoke |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-055"
bats tests/agtoosa.bats -f "AM-"
git diff --check
```

## Evidence

Record RED/GREEN evidence here and in `docs/archived/evidence-DEV-055.md` at review/ship.
