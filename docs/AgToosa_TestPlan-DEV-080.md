# Test Plan: DEV-080 — Official Registry Pack Pilot

> **Spec:** `docs/archived/spec-DEV-080.md`
> **Status:** ⬜ Backlog
> **Test prefix:** OPP
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** Not run; this plan contains no test or install evidence.

## Coverage Target

Prove the three-pack limit, DEV-053 manifest conformance, examples, compatibility, controlled install behavior, registry safety boundaries, maintenance ownership, and honest external-publication state. All rows are planned until the story is approved, enrolled, and executed.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | OPP-001 | Exactly Three Pilot Domains | Docs/contract | Inventory contains only web, API/service, and infrastructure/security, one primary domain each | Planned — not run `@smoke` |
| AC-002 | Must | OPP-002 | Catalog Manifest Conformance | Schema/integration | All three manifests satisfy the implemented DEV-053 fields, provenance, integrity, and trust classification | Planned — not run `@smoke` |
| AC-003 | Must | OPP-003 | Pack Example Completeness | Docs/contract | Every pack has prerequisites, intended use, runnable example, and explicit non-goals | Planned — not run |
| AC-004 | Must | OPP-004 | Compatibility Boundary Matrix | Docs/contract | Every pack names supported AgToosa versions/platforms and marks incompatible or untested combinations | Planned — not run |
| AC-005 | Must | OPP-005 | Web Pack Clean Install | Integration | Web fixture installs, queues, and merges into an isolated project with the expected file set | Planned — not run `@smoke` |
| AC-005 | Must | OPP-006 | API Service Pack Clean Install | Integration | API/service fixture installs, queues, and merges into an isolated project with the expected file set | Planned — not run |
| AC-005, AC-006 | Must | OPP-007 | Infrastructure Security Pack Safe Install | Integration/security | Infrastructure/security fixture follows preview, consent, queue, and merge boundaries | Planned — not run `@smoke` |
| AC-006 | Must | OPP-008 | Unsafe Pack Boundary Rejection | Negative/security | A denylisted destination or disallowed file is rejected without weakening existing controls | Planned — not run |
| AC-007 | Must | OPP-009 | Maintenance Ownership Contract | Docs/contract | Each pack records owner, cadence, compatibility policy, issue path, and deprecation process | Planned — not run |
| AC-008 | Must | OPP-010 | External Publication State Honesty | Docs/manual boundary | Candidate, submitted, and published states cannot be conflated; published requires confirmed external record | Planned — not run |

## Planned Validation Commands

These commands are illustrative future commands only; they were not executed while creating this plan.

```bash
bats tests/agtoosa.bats -f "DEV-080"
bats tests/agtoosa.bats -f "OPP-"
git diff --check
```

External-registry submission and approval require separately recorded manual confirmation; a local command cannot prove them.

## Smoke Set

- `OPP-001` — Exactly Three Pilot Domains
- `OPP-002` — Catalog Manifest Conformance
- `OPP-005` — Web Pack Clean Install
- `OPP-007` — Infrastructure Security Pack Safe Install

Smoke status: **Planned — not run**.

## TDD Evidence Placeholders

| Future task group | RED evidence | GREEN evidence |
|-------------------|--------------|----------------|
| 1. Catalog gate and pilot contract | Not run; no failing output recorded | Not run; no passing output recorded |
| 2. Three maintained candidates | Not run; no failing output recorded | Not run; no passing output recorded |
| 3. Local install and safety proof | Not run; no failing output recorded | Not run; no passing output recorded |
| 4. Documentation and external boundary | Not run; no failing output recorded | Not run; no passing output recorded |

### RED evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Failure excerpt: Not recorded
- Required future action: add focused OPP assertions before changing the implementation surfaces.

### GREEN evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Passing excerpt: Not recorded
- Required future action: record exact commands and outputs only after all mapped behavior is implemented.

No evidence may be inferred from the existence of this test plan.
