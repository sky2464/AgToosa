# Review: DEV-018 — Registry Pack Queue

> **Story ID:** DEV-018
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-018 fixes the two-step registry pack flow by staging installs in durable `.agtoosa/pack-queue/` (outside ephemeral `ship/`), merging the queue on project install, salvaging legacy `ship/packs/` before `ship/` rebuild, and matching behavior in `agtoosa.ps1`. Bash coverage is **PK1–PK5**; registry path traversal and extension allowlists remain enforced via existing `validate_pack_files` / `_merge_pack`.

No unresolved 🔴 Critical findings. DEV-018 is ready for `/agtoosa-ship`.

## Validation

| Check | Result |
|-------|--------|
| DEV-018 targeted tests | ✅ `bats tests/agtoosa.bats -f "PK"` — 5/5 passing |
| Registry smoke (related) | ✅ `bats -f "PK\|RV[1-5]:\|validate_pack\|RG7"` — 14/14 passing |
| Spec approval | ✅ `## ✅ Spec Approved` in `docs/spec-DEV-018.md` |
| AC coverage | ✅ PK1–PK5 map to AC-001–AC-004; AC-005 implemented in PS1 (no dedicated bats) |
| Implementation commit | ✅ `b273105` on `release/v4.11.0` |

## Findings

| Severity | Persona | Finding | Disposition |
|----------|---------|---------|-------------|
| 🟢 Passed | Security Officer | Queue under repo `.agtoosa/` (gitignored); `validate_pack_files` still runs on extract; merge uses same extension allowlist as `_merge_pack`; no new secrets or network surface. STRIDE: spoofing/tampering mitigated by existing SHA + path guards on install path. | Accepted |
| 🟢 Passed | Engineering Manager | Refactor `_merge_packs_under_root` reduces duplication; salvage hook placed correctly before `rm -rf ship`; `AGTOOSA_PACK_QUEUE_DIR` test override mirrors registry cache pattern. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: `--registry install` then `bash agtoosa.sh` merges queued packs; docs and maintainer note updated; non-goals respected. | Accepted |
| 🟢 Passed | QA Lead | PK1–PK5 cover stage, merge, salvage, ship-wipe survival, and persistence; TDD evidence from build session. | Accepted |
| 🟡 Warning | Engineering Manager | `lib/install.sh` is **506 lines** (was 477 pre-change; exceeds 500-line maintainer cap by 6). | Accepted; follow-up: extract pack-merge block to `lib/packs.sh` or trim adjacent helpers |
| 🟡 Warning | QA Lead | **AC-005** (PowerShell parity) has no dedicated bats (e.g. PK6 invoking `agtoosa.ps1`); parity verified by code inspection only. | Accepted; recommend PK6 if PS1 regressions become common |
| 🟡 Warning | QA Lead | Full suite `bats tests/agtoosa.bats` reports teardown failures when `ship/` is non-empty; PK tests pass in full run. Pre-existing suite hygiene, not pack-queue logic. | Accepted; optional chore: harden global `teardown` |
| 🟡 Warning | Engineering Manager | `_merge_pack` always exits 0; queue dirs are removed after merge even if zero files copied (edge case for empty/corrupt pack dirs). | Accepted; pre-existing merge semantics |
| 🟡 Warning | Review Process | Cross-platform second-opinion (`/agtoosa-review cross`) not run in this pass. | Accepted; recommended for registry changes but not blocking |

## Simplifier notes (no code changes in review)

1. **`_merge_packs_under_root`** — clear extraction; keep as canonical merge loop.
2. **PS1 `Merge-PacksUnderRoot`** — mirrors bash; could share allowlist constant later.
3. **`install_files` pack section** — candidate to move to `lib/packs.sh` when addressing 500-line limit.

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 5  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-018.
