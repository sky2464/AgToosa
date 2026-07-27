# Test Plan: DEV-131 — Sequential Approval + Release Publication Gate

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | NXT-013 | Docs | Sequential Approval Contract in template + docs `AgToosa_Next.md`; served-by-next in Spec + Agent | yes |
| AC-002 | NXT-003 | Docs | Single-phase dispatch documented (no auto-chain) | yes |
| AC-003 | NXT-014 | Docs | Post-ship idle cold-start + `No spec is planned` text | no |
| AC-001 | NXT-015 | Docs | ADR-019 Sequential Approval amendment | no |
| AC-004 | RL-002 | Docs | `AgToosa_Ship.md` release publication rule | no |
| AC-005 | RL-001 | Docs | Maintainer `tech-stack.md` deploy_command + deploy_verify | no |
| AC-006 | RL-003 | Integration | `check-launch-readiness.sh` remote tag check | no |
| AC-004 | RL-004 | Integration | `release-advanced.yml` canonical tag workflow | no |
| AC-007 | All above | Regression | Full filter `NXT-013|NXT-014|NXT-015|DEV-131 RL` exits 0 | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| Manual | Ship with deploy_command but no remote tag | Agent stops; no `Release X shipped` row |
| Manual | `/agtoosa-next` with 🔴 Critical review | BLOCKED; no ship dispatch |
