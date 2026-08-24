# Spec: DEV-150 — Corporate Runtime Release Asset

> **Story ID:** DEV-150
> **Epic:** DEV-001 — Core Generator Engine / DEV-111 — Install Hardening
> **Status:** 🟦 Todo
> **Estimate:** M
> **Clarity:** `ready`
> **Spec created:** 2026-08-01
> **Extends:** `docs/spikes/install-corporate-edr-plan.md` Phase 2 · DEV-148 (v5.3.60)

> **Milestone re-target (2026-08-23):** originally approved for v5.3.61; re-targeted to v5.3.63 — v5.3.61/v5.3.62 shipped unrelated fixes. See Master-Plan Update Log.

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Deliverable | Spike Phase 2: `agtoosa-runtime-vX.Y.Z.tar.gz` with `{agtoosa.sh, agtoosa.ps1, lib/, template/}` |
| Release gap | `release-advanced.yml` has no runtime tarball; Homebrew uses source archive |
| Wave | Bundled with DEV-151 in milestone v5.3.61 |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Wave packaging? | A — single v5.3.61 wave |
| Q2 | DEV-151 scope? | B — CI hardening + post-ship issues-sync hook |

#### Documented assumptions

- Homebrew runtime URL switch is Should (best-effort, continue-on-error).
- Runtime pack excludes bootstrap scripts.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish minimal runtime release artifact for corporate/EDR-safe installs |
| User outcome | Corporate users verify SHA256, extract, run generator without git clone |
| Success condition | Runtime tarball on every release in SHA256SUMS; RTA-001–RTA-006 green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-150.md`; bats RTA-001–RTA-006 |
| Non-goals | Authenticode; winget; shipping tests/fixtures; replacing git clone for maintainers |
| Assumptions | Tag push triggers release-advanced.yml |
| Risks | Accidental inclusion of maintainer paths; size regression |
| Unresolved questions | None |

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN release runs on tag vX.Y.Z THE SYSTEM SHALL build `agtoosa-runtime-vX.Y.Z.tar.gz` with exactly `agtoosa.sh`, `agtoosa.ps1`, `lib/`, `template/` at root | Must |
| AC-002 | WHEN runtime tarball is built THE SYSTEM SHALL append SHA-256 to release SHA256SUMS | Must |
| AC-003 | WHEN bats RTA-001 runs THE SYSTEM SHALL assert archive members match AC-001 exactly | Must |
| AC-004 | WHEN bats RTA-002 runs THE SYSTEM SHALL assert runtime tarball smaller than source archive | Must |
| AC-005 | WHEN readme-reference corporate section is read THE SYSTEM SHALL prefer runtime tarball over source archive | Must |
| AC-006 | WHEN install-corporate-edr-plan Phase 2 is read THE SYSTEM SHALL mark Phase 2 shipped | Must |
| AC-007 | WHEN Homebrew bump runs THE SYSTEM SHALL attempt runtime URL (best-effort) | Should |

## 2. Design

| Surface | Change |
|---------|--------|
| `scripts/pack-runtime.sh` | Deterministic pack script |
| `.github/workflows/release-advanced.yml` | Pack, upload, SHA256SUMS |
| `tests/agtoosa.bats` | RTA-001–RTA-006 |
| `docs/guides/readme-reference.md` | Corporate runtime block |

## 3. Tasks

- [ ] 1. `scripts/pack-runtime.sh` — AC-001
- [ ] 2. Release workflow pack + upload — AC-001, AC-002
- [ ] 3. Bats RTA-001–RTA-006 — AC-003, AC-004
- [ ] 4. Docs + spike update — AC-005, AC-006
- [ ] 5. Homebrew runtime URL (best-effort) — AC-007

### 3.2 Test Plan

- `docs/AgToosa_TestPlan-DEV-150.md`

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | Pass |
| Goal / AC / tasks aligned | Pass |

## ✅ Spec Approved

Approved: 2026-08-01 — served by `/agtoosa-next` (Sequential Approval).
