# Review: DEV-133 — GitHub Branch Hygiene for Cursor Agent Sprawl

> **Story:** DEV-133  
> **Review date:** 2026-07-28  
> **Risk tier:** Low (maintainer-only GitHub hygiene; prefix-filtered deletes)  
> **Outcome:** ✅ PASS  
> **Suggested release:** PATCH **5.3.46 → 5.3.47**

## Verdict

| Severity | Count |
|----------|-------|
| 🔴 Critical | 0 |
| 🟡 Warning | 1 |
| 🟢 Passed | 4 personas + Goal Contract |

**Ship recommendation:** PASS — dry-run default, denylist for `main`/`master`, `cursor/` prefix filter, scheduled workflow + maintainer runbook; BRH bats green.

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Auto-retire stale `cursor/*` agent branches after PR close |
| User outcome | 🟢 Maintainer script + weekly workflow reduce manual `gh` cleanup |
| Success condition | 🟢 BRH-001–006 6/6 PASS |
| Non-goals | 🟢 No template/generator changes; no non-`cursor/*` deletes |

## Structured Findings

| ID | Severity | Persona | Finding | Next action |
|----|----------|---------|---------|-------------|
| R-133-001 | 🟡 | Security | `--apply` requires live `gh` auth — no offline integration test for delete path | Accepted — dry-run + denylist bats cover contract; manual dispatch for first prod run |
| R-133-002 | 🟢 | Security | Denylist + prefix filter mitigate wrong-branch delete (STRIDE tampering) | Ship |
| R-133-003 | 🟢 | Engineering | Script 183 lines; helpers sourceable for bats; workflow pins checkout SHA | — |
| R-133-004 | 🟢 | CEO/PO | All 6 Must ACs mapped to BRH bats | — |
| R-133-005 | 🟢 | QA | `bats --filter 'BRH-'` → 6/6 PASS | — |

## AC Coverage

| AC | Coverage | Status |
|----|----------|--------|
| AC-001 | BRH-001 dry-run default | 🟢 |
| AC-002 | BRH-002 apply/close-prs/prefix flags | 🟢 |
| AC-003 | BRH-003 main/master denylist | 🟢 |
| AC-004 | BRH-004 branch-hygiene.yml schedule + dispatch | 🟢 |
| AC-005 | BRH-005 maintainer runbook | 🟢 |
| AC-006 | BRH-006 regression filter | 🟢 |

## Cross-Model Review

**Skipped** — Chore S, maintainer-only surface, full BRH contract coverage. Virtual personas sufficient per on-demand tier.

## Terminal Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/agtoosa.bats --filter 'BRH-'` | 0 | 6/6 PASS |

Review ✅ Approved — 2026-07-28 — served by `/agtoosa-next`; ready for `/agtoosa-ship DEV-133 v5.3.47`.
