# Review: DEV-132 — Preserve Evidence JSONL on Re-install and Update

> **Story:** DEV-132  
> **Review date:** 2026-07-27  
> **Risk tier:** Low (generator install-path fix; no new trust boundary)  
> **Outcome:** ✅ PASS  
> **Suggested release:** PATCH **5.3.45 → 5.3.46**

## Verdict

| Severity | Count |
|----------|-------|
| 🔴 Critical | 0 |
| 🟡 Warning | 2 |
| 🟢 Passed | 4 personas + Goal Contract |

**Ship recommendation:** PASS — project-owned evidence JSONL wired across Bash + PowerShell install/update/reinstall/uninstall/plan paths; EVJ bats green.

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Evidence JSONL preserved on all mutating install paths when present |
| Success condition | 🟢 EVJ-001–006 6/6 PASS; preserve banner shows evidence-ledger reason |
| Non-goals | 🟢 JSONL authority unchanged; fresh-install seed behavior unchanged |

## Structured Findings

| ID | Severity | Persona | Finding | Next action |
|----|----------|---------|---------|-------------|
| R-132-001 | 🟡 | QA | Verifier G3-no-red — no RED block in test plan (data-loss fix) | Accepted — EVJ integration bats cover regression |
| R-132-002 | 🟡 | Engineering | PS1 Master-Plan/Changelog/Architecture share generic "project plan" reason string | Pre-existing; evidence JSONL has correct dedicated reason |
| R-132-003 | 🟢 | Security | Prevents silent append-only ledger wipe on upgrade — data-integrity win | Ship |
| R-132-004 | 🟢 | Engineering | Centralized `_AGTOOSA_PROJECT_OWNED_DOCS` reduces drift vs hard-coded trio | — |
| R-132-005 | 🟢 | CEO/PO | All 7 Must ACs mapped to EVJ bats | — |
| R-132-006 | 🟢 | QA | `bats --filter EVJ-` → 6/6 PASS | — |

## AC Coverage

| AC | Coverage | Status |
|----|----------|--------|
| AC-001 | EVJ-001 install re-run | 🟢 |
| AC-002 | EVJ-002 update | 🟢 |
| AC-003 | EVJ-003 reinstall --clean | 🟢 |
| AC-004 | EVJ-004 uninstall | 🟢 |
| AC-005 | EVJ-005 PowerShell | 🟢 |
| AC-006 | EVJ-006 plan classify | 🟢 |
| AC-007 | EVJ-001–006 filter | 🟢 |

## Cross-Model Review

**Skipped** — Fix XS, narrow install-path change, full EVJ integration coverage. Virtual personas sufficient per on-demand tier.

## Terminal Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/agtoosa.bats --filter 'EVJ-'` | 0 | 6/6 PASS |
| `bash docs/agtoosa-verify.sh` | 0 | pass · 0 fail |

Review ✅ Approved — 2026-07-27 — ready for `/agtoosa-ship DEV-132 v5.3.46`.
