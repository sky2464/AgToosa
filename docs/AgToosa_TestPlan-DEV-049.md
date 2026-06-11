# Test Plan: DEV-049 - Evidence Ledger

> **Spec:** `docs/archived/spec-DEV-049.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-049"`
> **Status:** ⬜ Backlog

## Coverage Target

This plan will prove DEV-049 only after the story is enrolled and implemented. Until then, it preserves the competitive execution wave backlog contract and claim boundary.

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | DEV-049-T-001 | Docs/Integration | Capability states user outcome and proof before shipped claims | planned |
| AC-002 | DEV-049-T-002 | Docs/Integration | Enforcement language is classified as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap | planned |
| AC-003 | DEV-049-T-003 | Docs/Integration | Repo-local source-of-truth boundary is preserved for external integrations | planned |
| AC-004 | DEV-049-T-004 | Bats | Focused failing regression coverage is added before behavior changes | planned |
| AC-005 | DEV-049-T-005 | Evidence | Ship evidence is recorded without broader claims | planned |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-049"
bats tests/agtoosa.bats -f "DEV-042-060"
git diff --check
```

## Evidence

Backlog creation evidence is covered by the competitive wave tests in `tests/agtoosa.bats`. Implementation evidence must be added when this story is built.
