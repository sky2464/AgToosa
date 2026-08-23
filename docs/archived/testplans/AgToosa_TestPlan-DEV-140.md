# Test Plan: DEV-140 — Help vs Next Disambiguation Hardening

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | NLX-009 | Docs | Disambiguation table in `AgToosa_Agent.md` (docs + template) | yes |
| AC-002 | NLX-010 | Docs | Forbidden closure anti-patterns in `AgToosa_Next.md` (docs + template) | yes |
| AC-003 | NLX-011 | Docs | Help adapters warn against freeform `next`; next adapters state PROGRESS executes | no |
| AC-004 | NLX-012 | Integration | `progress-continuation-proof` in corpus + six platform fixture trees | yes |
| AC-004 | SR-001 | Release | v5.3.54 version pins + changelog entry | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| Manual | User says `next` after `Next: /agtoosa-next` closure | Execute `/agtoosa-next` with dispatch banner — not help preview |
| Manual | User invokes `/agtoosa-help next` | Read-only preview ending `To execute: /agtoosa-next` |
