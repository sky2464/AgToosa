# Review: DEV-027 — Agentic `/agtoosa-update`

> **Story ID:** DEV-027
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-027 resolves the split contract between read-only briefing and real CLI updates by redefining the canonical `Docs/AgToosa_Update.md` workflow as **Detect → Plan → Apply → Verify** with **ask-then-apply**, explicit approval before mutation, `bash agtoosa.sh --update <project>` as the mutation source of truth, and a read-only `check` sub-command. Platform adapters (Claude, Cursor, Gemini, Copilot, Windsurf, Codex skill/prompt) and maintainer mirror `docs/AgToosa_Update.md` are aligned. Bats **T-001–T-009** lock all Must ACs.

No unresolved 🔴 Critical findings. Ready for `/agtoosa-ship` (v5.1.0 template release; version wiring at ship).

## Validation

| Check | Result |
|---|---|
| DEV-027 targeted tests | ✅ `bats tests/agtoosa.bats --filter 'T-00[1-9]:'` — 9/9 passing |
| Spec approval | ✅ `docs/archived/spec-DEV-027.md` — build complete, Must ACs defined |
| AC coverage (Must) | ✅ AC-001–AC-007 → T-001–T-007; AC-008–AC-009 → T-008–T-009 (see `docs/AgToosa_TestPlan-DEV-027.md`) |
| Threat model | ✅ STRIDE table in spec § 2.3; approval gate, CLI delegation, preflight, migration guidance in canonical doc |
| Build tasks | ✅ 13/13 complete per `docs/Master-Plan.md` Active Tasks |
| Full generator suite | 🟡 `bats tests/agtoosa.bats` — red: `--version` pin expects `AgToosa v5.0.0` while `AGTOOSA_VERSION` is `5.0.1` (cascades inject_version/copy tests). Fix at ship per release checklist; not a DEV-027 contract regression |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | Template-only change; no new executables or secrets. STRIDE mitigations: explicit approval before Apply (AC-003), CLI as mutation source (AC-004), preflight for dirty git/malformed markers (AC-008), verification reports filenames only (spec § 2.3). | Accepted |
| 🟢 Passed | Engineering Manager | Scope limited to `template/Docs/AgToosa_Update.md`, adapters, bats, maintainer mirrors; `lib/update.sh` unchanged. Canonical doc ~160 lines; adapters are thin routers. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: users get detect → plan → approve → CLI update → verify; `check` stays read-only. All Must user stories and ACs satisfied. Non-goals respected (no auto-approve, no preservation list change). | Accepted |
| 🟢 Passed | QA Lead | T-001–T-009 green; test plan evidence recorded; 9/9 Must ACs mapped; smoke set T-001–T-007 covered. | Accepted |
| 🟡 Warning | QA Lead | Full `bats tests/agtoosa.bats` fails on stale `--version prints version string` pin (`v5.0.0` vs `5.0.1`). Ship must bump `AGTOOSA_VERSION`, `agtoosa.ps1`, bats pin, and README badge together. | Accepted — ship gate |
| 🟡 Warning | Engineering Manager | `template/CLAUDE.md`, `AGENTS.md`, `OPENCODE.md` optional-utilities blurbs still say “update workflow files to latest” — understates agentic contract; adapters route to canonical doc. | Accepted — optional doc polish at ship |
| 🟡 Warning | Engineering Manager | Contract enforcement is markdown instructions + grep bats only — no runtime guarantee agents comply (inherent to template stories). | Accepted |
| 🟡 Warning | QA Lead | Filtered `--update` regression run can fail when `tests/../ship` is non-empty (teardown `rm -rf ship`); clean `ship/` before filtered runs. | Accepted — operator hygiene |

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 4  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-027 — suggest **v5.1.0** (template + docs + bats contract; bump version pins during ship).
