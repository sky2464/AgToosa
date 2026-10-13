# Test Plan: DEV-152 — Bats Cleanup & Version Pin Consolidation

| AC | Test ID | Description | Type | Expected |
|----|---------|-------------|------|----------|
| AC-001 | BCP-001 | Stale `v5.3.*` hardcodes in `tests/agtoosa.bats` | Contract | `grep` count ≤ 10 active pins; remainder parameterized or removed |
| AC-002 | BCP-002 | Wave 2–4 regression block tagged or isolated | Contract | Lines ~7321–7860 use `@regression` or regression-only boundary |
| AC-003 | BCP-003 | DEV-119–124 ship wave pins consolidated | Contract | Lines ~13113–15437 tagged `@regression` or isolated |
| AC-004 | BCP-004 | Bats compile gate | Integration | `bats --compile tests/agtoosa.bats` exit 0 |
| AC-005 | BCP-005 | Release notes / CHANGELOG mention cleanup | Contract | Brief summary in CHANGELOG or release notes |

Smoke (maintainer loop): `bats tests/agtoosa.bats -f 'DEV-152|BCP-'` after BCP tests land.

Curated CI alignment: `bash scripts/test-fast.sh` or `bats tests/agtoosa.bats -f '@smoke BCL|PN|WP2|ACC|NET|PSP|CORE'` must remain green after consolidation (no semantic test rewrites).
