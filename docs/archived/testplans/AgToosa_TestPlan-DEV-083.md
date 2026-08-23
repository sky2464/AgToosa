# Test Plan: DEV-083 — Voluntary Workflow Metrics and Case Study Kit

> **Spec:** `docs/archived/spec-DEV-083.md`
> **Status:** ✅ Build complete — MET contract green
> **Test prefix:** MET
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** RED then GREEN recorded 2026-07-11; no user metric data or real case-study evidence claimed.

## Coverage Target

Check that the future kit is voluntary and local-only, defines a complete common schema and case-study boundary, covers all six requested measures, installs as documentation, and introduces no collection or reporting path.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | MET-001 | Voluntary Local-Only Boundary | Docs/security | Kit requires opt-in, local source control, redaction/withdrawal, and no hooks, network sender, background analytics, or auto-reporting | ✅ Pass `@smoke` |
| AC-002 | Must | MET-002 | Common Metric Schema Completeness | Docs/contract | Every required purpose, population, formula/unit, window, source, exclusion, missing-data, privacy, evidence, limitation, and consent field exists | ✅ Pass |
| AC-002 | Must | MET-003 | Evidence-Bounded Case Study Template | Docs/claim boundary | Case-study template separates context, method, evidence, synthetic/observed state, limits, consent, and publication review | ✅ Pass `@smoke` |
| AC-003 | Must | MET-004 | Install Success Definition | Docs/contract | Template distinguishes attempts, completion, post-install check, failure stage, platform/version, and retry | ✅ Pass `@smoke` |
| AC-004 | Must | MET-005 | Verifier Adoption Definition | Docs/contract | Template distinguishes eligibility, availability, actual runs, mode, result, follow-up, and window | ✅ Pass |
| AC-005 | Must | MET-006 | Handoff Import Outcome Definition | Docs/privacy | Template distinguishes export/import outcomes and target without collecting handoff content | ✅ Pass |
| AC-006 | Must | MET-007 | Cross-Model Finding State Definition | Docs/safety | Template distinguishes proposed, confirmed, duplicate, rejected, and resolved findings and prohibits individual scoring | ✅ Pass |
| AC-007 | Must | MET-008 | Cycle Time Boundary Definition | Docs/contract | Template defines events, pauses, deferred intervals, incomplete cycles, timezone, aggregation, and sample size | ✅ Pass |
| AC-008 | Must | MET-009 | Pack Maintenance No-SLA Definition | Docs/claim boundary | Template records population, review age, open items, response state, deprecation, and date without SLA language | ✅ Pass |
| AC-001, AC-002 | Must | MET-010 | Metrics Kit Inventory and Mirror Contract | Bats/integration | Canonical kit and case-study template install/update correctly, mirrors align, and only documentation artifacts are added | ✅ Pass `@smoke` |

## Planned Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-083"
bats tests/agtoosa.bats -f "MET-"
git diff --check
```

A human privacy and claims review remains required for any future real publication. Contract tests prove kit language and inventory, not that a future user consents correctly.

## Smoke Set

- `MET-001` — Voluntary Local-Only Boundary — ✅ Pass
- `MET-003` — Evidence-Bounded Case Study Template — ✅ Pass
- `MET-004` — Install Success Definition — ✅ Pass
- `MET-010` — Metrics Kit Inventory and Mirror Contract — ✅ Pass

Smoke status: **Pass** (2026-07-11).

## TDD Evidence

| Task group | RED evidence | GREEN evidence |
|------------|--------------|----------------|
| 1. Voluntary measurement contract | See RED block | See GREEN block |
| 2. Six metric templates | See RED block | See GREEN block |
| 3. Documentation kit | See RED block | See GREEN block |
| 4. Documentation contract proof | See RED block | See GREEN block |

### RED evidence — Wave 1 (MET bats before kit files)

- Command: `bats tests/agtoosa.bats -f "DEV-083"`
- Exit code: 1 (10 failed)
- Failure excerpt: `[ -f "$f" ]' failed` / `[ -f "$MET_KIT_TEMPLATE" ]' failed` (kit and case-study files absent)
- Required action completed: author kit + case-study templates, mirrors, and `lib/config.sh` registration.

### GREEN evidence — after kit + registration

- Command: `bats tests/agtoosa.bats -f "DEV-083"`
- Exit code: 0
- Passing excerpt: `ok 1` … `ok 10` (MET-001–MET-010)
- Also: `git diff --check` exit 0; `--list-template-files` lists both Docs artifacts.

### Privacy / claims review evidence — 2026-07-11

| Check | Result |
|-------|--------|
| Opt-in, local-only, redaction, withdrawal, consent | Present in MetricsKit §1 |
| No affirmative curl/POST/submit telemetry instructions in kit | Pass (exclusion list only) |
| No telemetry/collection hooks added to `agtoosa.sh` / `lib/*.sh` | Pass (docs inventory only) |
| Six metrics + common schema + synthetic labels | Present; examples labeled SYNTHETIC / non-customer |
| Case study claim boundary + publication checklist | Present |
| No individual scoring / no-SLA language | Present |
| Versions bumped | **Not done** (out of scope per story) |

No real metric results or customer case studies were authored or claimed.
