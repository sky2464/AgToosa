# Review: DEV-011 — AgToosa Product vs Dogfood Boundary

> **Story ID:** DEV-011
> **Reviewed:** 2026-05-23
> **Verdict:** ✅ PASS

## Summary

DEV-011 documents **Generated Project Mode** vs **Maintainer Dogfood Mode** in the maintainer guide, ADR-008, canonical template docs (`AgToosa_Agent`, `Init`, `Spec`, `Status`), and 15 spec/status platform adapters. B1–B5 bats lock the contract. No generator runtime or `lib/config.sh` changes. Full suite green (207/207).

No unresolved 🔴 Critical findings. DEV-011 is ready for `/agtoosa-ship`.

## Validation

| Check | Result |
|---|---|
| DEV-011 targeted tests | ✅ `bats tests/agtoosa.bats -f "B[1-5]:"` — 5/5 passing |
| Full generator suite | ✅ `bats tests/agtoosa.bats` — 207/207 passing |
| STRIDE mitigations (spec §2.3) | ✅ Spoofing/Tampering/Information Disclosure/Repudiation addressed in docs + B2–B4 |
| Build scope | ✅ Matches `docs/archived/spec-DEV-011.md` §2.4 |
| ADR-008 | ✅ Accepted; terminology decision recorded |
| Spec approval | ✅ `## ✅ Spec Approved` in spec-DEV-011.md |
| AC coverage | ✅ B1–B5 map to AC-001 through AC-005 |

### Terminal evidence (review run)

| Command | Exit | Result | Warnings | Errors |
|---------|------|--------|----------|--------|
| `bats tests/agtoosa.bats -f "B[1-5]:"` | 0 | pass (5/5) | none | none |
| `bats tests/agtoosa.bats` | 0 | pass (207/207) | none | none |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | Markdown-only; no new executables or secrets. STRIDE table in spec satisfied. Operating-context docs reduce identity confusion (Spoofing/Tampering). | Accepted |
| 🟢 Passed | Engineering Manager | ADR-008 covers architectural decision. Canonical-before-adapters pattern followed. `lib/config.sh` untouched per AC-005. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract satisfied: named modes, maintainer vs generated language, B1–B5 proof. User stories met. | Accepted |
| 🟢 Passed | QA Lead | All Must ACs have B1–B5 coverage. Full regression suite green. No flaky signal on single review run. | Accepted |
| 🟡 Warning | Engineering Manager | B4 omits `.windsurf/workflows/agtoosa-{spec,status}.md` though rules/commands were updated. | Accepted; extend B4 or add B6 at ship if Windsurf workflow picker is primary surface |
| 🟡 Warning | Engineering Manager | Domain terms live in `docs/Context/CONTEXT.md` only; no `template/Docs/Context/CONTEXT.md` for init copy. | Accepted; spec allowed optional template mirror; follow-up if init should seed CONTEXT |
| 🟡 Warning | Engineering Manager | `tests/agtoosa.bats` ~1765 lines exceeds 500-line limit. | Accepted; established harness pattern |
| 🟡 Warning | CEO / Product Owner | No `[Unreleased]` CHANGELOG entry for DEV-011 yet. | Accepted; ship-phase hygiene per release checklist |
| 🟡 Warning | QA Lead | Build/Review/QA canonical docs lack Operating Context callouts (spec scoped Init/Spec/Status only). | Accepted; Agent.md cross-link sufficient for most flows; optional follow-up |

## Goal Contract Alignment

| Field | Result | Notes |
|---|---|---|
| Goal | ✅ | Two operating contexts explicit in maintainer + template docs |
| User outcome | ✅ | Dogfood scope vs downstream product language separated |
| Success condition | ✅ | B1–B5 + 207/207 bats |
| Proof / evidence | ✅ | Terminal evidence table above |

## Threat model (STRIDE) verification

| Threat | Mitigation status |
|--------|-------------------|
| Agent treats user app as AgToosa | ✅ `AgToosa_Agent.md` Operating Contexts + B2 |
| Maintainer uses generated-project assumptions | ✅ `agtoosa-maintainer.md` + B1 |
| Status implies AgToosa for all installs | ✅ Status/Spec callouts + B3 |
| Adapter drift from canonical | ✅ B4 (15 surfaces) |
| Over-broad bats grep | ✅ B2 forbids only explicit bad phrase; framework mentions allowed |

## Simplification (Part 2)

No refactors required. Changes are declarative markdown and targeted grep tests; adapter updates reuse one-line pointer pattern.

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 5  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-011.
