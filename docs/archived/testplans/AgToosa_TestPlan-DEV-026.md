# Test Plan: DEV-026 — Codex Agent Mode Spec Workflow Execution

> **Spec:** `docs/archived/spec-DEV-026.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 | Integration | Codex spec skill and prompt require full-flow execution terms: research, Smart Interview, Goal Contract, task planning, test plan skeleton, and approval gate | yes |
| AC-002 | T-002 | Integration | Codex spec prompt/skill preserve sub-command dispatch for `research`, `plan`, `quick`, `tasks`, and `to-issues` | yes |
| AC-003 | T-003 | Integration | Codex spec adapter still references `Docs/AgToosa_Spec.md` as canonical and does not duplicate full `## Part 1` / `## Part 2` workflow bodies | yes |
| AC-004 | T-004 | Integration | DEV-026 bats assertions fail if required agent-mode execution contract terms are removed | yes |
| AC-005 | T-005 | Integration | Existing W1 phase-stop coverage still proves Codex spec surfaces do not auto-run `/agtoosa-build` | yes |

## Negative / Edge Scenarios

| ID | Scenario | Expected |
|----|----------|----------|
| T-001-N | Remove `Smart Interview` or `Goal Contract` from the Codex skill contract | DEV-026 focused bats test fails |
| T-003-N | Add copied `## Part 1` / `## Part 2` sections to the Codex skill | Non-duplication assertion fails |
| T-005-N | Remove the `/agtoosa-build` phase-stop wording from a Codex spec surface | W1 phase-stop test fails |

## Smoke Set

T-001, T-002, T-003, T-004, T-005

## Evidence (build)

| Test ID | Bats test | Result |
|---------|-----------|--------|
| T-001 | `CS1: Codex spec skill and prompt require agent-mode execution contract terms` | pass |
| T-002 | `CS2: Codex spec skill and prompt preserve sub-command dispatch` | pass |
| T-003 | `CS3: Codex spec adapter keeps Docs/AgToosa_Spec.md canonical without Part duplication` | pass |
| T-004 | `CS1`–`CS4` (contract regression bundle) | pass |
| T-005 | `CS5` + `W1: spec adapters forbid auto-chaining to /agtoosa-build` | pass |

Focused filter (`CS1|CS2|CS3|CS4|CS5|K2|K3|W1|CX1`): 11/11 green. Full suite: 287/287 green (2026-05-24 build).
