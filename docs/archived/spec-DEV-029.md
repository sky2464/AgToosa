# Spec: DEV-029 — Stop Branch-Protection Workflow Failure Emails

> **Story ID:** DEV-029
> **Epic:** DEV-004 — Maintainer CI / Release Hygiene
> **Status:** 🏁 Shipped (v5.2.1 — 2026-05-25; manual tasks 3–4 complete 2026-06-06)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

GitHub creates failed workflow runs for `.github/workflows/branch-protection.yml` on `push` events to `main` (for example commit `24edd76`), even though the workflow only declared `pull_request`. Failed run `26369623155` had `event: push`, `headBranch: main`, `jobs: []`, and GitHub reported “No jobs were run.”

The repository is private and ruleset/branch-protection APIs return 403 (“Upgrade to GitHub Pro or make this repository public”), so protected-branch automation cannot rely on GitHub rulesets today. The workflow must be push-safe on its own.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Stop failure emails from empty workflow runs on push to `main` while preserving PR hygiene checks. |
| User outcome | Pushes to `main` produce a successful workflow run; PRs still enforce labels and description. |
| Success condition | `push` to `main` runs a minimal success job; `pull_request` runs existing validation jobs; no “No jobs were run” failures. |
| Proof / evidence | `gh run list --repo sky2464/AgToosa --workflow branch-protection.yml --limit 5` shows `success` after the next push. |
| Non-goals | Enabling GitHub Pro rulesets; changing repository plan; renaming the workflow file path. |
| Assumptions | Fix is workflow-only; unrelated local worktree changes stay untouched. |

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a commit is pushed to `main` THE SYSTEM SHALL run `.github/workflows/branch-protection.yml` with at least one job that completes successfully | Must |
| AC-002 | WHEN a pull request targets `main` THE SYSTEM SHALL run label, description, and issue-link checks unchanged | Must |
| AC-003 | WHEN the workflow runs on `push` THE SYSTEM SHALL NOT run PR-only validation jobs | Must |
| AC-004 | WHEN the workflow display name is shown in GitHub THE SYSTEM MAY use “PR Hygiene Checks” while keeping file path `branch-protection.yml` | Should |

## 2. Implementation

### 2.1 Workflow changes

- Add `push: branches: [main]` trigger.
- Add `push-main-ok` job with `if: github.event_name == 'push'`.
- Guard `require-labels`, `require-description`, `link-issue`, and `all-checks-pass` with `if: github.event_name == 'pull_request'`.
- Rename workflow `name` to `PR Hygiene Checks`.

### 2.2 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Push events run zero jobs and emit failure emails | Denial of Service | AC-001, AC-003 — `push-main-ok` job on `push` only |
| PR hygiene checks accidentally skipped on `pull_request` | Tampering | AC-002 — PR jobs guarded with `if: github.event_name == 'pull_request'` |
| Maintainer mistakes push-safe workflow for disabled branch protection | Spoofing | Workflow name `PR Hygiene Checks`; docs note ruleset APIs unavailable on private repo |
| Workflow YAML drift reintroduces empty push runs | Repudiation | DEV-029 bats T-001–T-005 lock triggers, guards, and display name |
| False confidence from green push job without PR checks | Elevation of Privilege | Manual tasks 3–4 verify live GitHub behavior post-merge |

## Build Scope

| File / area | Change |
|-------------|--------|
| `.github/workflows/branch-protection.yml` | Push-safe triggers, job guards, display name |
| `tests/agtoosa.bats` | DEV-029 structural regression tests |
| `docs/AgToosa_TestPlan-DEV-029.md` | AC → test mapping |
| `docs/Master-Plan.md` | Active tasks and cycle bookkeeping |

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Workflow push-safe + PR guards
  - [x] 1.1 Add `push` trigger and `push-main-ok` job — _AC-001, AC-003_
  - [x] 1.2 Guard PR jobs with `if: github.event_name == 'pull_request'` — _AC-002, AC-003_
  - [x] 1.3 Rename workflow display name to PR Hygiene Checks — _AC-004_
- [x] **2.** Regression coverage
  - [x] 2.1 Add DEV-029 bats T-001–T-005 — _AC-001–AC-004, AC-010_
  - [x] 2.2 Add `docs/AgToosa_TestPlan-DEV-029.md` — _AC-010_
- [x] **3.** Post-merge verification — push run `26419089522` success
  - [x] 3.1 Push to `main` yields successful run — _AC-001_
  - [x] 3.2 `gh run list --workflow branch-protection.yml --limit 5` shows success — _AC-001_
- [x] **4.** PR path regression — PR #29 / run `27050231744` success
  - [x] 4.1 PR to `main` still runs label/description/issue checks — _AC-002_

### Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3, 2.1, 2.2
**Wave 2 (manual-deferred):** 3.1, 3.2, 4.1

### 3.2 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-029.md`

## ✅ Spec Approved

Approved: 2026-05-24 (plan review — DEV-029)
