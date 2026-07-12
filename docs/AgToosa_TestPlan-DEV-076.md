# Test Plan: DEV-076 — Static Documentation Site Proof

> **Spec:** `docs/archived/spec-DEV-076.md`
> **Status:** ✅ Executed — SITE GREEN
> **Created:** 2026-07-11
> **Executed:** 2026-07-11
> **Test prefix:** `SITE`

## Scope

Build and repository-contract proof for a GitHub Pages-compatible artifact sourced directly from canonical markdown. Deployment availability and user adoption are not tested.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | SITE-001 | Pages build reads canonical docs directly | Integration | Builder source is `docs/`; output is temporary and no copied markdown tree exists | ✅ Pass |
| AC-001, AC-002 | SITE-002 | Site navigation links instead of cloning prose | Docs/source contract | Landing content points to canonical paths and contains no maintained guide copy | ✅ Pass |
| AC-003 | SITE-003 | Pull-request workflow fails closed on build error | Workflow contract | Matching docs/config changes invoke the build and preserve its non-zero exit | ✅ Pass |
| AC-004 | SITE-004 | Project Pages base path resolves | Build/link | Representative navigation and assets resolve below `/AgToosa/` | ✅ Pass |
| AC-005 | SITE-005 | Representative canonical pages render | Build | Entry content, Agent guide, and first-15 walkthrough appear in output | ✅ Pass |
| AC-005 | SITE-006 | Artifact identifies its source revision | Provenance | Workflow logs or metadata contain the checked-out commit SHA | ✅ Pass |
| AC-006 | SITE-007 | Proof has no runtime service or tracking | Security/source | Scoped files contain no backend, database, auth, analytics, or runtime secret requirement | ✅ Pass |
| AC-003, AC-006 | SITE-008 | Docs workflow is pinned and least privilege | Security/workflow | Third-party actions are immutable-pinned and workflow permissions are read-only for build | ✅ Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Build source points to a duplicated `site-content/` directory | SITE-001 | Source-boundary test fails |
| Root-relative links omit the `/AgToosa/` prefix | SITE-004 | Link test fails |
| One representative canonical page is copied but not rendered from its source | SITE-002, SITE-005 | Source/render assertions fail |
| Workflow swallows a non-zero builder exit | SITE-003 | Workflow contract test fails |
| Workflow requests write or deploy permissions during the proof | SITE-008 | Least-privilege check fails |
| Analytics key or backend URL appears in configuration | SITE-007 | No-runtime check fails |

## Smoke Set

- `@smoke SITE-001` — canonical source and ephemeral output.
- `@smoke SITE-003` — pull-request build fails closed.
- `@smoke SITE-005` — representative pages render.

Smoke command: `bats tests/agtoosa.bats -f "DEV-076|SITE-"`

## RED Evidence

### RED evidence — 1.1 / Wave 1 (proof contract)

```
Command: bats tests/agtoosa.bats -f "DEV-076|SITE-"
Exit code: 1
Failure excerpt:
  not ok 1 DEV-076 @smoke SITE-001: ... `[ -f "$config" ]' failed
  not ok 2 DEV-076 SITE-002: ... `[ -f "$index" ]' failed
  not ok 3 DEV-076 @smoke SITE-003: ... `[ -f "$wf" ]' failed
  (8/8 SITE tests failed before implementation)
```

## GREEN Evidence

### GREEN evidence — 1–5 (full SITE suite)

```
Command: bats tests/agtoosa.bats -f "DEV-076|SITE-"
Exit code: 0
Pass excerpt:
  ok 1 DEV-076 @smoke SITE-001: Pages build reads canonical docs directly
  ok 2 DEV-076 SITE-002: Site navigation links instead of cloning prose
  ok 3 DEV-076 @smoke SITE-003: Pull-request workflow fails closed on build error
  ok 4 DEV-076 SITE-004: Project Pages base path resolves
  ok 5 DEV-076 @smoke SITE-005: Representative canonical pages render
  ok 6 DEV-076 SITE-006: Artifact identifies its source revision
  ok 7 DEV-076 SITE-007: Proof has no runtime service or tracking
  ok 8 DEV-076 SITE-008: Docs workflow is pinned and least privilege
  1..8
```

## Spike Recommendation

**Proceed (optional owner enablement) — do not launch a production docs platform yet.**

Evidence shows a pinned, least-privilege, build-only workflow can render canonical `docs/` under `/AgToosa/` into an ephemeral artifact without a second source tree, backend, or analytics. Repository owners may later enable GitHub Pages deployment as a separate decision; this spike does not require or automate production deploy.
