# Test Plan: DEV-135 — Natural-Language Continuation → `/agtoosa-next`

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | NLX-001 | Docs | `PROGRESS` class + Continuation Context Contract in `AgToosa_Agent.md` (docs + template) | yes |
| AC-001 | NLX-002 | Docs | Expanded continuation examples in `AgToosa_Next.md` Relationship section (docs + template) | yes |
| AC-005 | NLX-003 | Docs | `agtoosa-core.mdc` documents context-aware disambiguation priority table | no |
| AC-005 | NLX-004 | Docs | `agtoosa-maintainer-core.mdc` parity with template sequential routing | no |
| AC-005 | NLX-005 | Docs | `agtoosa-next` skill references Continuation Context Contract | no |
| AC-006 | NLX-006 | Docs | ADR-019 amended with PROGRESS / context rules | no |
| AC-002 | NLX-007 | Docs | Phase Stop preserved — no "always chain on okay" language | no |
| AC-004 | NLX-008 | Docs | Review BLOCKED routing documented in `AgToosa_Next.md` Step 1b | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| Manual | "okay" during pending spec interview Q | Answer interview — do not dispatch `/agtoosa-next` |
| Manual | Review BLOCKED + "continue" | Fix/review tributary — not ship |
