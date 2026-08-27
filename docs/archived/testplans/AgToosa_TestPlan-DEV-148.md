# Test Plan: DEV-148 — One-Line Install Hardening

> **Spec:** `docs/archived/spec-DEV-148.md`
> **Status:** 🏁 Shipped — v0.3.60
> **Created:** 2026-08-27 (retroactive backfill; code shipped 2026-08-01 via PR #92)
> **Test prefix:** `B32` (bash 3.2 nounset guard) · `INS` (install/bootstrap hardening docs, shared DEV-147 wave)

## Scope

Fixes one-line install failure on fresh Windows (AV false-positive on in-memory PowerShell execution) and macOS (`bash 3.2` `set -u` crash on an empty `forwarded_args[@]` expansion, and missing `git`/`sh` guidance). Closes [#89](https://github.com/sky2464/AgToosa/issues/89).

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | B32-001 | `bootstrap.sh` guards empty `forwarded_args[@]` for bash 3.2 `set -u` | Contract | `${#forwarded_args[@]}`-style guard present before array expansion | ✅ |
| AC-002 | B32-002 | `bootstrap.sh --ref` succeeds end-to-end with no forwarded args | Integration | Exit 0; fixture archive extracts and runs | ✅ |
| AC-003 | INS-001 | README quick-install snippet uses AV-friendly bootstrap pattern | Contract | No in-memory `IEX`/`-EncodedCommand` PowerShell pattern in README | ✅ |
| AC-004 | INS-002 | `readme-reference.md` documents bootstrap failure modes | Contract | Troubleshooting section present | ✅ |
| AC-005 | INS-003 | Bootstrap help text avoids in-memory PowerShell execution guidance | Contract | Help output steers to file-download install | ✅ |
| AC-006 | INS-004 | `readme-reference.md` documents a managed-device (corporate/EDR) install ladder | Contract | Ladder of fallback install options documented | ✅ |

## Smoke Set

- `@smoke` — none declared at time of shipping; recommend `B32-001` as smoke on next touch of `bootstrap.sh`.

Smoke command: `bats tests/agtoosa.bats -f "DEV-148|B32-|DEV-147 INS-"`

## Note on Test ID Attribution

`INS-001`–`INS-004` are tagged `DEV-147` in `tests/agtoosa.bats` (same Aug 1–2 wave, bundled in PR #92) even though the install-hardening behavior they assert is the DEV-148/#89 fix. This is pre-existing test-ID drift from the batched wave, not corrected here — flagged for awareness rather than re-tagged, to avoid an unrelated bats churn in a documentation-only backfill.

## Spec Quality Analyzer Evidence

- All Must ACs (AC-001–AC-006) map to at least one B32/INS row.
- No live network or AV-product calls in bats; fixture/grep-based only.
