# Test Plan: DEV-080 — Official Registry Pack Pilot

> **Spec:** `docs/archived/spec-DEV-080.md`
> **Status:** 🟨 Build executed
> **Test prefix:** OPP
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** RED then GREEN recorded 2026-07-11; manual external publish open.

## Coverage Target

Prove the three-pack limit, DEV-053 manifest conformance, examples, compatibility, controlled install behavior, registry safety boundaries, maintenance ownership, and honest external-publication state.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | OPP-001 | Exactly Three Pilot Domains | Docs/contract | Inventory contains only web, API/service, and infrastructure/security, one primary domain each | Pass `@smoke` |
| AC-002 | Must | OPP-002 | Catalog Manifest Conformance | Schema/integration | All three manifests satisfy the implemented DEV-053 fields, provenance, integrity, and trust classification | Pass `@smoke` |
| AC-003 | Must | OPP-003 | Pack Example Completeness | Docs/contract | Every pack has prerequisites, intended use, runnable example, and explicit non-goals | Pass |
| AC-004 | Must | OPP-004 | Compatibility Boundary Matrix | Docs/contract | Every pack names supported AgToosa versions/platforms and marks incompatible or untested combinations | Pass |
| AC-005 | Must | OPP-005 | Web Pack Clean Install | Integration | Web fixture installs, queues, and merges into an isolated project with the expected file set | Pass `@smoke` |
| AC-005 | Must | OPP-006 | API Service Pack Clean Install | Integration | API/service fixture installs, queues, and merges into an isolated project with the expected file set | Pass |
| AC-005, AC-006 | Must | OPP-007 | Infrastructure Security Pack Safe Install | Integration/security | Infrastructure/security fixture follows preview, consent, queue, and merge boundaries | Pass `@smoke` |
| AC-006 | Must | OPP-008 | Unsafe Pack Boundary Rejection | Negative/security | A denylisted destination or disallowed file is rejected without weakening existing controls | Pass |
| AC-007 | Must | OPP-009 | Maintenance Ownership Contract | Docs/contract | Each pack records owner, cadence, compatibility policy, issue path, and deprecation process | Pass |
| AC-008 | Must | OPP-010 | External Publication State Honesty | Docs/manual boundary | Candidate, submitted, and published states cannot be conflated; published requires confirmed external record | Pass |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-080"
git diff --check
```

External-registry submission and approval require separately recorded manual confirmation; a local command cannot prove them. Tasks 4.2/4.3 remain `[manual-deferred]`.

## Smoke Set

- `OPP-001` — Exactly Three Pilot Domains
- `OPP-002` — Catalog Manifest Conformance
- `OPP-005` — Web Pack Clean Install
- `OPP-007` — Infrastructure Security Pack Safe Install

Smoke status: **Pass** (included in GREEN run below).

## TDD Evidence

| Task group | RED evidence | GREEN evidence |
|------------|--------------|----------------|
| 1. Catalog gate and pilot contract | Recorded (OPP fail before packs/docs) | Recorded |
| 2. Three maintained candidates | Recorded | Recorded |
| 3. Local install and safety proof | Recorded | Recorded |
| 4. Documentation and external boundary | Recorded (4.1 automated; 4.2/4.3 deferred) | Recorded for 4.1 |

### RED evidence — OPP suite (before pack authorship)

```
RED evidence — 3.1 / OPP-001–OPP-010
Command: bats tests/agtoosa.bats -f "DEV-080"
Exit code: nonzero (10 failed)
Failure excerpt:
  not ok 1 DEV-080 @smoke OPP-001: Exactly Three Pilot Domains
  #   `grep -q "## Official Pack Pilot" "$inv"' failed
  not ok 2 DEV-080 @smoke OPP-002: Catalog Manifest Conformance
  #   `[ -f "$root/packs/$pack/manifest.json" ]' failed
  not ok 5 DEV-080 @smoke OPP-005: Web Pack Clean Install
  #   `[ -d "$fixture" ]' failed
```

### GREEN evidence — OPP suite (after packs, fixtures, inventory)

```
GREEN evidence — DEV-080 automated tasks
Command: bats tests/agtoosa.bats -f "DEV-080"
Exit code: 0
Passing excerpt:
  ok 1 DEV-080 @smoke OPP-001: Exactly Three Pilot Domains
  ok 2 DEV-080 @smoke OPP-002: Catalog Manifest Conformance
  ok 5 DEV-080 @smoke OPP-005: Web Pack Clean Install
  ok 7 DEV-080 @smoke OPP-007: Infrastructure Security Pack Safe Install
  ok 10 DEV-080 OPP-010: External Publication State Honesty
  (10/10 ok)

Command: git diff --check
Exit code: 0
```

### Manual publish — open

- Task 4.2 Submit external registry entries — `[manual-deferred: 2026-07-11]`
- Task 4.3 Confirm accepted external records — `[manual-deferred: 2026-07-11]`
- Local state remains **local candidate** / **not externally published**
