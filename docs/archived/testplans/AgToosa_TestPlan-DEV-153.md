# Test Plan: DEV-153 — Bats Tiering & Smoke-Set Extraction

> **Story:** DEV-153 · **Spec:** `docs/archived/spec-DEV-153.md`

## Tag analysis (baseline after DEV-152 merge)

Captured via `bash scripts/analyze-bats-tags.sh` on branch start (2026-11-20).

| Metric | Baseline | Target |
|--------|----------|--------|
| `@smoke` name occurrences | 205 (after dual-tag strip) | 45–75 |
| `@regression` occurrences | 107+ | ≥103 ship-wave SR |
| Dual `@regression` + `@smoke` on SR-001 | 26 → 0 (strip `@smoke` from regression SR) | 0 |

## Verification commands

```bash
bash scripts/analyze-bats-tags.sh
time bats tests/agtoosa.bats -f '@smoke'
time bats tests/agtoosa.bats -f '@regression'
bats tests/agtoosa.bats -f 'DEV-152|BCP-'
```

## CI intent (task 4)

- **PR:** curated or `@smoke`-filtered bats (&lt;15s target)
- **main / release:** full suite or `@regression` job after smoke