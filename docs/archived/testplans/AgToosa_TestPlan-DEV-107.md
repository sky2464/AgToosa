# Test Plan: DEV-107 — Agent-Instructed Orchestration Brain

> **Spec:** `docs/archived/spec-DEV-107.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-107\\|ORB-"`
> **Status:** 🏁 Shipped — v5.3.19; smoke PASS

## Coverage Target

80% — focused contract tests on Orchestration doc, Claim Boundary, workflow pointers, and `lib/config.sh` inventory.

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | ORB-001 | Integration | `AgToosa_Orchestration.md` exists in template + docs; defines inventory sources, lane-plan algorithm, merge rules, sequential fallback note | yes @smoke |
| AC-002 | ORB-002 | Integration | Inventory section names platforms, skills, specialists, MCP, plugins/host tools, Work Package DAG | yes @smoke |
| AC-003 | ORB-003 | Integration | Spec, Build, Review, Ship docs reference `AgToosa_Orchestration` / Orchestration Brain step 0 | yes @smoke |
| AC-004 | ORB-004 | Integration | Claim Boundary classifies agent-instructed / generator-enforced / CI / manual / roadmap; forbids runtime scheduler / hosted auto-launch claims | yes |
| AC-005 | ORB-005 | Integration | Orchestration or Build wiring preserves disjoint ownership / sequential fallback language (DEV-045) | yes |
| AC-006 | ORB-006 | Integration | Orchestration doc requires orchestrator-only Master-Plan mutation + import gate for external agents | yes |
| AC-007 | ORB-008 | Bats | `lib/config.sh` / `--list-template-files` registers `AgToosa_Orchestration.md` | yes @smoke |
| AC-008 | ORB-001–ORB-008 | Bats | Full DEV-107 / ORB filter green | yes @smoke |
| AC-009 | ORB-007 | Integration | Agent + Quickref + subagent-heavy guide reference Orchestration Brain; QA/task Should pointers optional | yes |
| AC-010 | ORB-001–ORB-008 | Bats | RED then GREEN evidence recorded below at build | yes @smoke |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-107"
bats tests/agtoosa.bats -f "ORB-"
git diff --check
```

## Evidence

### RED evidence (2026-07-12)

```text
$ bats tests/agtoosa.bats -f "ORB-"
# Before implementation: filter not present / tests missing (expected RED at Wave 1 start)
```

Result: **RED confirmed** at build start — no `AgToosa_Orchestration.md`, no ORB section in bats, no workflow hooks.

### GREEN evidence (2026-07-12)

```text
$ bats tests/agtoosa.bats -f "DEV-107|ORB-"
1..8
ok 1 DEV-107 @smoke ORB-001
ok 2 DEV-107 @smoke ORB-002
ok 3 DEV-107 @smoke ORB-003
ok 4 DEV-107 ORB-004
ok 5 DEV-107 ORB-005
ok 6 DEV-107 ORB-006
ok 7 DEV-107 ORB-007
ok 8 DEV-107 @smoke ORB-008
```

Result: **8/8 green**. Deliverables: `AgToosa_Orchestration.md` (template + docs), Spec/Build/Review/Ship/Agent/Quickref/guide hooks, `lib/config.sh` registration; ADR-003 amendment verified at spec time.
