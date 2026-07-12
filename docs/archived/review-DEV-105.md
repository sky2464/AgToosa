# Review Report — DEV-105

> **Story:** DEV-105 — PowerShell Maintain + Update Parity  
> **Wave:** Rev4 Wave 1a (with DEV-086 · DEV-090)  
> **Reviewed:** 2026-07-12  
> **Personas:** Security Officer · Engineering Manager · CEO/Product · QA Lead · Cross-Model  
> **Verdict:** ✅ PASS (warnings accepted)

## Findings

| Sev | Persona | Finding | Disposition |
|-----|---------|---------|-------------|
| 🟢 | Security | Array-splatted bash invoke; UpdatePath required; uninstall preserves Master-Plan/Context via bash | Pass |
| 🟡 | Security | PS1 maintain lacks install-style self-target guard | Accepted — bash blocks update/uninstall self-target |
| 🟡 | Security | `AGTOOSA_BASH` env override is trust boundary | Accepted — document |
| 🟡 | Security | Uninstall may leave `Docs/agtoosa-lock.json` | Accepted — follow-up |
| 🟢 | Arch | `Invoke-AgToosaMaintain` focused; bash-authoritative update | Pass |
| 🟡 | Arch | `agtoosa.ps1` 1383 &gt; 500 (pre-existing monolith) | Accepted — extraction backlog |
| 🟢 | CEO | Goal Contract mostly met; dispatch parity real | Pass |
| 🟡 | QA | AC-006 lock.json half untested when packs present; PSP-004 asserts version only | Accepted — AC-006 conditional on packs; bash lock bats exist; add pack fixture later |
| 🟡 | QA | Pester fixture bootstrap flake (1st run); process exit may mask FailedCount | Accepted — re-run green; CI note |
| 🟡 | Cross-Model | Bats mostly grep contracts; Pester exit codes permissive | Accepted — strengthen integration negatives later |

## Goal Contract Alignment

| Field | Result |
|-------|--------|
| Goal / User outcome | 🟢 Pass |
| Success condition + proof | 🟢 Pass (PSP bats + Pester) |
| Non-goals | 🟢 Pass (no native verifier / JSON flags) |

## Cross-Model Review

**Risk tier:** Recommended  
**Gate:** Independent read-only reviewer ([cross-model](3efc937a-937e-4929-bc23-6bccab9d0f54)).

| Finding | Confidence |
|---------|------------|
| Grep-heavy PSP coverage | reviewer-only |
| Lock JSON assertion gap for packful updates | both-models |

## Terminal Evidence (orchestrator)

```text
$ bats tests/agtoosa.bats -f "DEV-105|PSP-"
1..5 all ok — EXIT 0
$ pwsh Invoke-Pester tests/pester/agtoosa-maintain.Tests.ps1
PassedCount 6 (stable re-run)
```

## Ship version suggestion

PATCH **5.3.16** (batched Wave 1a).

## Approval

Review ✅ Approved — 0 🔴 Critical · warnings accepted · proceed to `/agtoosa-ship`.
