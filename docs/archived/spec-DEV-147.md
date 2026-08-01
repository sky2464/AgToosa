# Spec: DEV-147 — Tracker CI Publish Hardening

> **Story ID:** DEV-147
> **Epic:** DEV-051 — Tracker Sync Bridge / DEV-139 — GitHub Issues PM Bridge
> **Status:** 🟦 Todo
> **Estimate:** S
> **Clarity:** `ready`
> **Spec created:** 2026-07-29
> **Extends:** DEV-139 — GitHub Issues PM Bridge · DEV-141–DEV-145 tracker discovery/bootstrap/status-check/apply

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Gap | GIS-001–GIS-010 cover `--tracker publish` manifest rendering only; `scripts/agtoosa-issues-sync.sh` upsert loop has no dedicated bats |
| CI exists | `.github/workflows/agtoosa-issues-sync.yml` runs dry-run + live `gh` on `main` Master-Plan changes |
| Doctor pattern | DEV-144 `gitignore_doctor_check` wired in `lib/maintain.sh` is precedent for new Info/Warn findings |
| Authority | Master-Plan remains SoT; sync script is provider-enforced (`gh` + `GITHUB_TOKEN`) per `docs/AgToosa_TrackerSync.md` |
| Brownfield | `scripts/agtoosa-issues-sync.sh` and template mirror exist; upsert logic is inline and untested |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | What should DEV-147 target? | Tracker/Issues follow-up after DEV-141–145 |
| Q2 | Narrowest delivery slice? | CI publish hardening — bats for `issues-sync`, verifier/doctor gate, idempotent upsert fixtures |
| Q3 | Scope surfaces? | Maintainer dogfood **and** template pack mirrors |
| Q4 | Non-goals? | Strict CI-only — no webhook sync, bootstrap `--apply` wiring, Projects v2, or live `gh` in bats (mock only) |

#### Documented assumptions

- Estimate **S** — lib extraction + doctor + bats + template parity; no new CLI subcommands.
- Enrollment in Active Cycle for milestone **v5.3.60** — served by `/agtoosa-next` Sequential Approval.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make the GitHub Issues publish CI path testable, observable, and template-parity without expanding to live webhook or bootstrap automation |
| User outcome | Maintainers get deterministic bats for `agtoosa-issues-sync.sh`, a doctor finding when sync assets are missing or misaligned, and downstream template copies that match |
| Success condition | GIP-001–GIP-010 green; doctor emits structured `GIP-003` when workflow/script drift detected; template mirrors updated |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-147.md`; bats GIP-001–GIP-010 |
| Non-goals | Webhook bidirectional sync; Projects v2 kanban; `bootstrap --apply` → auto-publish loop; live `gh` network calls in bats; PowerShell-native sync reimplementation |
| Assumptions | Opt-in repos enable `agtoosa-issues-sync.yml`; `gh` remains the only supported transport for upsert |
| Risks | Mock `gh` drift from real CLI flags; doctor false positives on partial installs |
| Unresolved questions | None |

### 1.2 User Stories

**As a** maintainer, **I want** bats coverage for `agtoosa-issues-sync.sh` **so that** publish upsert regressions are caught before CI applies live `gh` calls.

**As a** downstream adopter, **I want** doctor to warn when sync script and workflow example drift **so that** template installs stay aligned with maintainer dogfood.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa-issues-sync.sh --dry-run` runs against a fixture project THE SYSTEM SHALL exit 0 and print deterministic issue rows from the publish manifest | Must |
| AC-002 | WHEN `gh` is absent THE SYSTEM SHALL exit non-zero with a clear error before manifest processing | Must |
| AC-003 | WHEN a mocked `gh` fixture simulates an existing issue by `upsert_key` THE SYSTEM SHALL take the edit path without creating duplicates | Must |
| AC-004 | WHEN a mocked `gh` fixture has no matching issue THE SYSTEM SHALL take the create path | Must |
| AC-005 | WHEN milestone title is present in manifest THE SYSTEM SHALL resolve or create milestone before upsert (mocked) | Must |
| AC-006 | WHEN shipped story state is `closed` in manifest THE SYSTEM SHALL invoke close on upsert (mocked) | Must |
| AC-007 | WHEN doctor runs and `agtoosa-issues-sync` workflow exists but `scripts/agtoosa-issues-sync.sh` is missing or template example drifts THE SYSTEM SHALL emit finding `GIP-003` (Warn) with fix hint | Must |
| AC-008 | WHEN doctor runs and workflow is absent THE SYSTEM SHALL NOT emit `GIP-003` (opt-in surface) | Must |
| AC-009 | WHEN template pack is synced THE SYSTEM SHALL mirror script and workflow example to `template/scripts/` and `template/.github/workflows/` | Must |
| AC-010 | WHEN README roadmap block is updated by sync dry-run THE SYSTEM SHALL preserve `AGTOOSA-ROADMAP` marker contract (regression vs GIS-008) | Should |

### 1.4 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `agtoosa-issues-sync.sh` dry-run | generator-enforced | Local manifest render only |
| `agtoosa-issues-sync.sh` upsert | provider-enforced | `gh` CLI + `GITHUB_TOKEN` in CI |
| `GIP-003` doctor finding | generator-enforced | Warn when opt-in workflow present |
| Bats mock `gh` | CI-enforced | No network; fixture recordings only |
| Live `gh` integration | manual | Out of scope for bats; existing workflow unchanged |

### 1.5 Brownfield Baseline

| Item | Current state | Intended delta |
|------|---------------|----------------|
| `scripts/agtoosa-issues-sync.sh` | Inline upsert loop; dry-run prints manifest rows | Extract testable lib; bats with mock `gh` |
| `lib/maintain.sh` | No issues-sync doctor check | Wire `github_issues_sync_doctor_check` |
| `tests/agtoosa.bats` | GIS-001–GIS-010 manifest only | Add GIP-001–GIP-010 sync-script section |
| Template mirrors | Exist but untested for drift | Parity enforced by AC-009 + GIP-010 |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `lib/github-issues-sync.sh` | New — upsert helpers + doctor check; accept `GH_CMD` override for bats |
| `scripts/agtoosa-issues-sync.sh` | Thin wrapper sourcing lib |
| `template/scripts/agtoosa-issues-sync.sh` | Mirror maintainer script |
| `lib/maintain.sh` | Wire `github_issues_sync_doctor_check` |
| `tests/fixtures/tracker-sync/issues-sync/` | Fixture project, manifest, mock `gh` |
| `tests/agtoosa.bats` | GIP-001–GIP-010 |
| `template/.github/workflows/agtoosa-issues-sync.yml.example` | Parity with maintainer workflow |
| `docs/AgToosa_TrackerSync.md` | Document GIP doctor finding + mock-bats note |
| `template/Docs/AgToosa_TrackerSync.md` | Mirror |

### 2.2 Sync flow

```
Master-Plan.md → agtoosa.sh --tracker publish → manifest.json
manifest.json → github_issues_sync_apply (lib) → gh upsert (or mock)
publish --readme → AGTOOSA-ROADMAP block in README.md
```

### 2.3 Mock `gh` contract (bats)

- Mock script on `PATH` as `gh`; records subcommands and args to a temp log.
- Supports: `issue list`, `issue create`, `issue edit`, `issue close`, `api` (milestones).
- Returns fixture JSON for `issue list --label <upsert_key>`.

### 2.4 Build Scope

**Files in scope:** `lib/github-issues-sync.sh`, `scripts/agtoosa-issues-sync.sh`, `template/scripts/agtoosa-issues-sync.sh`, `lib/maintain.sh`, `tests/agtoosa.bats`, `tests/fixtures/tracker-sync/issues-sync/`, `template/.github/workflows/agtoosa-issues-sync.yml.example`, `docs/AgToosa_TrackerSync.md`, `template/Docs/AgToosa_TrackerSync.md`

**Directories in scope:** `lib/`, `scripts/`, `tests/fixtures/tracker-sync/issues-sync/`, `template/scripts/`, `template/.github/workflows/`

**Out of scope:** `lib/github-issues.sh` manifest render (GIS-covered), `lib/tracker-discover.sh`, webhook workflows, `bootstrap --apply`, live CI workflow behavior changes beyond parity docs

### 2.5 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Token exposure in logs | Information disclosure | Script never echoes `GH_TOKEN`; bats use mock only |
| Duplicate Issues on re-sync | Tampering | Upsert by `agtoosa:DEV-XXX` label — AC-003/004 |
| Manifest tampering in CI | Repudiation | Dry-run gate in workflow before apply (unchanged) |
| Doctor false positive on fresh install | Denial of service | GIP-003 only when workflow file present |

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Lib extraction
  - [ ] 1.1 Create `lib/github-issues-sync.sh` with `github_issues_sync_dry_run` and `github_issues_sync_apply` — _AC-001, AC-003–AC-006_
  - [ ] 1.2 Refactor `scripts/agtoosa-issues-sync.sh` to source lib — _AC-001_
- [ ] **2.** Doctor gate
  - [ ] 2.1 `github_issues_sync_doctor_check` + `GIP-003` finding — _AC-007, AC-008_
  - [ ] 2.2 Wire into `lib/maintain.sh` — _AC-007_
- [ ] **3.** Fixtures + mock gh
  - [ ] 3.1 `tests/fixtures/tracker-sync/issues-sync/` fixture project + mock `gh` — _AC-003–AC-006_
- [ ] **4.** Bats GIP-001–GIP-010
  - [ ] 4.1 Dry-run, gh-missing, upsert paths, milestone, close state — _AC-001–AC-006_
  - [ ] 4.2 Doctor + template parity + README marker regression — _AC-007–AC-010_
- [ ] **5.** Template + docs
  - [ ] 5.1 Mirror script and workflow example — _AC-009_
  - [ ] 5.2 TrackerSync.md GIP section (maintainer + template) — _AC-007_

### Wave Plan

**Wave 1 (parallel):** 1.1, 3.1
**Wave 2 (sequential after Wave 1):** 1.2, 2.1, 2.2, 4.1, 4.2, 5.1, 5.2

### 3.2 Test Plan

- `docs/AgToosa_TestPlan-DEV-147.md`

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | Pass — all observable via bats or doctor JSON |
| Goal / Non-goals / AC / tasks aligned | Pass |
| Must AC → test plan mapping | Pass — GIP-001–GIP-010 |
| Claim Boundary classified | Pass — §1.4 |
| Master-Plan authority preserved | Pass |
| No TBD placeholders | Pass |

## ✅ Spec Approved

Approved: 2026-07-29 — served by `/agtoosa-next` (interview Q1–Q4 complete; cold-start pick: tracker CI publish hardening; Sequential Approval).
