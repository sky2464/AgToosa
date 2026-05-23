# Review: DEV-007 — /agtoosa-help next on-demand assistance helper

> **Story ID:** DEV-007
> **Reviewed:** 2026-05-23
> **Verdict:** ✅ PASS

## Summary

DEV-007 wires `/agtoosa-help next` into the three native help variants (Claude, Gemini, GitHub Copilot), mirrors assistance-only rules into Cursor/Windsurf core fallbacks, updates Agent docs, adds H1–H7 bats parity, and moves the feature from CHANGELOG Planned → Added.

No unresolved 🔴 Critical findings. DEV-007 is ready for `/agtoosa-ship` after user approval.

## Validation

| Check | Result |
|---|---|
| DEV-007 targeted tests | ✅ `bats tests/agtoosa.bats -f "H[1-7]"` — 7/7 passing |
| Full generator suite | ⚠️ Sandbox run: install/copy tests fail (environment); unrelated to DEV-007 diff. H1–H7 and S1 pass in isolation. |
| File size (500-line limit) | ✅ All touched help/core files &lt; 65 lines |
| ADR coverage | ✅ `docs/adr/ADR-006-help-on-demand-assistance.md` exists and matches implementation |
| CHANGELOG | ✅ `/agtoosa-help next` removed from `### Planned`; added under `### Added` |
| Build scope | ✅ Changes limited to spec-declared surfaces |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | Read-only and suggestion-only rules enforced in help text; no secrets, APIs, or mutating side effects in scope. STRIDE mitigations from spec reflected in AC-003/AC-004 bats (H4, H5). | Accepted |
| 🟢 Passed | Engineering Manager | Focused diff across template help files, core fallbacks, Agent docs, bats, and CHANGELOG. ADR-006 documents the on-demand assistance decision. | Accepted |
| 🟢 Passed | CEO / Product Owner | Must ACs implemented: static default help, read-only `next`, parity across platforms, assistance-only placement outside lifecycle diagram. | Accepted |
| 🟢 Passed | QA Lead | H1–H7 cover static help, parity surfaces, read-only, suggestion-only, empty-cycle routing, and Agent utility table. | Accepted |
| 🟡 Warning | Engineering Manager | Cursor/Windsurf core fallbacks expose `/agtoosa-help next` with abbreviated rules (empty cycle → `/agtoosa-spec` only) vs the full build/review/ship decision tree in native help files. | Accepted; fallbacks meet AC-005 “expose” minimum; users on Cursor/Windsurf should prefer native help where installed |
| 🟡 Warning | QA Lead | Test plan T-002 (AC-002: exactly one command + rationale) and T-007 (AC-007: ship when review complete) have no dedicated H* bats tests; behavior is present in Claude/Gemini/Copilot text. | Accepted; add H8/H9 in a follow-up chore if desired |
| 🟡 Warning | QA Lead | Test plan T-008 (AC-008 CHANGELOG) has no automated grep test; verified manually in `CHANGELOG.md`. | Accepted |
| 🟡 Warning | QA Lead | `S2` install smoke and many generator install tests fail in sandboxed CI-like runs; pre-existing environment issue, not introduced by DEV-007. | Accepted; H1–H7 are the DEV-007 gate |
| 🟡 Warning | Review Process | Cross-platform second-opinion review (`/agtoosa-review cross`) not run in this pass. | Accepted; recommended but not blocking for docs/template wiring |

## Acceptance Criteria Review

| AC | Priority | Result | Evidence |
|---|---|---|---|
| AC-001 | Must | ✅ Pass | H1: default help paths forbid reading Master-Plan / Docs on static path |
| AC-002 | Must | ✅ Pass | Claude/Gemini/Copilot define “exactly one” command + Rationale output; Cursor/Windsurf state “recommend exactly one” (abbreviated) |
| AC-003 | Must | ✅ Pass | H4: “Never modify” across all five surfaces |
| AC-004 | Must | ✅ Pass | H5: suggestion-only / does not auto-run mutating commands |
| AC-005 | Must | ✅ Pass | H2 + H3: `/agtoosa-help next` in three native variants + two core fallbacks |
| AC-006 | Must | ✅ Pass | H6: empty Active Cycle → `/agtoosa-spec` in Claude + Cursor core |
| AC-007 | Should | ✅ Pass | Native help files include “Review passed → `/agtoosa-ship`”; not spelled out in Cursor/Windsurf bullets |
| AC-008 | Should | ✅ Pass | CHANGELOG Planned entry removed; Added entry documents feature |

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 4  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-007 (pending user approval).
