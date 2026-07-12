# Test Plan: DEV-056 — Retrospective Learning Loop

> **Spec:** `docs/archived/spec-DEV-056.md`
> **Status:** ✅ Done
> **Execution state:** GREEN recorded
> **Primary filter:** `bats tests/agtoosa.bats -f "DEV-056"`
> **Contract filter:** `bats tests/agtoosa.bats -f "RL-"`

## Coverage Target

Target: 7 of 7 Must-priority acceptance criteria. RL-001–RL-007 lock ACs; RL-008 covers install/discovery wiring.

| AC | Priority | Test ID | Type | Assertion | Automated |
|----|----------|---------|------|-----------|-----------|
| AC-001 | Must | RL-001 | Docs / fixture integration | Retro contract and complete-cycle fixture contain metadata plus Planned vs Shipped, Evidence Index, Keep, Stop, Start, Rejected Overreach, and Proposals; one cycle path | `@smoke` |
| AC-002 | Must | RL-002 | Docs / fixture integration | Every proposal has required fields and allowed enums; policy proposals carry an allowed enforcement class | `@smoke` |
| AC-003 | Must | RL-003 | Mutation-boundary integration | Retro workflow leaves Master-Plan, approved specs, policy, Context, tests, and specialist targets unchanged and emits only canonical next commands | `@smoke` |
| AC-004 | Must | RL-004 | Bats / integration | Inputs are limited to documented repo-local sources; missing optional sources become `unavailable`; no network command is required | `@smoke` |
| AC-005 | Must | RL-005 | Docs / claim contract | Retro controls use generator-enforced, CI-enforced, agent-instructed, manual, and roadmap labels without claiming automated learning | `@smoke` |
| AC-006 | Must | RL-006 | Fixture integration | Two distinct evidence pointers produce `repeated-pattern`; one pointer produces `single-cycle` | `@smoke` |
| AC-007 | Must | RL-007 | Security / fixture integration | Retro summaries redact credential/private-URL fixtures, omit unbounded logs, and retain safe repo-relative pointers | `@smoke` |

## Fixtures

| Fixture | Purpose |
|---------|---------|
| `tests/fixtures/retro/complete-cycle/` | Full local cycle sources + expected structured retro |
| `tests/fixtures/retro/missing-optional/` | Optional review/evidence/events absent → `unavailable` |
| `tests/fixtures/retro/repeated-friction/` | Two distinct pointers → `repeated-pattern` |
| `tests/fixtures/retro/secret-bearing/` | Synthetic credential/URL/log; retro keeps `[REDACTED]` + pointer |

Synthetic credential marker: `SYNTHETIC_CREDENTIAL_FIXTURE_VALUE_001` (no real tokens).

## TDD Evidence

### RED evidence — recorded

```
RED evidence — 1.2 / RL-001–RL-008
Command: bats tests/agtoosa.bats -f "DEV-056 RL-"
Exit code: 1
Failure excerpt:
  not ok 1 DEV-056 RL-001: `[ -f "$f" ]' failed  (AgToosa_Retro.md missing)
  not ok 2–7: same missing contract
  not ok 8 DEV-056 RL-008: Docs/AgToosa_Retro.md absent from --list-template-files
Timestamp: 2026-07-12T02:48:00Z
```

### GREEN evidence — recorded

```
GREEN evidence — 5.1 / DEV-056
Command: bats tests/agtoosa.bats -f "DEV-056"
Exit code: 0
Pass/fail: PASS — 9/9 (CW-019 + RL-001–RL-008)
Timestamp: 2026-07-12T02:52:52Z (re-verified after RL-007 fixture marker fix)

GREEN evidence — RL namespace
Command: bats tests/agtoosa.bats -f "RL-"
Exit code: 0
Pass/fail: PASS — 8/8

GREEN evidence — verifier
Command: bash docs/agtoosa-verify.sh
Exit code: 0
Result: PASS (0 fail)

GREEN evidence — whitespace
Command: git diff --check
Exit code: 0
```

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-056"
bats tests/agtoosa.bats -f "RL-"
bash docs/agtoosa-verify.sh
git diff --check
```

Claim boundary: generator installs Retro contract; RL bats are CI-enforced when run; proposal generation is agent-instructed; acceptance is manual; automatic application is roadmap.

## Evidence Status

RED evidence: recorded.
GREEN evidence: recorded (focused).
Review evidence: not recorded.
Ship evidence: not recorded.
