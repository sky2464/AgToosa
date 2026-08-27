# Spec: DEV-148 — One-Line Install Fails on Fresh Windows/macOS

> **Story ID:** DEV-148
> **Epic:** DEV-001 — Core Install / DEV-111 — Bootstrap Hardening
> **Status:** 🏁 Shipped — v0.3.60
> **Estimate:** M
> **Clarity:** `ready`
> **Spec created:** 2026-08-27 (retroactive backfill — build/ship happened 2026-08-01 via PR #92)

> **Backfill note:** This spec is written after the fact to close a documentation gap flagged in the 2026-08-14/15 maintainer dream reports: DEV-148 shipped code, bats, and a Master-Plan/CHANGELOG entry, but never got the `docs/archived/spec-*.md` / `review-*.md` / `evidence-*.md` quartet other DEV stories receive. Content below is reconstructed from `docs/archived/cycle-2026-08-01-release-5.3.60.md`, `CHANGELOG.md` v0.3.60, GitHub issue #89, and `tests/agtoosa.bats` B32-001/002 + DEV-147 INS-001–004.

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked, reconstructed from shipped artifacts)

| Checklist area | Finding |
|----------------|---------|
| Root cause (Windows) | Fresh-Windows one-line install used an in-memory PowerShell execution pattern that antivirus/EDR products commonly flag, blocking install before it starts |
| Root cause (macOS) | `bootstrap.sh` expanded `forwarded_args[@]` under `set -u`; on stock macOS `bash 3.2` an empty array expansion under `nounset` throws `unbound variable`, aborting bootstrap before `--ref`/`--archive` could run |
| Reporting | Filed as GitHub issue #89 |
| Wave | Bundled with DEV-147 (Tracker CI Publish Hardening) and DEV-149 (Issues-Sync README Guard) into PR #92, shipped as v0.3.60 |

#### Documented assumptions

- Estimate **M** reflects two independent platform-specific root causes (Windows AV pattern + macOS bash 3.2 compat) plus troubleshooting docs, not a single-line fix.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make the documented one-line install work on a fresh Windows machine (no AV false-positive) and fresh macOS (no `bash 3.2` crash), with troubleshooting docs for both |
| User outcome | A user following the README quick-install succeeds on first try on either platform |
| Success condition | `bootstrap.sh` guards the bash 3.2 `set -u` case; README/help avoid AV-triggering PowerShell patterns; troubleshooting doc covers both failure modes |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-148.md`; bats B32-001/002 + DEV-147 INS-001–004 |
| Non-goals | Rewriting the PowerShell bootstrap end-to-end; shipping a signed installer; corporate/EDR runtime tarball (deferred to DEV-150) |
| Assumptions | Users on managed/corporate Windows devices may still need the fallback ladder documented in `readme-reference.md`, not a guaranteed silent install |
| Risks | Future `bootstrap.sh` edits could reintroduce the unguarded `forwarded_args[@]` expansion if B32-001 is not kept as a permanent regression test |
| Unresolved questions | None |

### 1.2 User Stories

**As a** new user on a fresh macOS machine, **I want** the one-line install to survive `bash 3.2`'s `set -u` semantics **so that** I don't hit an `unbound variable` crash before the installer even runs.

**As a** new user on a fresh, AV-managed Windows machine, **I want** the documented install command to avoid patterns that trip antivirus/EDR **so that** install isn't silently blocked.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `bootstrap.sh` runs on bash 3.2 with `set -u` and no forwarded args THE SYSTEM SHALL guard the `forwarded_args[@]` expansion instead of raising `unbound variable` | Must |
| AC-002 | WHEN `bootstrap.sh --ref <tag>` runs with no forwarded args THE SYSTEM SHALL complete successfully end-to-end | Must |
| AC-003 | WHEN a user reads the README quick-install snippet THE SYSTEM SHALL present a pattern that does not match common AV/EDR in-memory-execution signatures | Must |
| AC-004 | WHEN bootstrap or install fails THE SYSTEM SHALL point the user at `docs/guides/readme-reference.md` troubleshooting for their failure mode | Must |
| AC-005 | WHEN a user is on a managed/corporate device THE SYSTEM SHALL document a fallback install ladder (file-download, not just pipe-to-shell) | Should |

### 1.4 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `bootstrap.sh` bash 3.2 guard | generator-enforced | Local script behavior only |
| README/help install pattern | generator-enforced | Documentation contract, not an AV bypass guarantee |
| Managed-device install ladder | manual | User still chooses which fallback step to run |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `bootstrap.sh` | Guard `forwarded_args[@]` expansion (`${#forwarded_args[@]}`-style check) before use under `set -u` |
| `README.md` | Quick-install snippet updated to AV-friendly pattern |
| `docs/guides/readme-reference.md` | Troubleshooting section for bootstrap failure modes + managed-device install ladder |
| `bootstrap.sh` help text | Avoid recommending in-memory PowerShell execution |

### 2.2 Build Scope

**Files in scope:** `bootstrap.sh`, `README.md`, `docs/guides/readme-reference.md`

**Out of scope:** `bootstrap.ps1` behavior changes beyond parity docs, corporate runtime tarball (later shipped separately as DEV-150)

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** macOS bash 3.2 guard
  - [x] 1.1 Guard `forwarded_args[@]` expansion in `bootstrap.sh` — _AC-001, AC-002_
- [x] **2.** Windows AV-safe install pattern
  - [x] 2.1 Update README quick-install snippet — _AC-003_
  - [x] 2.2 Update bootstrap help text — _AC-003_
- [x] **3.** Troubleshooting docs
  - [x] 3.1 `readme-reference.md` failure-mode section — _AC-004_
  - [x] 3.2 `readme-reference.md` managed-device install ladder — _AC-005_

### 3.2 Test Plan

- `docs/archived/testplans/AgToosa_TestPlan-DEV-148.md`

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | Pass — AC-001/002 via B32 bats; AC-003/004 via grep-based INS bats |
| Goal / Non-goals / AC / tasks aligned | Pass |
| Must AC → test plan mapping | Pass — B32-001/002, DEV-147 INS-001–004 |
| Claim Boundary classified | Pass — §1.4 |
| Master-Plan authority preserved | Pass — row unchanged, this spec documents already-shipped state |
| No TBD placeholders | Pass |

## 🏁 Shipped

Shipped: 2026-08-01 — v0.3.60, PR #92, closes [#89](https://github.com/sky2464/AgToosa/issues/89). Spec backfilled 2026-08-27 per dream-report Priority 1 finding.
