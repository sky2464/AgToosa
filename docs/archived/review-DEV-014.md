# Review: DEV-014 — Cursor Slash Command Routing

> **Story ID:** DEV-014
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-014 mirrors the DEV-012 GitHub routing pattern for Cursor: all 14 `template/.cursor/commands/agtoosa-*.md` adapters now declare native `/agtoosa-*` workflow routing with explicit no-`/create-skill` guardrails; `agtoosa-core.mdc` and `agtoosa-status.mdc` reserve workflow command names; Init/Spec/Skills synthesis docs reject `.cursor/commands/agtoosa-*.md` collisions; and **CU1–CU5** bats lock the contract. Template/docs/tests only; no generator runtime changes.

No unresolved 🔴 Critical findings. DEV-014 is ready for `/agtoosa-ship`.

## Validation

| Check | Result |
|---|---|
| DEV-014 targeted tests | ✅ `bats tests/agtoosa.bats -f "CU[1-5]:"` — 5/5 passing |
| Full generator suite | ✅ `bats tests/agtoosa.bats` — 223/223 passing |
| STRIDE mitigations (spec §2.3) | ✅ Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation covered via command files, core rule, synthesis dedupe, CU1–CU5 |
| Build scope | ✅ Matches `docs/archived/spec-DEV-014.md` §2.4; no out-of-scope `lib/*.sh` or ship-doc drift |
| Spec approval | ✅ `## ✅ Spec Approved` appended during review |
| AC coverage | ✅ CU1–CU5 map to AC-001 through AC-005 |

### Terminal evidence (review run)

| Command | Exit | Result | Warnings | Errors |
|---------|------|--------|----------|--------|
| `bats tests/agtoosa.bats -f "CU[1-5]:"` | 0 | pass (5/5) | none | none |
| `bats tests/agtoosa.bats` | 0 | pass (223/223) | none | none |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | Markdown-only; no secrets or new executables. STRIDE table satisfied; no-`/create-skill` routing reduces accidental skill scaffold exposure (Information Disclosure). | Accepted |
| 🟢 Passed | Engineering Manager | Scope limited to Cursor adapters, two rules, three synthesis docs, and bats; `lib/config.sh` untouched per spec. Parallels DEV-012 canonical-before-adapters pattern. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: explicit command routing, always-on reservation, synthesis collision guardrails, CU1–CU5 proof. Both user stories satisfied. | Accepted |
| 🟢 Passed | QA Lead | All Must ACs covered by CU1–CU5; full regression 223/223 green; test plan `docs/AgToosa_TestPlan-DEV-014.md` aligned. | Accepted |
| 🟡 Warning | CEO / Product Owner | `docs/archived/spec-DEV-014.md` lacked `## ✅ Spec Approved` before review (present on DEV-012/013). | Fixed during review |
| 🟡 Warning | QA Lead | CU5 asserts guardrails on fresh Cursor install only; `--update` reinstall path not bats-locked (spec task 4.5 mentions install/update). | Accepted; G-series precedent; template contract is source of truth |
| 🟡 Warning | Engineering Manager | `tests/agtoosa.bats` exceeds 500-line limit (~1990 lines). | Accepted; established harness pattern |
| 🟡 Warning | CEO / Product Owner | No `[Unreleased]` CHANGELOG entry for DEV-014 yet. | Accepted; ship-phase hygiene |
| 🟡 Warning | Engineering Manager | Cursor IDE routing behavior cannot be exercised in CI; tests assert generated contract only (spec Risk row). | Accepted; documented assumption |

## Goal Contract Alignment

| Field | Result | Notes |
|---|---|---|
| Goal | ✅ | `/agtoosa-*` routed via explicit Cursor command files, not `/create-skill` |
| User outcome | ✅ | `/agtoosa-status` delegates read-only to `Docs/AgToosa_Status.md` with sub-commands |
| Success condition | ✅ | Command files + core rule + synthesis dedupe + CU1–CU5 green |
| Proof / evidence | ✅ | Terminal evidence above |

## Threat model (STRIDE) verification

| Threat | Mitigation status |
|--------|-------------------|
| `/agtoosa-status` interpreted as `/create-skill` | ✅ AC-001/003 + CU1/CU3 |
| Generated skill shadows `.cursor/commands/agtoosa-status.md` | ✅ AC-004 + CU4 |
| Agent cannot explain wrong command routing | ✅ CU1/CU3 strings in repo |
| Skill synthesis leaks workflow context | ✅ Existing secret rules + no-create-skill routing |
| Cursor command file drift | ✅ CU1 over all adapters + CU5 install smoke |
| Generic skill command gains authority over AgToosa names | ✅ `agtoosa-core.mdc` always-on reservation |

## Simplification (Part 2)

No refactors required. Per-command routing blocks are intentionally duplicated (self-contained adapters for Cursor discovery), matching the DEV-012 per-prompt pattern. Routing section title and guardrail phrasing are consistent across all 14 command files.

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 4 (1 fixed)  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-014.
