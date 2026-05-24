# Test Plan: DEV-028 — Plan-Mode Spec Interview for /agtoosa-spec

> **Spec:** `docs/archived/spec-DEV-028.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 | Integration | Canonical spec workflow contains the Plan-Mode Spec Interview Contract for full `/agtoosa-spec` | yes |
| AC-002 | T-002 | Integration | Contract requires research/context/codebase exploration before user questions | yes |
| AC-003 | T-003 | Integration | Contract requires one question at a time, contextual options, recommended default, and free-text override | yes |
| AC-004 | T-004 | Integration | Contract requires inferable answers to be stated as findings instead of re-asked | yes |
| AC-005 | T-005 | Integration | Full flow uses adaptive cap 8 and `quick` remains cap 2 | yes |
| AC-006 | T-006 | Integration | Budget exhaustion requires a continue-or-proceed-with-assumptions gate | yes |
| AC-007 | T-007 | Integration | Decision-complete checklist includes Goal Contract, non-goals, ACs, scope, affected surfaces, risk/failure modes, security/trust boundaries, test evidence, rollout/compatibility, and unresolved assumptions | yes |
| AC-008 | T-008 | Integration | All native `/agtoosa-spec` adapters reference the canonical plan-mode contract without duplicating full workflow bodies | yes |
| AC-009 | T-009 | Integration | Spec adapters preserve phase stop and forbid auto-running `/agtoosa-build` | yes |
| AC-010 | T-010 | Integration | Focused DEV-028 tests plus existing adapter/spec regression filters remain green | no |

## Negative / Edge Scenarios

| ID | Scenario | Expected |
|----|----------|----------|
| T-001-N | Remove `Plan-Mode Spec Interview Contract` from the canonical workflow | DEV-028 canonical-contract test fails |
| T-003-N | Remove recommended defaults or one-question-at-a-time wording | Interview-format assertion fails |
| T-005-N | Change full-flow budget back to 4 or `quick` above 2 | Budget assertion fails |
| T-006-N | Remove continue/proceed-with-assumptions gate after budget exhaustion | Budget-exhaustion assertion fails |
| T-007-N | Remove security/trust boundaries or rollout/compatibility from decision-complete checklist | Decision-complete assertion fails |
| T-008-N | Leave one native adapter without plan-mode wording | Adapter parity assertion fails |
| T-009-N | Remove no-auto-build phase-stop wording | Existing W1 or DEV-028 phase-stop assertion fails |

## Smoke Set

T-001, T-002, T-003, T-004, T-005, T-006, T-007, T-008, T-009

## Evidence (build)

| Test ID | Bats test name | Result |
|---------|----------------|--------|
| T-001 | `DEV-028 T-001: canonical spec workflow contains Plan-Mode Spec Interview Contract` | pass |
| T-002 | `DEV-028 T-002: contract requires research before user questions` | pass |
| T-003 | `DEV-028 T-003: contract requires one question at a time and contextual options` | pass |
| T-004 | `DEV-028 T-004: contract requires inferable answers as findings not re-asked` | pass |
| T-005 | `DEV-028 T-005: full flow adaptive cap 8 and quick cap 2` | pass |
| T-006 | `DEV-028 T-006: budget exhaustion continue or proceed with assumptions gate` | pass |
| T-007 | `DEV-028 T-007: decision-complete checklist covers required fields` | pass |
| T-008 | `DEV-028 T-008: native spec adapters reference plan-mode contract without Part duplication` | pass |
| T-009 | `DEV-028 T-009: spec adapters preserve phase stop and forbid auto-build` | pass |
| T-010 | `DEV-028 T-010: maintainer spec mirror contains plan-mode contract` | pass |

Regression (2026-05-24 build): `bats tests/agtoosa.bats -f "DEV-028"` → 10/10; `-f "W1:|W3:|CS1:|CS4:|G4:"` → 6/6; `-f "CS1:|CS2:|CS3:|CS4:|CS5:|CU1:|GM1:|WS1:"` → 8/8. CS1 term updated from `Smart Interview` to `Plan-Mode Spec Interview` to match DEV-028 contract.

Review (2026-05-24): Re-verified DEV-028 filter 10/10; review report `docs/archived/review-DEV-028.md` — verdict PASS, 0 🔴 Critical.

Ship (2026-05-24): `bats tests/agtoosa.bats` → 306/306; version **v5.2.0**; smoke T-001–T-009 9/9 green.
