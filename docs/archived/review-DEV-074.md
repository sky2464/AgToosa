# Review: DEV-074 — PS1 non-interactive install parity + Pester suite

> **Story ID:** DEV-074
> **Reviewed:** 2026-07-08
> **Verdict:** ✅ PASS

## Summary

DEV-074 adds `-Path`, `-Platforms`, and `-Yes` to `agtoosa.ps1` for bash-equivalent non-interactive installs, implements `ConvertTo-PlatformList` with unknown-platform rejection, wires `-DryRun` on the NI path, and adds bats DEV-074 CT-001–CT-004 plus Pester NI-001–NI-005. A case-insensitive variable collision (`$Platforms` vs `$selectedPlatforms`) was caught during build and fixed before review.

## Validation

| Check | Command | Exit | Result |
|---|---|---|---|
| DEV-074 targeted bats | `bats tests/agtoosa.bats -f "DEV-074"` | 0 | ✅ 4/4 |
| DEV-033 regression | `bats tests/agtoosa.bats -f "DEV-033"` | 0 | ✅ 4/4 |
| DEV-071 bash NI regression | `bats tests/agtoosa.bats -f "DEV-071"` | 0 | ✅ 3/3 |
| Pester NI suite | `Invoke-Pester tests/pester/agtoosa-install.Tests.ps1` | 0 | ✅ 5/5 |
| Maintainer verifier | `bash docs/agtoosa-verify.sh` | 0 | ✅ PASS (9 pass, 2 warn) |
| Spec approval | `docs/archived/spec-DEV-074.md` | — | ✅ `## ✅ Spec Approved` |
| AC coverage (Must) | AC-001–AC-005 | — | ✅ CT-001–CT-004 + Pester NI-001–NI-005 |
| STRIDE threat model | spec §2.2 | — | ✅ Present |
| Version parity (pre-ship) | bash/ps1/npm | — | ✅ 5.3.1 aligned |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | STRIDE mitigations hold: path validation, no code execution from flags, fail-fast on invalid tokens | Accepted |
| 🟢 Passed | Engineering Manager | Scope limited to `agtoosa.ps1`, bats, Pester; `agtoosa.ps1` 1259 lines (over 500-line soft limit — pre-existing monolith; extraction deferred per spec non-goals) | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: `pwsh agtoosa.ps1 -Path … -Platforms … -Yes` installs without stdin; version marker written | Accepted |
| 🟢 Passed | QA Lead | All Must ACs covered; bash NI regression green; interactive PV-003 smoke unaffected | Accepted |
| 🟡 Warning | Engineering Manager | Pester not in CI — Windows NI coverage depends on local `pwsh` + manual `Invoke-Pester` (same gap as DEV-033 analyzer) | Accepted |
| 🟡 Warning | QA Lead | `agtoosa.ps1` exceeds 500-line review threshold — track module extraction in backlog (spec non-goal for DEV-074) | Accepted |

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 2  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-074 as **v5.3.2** (PATCH+1 per ADR-005).
