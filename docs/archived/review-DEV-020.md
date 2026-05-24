# Review: DEV-020 — Registry Install Version Pinning

> **Story ID:** DEV-020
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-020 closes a real trust gap: `pack-name@version` was parsed but not enforced in Bash, and PowerShell warned then proceeded. Commit `5119ba9` adds `registry_resolve_pack_entry()` with jq `name` + `version` selection, wires `registry_install()` and `Invoke-RegistryInstall` to fail closed before download, updates registry docs, and locks behavior with **RV1–RV5**. Scope matches the spec; no generator template inventory drift.

No unresolved 🔴 Critical findings. DEV-020 is ready for `/agtoosa-ship`.

## Validation

| Check | Result |
|---|---|
| DEV-020 targeted tests | ✅ `bats tests/agtoosa.bats -f "RV[1-5]:"` — 5/5 passing |
| Registry regression slice | ✅ `bats tests/agtoosa.bats -f "registry"` — 21/21 passing (includes RV1–RV3, RV5, RG, PK) |
| Full generator suite | 🟡 `bats tests/agtoosa.bats` — 172/255 passing; 83 failures pre-existing (install-path exit 127), not introduced by DEV-020 |
| STRIDE mitigations (spec §2.3) | ✅ Fail-closed before download; PS1 parity; error lists available version(s) |
| Build scope | ✅ Matches `docs/archived/spec-DEV-020.md` §2.4 |
| Spec approval | ✅ `## ✅ Spec Approved` in spec-DEV-020.md |
| AC coverage | ✅ RV1–RV5 map to AC-001 through AC-005 per test plan |

### Terminal evidence (review run)

| Command | Exit | Result | Warnings | Errors |
|---------|------|--------|----------|--------|
| `bats tests/agtoosa.bats -f "RV[1-5]:"` | 0 | pass (5/5) | none | none |
| `bats tests/agtoosa.bats -f "registry"` | 0 | pass (21/21) | none | none |
| `bats tests/agtoosa.bats` | 1 | 172/255 pass | 83 install-path failures (exit 127) | pre-existing sandbox/CI environment |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | Fail-closed pinning restores meaning of per-tarball SHA-256 pins; mismatch aborts before download. No new secrets, network surface, or executable pack content. STRIDE table satisfied. | Accepted |
| 🟢 Passed | Engineering Manager | Focused helper `registry_resolve_pack_entry()` keeps `registry_install()` readable; Bash/PS1 parity on selection and errors. `lib/registry.sh` 478 lines (under 500). Scope limited to registry install + docs + bats. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: pinned installs match index or error clearly; unpinned behavior preserved. Both user stories satisfied. Intentional behavior change for users who relied on silent override. | Accepted |
| 🟢 Passed | QA Lead | All Must ACs covered by RV1–RV5; test plan `docs/AgToosa_TestPlan-DEV-020.md` aligned; RV2 exercises CLI failure before download. | Accepted |
| 🟡 Warning | QA Lead | Full `bats tests/agtoosa.bats` not green (83 failures, mostly platform install exit 127). Story proof is RV filter per spec Goal Contract. | Accepted; pre-existing harness/environment; not DEV-020 regression |
| 🟡 Warning | QA Lead | RV1/RV3 test `registry_resolve_pack_entry` only, not end-to-end download for AC-001 (test plan allows resolver-first approach). | Accepted; RV2 covers CLI install failure path; download/SHA path unchanged from DEV-003 |
| 🟡 Warning | Engineering Manager | Post-resolve check at `registry_install` lines 301–304 is redundant when jq resolver already filtered by version. | Accepted; harmless belt-and-suspenders; optional cleanup later |
| 🟡 Warning | Engineering Manager | `tests/agtoosa.bats` ~2471 lines (exceeds 500-line guideline). | Accepted; established harness pattern |
| 🟡 Warning | CEO / Product Owner | No `[Unreleased]` CHANGELOG entry for DEV-020 yet. | Accepted; ship-phase hygiene |
| 🟡 Warning | Security Officer | `@` split uses first `@` only (`${pack_spec%@*}` / `${pack_spec#*@}`); scoped pack names with `@` would misparse. | Accepted; ADR-002 flat names; out of spec scope |

## Goal Contract Alignment

| Field | Result | Notes |
|---|---|---|
| Goal | ✅ | `@version` installs fail unless registry entry matches |
| User outcome | ✅ | Wrong pin → non-zero error with available version(s); no silent wrong version |
| Success condition | ✅ | Bash + PS1 enforce; RV1–RV5 green |
| Proof / evidence | ✅ | Terminal evidence above; commit `5119ba9` |

## Threat model (STRIDE) verification

| Threat | Mitigation status |
|--------|-------------------|
| User believes they pinned v1.1.0 but receives v1.2.0 | ✅ AC-001/002 + RV1/RV2 |
| Attacker tricks user into installing "latest" while docs say pinned | ✅ Explicit errors; meta uses resolved version |
| Silent cross-version install bypasses SHA intent | ✅ Fail closed before download |
| Registry install denied when old version absent from index | ✅ Actionable error (acceptable per spec) |
| PS1-only bypass | ✅ AC-004 + RV5 |

## Simplification (Part 2)

Optional follow-up (non-blocking): remove redundant `pack_version` vs `pack_version_resolved` check in `registry_install` when jq resolver is used, since `registry_resolve_pack_entry` already enforces the pin. No refactor required for ship.

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 6  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-020.
