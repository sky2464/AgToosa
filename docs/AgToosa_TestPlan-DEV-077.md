# Test Plan: DEV-077 — Authoring Guide and Onboarding Surface

> **Spec:** `docs/archived/spec-DEV-077.md`
> **Status:** ⬜ Backlog — Not executed
> **Created:** 2026-07-11
> **Test prefix:** `AUTH`

## Scope

Documentation and adapter contract coverage for canonical authoring content, registry-pack readiness fields, README/help discovery, link integrity, and non-duplication. Registry product behavior is excluded.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | AUTH-001 | Extension guide covers current wiring surfaces | Docs/inventory | Guide names current platform templates, config/staging/install wiring, and parity checks | ⬜ Not run |
| AC-002 | AUTH-002 | Pack handbook carries the complete readiness checklist | Docs contract | All seven required readiness fields are checkable and clearly owned | ⬜ Not run |
| AC-003 | AUTH-003 | Registry points to one pack handbook | Mirror/non-duplication | Template and maintainer Registry docs link the handbook without copying its full checklist | ⬜ Not run |
| AC-004 | AUTH-004 | README exposes both authoring paths | Discovery | README links extension and registry-pack authoring with concise descriptions | ⬜ Not run |
| AC-005 | AUTH-005 | Native help surfaces share one authoring pointer | Adapter parity | Every maintained help adapter exposes a generated-project-safe canonical URL | ⬜ Not run |
| AC-005 | AUTH-006 | Authoring discovery preserves static help | Regression | Default help still requires no Master-Plan, git, or project-context read | ⬜ Not run |
| AC-006 | AUTH-007 | Authoring links fail closed on drift | Link/inventory | Missing or renamed canonical targets fail README, Registry, and adapter checks | ⬜ Not run |
| AC-007 | AUTH-008 | Handbook labels enforcement honestly | Claim contract | Repository checks, registry review, manual actions, and roadmap items are distinct | ⬜ Not run |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Extension guide omits a currently installed platform surface | AUTH-001 | Inventory comparison fails |
| Pack checklist omits provenance or named owner | AUTH-002 | Required-field check fails |
| Registry embeds a second complete checklist | AUTH-003 | Non-duplication check fails |
| A template help adapter uses `docs/...` as a downstream-local path | AUTH-005 | Generated-project-safe link check fails |
| Adding the pointer causes default help to read project state | AUTH-006 | Static-help regression fails |
| Handbook calls manual registry approval CI-enforced | AUTH-008 | Claim-boundary check fails |

## Smoke Set

- `@smoke AUTH-002` — complete registry-pack readiness checklist.
- `@smoke AUTH-005` — maintained help adapter parity.
- `@smoke AUTH-007` — canonical link integrity.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-077|AUTH-"`

## RED Evidence — Unexecuted Placeholders

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Authoring discovery contract | `bats tests/agtoosa.bats -f "DEV-077|AUTH-"` | Not recorded | Not run; handbook and discovery contract are pending |
| 2. Canonical authoring content | `bats tests/agtoosa.bats -f "AUTH-001|AUTH-002|AUTH-008"` | Not recorded | Not run; canonical content is not yet complete |
| 3. Registry and README discovery | `bats tests/agtoosa.bats -f "AUTH-003|AUTH-004|AUTH-007"` | Not recorded | Not run; discovery links are pending |
| 4. Help discovery parity | `bats tests/agtoosa.bats -f "AUTH-005|AUTH-006|AUTH-007"` | Not recorded | Not run; help adapters are pending |
| 5. Evidence | `bats tests/agtoosa.bats -f "DEV-077|AUTH-"` | Not recorded | Not run; final evidence pending |

## GREEN Evidence — Unexecuted Placeholders

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Authoring discovery contract | `bats tests/agtoosa.bats -f "DEV-077|AUTH-"` | Not recorded | Not run |
| 2. Canonical authoring content | `bats tests/agtoosa.bats -f "AUTH-001|AUTH-002|AUTH-008"` | Not recorded | Not run |
| 3. Registry and README discovery | `bats tests/agtoosa.bats -f "AUTH-003|AUTH-004|AUTH-007"` | Not recorded | Not run |
| 4. Help discovery parity | `bats tests/agtoosa.bats -f "AUTH-005|AUTH-006|AUTH-007"` | Not recorded | Not run |
| 5. Evidence | `bats tests/agtoosa.bats -f "DEV-077|AUTH-"` | Not recorded | Not run |

No test has been executed for this backlog story.
