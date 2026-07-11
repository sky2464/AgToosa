# Test Plan: DEV-075 — Subagent and Persona Guide Suite

> **Spec:** `docs/archived/spec-DEV-075.md`
> **Status:** ⬜ Backlog — Not executed
> **Created:** 2026-07-11
> **Test prefix:** `ADP`

## Scope

Documentation contract coverage for the two-lane walkthrough, three audience guides, safety boundaries, canonical links, and README discovery. No live agent or model call is required.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | ADP-001 | Walkthrough preserves the end-to-end lane sequence | Docs contract | Spec → two lanes → handoff → import → cross-model review appears in order | ⬜ Not run |
| AC-002 | ADP-002 | Each lane is bounded and merge-safe | Docs contract | Both lanes name ACs, files, actions, verification, return fields, and overlap handling | ⬜ Not run |
| AC-003 | ADP-003 | Imported evidence gates closure | Docs contract | Walkthrough forbids task closure before import mapping and local verification | ⬜ Not run |
| AC-004 | ADP-004 | Review path is independent or honestly downgraded | Docs contract | Writer/reviewer roles and sequential/skip fallbacks are explicit | ⬜ Not run |
| AC-005 | ADP-005 | Audience guide inventory is complete | File/integration | Subagent-heavy, security-sensitive, and solo-developer guides exist | ⬜ Not run |
| AC-005 | ADP-006 | Guides route to canonical workflow owners | Link contract | Relevant guides link Handoff, Import, Cross-Model Review, and Agent Capability docs | ⬜ Not run |
| AC-006 | ADP-007 | Security guide enforces least-privilege documentation | Security/docs | Secret redaction, STRIDE, protected surfaces, and explicit authorization are present | ⬜ Not run |
| AC-007 | ADP-008 | README exposes every guide | Discovery | README links the walkthrough and all three audience guides | ⬜ Not run |
| AC-007 | ADP-009 | Navigation does not fork canonical contracts | Regression | README and guide navigation link rather than copy full command/enforcement contracts | ⬜ Not run |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Lane A and Lane B both own the same file without a merge rule | ADP-002 | Contract check fails |
| Walkthrough moves directly from handoff return to completed task | ADP-003 | Contract check fails |
| Same writer persona is called an independent reviewer without disclosure | ADP-004 | Contract check fails |
| Security guide permits secrets or silent `.github/workflows/` edits | ADP-007 | Security wording check fails |
| README copies a full workflow table that can drift | ADP-009 | Non-duplication check fails |

## Smoke Set

- `@smoke ADP-001` — end-to-end sequence.
- `@smoke ADP-003` — import-before-closure boundary.
- `@smoke ADP-007` — security-sensitive delegation boundary.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-075|ADP-"`

## RED Evidence — Unexecuted Placeholders

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Contract tests and shared structure | `bats tests/agtoosa.bats -f "DEV-075|ADP-"` | Not recorded | Not run; expect missing guide inventory and links before implementation |
| 2. End-to-end walkthrough | `bats tests/agtoosa.bats -f "ADP-001|ADP-002|ADP-003|ADP-004"` | Not recorded | Not run; walkthrough does not yet exist |
| 3. Audience guides | `bats tests/agtoosa.bats -f "ADP-005|ADP-006|ADP-007"` | Not recorded | Not run; audience guides do not yet exist |
| 4. Discovery without duplication | `bats tests/agtoosa.bats -f "ADP-008|ADP-009"` | Not recorded | Not run; discovery links are not yet implemented |
| 5. Evidence | `bats tests/agtoosa.bats -f "DEV-075|ADP-"` | Not recorded | Not run; final evidence pending build |

## GREEN Evidence — Unexecuted Placeholders

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Contract tests and shared structure | `bats tests/agtoosa.bats -f "DEV-075|ADP-"` | Not recorded | Not run |
| 2. End-to-end walkthrough | `bats tests/agtoosa.bats -f "ADP-001|ADP-002|ADP-003|ADP-004"` | Not recorded | Not run |
| 3. Audience guides | `bats tests/agtoosa.bats -f "ADP-005|ADP-006|ADP-007"` | Not recorded | Not run |
| 4. Discovery without duplication | `bats tests/agtoosa.bats -f "ADP-008|ADP-009"` | Not recorded | Not run |
| 5. Evidence | `bats tests/agtoosa.bats -f "DEV-075|ADP-"` | Not recorded | Not run |

No test has been executed for this backlog story.
