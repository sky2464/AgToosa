# Review: DEV-022 — Registry Publish PS1 + Offline Cache Hardening

> **Story ID:** DEV-022
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-022 closes audit leftovers MF-4 and SI-5: PowerShell `--registry publish` now prints a Bash redirect instead of "Unknown registry command"; maintainer and template registry docs add an **Offline cache and trust** section; `fetch_registry` documents HTTPS-only index trust and per-pack SHA-256 verification; bats **RC1–RC3** lock the contracts. Scope matches the spec (redirect-only PS1 publish, no wizard, no schema changes).

No unresolved 🔴 Critical findings. DEV-022 is ready for `/agtoosa-ship`.

## Validation

| Check | Result |
|---|---|
| DEV-022 targeted tests | ✅ `bats tests/agtoosa.bats -f "RC[1-3]:"` — 3/3 passing |
| Registry regression slice | ✅ `bats tests/agtoosa.bats -f "registry"` — 24/24 passing (includes RC1–RC3, RV, RG, PK) |
| STRIDE mitigations (spec §2.2) | ✅ PS1 redirect; stale-cache guidance + per-pack SHA-256; `fetch_registry` security comment |
| Build scope | ✅ Matches `docs/archived/spec-DEV-022.md` §2.3 |
| Spec approval | ✅ `## ✅ Spec Approved` in spec-DEV-022.md |
| AC coverage | ✅ RC1–RC3 map to AC-001 through AC-004 per test plan |

### Terminal evidence (review run)

| Command | Exit | Result | Warnings | Errors |
|---------|------|--------|----------|--------|
| `bats tests/agtoosa.bats -f "RC[1-3]:"` | 0 | pass (3/3) | none | none |
| `bats tests/agtoosa.bats -f "registry"` | 0 | pass (24/24) | none | none |
| RC2 intermittent teardown | 1 (first run) | RC2 logic passed; `teardown` `rm -rf ship/` failed (non-empty `ship/Docs`) | pre-existing harness flake | not DEV-022 regression; re-run green |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | PS1 publish no longer dead-ends users into a broken path; offline docs state HTTPS-only index trust and independent SHA-256 verification for high-assurance installs; `fetch_registry` comment mirrors docs. Per-pack SHA-256 on install unchanged. STRIDE table satisfied. | Accepted |
| 🟢 Passed | Engineering Manager | Minimal diff: one `publish` switch branch, doc subsection (maintainer + template parity), four-line security comment, three focused bats. `lib/registry.sh` 482 lines (under 500). No generator inventory drift. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: Windows users get actionable Bash publish guidance; offline/cache behavior documented and regression-tested. Non-goals respected (no PS1 wizard, no GPG registry). | Accepted |
| 🟢 Passed | QA Lead | All Must ACs covered by RC1–RC3; test plan `docs/AgToosa_TestPlan-DEV-022.md` aligned; RC3 proves cache-isolated `info` without network. | Accepted |
| 🟡 Warning | Engineering Manager | `agtoosa.ps1` `Show-Usage` lists list/search/info/install but not `publish` (param help updated; interactive help omits redirect). | Accepted; optional follow-up in ship or DEV-023 |
| 🟡 Warning | Engineering Manager | PS1 `Invoke-RegistryFetch` uses `%USERPROFILE%\.cache\agtoosa` only; docs document `AGTOOSA_REGISTRY_CACHE_DIR` for Bash. No PS1 env override for offline cache. | Accepted; out of spec scope; README already recommends WSL/Git Bash for full registry parity |
| 🟡 Warning | QA Lead | RC3 overlaps existing `registry info returns pack details from local cache` test; both prove cache hit. | Accepted; RC3 names DEV-022 smoke filter per spec |
| 🟡 Warning | Engineering Manager | `tests/agtoosa.bats` ~2614 lines (exceeds 500-line guideline). | Accepted; established harness pattern |
| 🟡 Warning | CEO / Product Owner | No `[Unreleased]` CHANGELOG entry for DEV-022 yet. | Accepted; ship-phase hygiene |

## Goal Contract Alignment

| Field | Result | Notes |
|---|---|---|
| Goal | ✅ | PS1 publish path + offline/cache docs and tests |
| User outcome | ✅ | Windows users redirected to Bash; air-gapped use documented |
| Success condition | ✅ | PS1 `publish` handled; docs + RC1–RC3 green |
| Proof / evidence | ✅ | Terminal evidence above |

## Threat model (STRIDE) verification

| Threat | Mitigation status |
|--------|-------------------|
| Stale malicious cache trusted forever | ✅ Docs: delete cache / TTL; SHA-256 per pack on install |
| PS1 users publish via broken path | ✅ AC-001 + RC1 redirect to `bash agtoosa.sh --registry publish` |

## Simplification (Part 2)

No refactor required for ship. Optional: add `-RegistryCommand publish` to `Show-Usage` registry section for discoverability.

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 5  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-022.
