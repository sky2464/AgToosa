# Test Plan — DEV-127 README Experience Refresh

| Story | DEV-127 |
|-------|---------|
| Spec | `docs/archived/spec-DEV-127.md` |
| Scope | README, guides, media, wiki, bats |

## AC → Test mapping

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | RMH-001 | Static | Hero asset files exist and README references them | yes |
| AC-001 | RMH-002 | Static | README body line count ≤ 180 (excl. product-truth block) | yes |
| AC-001 | PRF-001–009 | Integration | Proof-journey contracts unchanged | yes |
| AC-002 | RMH-003 | Static | readme-reference.md contains Installation + How It Differs | yes |
| AC-002 | RMH-004 | Static | architecture-overview.md contains full lifecycle mermaid | yes |
| AC-003 | RMH-005 | Static | Remotion package.json + render docs present | yes |
| AC-004 | RMH-006 | CLI | `check-launch-readiness.sh --mode private` passes | yes |
| AC-005 | RMH-007 | Static | Competitor strings in readme-reference; DEV-037 bats updated | yes |
| AC-005 | RMH-008 | Static | Competitive wave strings in readme-reference; DEV-042 bats updated | yes |
| AC-006 | RMH-009 | Static | Wiki Home has no Linear canonical claim; links new guides | yes |
| AC-007 | — | Manual | Read-more includes first-15 + video slot | manual |

## Commands

```bash
bats tests/agtoosa.bats -f '^DEV-127|^RMH-|PRF-00'
bash scripts/check-launch-readiness.sh --mode private
```
