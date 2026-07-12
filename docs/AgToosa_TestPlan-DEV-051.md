# Test Plan: DEV-051 — Tracker Sync Bridge

> **Spec:** `docs/archived/spec-DEV-051.md`
> **Future smoke filter:** `bats tests/agtoosa.bats -f "DEV-051"`
> **Status:** 🟦 Todo (enrolled v5.3.14)
> **Evidence state:** Not executed

## Coverage Target

Prove the narrow v1 contract—deterministic one-way export plus proposal-only import—without using live provider APIs or implying that external trackers can override `docs/Master-Plan.md`.

All Must acceptance criteria are mapped below. Test IDs TS-001–TS-008 are planned names, not existing or passing tests.

| AC | Test ID | Type | Planned assertion | Automation state |
|----|---------|------|-------------------|------------------|
| AC-001, AC-002 | TS-001 | Bats / fixture | Two exports of identical state have the same normalized payload and export ID; required v1 fields are present. | planned @smoke |
| AC-001 | TS-002 | Bats / fixture | Export normalizes multiple Master-Plan stories and referenced ACs in stable story-ID order. | planned @smoke |
| AC-003 | TS-003 | Bats / mutation guard | A valid return envelope produces a proposal artifact and leaves Master-Plan, specs, and task checkboxes byte-for-byte unchanged. | planned @smoke |
| AC-004, AC-005 | TS-004 | Bats / negative | Unknown story, unsupported field, missing base ID, stale digest, and repo/tracker conflict are rejected or marked stale; repo value wins. | planned @smoke |
| AC-006 | TS-005 | Docs / contract | Canonical workflow maps GitHub Issues, Linear, Jira, and TaskMaster fields and states that transport/API writes are outside v1. | planned |
| AC-007 | TS-006 | Bats / security | Token-bearing URL, absolute path, control characters, oversized input, and unknown sensitive key are redacted or rejected without secret echo. | planned @smoke |
| AC-008, AC-009 | TS-007 | Integration | Config inventory and every thin platform adapter route to the canonical Tracker Sync doc; enforcement classifications are present. | planned |
| AC-010, AC-011 | TS-008 | Bats / evidence | Focused section is RED before implementation, GREEN afterward, and recorded evidence makes no live-sync or tracker-authority claim. | planned @smoke |

## Fixture Matrix

| Fixture | Purpose | Expected result |
|---------|---------|-----------------|
| `tests/fixtures/tracker-sync/project/` | Stable Master-Plan with two referenced specs | Deterministic v1 export |
| `returns/valid.json` | One recognized status proposal against current base | Proposal row; no source mutation |
| `returns/stale.json` | Old export ID and digest | `stale`; fresh export required |
| `returns/unknown-story.json` | Story ID absent from current Master-Plan | `rejected` |
| `returns/unsupported-field.json` | Provider-only custom field | `unsupported`; original preserved in escaped diagnostic |
| `returns/secret-bearing.json` | Credential URL and absolute workstation path | Redacted or rejected; no secret in output |
| `returns/oversized.json` | Input beyond documented size/record bounds | Bounded failure before full parse |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected |
|----------|---------|----------|
| `generated_at` changes between exports | TS-001 | Export ID remains stable because volatile metadata is excluded from its digest. |
| Stories appear in a different Markdown order | TS-002 | Normalized records remain sorted by story ID. |
| Proposal output path aliases `docs/Master-Plan.md` | TS-003 | Command refuses before writing. |
| Return proposes deleting a story | TS-004 | Unsupported in v1; repo story remains unchanged. |
| Provider status has no AgToosa equivalent | TS-004, TS-005 | Item is `unsupported`; mapping guidance names the gap. |
| Secret appears in an unknown nested key | TS-006 | Unknown structure is rejected without value echo. |
| One platform adapter embeds alternate conflict rules | TS-007 | Contract test fails; adapter must delegate to canonical doc. |
| Provider API is unavailable | TS-005 | Core export/proposal commands are unaffected because they perform no network calls. |

## Future Validation Commands

These commands are the intended build-time checks. They have **not** been run for this backlog spec.

```bash
bats tests/agtoosa.bats -f "DEV-051|TS-"
bash agtoosa.sh --tracker export --path tests/fixtures/tracker-sync/project --output "$TMPDIR/dev-051-export.json"
bash agtoosa.sh --tracker propose --path tests/fixtures/tracker-sync/project --input tests/fixtures/tracker-sync/returns/valid.json --output "$TMPDIR/dev-051-proposal.md"
bats tests/agtoosa.bats
git diff --check
```

PowerShell parity command to exercise after implementation:

```powershell
.\agtoosa.ps1 -Tracker export -Path tests\fixtures\tracker-sync\project -Output $env:TEMP\dev-051-export.json
```

## Evidence

The blocks below are placeholders required for future TDD capture. `Not executed` is not proof of behavior.

### RED evidence — Task 1

| Field | Placeholder |
|-------|-------------|
| Command | `bats tests/agtoosa.bats -f "DEV-051|TS-"` |
| Exit code | Not executed |
| Failure excerpt | Not captured |
| Source hashes before/after | Not captured |
| Recorded | Not recorded |

### GREEN evidence — Tasks 2 and 3

| Field | Placeholder |
|-------|-------------|
| Command | `bats tests/agtoosa.bats -f "DEV-051|TS-"` |
| Exit code | Not executed |
| Pass/fail | Not captured |
| Source mutation guard | Not captured |
| Warnings/errors | Not captured |
| Recorded | Not recorded |

### Regression and claim review — Task 4

| Field | Placeholder |
|-------|-------------|
| Full regression command | `bats tests/agtoosa.bats` |
| Exit code | Not executed |
| `git diff --check` | Not executed |
| Live-provider API calls | Must remain `none` for v1 |
| Claim-boundary reviewer | Not assigned |
| Evidence ledger pointer | Not created |
