# Test Plan: DEV-042 - Spec Quality Analyzer

> **Spec:** `docs/archived/spec-DEV-042.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-042"`
> **Status:** ✅ Done

## Coverage Target

This plan will prove DEV-042 after implementation. Enrollment evidence is active now; implementation evidence must still preserve the competitive execution wave claim boundary.

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | SQA-001 | Docs/Integration | Canonical and template spec workflows define the Spec Quality Analyzer gate | yes |
| AC-002 | SQA-002 | Docs/Integration | Analyzer checklist runs before spec approval and classifies claim boundaries | yes |
| AC-003 | SQA-001 | Docs/Integration | Analyzer preserves `docs/Master-Plan.md` / `Docs/Master-Plan.md` source-of-truth boundaries | yes |
| AC-004 | SQA-001, SQA-002, SQA-003 | Bats | Focused failing regression coverage was added before workflow edits | yes |
| AC-005 | SQA-003 | Evidence | Test plan records analyzer implementation evidence without shipped runtime claims | yes |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-042"
bats tests/agtoosa.bats -f "DEV-042-060"
git diff --check
```

## Evidence

Spec Quality Analyzer gate implemented in `docs/AgToosa_Spec.md` and `template/Docs/AgToosa_Spec.md`.

Validation evidence:

```bash
bats tests/agtoosa.bats -f "DEV-042"
```

The analyzer remains agent-instructed until a later story wires generator-enforced or CI-enforced checks.
