# Spec: DEV-129 — Smart Upgrade UX Polish

> **Story ID:** DEV-129  
> **Epic:** DEV-001 — Generator  
> **Status:** 🏁 Shipped — v5.3.43  
> **Estimate:** S  
> **Clarity:** `ready`  
> **Spec created:** 2026-07-26  
> **Ship target:** v5.3.43

### Plan-Mode Spec Interview (findings)

| # | Finding | Source |
|---|---------|--------|
| 1 | Upgrade cleanup output (~115 lines × 2) dominates successful Cursor-only upgrades | miToosa v5.3.34→5.3.42 dogfood |
| 2 | Platform prompt example `1` is ambiguous vs replace semantics (DEV-128) | Upgrade UX review |
| 3 | Accidental platform narrow needs a confirm gate before apply | DEV-128 risk mitigation |
| 4 | Backup/gitignore hint contradicts immediate cleanup offer | Same session |
| 5 | “Prepared N” vs “Updated M” confuses delta apply | Same session |

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Reduce upgrade-session noise and clarify platform replace + cleanup consequences |
| User outcome | Re-running `agtoosa.sh` on upgrade shows compact cleanup, clear platform copy, and optional narrowing confirm |
| Success condition | UPG-008–UPG-009 + CLN-018–CLN-019 green; Bash + PowerShell parity |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-129.md`; bats `UPG-008+`, `CLN-018+` |
| Non-goals | Change DEV-128 replace semantics; silent file deletion |
| Assumptions | Cleanup remains opt-in after apply |
| Risks | Users who relied on verbose cleanup lists use `--verbose` |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN cleanup has ≥10 candidates THE SYSTEM SHALL print compact plan/apply summaries by default |
| AC-002 | Must | WHEN `--cleanup --verbose` THE SYSTEM SHALL list every candidate and removal line |
| AC-003 | Must | WHEN user explicitly narrows platforms on upgrade THE SYSTEM SHALL confirm before staging |
| AC-004 | Must | WHEN user presses Enter at platform prompt THE SYSTEM SHALL skip narrowing confirmation |
| AC-005 | Must | WHEN platform selection changes THE SYSTEM SHALL echo removed platform names |
| AC-006 | Should | WHEN merge backup created THE SYSTEM SHALL note cleanup vs gitignore options |
| AC-007 | Should | WHEN smart upgrade stages files THE SYSTEM SHALL clarify delta apply vs prepared count |
| AC-008 | Must | WHEN DEV-129 ships THE SYSTEM SHALL add bats UPG-008–UPG-009 and CLN-018–CLN-019 |

## 2. Design

- `lib/cleanup.sh` — compact plan/apply, `--verbose`
- `lib/apply.sh` — platform snapshot, narrowing confirm, selection summary
- `agtoosa.sh`, `agtoosa.ps1` — prompt copy, prepared banner, PS parity
- `lib/install.sh`, `lib/update.sh` — backup hint, `/agtoosa-update` nudge
- `docs/AgToosa_Update.md` + template mirror

## 3. Tasks

- [x] **1.** Compact cleanup — _AC-001, AC-002_
- [x] **2.** Platform prompt + narrowing gate — _AC-003–AC-005_
- [x] **3.** Message polish — _AC-006, AC-007_
- [x] **4.** Bats + Pester — _AC-008_

## ✅ Spec Approved

Approved: 2026-07-26 — maintainer dogfood expedite (post-build UX review).
