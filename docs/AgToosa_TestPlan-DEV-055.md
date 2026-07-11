# Test Plan: DEV-055 — Agent Capability Matrix

> **Spec:** `docs/archived/spec-DEV-055.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-055"`
> **Status:** 🟨 In Progress — Wave 1 complete

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

### Wave 1 RED (2026-07-11)

```text
$ bats tests/agtoosa.bats -f "DEV-055"
1..8
ok 1 DEV-055 CW-018
ok 2 DEV-055 AM-001
not ok 3 DEV-055 AM-002  # config registration (Wave 2)
not ok 4 DEV-055 AM-003  # Handoff wiring (Wave 2)
not ok 5 DEV-055 AM-004  # Review/Build wiring (Wave 2)
not ok 6 DEV-055 AM-005  # Help wiring (Wave 2)
not ok 7 DEV-055 AM-006  # Specialists cross-link (Wave 2)
ok 8 DEV-055 AM-007
```

Result: **3 pass / 5 fail** (expected RED for AM-002–AM-006 until Wave 2).
Artifacts: `template/Docs/AgToosa_AgentCapability.md`, `docs/AgToosa_AgentCapability.md`.
