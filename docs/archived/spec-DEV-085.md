# Spec: DEV-085 — Chore: Post-v5.3.12 Release Hygiene

> **Story ID:** DEV-085
> **Type:** Chore
> **Epic:** DEV-004 — Testing & QA Harness
> **Status:** 🏁 Shipped (v5.3.13)
> **Estimate:** XS
> **Spec created:** 2026-07-11

## Context

After v5.3.12 ship, ship-regression bats coverage from commit `bb8a8bd` was lost and `docs/Master-Plan.md` drifted (Active Cycle, Completed This Cycle, Update Log, Epics). This chore restores regression guards and reconciles PM state without product behavior changes.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Restore post-ship bats regression coverage and reconcile Master-Plan lifecycle state after v5.3.12. |
| User outcome | Maintainers retain ship-regression SR tests and accurate PM pointers through the next PATCH release. |
| Success condition | Bats suite restored (`bb8a8bd` SR sections); Master-Plan reflects v5.3.13 ship; version pins bumped to 5.3.13; DEV-085 SR-001–SR-003 green. |
| Proof / evidence | Full bats 680/680 PASS; `bash docs/agtoosa-verify.sh` PASS; DEV-085 archived spec/review/evidence; CHANGELOG 5.3.13 entry. |
| Non-goals | New generator features, template changes, or demand-gated backlog enrollment (DEV-051/057). |
| Assumptions | v5.3.12 product artifacts remain correct; hygiene is docs/tests/PM only. |
| Risks | Version pin drift across bash/ps1/npm/README/examples; historical SR tests conflated with live pins. |
| Unresolved questions | None. |

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the maintainer repo ships v5.3.13 THE SYSTEM SHALL align `AGTOOSA_VERSION` across bash, PowerShell, and npm to `5.3.13` | Must |
| AC-002 | WHEN ship completes THE SYSTEM SHALL archive spec, review, and evidence artifacts for DEV-085 with `phase=ship` rows | Must |
| AC-003 | WHEN ship completes THE SYSTEM SHALL record v5.3.13 in Master-Plan, CHANGELOG, and DEV-085 SR-003 with milestone `v5.3.14 (next)` | Must |

## ✅ Spec Approved

Approved: 2026-07-11 22:15
Enrollment: post-v5.3.12 hygiene PATCH (DEV-085)
