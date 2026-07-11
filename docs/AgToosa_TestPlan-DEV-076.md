# Test Plan: DEV-076 — Static Documentation Site Proof

> **Spec:** `docs/archived/spec-DEV-076.md`
> **Status:** ⬜ Backlog — Not executed
> **Created:** 2026-07-11
> **Test prefix:** `SITE`

## Scope

Build and repository-contract proof for a GitHub Pages-compatible artifact sourced directly from canonical markdown. Deployment availability and user adoption are not tested.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | SITE-001 | Pages build reads canonical docs directly | Integration | Builder source is `docs/`; output is temporary and no copied markdown tree exists | ⬜ Not run |
| AC-001, AC-002 | SITE-002 | Site navigation links instead of cloning prose | Docs/source contract | Landing content points to canonical paths and contains no maintained guide copy | ⬜ Not run |
| AC-003 | SITE-003 | Pull-request workflow fails closed on build error | Workflow contract | Matching docs/config changes invoke the build and preserve its non-zero exit | ⬜ Not run |
| AC-004 | SITE-004 | Project Pages base path resolves | Build/link | Representative navigation and assets resolve below `/AgToosa/` | ⬜ Not run |
| AC-005 | SITE-005 | Representative canonical pages render | Build | Entry content, Agent guide, and first-15 walkthrough appear in output | ⬜ Not run |
| AC-005 | SITE-006 | Artifact identifies its source revision | Provenance | Workflow logs or metadata contain the checked-out commit SHA | ⬜ Not run |
| AC-006 | SITE-007 | Proof has no runtime service or tracking | Security/source | Scoped files contain no backend, database, auth, analytics, or runtime secret requirement | ⬜ Not run |
| AC-003, AC-006 | SITE-008 | Docs workflow is pinned and least privilege | Security/workflow | Third-party actions are immutable-pinned and workflow permissions are read-only for build | ⬜ Not run |

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

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-076|SITE-"`

## RED Evidence — Unexecuted Placeholders

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Define the proof contract | `bats tests/agtoosa.bats -f "DEV-076|SITE-"` | Not recorded | Not run; site proof files do not yet exist |
| 2. Configure the static source | `bats tests/agtoosa.bats -f "SITE-001|SITE-002|SITE-004"` | Not recorded | Not run; source configuration and landing page are pending |
| 3. Add the build-only workflow | `bats tests/agtoosa.bats -f "SITE-003|SITE-006|SITE-008"` | Not recorded | Not run; workflow is pending |
| 4. Prove representative rendering | `bats tests/agtoosa.bats -f "SITE-004|SITE-005|SITE-007"` | Not recorded | Not run; no static artifact has been built |
| 5. Record spike evidence | `bats tests/agtoosa.bats -f "DEV-076|SITE-"` | Not recorded | Not run; recommendation pending |

## GREEN Evidence — Unexecuted Placeholders

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Define the proof contract | `bats tests/agtoosa.bats -f "DEV-076|SITE-"` | Not recorded | Not run |
| 2. Configure the static source | `bats tests/agtoosa.bats -f "SITE-001|SITE-002|SITE-004"` | Not recorded | Not run |
| 3. Add the build-only workflow | `bats tests/agtoosa.bats -f "SITE-003|SITE-006|SITE-008"` | Not recorded | Not run |
| 4. Prove representative rendering | `bats tests/agtoosa.bats -f "SITE-004|SITE-005|SITE-007"` | Not recorded | Not run |
| 5. Record spike evidence | `bats tests/agtoosa.bats -f "DEV-076|SITE-"` | Not recorded | Not run |

No test or GitHub Pages deployment has been executed for this backlog spike.
