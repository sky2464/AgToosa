# Spec: DEV-035 - Launch P0 publication and quickstart gate

> **Story ID:** DEV-035
> **Epic:** DEV-004 - Testing & QA Harness
> **Status:** 🏁 Shipped (v5.2.6 — 2026-06-07)
> **Estimate:** M
> **Spec created:** 2026-06-07
> **Launch specs:** LRS-001, LRS-002, LRS-012 public-link subset, LRS-013 public/private gate subset

## Context

The strategic launch review found that public GitHub, raw bootstrap, registry, Homebrew, and support URLs returned 404 from this environment. The owner clarified this is expected because the repository is intentionally private during staging. That state is acceptable before launch, but the README currently reads as if anonymous public install and support links are ready.

DEV-035 makes the repo launch-aware. It adds a private-staging/public-launch readiness command, updates quickstart and support docs to avoid accidental public claims, and adds regression coverage so private-staging 404s are not confused with public-launch readiness.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make publication status, quickstart install claims, and support links explicitly gated for private staging versus public launch. |
| User outcome | Maintainers can run a local readiness gate before public launch and know exactly which public surfaces still require manual publication. |
| Success condition | README/support docs are truthful in private staging, a launch checker exists, Bats covers private/public mode behavior, and Master-Plan records DEV-035 as the first launch-readiness story. |
| Proof / evidence | `bats tests/agtoosa.bats -f "DEV-035"`, `bash scripts/check-launch-readiness.sh --mode private`, and `git diff --check` pass. |
| Non-goals | Publishing external repos, fixing PowerShell update parity, fixing registry archive shape, Homebrew release hardening, or rewriting competitive positioning. |
| Assumptions | Public launch means anonymous developer access. Private staging remains allowed until launch mode is explicitly enabled. |
| Risks | Docs can drift into looking public-ready before publication. Mitigate with explicit private-staging wording and public-mode URL checks. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN the repo is private THE SYSTEM SHALL state that public install/support URLs are private-staging gates rather than public-ready commands. |
| AC-002 | WHEN a maintainer runs the readiness checker in private mode THE SYSTEM SHALL validate local launch docs and skip anonymous public URL checks. |
| AC-003 | WHEN a maintainer runs the readiness checker in public mode THE SYSTEM SHALL check repo, release, raw bootstrap, registry, support, issues, discussions, and Homebrew URLs if advertised. |
| AC-004 | WHEN README quickstart is read THE SYSTEM SHALL place pinned release guidance before `main` guidance and label `main` as development-only. |
| AC-005 | WHEN support and issue templates are read THE SYSTEM SHALL ask for OS, shell, install command, AgToosa version, target project context, and affected surface. |
| AC-006 | WHEN focused DEV-035 tests run THE SYSTEM SHALL prevent regression to unqualified public-ready wording while the project is private. |

## Design

Add `scripts/check-launch-readiness.sh` with `--mode private` and `--mode public`. Private mode checks local files and docs language only. Public mode performs the same checks plus anonymous URL checks with `curl`.

Update README to say the project is in private staging until publication. Keep the public commands, but label them as launch-target commands that require the repo/release URLs to be public. Keep clone/manual install for private collaborators.

Update GitHub support docs and issue templates so they collect actionable launch-support data.

## Build Scope

Ready to proceed. Files in scope: `scripts/check-launch-readiness.sh`, `README.md`, `.github/SUPPORT.md`, `.github/DISCUSSIONS.md`, `.github/ISSUE_TEMPLATE/bug.yml`, `.github/ISSUE_TEMPLATE/feature.yml`, `tests/agtoosa.bats`, `docs/Master-Plan.md`, and `docs/AgToosa_TestPlan-DEV-035.md`.

## Task Tree

- [ ] **1.** Add failing DEV-035 Bats checks - _AC-001-AC-006_
- [ ] **2.** Implement launch-readiness checker - _AC-002, AC-003, AC-006_
- [ ] **3.** Update README quickstart publication wording - _AC-001, AC-004_
- [ ] **4.** Update support/community docs and issue templates - _AC-005_
- [ ] **5.** Record test-plan evidence - _AC-006_
- [ ] **6.** Run focused and broader validation - _AC-002, AC-006_

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-035.md`
