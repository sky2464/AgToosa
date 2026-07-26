# Spec: DEV-128 — Smart Upgrade Platform Selection & Version Guards

> **Story ID:** DEV-128  
> **Epic:** DEV-001 — Generator  
> **Status:** 🏁 Shipped — v5.3.42 (hotfix: read -rp platform prompt)  
> **Estimate:** S  
> **Clarity:** `ready`  
> **Spec created:** 2026-07-26  
> **Ship target:** v5.3.41

### Plan-Mode Spec Interview (findings)

| # | Finding | Source |
|---|---------|--------|
| 1 | User expects upgrade platform digits to **set** the active set, not add to it | Repro: `Add platforms: 1` kept all five platforms |
| 2 | Accidental downgrade is unacceptable; generator must be ≥ installed | Repro: `v5.3.36 → v5.3.34`; user rejects backwards movement |
| 3 | Terminal up-arrow pollutes menu input | User report; `read -rp` without sanitization |
| 4 | Cleanup for deselected platforms already exists but is unreachable | `offer_cleanup_after_apply` + lock never shrinks |
| 5 | PowerShell has identical union bug | `agtoosa.ps1` smart-upgrade block |

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Fix smart-upgrade platform replace semantics and block accidental generator downgrades |
| User outcome | Re-running `agtoosa.sh` on an existing project narrows platforms when requested and refuses older generators |
| Success condition | UPG-001–UPG-006 bats green; Bash + PowerShell parity |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-128.md`; bats `UPG-*` |
| Non-goals | Semver scheme change; silent auto-delete of platform files; rewriting merge engine |
| Assumptions | `--force` is the only intentional downgrade escape hatch |
| Risks | Users who relied on union-add must learn replace semantics — mitigated by prompt copy |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN user enters platform digits on smart upgrade THE SYSTEM SHALL **replace** the active platform set (not union) |
| AC-002 | Must | WHEN user presses Enter at platform prompt THE SYSTEM SHALL keep currently detected platforms |
| AC-003 | Must | WHEN generator version is strictly less than installed version THE SYSTEM SHALL exit with error unless `--force` |
| AC-004 | Must | WHEN `--platforms` is passed on upgrade THE SYSTEM SHALL replace selection without re-unioning installed sentinels |
| AC-005 | Must | WHEN platform menu input contains escape sequences THE SYSTEM SHALL strip non-menu characters before parsing |
| AC-006 | Must | WHEN all platforms are pre-installed THE SYSTEM SHALL still show the change-platform prompt (unless `--yes`) |
| AC-007 | Must | WHEN DEV-128 ships THE SYSTEM SHALL add bats UPG-001–UPG-006 and Pester mirrors |

## 2. Design

### 2.1 Build Scope

- `lib/version.sh` — `assert_not_downgrade`, `upgrade_banner_text`
- `lib/apply.sh` — `sanitize_platform_menu_input`, `PLATFORM_SELECTION_EXPLICIT`
- `agtoosa.sh` — interactive upgrade prompt, downgrade guard, `--update` guard
- `lib/update.sh` — respect explicit platform selection
- `agtoosa.ps1` — parity
- `docs/AgToosa_Update.md` + template mirror
- `tests/agtoosa.bats` UPG section; `tests/pester/agtoosa-install.Tests.ps1`

## 3. Tasks

- [x] **1.** Version helpers — _AC-003_
- [x] **2.** Bash upgrade UX — _AC-001, AC-002, AC-004, AC-005, AC-006_
- [x] **3.** PowerShell parity — _AC-001–AC-006_
- [x] **4.** Bats UPG-001–UPG-006 — _AC-007_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-128.md`.
