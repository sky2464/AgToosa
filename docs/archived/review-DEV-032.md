# Review: DEV-032 — Patch-first release versioning (5.x line)

> **Story ID:** DEV-032
> **Reviewed:** 2026-05-25
> **Verdict:** ✅ PASS

## Summary

DEV-032 codifies **patch-first** maintainer release cadence: [ADR-005](../adr/ADR-005-release-cadence.md), bump tree in `docs/agtoosa-maintainer.md`, version-bump sections in ship/review workflows (template + maintainer mirrors), readiness gate 7 alignment, and bats **DEV-032 VP-001–VP-005**. No generator runtime changes.

DEV-029 already shipped as **v5.2.1** (PATCH from 5.2.0), which is early evidence the policy works in practice. Milestone is **v5.2.2 (next)** per ADR-005.

## Validation

| Check | Result |
|---|---|
| DEV-032 targeted tests | ✅ `bats tests/agtoosa.bats -f "DEV-032"` — 5/5 passing |
| Spec approval | ✅ `docs/archived/spec-DEV-032.md` — `## ✅ Spec Approved`; all build tasks `[x]` |
| AC coverage (Must) | ✅ AC-002–AC-007 → VP-001–VP-005; AC-001/AC-005 partially manual (see test plan) |
| Threat model | ✅ STRIDE table in spec § 2.3; CI tag parity unchanged |
| Version parity | ✅ `agtoosa.sh` / `agtoosa.ps1` both `5.2.1`; bats `--version` pin matches |
| Full generator suite | 🟡 343 pass, **1 fail** — `self-targeting interactive install includes maintainer guidance` (DEV-030 scope, not DEV-032) |

## Goal Contract alignment

| Field | Verdict |
|---|---|
| Goal | ✅ PATCH default on active MINOR train documented |
| User outcome | ✅ Predictable 5.2.x steps; Milestone tracks next PATCH |
| Success condition | ✅ Policy in maintainer + ship + review + ADR-005; VP-001–VP-005 green |
| Proof / evidence | ✅ Targeted bats; DEV-029 ship at 5.2.1 demonstrates patch cadence |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | Docs/ADR/bats only; no new executables or trust boundaries. STRIDE mitigations unchanged (tag == `AGTOOSA_VERSION`, CHANGELOG headings). | Accepted |
| 🟢 Passed | Engineering Manager | Scope matches spec § 2.4; ADR-005 added with ADR-004 cross-link; adapters not duplicated; `tests/agtoosa.bats` growth is grep-only section (~35 lines). | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract and all **Must** ACs satisfied; non-goals respected (no `version_lt` change, no CI auto-bump). | Accepted |
| 🟢 Passed | QA Lead | VP-001–VP-005 green; test plan maps Must ACs; `docs/AgToosa_Review.md` mirror contains PATCH-first ship line (verified; not grep-locked). | Accepted |
| 🟡 Warning | QA Lead | VP-004 greps `template/Docs/AgToosa_Review.md` only — maintainer `docs/AgToosa_Review.md` not in bats (AC-004 partial automation). | Accepted — optional VP-006 at ship |
| 🟡 Warning | QA Lead | AC-001 (default PATCH for Fix/Chore/S) and Should AC-008 have no dedicated bats — policy enforced by prose + ship behavior. | Accepted — manual ship verification |
| 🟡 Warning | QA Lead | Full `bats tests/agtoosa.bats` has 1 unrelated failure (test 57, DEV-030). Resolve before combined ship or ship DEV-032 on a clean branch. | Accepted — not DEV-032 regression |
| 🟡 Warning | Engineering Manager | Policy compliance is markdown + grep only (inherent to workflow-doc stories); agents can still ignore guidance. | Accepted — same class as DEV-028 |

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 4  🟢 Passed: 4**

**Ship version suggestion:** **v5.2.2** (PATCH+1 on current MINOR — DEV-032 is Chore/S; aligns with ADR-005 and Milestone `v5.2.2 (next)`).

Next: `/agtoosa-ship` for DEV-032 — sync `AGTOOSA_VERSION`, README badge, bats `--version` pin, and `CHANGELOG.md` `## [5.2.2]` when shipping this story.
