# Test Plan: DEV-134 — Natural-Language Continuation → `/agtoosa-next`

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | NLX-001 | Docs | `PROGRESS` class + Continuation Context Contract in `AgToosa_Agent.md` (docs + template) | yes |
| AC-001 | NLX-002 | Docs | Expanded continuation examples in `AgToosa_Next.md` Relationship section (docs + template) | yes |
| AC-005 | NLX-003 | Docs | `agtoosa-core.mdc` documents context-aware disambiguation priority table | no |
| AC-005 | NLX-004 | Docs | `agtoosa-maintainer-core.mdc` parity with template sequential routing | no |
| AC-005 | NLX-005 | Docs | `agtoosa-next` skill references Continuation Context Contract | no |
| AC-006 | NLX-006 | Docs | ADR-019 amended with PROGRESS / context rules | no |
| AC-002 | NLX-007 | Docs | Phase Stop preserved — no "always chain on okay" language in Agent or Next docs | no |
| AC-004 | NLX-008 | Docs | Review BLOCKED routing documented in `AgToosa_Next.md` (docs + template) | yes |
| AC-006 | All above | Regression | Filter `NLX-` exits 0 | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| Manual | User says "okay" during pending spec interview Q | Agent answers interview — does not dispatch `/agtoosa-next` |
| Manual | User says "next" after `Next: /agtoosa-next` closure | Full `/agtoosa-next` dispatch with SYNC pulse |
| Manual | Review BLOCKED + user says "continue" | Fix/review tributary — not `/agtoosa-ship` |
