# Test Plan — DEV-146 README First-Visit Simplification

| Story | DEV-146 |
|-------|---------|
| Spec | `docs/archived/spec-DEV-146.md` |
| Scope | README, readme-reference, bats |

## AC → Test mapping

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | RMF-003 | Static | Quick install section precedes hero GIF reference | yes |
| AC-001 | RMF-001 | Static | Windows PowerShell quick install in README | yes |
| AC-001 | RMF-002 | Static | Confirmed tagline present | yes |
| AC-002 | RMH-002 | Static | README body line count ≤ 180 (excl. product-truth) | yes |
| AC-003 | PRF-001–009 | Integration | Proof-journey contracts | yes |
| AC-003 | RMH-001–006 | Static | Hero assets + launch checker | yes |
| AC-003 | R1, R2, R7 | Static | Workflow/enforcement README greps | yes |
| AC-003 | DEV-035 LG-001 | Static | Public launch command labels | yes |
| AC-003 | DEV-037 TD-001–002 | Static | Dependency qualification + readme-reference link | yes |
| AC-003 | DEV-039 FG-004 | Static | First-15 walkthrough link | yes |
| AC-003 | DEV-041 PL-003 | Static | Public launch proof + proof repo links | yes |
| AC-003 | DEV-042-060 CW-004 | Static | Competitive wave via readme-reference | yes |
| AC-004 | RMH-003 | Static | readme-reference holds relocated depth | yes |
| AC-005 | RMF-001–003 | Static | New first-visit contract bats | yes |

## Commands

```bash
bats tests/agtoosa.bats -f '^DEV-146|^RMF-|PRF-00|RMH-|DEV-035 LG|DEV-037 TD|DEV-039 FG-004|DEV-041 PL-003|DEV-042-060 CW-004|^R1:|^R2:|^R7:'
bash scripts/check-launch-readiness.sh --mode private
```
