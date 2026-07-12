# Capability: lifecycle-next-step-sync

> Living system spec — merged from story capability deltas at ship time.  
> **Last changed by:** DEV-109 (2026-07-12)

## Requirements

| ID | EARS | Last changed by | Notes |
|----|------|-----------------|-------|
| LNS-001 | WHEN Spec/Build/Review/Ship completes successfully, THE SYSTEM SHALL print a primary lifecycle next-step (not `/agtoosa-status` as headline) plus an executive SYNC pulse | DEV-109 | dual-line close |
| LNS-002 | WHEN `agtoosa.sh --status-line` or `agtoosa.ps1 -StatusLine` runs, THE SYSTEM SHALL emit the same SYNC format read-only from Master-Plan | DEV-109 | generator-enforced CLI |
| LNS-003 | WHEN multi-objective spec work is requested, THE SYSTEM SHALL run multi-spec intake with combinable clarity tags (`ready`, `sa-ready`, `needs-interview`) | DEV-109 | per-story interview gate |
| LNS-004 | WHEN Plan-Mode Spec Interview hits soft cap, THE SYSTEM SHALL allow repeating +4 on free-text new directions until Decision-complete | DEV-109 | not a hard stop at 8 |
| LNS-005 | WHEN describing phase close, THE SYSTEM SHALL demote universal status-only closure to optional verify guidance | DEV-109 | preserves closure-loop without obscuring lifecycle |

## References

- ADR: `docs/adr/ADR-012-lifecycle-next-step-sync.md`
- Agent contract: `docs/AgToosa_Agent.md` → Lifecycle Next-Step Contract
- Spec: `docs/archived/spec-DEV-109.md`
