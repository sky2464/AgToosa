# Review: DEV-003 — Registry Prod-Readiness (Audit Closure)

> **Story ID:** DEV-003
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-003 closes remaining v3.1 registry audit items: `merge_platform_file` Case B injects version markers on `--update` (without double-wrapping pre-injected `ship/` sources), registry bash UX (`info` exits 1 on unknown pack, search no-results + safe jq probe handling, `registry_publish` via `jq -n`), PS1 `@(ConvertFrom-Json)`, and **RG1–RG8** bats. Generator/runtime changes are limited to `lib/copy.sh`, `lib/registry.sh`, `agtoosa.ps1`, and docs.

No unresolved 🔴 Critical findings. DEV-003 is ready for `/agtoosa-ship` (prefer a focused commit/PR separate from DEV-016 if possible).

## Validation

| Check | Result |
|---|---|
| DEV-003 targeted tests | ✅ `bats tests/agtoosa.bats -f "RG[1-8]:"` — 8/8 passing |
| Full generator suite | ✅ `bats tests/agtoosa.bats` — 246/246 passing |
| STRIDE mitigations (spec §2.3) | ✅ jq injection, path traversal, publish JSON, Case B merge stability, unknown-pack exit code |
| Build scope | ✅ Matches `docs/archived/spec-DEV-003.md` §2.4 |
| Spec approval | ✅ `## ✅ Spec Approved` in spec-DEV-003.md |
| AC coverage | ✅ RG1–RG8 map to AC-001 through AC-008 |

### Terminal evidence (review run)

| Command | Exit | Result | Warnings | Errors |
|---------|------|--------|----------|--------|
| `bats tests/agtoosa.bats -f "RG[1-8]:"` | 0 | pass (8/8) | none | none |
| `bats tests/agtoosa.bats` | 0 | pass (246/246) | none | none |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | `jq --arg` preserved for search/info; publish uses `jq -n`; path traversal guard unchanged (RG7); no new secrets or network surface. | Accepted |
| 🟢 Passed | Engineering Manager | Case B correctly branches: raw `TEMPLATE_DIR` sources get `inject_version`; pre-injected `ship/` sources append as-is. Fixes CB-4 without breaking DEV-172 Case B test. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: registry/update flows safe and predictable; RG1–RG8 + full suite evidence. | Accepted |
| 🟢 Passed | QA Lead | All Must ACs covered by RG1–RG8; merge regression RG3 + existing DEV-172 Case B test both green. | Accepted |
| 🟡 Warning | Security Officer | `registry_search` treats jq regex failures like empty results (exit 0, “No packs found…”). Safe per AC-008 but indistinguishable from a true empty search in automation. | Accepted; intentional tradeoff for probe safety |
| 🟡 Warning | Engineering Manager | `tests/agtoosa.bats` exceeds 500-line limit (~2300+ lines). | Accepted; established harness pattern |
| 🟡 Warning | CEO / Product Owner | No `[Unreleased]` CHANGELOG entry for DEV-003 yet. | Accepted; ship-phase hygiene |
| 🟡 Warning | Engineering Manager | Working tree also contains DEV-016 template changes and uncommitted Codex prompt wiring — split commits/PRs at ship time. | Accepted; ship hygiene |

## Goal Contract Alignment

| Field | Result | Notes |
|---|---|---|
| Goal | ✅ | Remaining audit blockers closed in bash/PS1 + tests |
| User outcome | ✅ | Staged packs, safe merge on update, clear registry errors |
| Success condition | ✅ | CB-4, registry UX, publish JSON, PS1 array, RG1–RG8, full suite green |
| Proof / evidence | ✅ | Terminal evidence above |

## Threat model (STRIDE) verification

| Threat | Mitigation status |
|--------|-------------------|
| jq filter injection via search | ✅ RG1 + `--arg` + graceful jq failure handling |
| Path traversal in pack tarballs | ✅ RG7 / existing `validate_pack_files` |
| Malformed publish JSON | ✅ AC-005 / RG5 / `jq -n` |
| Update merge duplicates unmarked blocks | ✅ AC-001/002 / RG3 |
| Silent success on unknown pack | ✅ AC-003 / RG2 |
| PS1 single-element JSON array | ✅ AC-006 / RG6 |

## Simplification (Part 2)

No refactors required. Case B branch is minimal and matches install vs update source shapes.

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 4  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-003.
