# Review: DEV-054 — Signed Registry Provenance

> **Story:** DEV-054  
> **Date:** 2026-07-08  
> **Verdict:** ✅ PASS  
> **Suggested release:** PATCH **5.3.4 → 5.3.5** (ADR-005 patch-first)

## Summary

Optional minisign soft-warn provenance for registry packs and release/bootstrap sidecars: `lib/provenance.sh`, registry + bootstrap wiring, ADR-011, Trust/Readiness/Registry docs, bundled pubkey path, SP-001–SP-006 bats. Goal Contract satisfied; M-1 keygen remains Manual/Deferred; fail-closed / SBOM / cosign verify remain roadmap.

| Persona | 🔴 Critical | 🟡 Warning | 🟢 Passed |
|---------|-------------|------------|-----------|
| Security Officer | 0 | 2 | 6 |
| Engineering Manager | 0 | 2 | 5 |
| CEO / Product Owner | 0 | 1 | 1 |
| QA Lead | 0 | 1 | 3 |
| **Unresolved Critical** | **0** | — | — |

## Findings

| Sev | Persona | Finding | Disposition |
|-----|---------|---------|-------------|
| 🟡 | Security | Soft-warn invalid signatures still allow install — accepted risk per spec interview | **Accepted** |
| 🟡 | Security | Placeholder pubkey until M-1; real release signatures not yet produced | **Accepted** — documented in `docs/security/README.md` |
| 🟡 | EM | Bootstrap uses inline soft-verify (not `lib/provenance.sh`) — minor duplication | **Accepted** — bootstrap runs pre-extract without full SCRIPT_DIR layout |
| 🟡 | EM | No PowerShell minisign parity on registry install | **Accepted** — spec allows bash-first; PS1 verified-flag parity unchanged |
| 🟡 | CEO | P0 trust gap partially closed; mandatory signed installs still roadmap | **Accepted** — Claim Boundary honest |
| 🟡 | QA | AC-007 ship evidence pending until `/agtoosa-ship` | **Fixed at ship** |

## Goal Contract Alignment

| Story | Alignment |
|-------|-----------|
| DEV-054 | 🟢 Pass — dual-surface schema, soft-warn verify when sig present, unsigned path unchanged, honest enforcement classification, SP bats green |

## Terminal Evidence — QA

| Field | Value |
|-------|--------|
| Command | `bats tests/agtoosa.bats -f "DEV-054"` |
| Exit code | 0 |
| Pass/fail | PASS — 10/10 (CW-017, SP-001–SP-006, PS-001–PS-003) |
| Verifier | `bash docs/agtoosa-verify.sh --root .` → PASS (12 pass · 0 warn · 0 fail) |
| Next | `/agtoosa-ship` PATCH 5.3.5 |

## ✅ Review Approved

Approved: 2026-07-08 18:40  
Unresolved 🔴 Critical: 0
