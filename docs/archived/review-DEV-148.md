# Review: DEV-148 — One-Line Install Fails on Fresh Windows/macOS

> **Story ID:** DEV-148 (bundled in PR #92 wave with DEV-147, DEV-149)
> **Review date:** 2026-08-27 (retroactive backfill — original wave review is `docs/archived/review-DEV-147.md`, 2026-08-01)
> **Verdict:** PASS
> **Critical findings:** 0
> **Host mode handoff:** Backfilled per dream-report Priority 1 finding (2026-08-14/15); no new code

### Plan-Mode Review Briefing (findings)

| Subsection | Summary |
|------------|---------|
| **Persona synthesis** | **Security:** bash 3.2 guard is a pure `set -u` compatibility fix — no new attack surface; AV-safe install pattern reduces false-positive blocking without weakening integrity checks (`--sha256`, `SHA256SUMS` unaffected). **EM:** Fix is localized to `bootstrap.sh` array-expansion guard and doc copy; no lib/ churn. **CEO:** Closes #89, the highest-reported fresh-install friction point at the time. **QA:** B32-001/002 + DEV-147 INS-001–004 all green. |
| **Iron Law hypotheses** | None — this is a documentation backfill of already-shipped, already-reviewed work; the original wave review (`review-DEV-147.md`) already covered DEV-148 under "Goal Contract Alignment → DEV-148 (#89): 🟢 Met". |
| **Cross-model gate** | Skipped — bash fixture tests + docs; no new auth/network surface. |
| **Host mode handoff** | Agent-mode review artifacts |

## Goal Contract Alignment

| Field | Status | Notes |
|-------|--------|-------|
| Goal | 🟢 Met | `bootstrap.sh` no longer crashes on macOS bash 3.2; AV-safe install pattern documented |
| User outcome | 🟢 Met | Fresh install succeeds on both platforms per B32/INS bats |
| Success condition | 🟢 Met | B32-001/002 exit 0; INS-001–004 exit 0 |
| Proof | 🟢 Met | `docs/archived/testplans/AgToosa_TestPlan-DEV-148.md` |
| Non-goals | 🟢 Respected | No PowerShell bootstrap rewrite; no signed installer |

## Findings

| Severity | Persona | Finding | Disposition |
|----------|---------|---------|-------------|
| 🟢 Passed | Security | No credential/token exposure; AV-safe pattern verified by grep-based INS-001/003 bats | No action |
| 🟢 Passed | Engineering | Guard is minimal and localized (`${#forwarded_args[@]}` check before expansion) | No action |
| 🟡 Info | Docs | This spec/review/evidence quartet did not exist until 2026-08-27, ~4 weeks after ship — tracked in the 2026-08-14/15 dream reports as Priority 1 | Resolved by this backfill |
| 🟢 Passed | QA | B32-001/002 + DEV-147 INS-001–004 all green at backfill time | No action |

## Verification Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/agtoosa.bats -f "DEV-148\|B32-\|DEV-147 INS-"` | 0 | 6/6 |

## Cross-Model Review

**Skipped** — documentation backfill of already-shipped bash fixture scope; no new code path introduced.

## Review Gate

No unresolved 🔴 Critical findings. Backfill closes the DEV-148 half of the Priority 1 dream-report finding (paired with DEV-149 backfill in the same PR).

---

Review ✅ Approved — 2026-08-27 — retroactive backfill; original functional review already passed 2026-08-01 (`review-DEV-147.md`).
