# Spec: DEV-151 — Tracker Publish CI Automation

> **Story ID:** DEV-151
> **Epic:** DEV-139 — GitHub Issues PM Bridge / DEV-051 — Tracker Sync Bridge
> **Status:** 🟦 Todo
> **Estimate:** S
> **Clarity:** `ready`
> **Spec created:** 2026-08-01
> **Extends:** DEV-147 (v5.3.60) — GIP bats + doctor + `lib/github-issues-sync.sh`

> **Milestone re-target (2026-08-23):** originally approved for v5.3.61; re-targeted to v5.3.63 — v5.3.61/v5.3.62 shipped unrelated fixes. See Master-Plan Update Log.

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Gap | DEV-147 shipped GIP bats but `agtoosa-issues-sync.yml` runs live `gh` without bats preflight; stale checkout pin; no `pull_request` gate |
| Post-ship | `release-advanced.yml` has no `issues-sync` job after publish — backlog/Issues drift until next Master-Plan push |
| Authority | Master-Plan remains SoT; sync is provider-enforced via `gh` + `GITHUB_TOKEN` |
| Non-goals carry-forward | No webhook sync; no `bootstrap --apply` auto-publish; no Projects v2 |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Wave packaging? | **A** — single v5.3.61 wave with DEV-150 |
| Q2 | DEV-151 narrowest slice? | **B** — CI hardening + post-ship `issues-sync` hook from `release-advanced.yml` |

#### Documented assumptions

- Post-ship sync uses same `scripts/agtoosa-issues-sync.sh` as push workflow; requires `contents: write` + `issues: write`.
- Post-ship job is best-effort (`continue-on-error: true`) so release is not blocked by Issues API failures.
- PR gate runs dry-run + GIP bats only — no live `gh` on PRs.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Automate and harden the GitHub Issues publish path: bats preflight before live sync, PR validation on Master-Plan changes, and post-release Issues sync |
| User outcome | Maintainers get failing CI before a bad publish reaches `main`; releases keep GitHub Issues aligned without waiting for the next Master-Plan push |
| Success condition | GIA-001–GIA-008 green; workflow runs GIP bats before live sync; PR job dry-runs on Master-Plan edits; post-ship job triggers after release publish |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-151.md`; bats GIA-001–GIA-008; workflow YAML review |
| Non-goals | Webhook bidirectional sync; `bootstrap --apply` → auto-publish; live `gh` in PR jobs; PowerShell sync reimplementation |
| Assumptions | `GITHUB_TOKEN` permissions sufficient in release environment; DEV-147 lib/fixtures remain stable |
| Risks | Post-ship sync races with concurrent Master-Plan edits; duplicate README roadmap commits; mock/bats drift from workflow flags |
| Unresolved questions | None |

### 1.2 User Stories

**As a** maintainer, **I want** GIP bats to run in CI before live `gh` sync **so that** publish regressions fail the workflow before mutating Issues.

**As a** maintainer, **I want** Issues synced after each release **so that** shipped story states mirror GitHub without a manual Master-Plan push.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa-issues-sync.yml` runs on `main` push THE SYSTEM SHALL execute `bats tests/agtoosa.bats -f "GIP-"` before live `gh` sync | Must |
| AC-002 | WHEN a pull request modifies `docs/Master-Plan.md` THE SYSTEM SHALL run `agtoosa-issues-sync.sh --dry-run` and GIP bats without live `gh` upsert | Must |
| AC-003 | WHEN `agtoosa-issues-sync.yml` checkout step runs THE SYSTEM SHALL use the same pinned `actions/checkout` SHA as other maintainer workflows | Must |
| AC-004 | WHEN `release-advanced.yml` completes `publish-release` THE SYSTEM SHALL run a post-ship job that invokes `agtoosa-issues-sync.sh` with `GITHUB_TOKEN` | Must |
| AC-005 | WHEN post-ship sync job fails THE SYSTEM SHALL NOT fail the overall release (`continue-on-error: true`) | Must |
| AC-006 | WHEN post-ship sync mutates `README.md` THE SYSTEM SHALL commit with `[skip ci]` message consistent with existing sync workflow | Must |
| AC-007 | WHEN template workflow example exists THE SYSTEM SHALL mirror maintainer workflow changes to `template/.github/workflows/agtoosa-issues-sync.yml.example` | Must |
| AC-008 | WHEN `docs/AgToosa_TrackerSync.md` documents CI paths THE SYSTEM SHALL describe PR gate, bats preflight, and post-ship hook | Must |

### 1.4 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| GIP bats preflight | CI-enforced | Blocks live sync on `main` |
| PR dry-run + bats | CI-enforced | No network upsert on PR |
| Post-ship sync | provider-enforced | `gh` + token; best-effort |
| Master-Plan authority | generator-enforced | Unchanged |

### 1.5 Brownfield Baseline

| Item | Current state | Intended delta |
|------|---------------|----------------|
| `.github/workflows/agtoosa-issues-sync.yml` | Dry-run then live sync; stale checkout pin; no bats | Add bats preflight; PR trigger; pin fix |
| `.github/workflows/release-advanced.yml` | No issues sync | Post-ship job after publish |
| `tests/agtoosa.bats` | GIP-001–GIP-010 | Add GIA workflow contract tests |
| Template example | May drift | Parity AC-007 |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `.github/workflows/agtoosa-issues-sync.yml` | `pull_request` paths; bats install + GIP preflight; checkout pin |
| `.github/workflows/release-advanced.yml` | `sync-issues-post-ship` job after `publish-release` |
| `tests/agtoosa.bats` | GIA-001–GIA-008 (workflow markers / job order) |
| `template/.github/workflows/agtoosa-issues-sync.yml.example` | Mirror maintainer workflow |
| `docs/AgToosa_TrackerSync.md` | CI automation section |
| `template/Docs/AgToosa_TrackerSync.md` | Mirror |

### 2.2 CI flow

```
PR (Master-Plan.md) → dry-run + GIP bats → pass/fail (no gh upsert)

main push (Master-Plan.md) → dry-run → GIP bats → live gh sync → README commit

tag release → publish-release → sync-issues-post-ship (best-effort) → README commit
```

### 2.3 Build Scope

**Files in scope:** `.github/workflows/agtoosa-issues-sync.yml`, `.github/workflows/release-advanced.yml`, `tests/agtoosa.bats`, `template/.github/workflows/agtoosa-issues-sync.yml.example`, `docs/AgToosa_TrackerSync.md`, `template/Docs/AgToosa_TrackerSync.md`

**Out of scope:** `lib/github-issues-sync.sh` logic changes (unless required for workflow flags); webhook workflows; bootstrap apply wiring

### 2.4 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Token over-permission in PR job | Elevation of privilege | PR job: dry-run + bats only — AC-002 |
| Bad publish reaches Issues | Tampering | GIP preflight AC-001 |
| Release blocked by Issues API | Denial of service | `continue-on-error` AC-005 |
| README commit loop | Denial of service | `[skip ci]` AC-006 |

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Issues-sync workflow hardening
  - [ ] 1.1 Pin checkout SHA; add bats install + GIP preflight before live sync — _AC-001, AC-003_
  - [ ] 1.2 Add `pull_request` job: dry-run + GIP only — _AC-002_
- [ ] **2.** Post-ship hook
  - [ ] 2.1 `sync-issues-post-ship` job in `release-advanced.yml` — _AC-004, AC-005, AC-006_
- [ ] **3.** Bats GIA-001–GIA-008
  - [ ] 3.1 Workflow contract tests (job order, PR trigger, post-ship marker) — _AC-001–AC-006_
- [ ] **4.** Template + docs
  - [ ] 4.1 Mirror workflow example — _AC-007_
  - [ ] 4.2 TrackerSync.md CI section (maintainer + template) — _AC-008_

### Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 3.1
**Wave 2 (sequential):** 1.2, 4.1, 4.2

### 3.2 Test Plan

- `docs/AgToosa_TestPlan-DEV-151.md`

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | Pass |
| Goal / Non-goals / AC / tasks aligned | Pass |
| Must AC → test plan mapping | Pass — GIA-001–GIA-008 |
| Claim Boundary classified | Pass |
| No TBD placeholders | Pass |

## ✅ Spec Approved

Approved: 2026-08-01 — served by `/agtoosa-next` (interview Q1–Q2; wave DEV-150 + DEV-151 v5.3.61; Sequential Approval).
