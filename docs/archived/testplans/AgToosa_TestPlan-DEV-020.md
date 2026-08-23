# Test Plan: DEV-020 — Registry Install Version Pinning

> **Spec:** `docs/archived/spec-DEV-020.md`
> **Coverage target:** 80%
> **Smoke filter:** `bats tests/agtoosa.bats -f "RV[1-5]:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (RV1) | Integration | Pinned `--registry install name@version` succeeds when fixture entry version matches | yes |
| AC-002 | T-002 (RV2) | Integration | Pinned install exits non-zero when requested version ≠ fixture version; no staging | yes |
| AC-003 | T-003 (RV3) | Integration | Unpinned `--registry install name` still resolves by name only | yes |
| AC-004 | T-004 (RV5) | Integration | PS1 registry install fails closed on version mismatch | yes |
| AC-005 | T-004 (RV4) | Unit | Bash `registry_install` compares parsed `pack_version` to registry entry (static/source guard) | yes |

## Negative / Edge Scenarios

| ID | Scenario |
|----|----------|
| T-001-N | Remove version filter from jq pinned path → RV1/RV2 fail |
| T-002-N | Allow install to continue after mismatch in PS1 → RV5 fails |
| T-003-N | Break unpinned name-only selection → RV3 fails |

## Commands

```bash
# Narrow DEV-020 filter first
bats tests/agtoosa.bats -f "RV[1-5]:"

# Full regression after targeted pass
bats tests/agtoosa.bats
```

## Implementation notes for test author

- Use `AGTOOSA_REGISTRY_CACHE_DIR` with `tests/fixtures/registry.json` (ml-pipeline `1.2.0`) — same pattern as RG tests.
- RV2 should request `ml-pipeline@9.9.9` and assert non-zero exit before any download (stderr mentions version).
- RV1 may source `registry_install` with mocked `curl` / stubbed entry, or use a fixture registry row plus skip download via extracting `_registry_resolve_pack_entry` if refactored; prefer minimal helper over live network.
- RV3: `ml-pipeline` without `@` should reach confirmation prompt (status 0 with `echo Y |` only if download is stubbed; otherwise assert jq resolution path via sourced function test).
