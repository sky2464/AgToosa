# Review: DEV-012 — GitHub Slash Command Routing

> **Story ID:** DEV-012
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-012 adds explicit `name: agtoosa-*` frontmatter to all 14 GitHub Copilot prompt adapters, documents `/agtoosa-*` workflow routing (not `/create-skill`) in Copilot instructions and the AgToosa GitHub agent, reserves `agtoosa-*` names in skill-synthesis docs, and locks the contract with G1–G5 bats. Template/docs-only; no generator runtime changes.

During review, duplicate `name:` lines in prompt bodies (sed artifact) were removed and G1 was tightened to require exactly one `name:` line per file.

No unresolved 🔴 Critical findings. DEV-012 is ready for `/agtoosa-ship`.

## Validation

| Check | Result |
|---|---|
| DEV-012 targeted tests | ✅ `bats tests/agtoosa.bats -f "G[1-5]:"` — 5/5 passing |
| Full generator suite | ✅ `bats tests/agtoosa.bats` — 212/212 passing |
| STRIDE mitigations (spec §2.3) | ✅ Spoofing/Tampering/DoS covered via prompt names, routing rules, reserved names, G1–G5 |
| Build scope | ✅ Matches `docs/archived/spec-DEV-012.md` §2.4 |
| Spec approval | ✅ `## ✅ Spec Approved` in spec-DEV-012.md |
| AC coverage | ✅ G1–G5 map to AC-001 through AC-005 |

### Terminal evidence (review run)

| Command | Exit | Result | Warnings | Errors |
|---------|------|--------|----------|--------|
| `bats tests/agtoosa.bats -f "G[1-5]:"` | 0 | pass (5/5) | none | none |
| `bats tests/agtoosa.bats` | 0 | pass (212/212) | none | none |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | Markdown-only; no secrets or new executables. STRIDE table satisfied; reserved names reduce skill-shadowing (Tampering). | Accepted |
| 🟢 Passed | Engineering Manager | Scope limited to template adapters and docs; `lib/config.sh` untouched per spec. Canonical-before-adapters pattern followed. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: explicit prompt names, routing guardrails, synthesis dedupe, G1–G5 proof. Both user stories satisfied. | Accepted |
| 🟢 Passed | QA Lead | All Must ACs covered by G1–G5; full regression 212/212 green. | Accepted |
| 🟡 Warning | Engineering Manager | Duplicate `name:` lines appeared in prompt bodies after frontmatter (fixed during review; G1 now asserts single `name:`). | Fixed |
| 🟡 Warning | QA Lead | AC proof cites installed `name: agtoosa-spec`; platform-5 install test checks file presence only, not frontmatter (G1 covers template contract). | Accepted |
| 🟡 Warning | Engineering Manager | Spec mentioned `agent: agent` preference; implementation keeps `mode: agent` for compatibility. | Accepted; matches spec “preserving compatible behavior” |
| 🟡 Warning | Engineering Manager | `OPENCODE.md` not updated with reserved-name note (spec listed as optional). | Accepted; Init/Spec/Skills sufficient |
| 🟡 Warning | Engineering Manager | `tests/agtoosa.bats` exceeds 500-line limit. | Accepted; established harness pattern |
| 🟡 Warning | CEO / Product Owner | No `[Unreleased]` CHANGELOG entry for DEV-012 yet. | Accepted; ship-phase hygiene |

## Goal Contract Alignment

| Field | Result | Notes |
|---|---|---|
| Goal | ✅ | Deterministic `/agtoosa-*` routing via prompt `name` + instructions |
| User outcome | ✅ | `/agtoosa-spec` maps to spec workflow, not `/create-skill` |
| Success condition | ✅ | Names + guardrails + G1–G5 green |
| Proof / evidence | ✅ | Terminal evidence above |

## Threat model (STRIDE) verification

| Threat | Mitigation status |
|--------|-------------------|
| `/agtoosa-spec` interpreted as `/create-skill` | ✅ AC-001/002 + G1/G2 |
| Generated skill shadows workflow command | ✅ AC-003 + G3 |
| Agent cannot explain wrong command | ✅ G2/G4 strings in repo |
| Skill synthesis leaks workflow context | ✅ Existing secret rules + dedupe |
| Prompt metadata drift | ✅ G1 over all `agtoosa-*.prompt.md` |

## Simplification (Part 2)

Removed stray duplicate `name:` body lines from all 14 prompt files. Strengthened G1 to count exactly one `name:` line per adapter.

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 5  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-012.
