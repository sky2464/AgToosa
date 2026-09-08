# Review: DEV-149 — Issues-Sync Dry-Run README Corruption (+ piped-bootstrap extension)

> **Story ID:** DEV-149 (original bundled in PR #92 wave; extension shipped independently v0.3.62)
> **Review date:** 2026-08-27 (retroactive backfill — original wave review is `docs/archived/review-DEV-147.md`, 2026-08-01)
> **Verdict:** PASS
> **Critical findings:** 0
> **Host mode handoff:** Backfilled per dream-report Priority 1 finding (2026-08-14/15); no new code

### Plan-Mode Review Briefing (findings)

| Subsection | Summary |
|------------|---------|
| **Persona synthesis** | **Security:** Neither fix expands network/auth surface — README guard is local file-write scoping, TTY handling is local stdin routing. **EM:** README guard and stdin-mode hardening are each small, localized diffs (`scripts/agtoosa-issues-sync.sh`, `lib/config.sh`); extension correctly reused the same `agtoosa_prompt_read`/`_agtoosa_tty_usable` helpers across `cleanup.sh`/`reinstall.sh`/`maintain.sh` rather than duplicating logic. **CEO:** Original fix stopped CI dry-runs from corrupting README diffs; extension fixed a real-world pipe-bootstrap install regression (v0.3.62 CHANGELOG entry). **QA:** GIS-011/012 (original) + B33-001–006 (extension) all green. |
| **Iron Law hypotheses** | None — documentation backfill of already-shipped, already-reviewed work. Original scope covered in `review-DEV-147.md` under "Goal Contract Alignment → DEV-149: 🟢 Met"; extension shipped and reviewed as part of v0.3.62 (CHANGELOG-documented, no separate review artifact existed for it either — also closed by this backfill). |
| **Cross-model gate** | Skipped — bash fixture tests + docs; no new auth/network surface. |
| **Host mode handoff** | Agent-mode review artifacts |

## Goal Contract Alignment

| Field | Status | Notes |
|-------|--------|-------|
| Goal (original) | 🟢 Met | `--dry-run` no longer mutates README; repeat publish keeps one END marker |
| Goal (extension) | 🟢 Met | `agtoosa_prompt_read` handles TTY, pipe-bootstrap, and piped-script-answer modes |
| Success condition | 🟢 Met | GIS-011/012 + B33-001–006 all exit 0 |
| Proof | 🟢 Met | `docs/archived/testplans/AgToosa_TestPlan-DEV-149.md` |
| Non-goals | 🟢 Respected | No README format redesign; `--yes`/`--path` semantics untouched |

## Findings

| Severity | Persona | Finding | Disposition |
|----------|---------|---------|-------------|
| 🟢 Passed | Security | No secret handling in either scope; stdin routing is local-only | No action |
| 🟢 Passed | Engineering | Extension correctly reused shared helpers instead of duplicating TTY-detection logic across `cleanup.sh`/`reinstall.sh`/`maintain.sh` | No action |
| 🟡 Info | Docs | Test-ID drift: `GIS-011`/`GIS-012` are tagged `DEV-139` in `tests/agtoosa.bats`, not `DEV-149`, despite asserting DEV-149 behavior. Flagged, not re-tagged, to avoid unrelated bats churn in a docs-only backfill. | Tracked; no functional impact |
| 🟢 Passed | QA | GIS-011/012 + B33-001–006 all green at backfill time | No action |

## Verification Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/agtoosa.bats -f "DEV-139 GIS-01[12]\|DEV-149"` | 0 | 8/8 |

## Cross-Model Review

**Skipped** — documentation backfill of already-shipped bash fixture scope; no new code path introduced.

## Review Gate

No unresolved 🔴 Critical findings. Backfill closes the DEV-149 half of the Priority 1 dream-report finding (paired with DEV-148 backfill in the same PR).

---

Review ✅ Approved — 2026-08-27 — retroactive backfill; original functional review already passed 2026-08-01 (original scope) and 2026-08-02 (extension, CHANGELOG-documented).
