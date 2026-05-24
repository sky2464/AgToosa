# Spec: DEV-021 — E2E Pinned Registry Install Test

> **Story ID:** DEV-021
> **Epic:** DEV-003 — Community Template Registry
> **Status:** ✅ Done (build complete 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

DEV-020 shipped fail-closed `pack-name@version` enforcement with bats **RV1–RV5**. Review accepted RV1/RV3 as resolver-only tests and RV4 as static grep guards; **AC-001** (full download → SHA-256 verify → stage → `.pack-meta.json`) is not exercised end-to-end in CI.

This story closes that gap with a **network-free** integration test: a fixture registry points at a `file://` tarball URL, `curl` downloads locally, SHA-256 is verified, and the pack lands in `AGTOOSA_PACK_QUEUE_DIR` with the pinned version in metadata.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Prove pinned registry install succeeds through download, integrity check, and queue staging — not only via `registry_resolve_pack_entry`. |
| User outcome | Maintainers trust that DEV-020’s install path works in CI without manual smoke. |
| Success condition | New bats test **RV6** passes: `mock-pack@1.0.0` installs from fixture registry + `file://` tarball into pack queue with correct `.pack-meta.json`. |
| Proof / evidence | `bats tests/agtoosa.bats -f "RV6:"` green; RV1–RV5 remain green. |
| Non-goals | Changing install behavior; PowerShell E2E (Bash-only); live GitHub/network registry fetch; new registry features. |
| Assumptions | `curl` supports `file://` URLs on CI/macOS/Linux runners used for bats. |
| Risks | `file://` unsupported on some runners → fallback to `PATH` curl stub script documented in test plan. |

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a pinned registry install uses a fixture index with matching name, version, URL, and SHA-256 THE SYSTEM SHALL download the tarball, verify SHA-256, stage files in the pack queue, and write `.pack-meta.json` with the resolved version | Must |
| AC-002 | WHEN DEV-021 ships THE SYSTEM SHALL add bats test **RV6** covering the full Bash install path (not resolver-only) | Must |
| AC-003 | WHEN RV6 runs THE SYSTEM SHALL use `AGTOOSA_REGISTRY_CACHE_DIR` and `AGTOOSA_PACK_QUEUE_DIR` so the test is hermetic and does not touch the developer’s global cache | Must |

### 1.3 Out of Scope

- PS1 registry install E2E
- Semver range resolution
- Multi-version registry index schema

## 2. Design

### 2.1 Architecture Blueprint

| Layer | Files | Change |
|-------|-------|--------|
| Test fixture | `tests/fixtures/registry-e2e-pinned.json`, `tests/fixtures/e2e-pack/` (or build tarball in-test from `mock-pack/`) | Registry row: `mock-pack@1.0.0`, `file://` URL, precomputed SHA-256 |
| Tests | `tests/agtoosa.bats` | **RV6**: build tar.gz if needed; run `echo Y \| AGTOOSA_REGISTRY_CACHE_DIR=… AGTOOSA_PACK_QUEUE_DIR=… bash agtoosa.sh --registry install mock-pack@1.0.0`; assert queue dir + meta |
| Docs | `docs/AgToosa_TestPlan-DEV-021.md` | Map AC → RV6 |

**Test flow:**

1. Create minimal pack tarball (single `workflow.md` at archive root — same layout as community packs).
2. `sha256sum` → embed in registry JSON.
3. Point `url` at `file://$tmpdir/pack.tar.gz`.
4. Run CLI install with pinned spec; assert exit 0, `$queue/mock-pack/.pack-meta.json` has `"version": "1.0.0"`.

**Fallback if `file://` fails on a runner:** prepend `PATH` with a stub `curl` that copies the fixture tarball when invoked with the expected URL (document in test plan).

### 2.2 STRIDE (abbreviated)

| Threat | Mitigation |
|--------|------------|
| Test passes while production download path regresses | RV6 calls full `registry_install` via CLI, not sourced helper only |
| Fixture tarball drifts from declared SHA-256 | Test computes SHA at runtime before writing registry JSON |

### 2.3 Build Scope

Files in scope: `tests/agtoosa.bats`, `tests/fixtures/` (new/updated fixtures only)

Out of scope: `lib/registry.sh` behavior changes unless required for testability (prefer env vars only)

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Fixture pack tarball and registry index
  - [x] 1.1 Tar-from-`mock-pack` in RV6 (no separate e2e-pack fixture) — _AC-001_
  - [x] 1.2 RV6 builds registry JSON with `file://` URL + matching SHA-256 — _AC-001, AC-003_
- [x] **2.** Bats RV6
  - [x] 2.1 Implement `@test "RV6: pinned registry install E2E stages pack with correct version"` — _AC-001, AC-002_
  - [x] 2.2 `file://` verified on macOS CI path; curl stub deferred (not needed) — _AC-001_
- [x] **3.** Verification
  - [x] 3.1 `docs/AgToosa_TestPlan-DEV-021.md` — _AC-002_
  - [x] 3.2 `bats -f "RV[1-6]:"` — 6/6 green — _AC-002_

### 3.2 Wave Plan

**Wave 1:** 1.1, 1.2

**Wave 2:** 2.1, 2.2

**Wave 3:** 3.1, 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-021.md`

## ✅ Spec Approved

Approved: 2026-05-24
