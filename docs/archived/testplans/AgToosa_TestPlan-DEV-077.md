# Test Plan: DEV-077 — Authoring Guide and Onboarding Surface

> **Spec:** `docs/archived/spec-DEV-077.md`
> **Status:** 🟨 Build complete — AUTH GREEN
> **Created:** 2026-07-11
> **Test prefix:** `AUTH`

## Scope

Documentation and adapter contract coverage for canonical authoring content, registry-pack readiness fields, README/help discovery, link integrity, and non-duplication. Registry product behavior is excluded.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | AUTH-001 | Extension guide covers current wiring surfaces | Docs/inventory | Guide names current platform templates, config/staging/install wiring, and parity checks | ✅ Pass |
| AC-002 | AUTH-002 | Pack handbook carries the complete readiness checklist | Docs contract | All seven required readiness fields are checkable and clearly owned | ✅ Pass `@smoke` |
| AC-003 | AUTH-003 | Registry points to one pack handbook | Mirror/non-duplication | Template and maintainer Registry docs link the handbook without copying its full checklist | ✅ Pass |
| AC-004 | AUTH-004 | README exposes both authoring paths | Discovery | README links extension and registry-pack authoring with concise descriptions | ✅ Pass |
| AC-005 | AUTH-005 | Native help surfaces share one authoring pointer | Adapter parity | Every maintained help adapter exposes a generated-project-safe canonical URL | ✅ Pass `@smoke` |
| AC-005 | AUTH-006 | Authoring discovery preserves static help | Regression | Default help still requires no Master-Plan, git, or project-context read | ✅ Pass |
| AC-006 | AUTH-007 | Authoring links fail closed on drift | Link/inventory | Missing or renamed canonical targets fail README, Registry, and adapter checks | ✅ Pass `@smoke` |
| AC-007 | AUTH-008 | Handbook labels enforcement honestly | Claim contract | Repository checks, registry review, manual actions, and roadmap items are distinct | ✅ Pass |

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

## RED Evidence

### RED evidence — 1.1 / Wave 1 discovery contract

```
Command: bats tests/agtoosa.bats -f "DEV-077|AUTH-"
Exit code: 1
Failure excerpt:
  not ok 2 … AUTH-002 … `[ -f "$handbook" ]' failed
  not ok 5 … AUTH-005 … `grep -q "Authoring resources" "$f"' failed
  not ok 7 … AUTH-007 … `[ -f "$root/docs/registry-pack-authoring.md" ]' failed
```

(All 8 AUTH tests failed before handbook/discovery content existed; AUTH-001 failed on missing Codex surface.)

### RED evidence — task groups 2–4

Covered by the same failing suite above (canonical files, Registry/README links, and help pointers absent).

## GREEN Evidence

### GREEN evidence — 5.1 full AUTH suite

```
Command: bats tests/agtoosa.bats -f "DEV-077|AUTH-"
Exit code: 0
Pass excerpt:
  ok 1 DEV-077 AUTH-001
  ok 2 DEV-077 @smoke AUTH-002
  ok 3 DEV-077 AUTH-003
  ok 4 DEV-077 AUTH-004
  ok 5 DEV-077 @smoke AUTH-005
  ok 6 DEV-077 AUTH-006
  ok 7 DEV-077 @smoke AUTH-007
  ok 8 DEV-077 AUTH-008
  1..8
```

### GREEN evidence — content subsets

```
Command: bats tests/agtoosa.bats -f "AUTH-001|AUTH-002|AUTH-008"
Exit code: 0

Command: bats tests/agtoosa.bats -f "AUTH-003|AUTH-004|AUTH-007"
Exit code: 0

Command: bats tests/agtoosa.bats -f "AUTH-005|AUTH-006|AUTH-007"
Exit code: 0
```
