# Review: DEV-021 — E2E Pinned Registry Install Test (RV6)

> **Story ID:** DEV-021
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-021 closes the DEV-020 review gap: **RV6** exercises the full Bash pinned install path (`--registry install mock-pack@1.0.0`) through `file://` download, SHA-256 verification, queue staging, and `.pack-meta.json` — not only `registry_resolve_pack_entry`. Scope is tests-only per spec; no `lib/registry.sh` changes.

No unresolved 🔴 Critical findings. DEV-021 is ready for `/agtoosa-ship` (or bundle with related registry stories).

## Validation

| Check | Result |
|---|---|
| DEV-021 smoke | ✅ `bats tests/agtoosa.bats -f "RV6:"` — pass when `ship/` teardown is clean |
| DEV-020 + DEV-021 slice | ✅ `bats tests/agtoosa.bats -f "RV[1-6]:"` — 6/6 pass with clean `ship/`; RV2/RV4 may report teardown failure if `tests/../ship` is non-empty (test bodies still pass) |
| Full generator suite | 🟡 `bats tests/agtoosa.bats` — not green (pre-existing install-path / harness issues); story proof is RV6 filter per Goal Contract |
| Build scope | ✅ Matches `docs/archived/spec-DEV-021.md` §2.3 (bats + fixtures via `mock-pack/`) |
| Spec approval | ✅ `## ✅ Spec Approved` in spec-DEV-021.md |
| AC coverage | ✅ RV6 maps to AC-001–AC-003 per `docs/AgToosa_TestPlan-DEV-021.md` |

### Terminal evidence (review run)

| Command | Exit | Result | Notes |
|---------|------|--------|-------|
| `rm -rf ship && bats tests/agtoosa.bats -f "RV6:"` | 0 | pass (1/1) | |
| `rm -rf ship && bats tests/agtoosa.bats -f "RV[1-6]:"` | 1 | 6/6 test bodies pass | Exit 1 from RV2/RV4 **teardown** `rm -rf ship` when `ship/Docs` left behind |
| `bats tests/agtoosa.bats -f "RV6:"` (dirty `ship/`) | 1 | teardown failure | Environmental; not RV6 logic failure |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | RV6 uses isolated cache/queue dirs; `file://` tarball is test-built at runtime with matching SHA-256. No new secrets, network egress, or production behavior change. | Accepted |
| 🟢 Passed | Engineering Manager | Single focused `@test` reuses `mock-pack` fixture; runtime SHA embed avoids fixture drift. Tests-only scope; no file >500 lines added. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: CI can trust DEV-020 install path end-to-end. All Must ACs implemented (AC-001 full path, AC-002 RV6 exists, AC-003 hermetic env vars). | Accepted |
| 🟢 Passed | QA Lead | RV6 calls CLI `registry install`, asserts `workflow.md` + `.pack-meta.json` version `1.0.0`. Test plan documents smoke filter. | Accepted |
| 🟡 Warning | QA Lead | Test plan negatives **T-001-N** (wrong SHA) and **T-002-N** (`file://` stub) not implemented. | Accepted; optional hardening; not Must ACs |
| 🟡 Warning | QA Lead | RV6 does not assert `.pack-meta.json` contains `sha256` field — only name/version. Integrity proven implicitly by successful install. | Accepted |
| 🟡 Warning | QA Lead | Global `teardown` `rm -rf ship` flakes when `ship/Docs` exists (case/path residue), causing bats exit 1 after otherwise-passing RV2/RV4/RV6. | Accepted; pre-existing harness; clean `ship/` before RV filter |
| 🟡 Warning | Engineering Manager | `tests/agtoosa.bats` working tree diff includes **DEV-022** RC1–RC3 block above RV6 (~143 lines total vs HEAD). Ship should separate or document bundled commits. | Accepted; out of DEV-021 scope but affects diff review |
| 🟡 Warning | CEO / Product Owner | `docs/archived/spec-DEV-021.md` and `docs/AgToosa_TestPlan-DEV-021.md` are untracked in git at review time. | Accepted; include on ship commit |
| 🟡 Warning | CEO / Product Owner | No `[Unreleased]` CHANGELOG entry for DEV-021 yet. | Accepted; ship-phase hygiene |

## Goal Contract Alignment

| Field | Result | Notes |
|---|---|---|
| Goal | ✅ | Full pinned install path proven in CI |
| User outcome | ✅ | Maintainers get network-free E2E without manual smoke |
| Success condition | ✅ | RV6 green; RV1–RV5 unchanged |
| Proof / evidence | ✅ | Terminal evidence above |

## Simplification (Part 2)

RV6 is a single linear integration test (~40 lines) with clear setup/assert/teardown. No refactor required for ship. Optional follow-ups (non-blocking): extract shared “build registry JSON + cache dir” helper if more E2E registry tests land; add T-001-N wrong-SHA negative; harden global `teardown` for `ship/` (e.g. `chmod -R u+w` before `rm -rf`).

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 6  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-021 (or ship with DEV-022 if bundling registry follow-ups).
