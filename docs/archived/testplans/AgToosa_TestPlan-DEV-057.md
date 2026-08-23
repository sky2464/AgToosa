# Test Plan: DEV-057 — Multi-Repo Story Overlay

> **Spec:** `docs/archived/spec-DEV-057.md`
> **Future smoke filter:** `bats tests/agtoosa.bats -f "DEV-057"`
> **Status:** ⬜ Backlog
> **Demand Gate:** Unmet
> **Prerequisite gate:** DEV-045 must ship before DEV-057 enrollment
> **Evidence state:** Not executed

## Coverage Target

After a real Demand Evidence Record is accepted, prove that the overlay coordinates explicit member repos without mutating them, replacing repo-local authority, skipping per-repo handoff/import, or claiming distributed transaction guarantees.

All Must acceptance criteria are mapped below. Test IDs MR-001–MR-010 are planned names, not existing or passing tests. Fixtures can test gate behavior but cannot satisfy the real-world Demand Gate.

| AC | Test ID | Type | Planned assertion | Automation state |
|----|---------|------|-------------------|------------------|
| AC-001 | MR-001 | Bats / governance | Missing or incomplete Demand Evidence Record keeps DEV-057 Backlog, lists missing fields, and prevents implementation path entry. | planned @smoke |
| AC-002 | MR-002 | Bats / schema | Manifest requires primary/member identity, ownership, allowlist, dependencies, artifact pointers, digests, and observation timestamps; duplicate/unknown records fail. | planned @smoke |
| AC-003, AC-004 | MR-003 | Bats / mutation guard | Member repo values win conflicts; validate/plan/status read only rostered allowlisted metadata and leave every member byte-for-byte unchanged. | planned @smoke |
| AC-005 | MR-004 | Integration | Each accepted handoff pointer resolves to a pack created in the member repo from its local approved spec; copied primary content is rejected. | planned @smoke |
| AC-006 | MR-005 | Integration | A member becomes `verified` only after member-local import and verification evidence; PR/branch/agent claims alone remain unverified. | planned @smoke |
| AC-007 | MR-006 | Bats / evidence | Aggregate index contains one complete pointer row per member with immutable ref/digest and never copies or replaces the member ledger. | planned @smoke |
| AC-008 | MR-007 | Bats / dependency | Unknown and cyclic dependencies fail validation; valid dependencies render an observed manual order without execution or DEV-045 scheduling claims. | planned |
| AC-009 | MR-008 | Bats / recovery | Missing, stale, blocked, and failed members keep aggregate readiness incomplete while preserving valid member evidence and producing deterministic reconcile steps. | planned @smoke |
| AC-010 | MR-009 | Bats / security | Traversal, symlink escape, credential URL, unauthorized repo, command text, controls, oversized manifest, and secret echo are rejected before member reads. | planned @smoke |
| AC-011, AC-012, AC-013 | MR-010 | Integration / evidence | Canonical docs/schema/config/adapters preserve per-repo flow; RED/GREEN and aggregate evidence are recorded without global-authority, execution, scheduler, or atomicity claims. | planned |

## Demand Gate Record

Populate this table with real delivery evidence before changing status or running build tasks. Test fixtures and hypothetical examples do not satisfy it.

| Required field | Current value | Evidence pointer | Gate result |
|----------------|---------------|------------------|-------------|
| Real delivery story and target | Not supplied | Not recorded | unmet |
| At least two independently governed repos and owners | Not supplied | Not recorded | unmet |
| Existing per-repo handoff/import attempt | Not supplied | Not recorded | unmet |
| Demonstrated insufficiency | Not supplied | Not recorded | unmet |
| Overlay benefit | Not supplied | Not recorded | unmet |
| Allowed/private data boundary | Not supplied | Not recorded | unmet |
| Human sponsor acceptance | Not supplied | Not recorded | unmet |

Overall: **unmet — DEV-057 stays ⬜ Backlog.**

## Fixture Matrix

| Fixture | Purpose | Expected result |
|---------|---------|-----------------|
| `tests/fixtures/multi-repo/coordinator/` | Primary repo with explicit manifest | Bounded validate/plan/status/index target |
| `member-api/`, `member-web/`, `member-infra/` | Independently governed fake repos | Per-member authority and evidence checks |
| `manifest-current.json` | Valid roster and current digests | Valid observed plan/status |
| `manifest-stale.json` | One member source digest changed | Member `stale`; aggregate incomplete |
| `manifest-cycle.json` | Cyclic `depends_on` graph | Validation failure; no plan |
| `manifest-missing.json` | Rostered member unavailable | Partial result plus reconcile step |
| `manifest-traversal.json` | Root escapes fixture boundary | Rejected before member read |
| `manifest-symlink.json` | Member root symlinks outside allowed fixture | Rejected before member read |
| `manifest-secret.json` | Credential-bearing remote reference | Rejected/redacted without secret echo |
| `member-import-missing/` | PR pointer but no local import evidence | Member remains unverified |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected |
|----------|---------|----------|
| User asks to enroll with no real attempted handoff/import flow | MR-001 | Story remains Backlog; missing gate fields printed. |
| Primary says `Done`; member Master-Plan says `In Progress` | MR-003 | Member value wins; overlay observation is conflicted/stale. |
| Status command runs against valid members | MR-003 | Hashes and git status of member fixtures are unchanged. |
| Handoff pack was assembled in primary repo from copied child spec | MR-004 | Pointer rejected; member-local handoff required. |
| Member PR merged but import evidence absent | MR-005 | Member is not verified. |
| Aggregate row points only to a mutable branch | MR-006 | Row incomplete until commit/digest is recorded. |
| Dependency references an unknown member | MR-007 | Validation failure; no inferred repository. |
| Two members pass and one is blocked | MR-008 | Passed evidence preserved; aggregate remains incomplete. |
| Roster path follows symlink outside authorized root | MR-009 | Reject before metadata read; no escaped path contents in output. |
| Docs say “atomic multi-repo ship” | MR-010 | Contract test fails; wording must state partial-failure semantics. |

## Future Validation Commands

These commands are intended only after the Demand Gate is accepted and implementation exists. They have **not** been run for this backlog spec.

```bash
bats tests/agtoosa.bats -f "DEV-057|MR-"
bash agtoosa.sh --overlay validate --path tests/fixtures/multi-repo/coordinator
bash agtoosa.sh --overlay plan --path tests/fixtures/multi-repo/coordinator
bash agtoosa.sh --overlay status --path tests/fixtures/multi-repo/coordinator
bash agtoosa.sh --overlay index --path tests/fixtures/multi-repo/coordinator --output "$TMPDIR/dev-057-evidence.md"
bats tests/agtoosa.bats
git diff --check
```

PowerShell parity command to exercise after implementation:

```powershell
.\agtoosa.ps1 -Overlay validate -Path tests\fixtures\multi-repo\coordinator
```

## Evidence

The blocks below are placeholders required for future TDD and per-repo capture. `Not executed` and the fixture plan are not evidence that the capability exists.

### Demand evidence — Task 0

| Field | Placeholder |
|-------|-------------|
| Accepted record | Not supplied |
| Sponsor | Not assigned |
| Acceptance timestamp | Not recorded |
| Evidence pointer | Not created |

### RED evidence — Task 1

| Field | Placeholder |
|-------|-------------|
| Command | `bats tests/agtoosa.bats -f "DEV-057|MR-"` |
| Exit code | Not executed |
| Failure excerpt | Not captured |
| Member hashes before/after | Not captured |
| Recorded | Not recorded |

### GREEN evidence — Tasks 2 and 3

| Field | Placeholder |
|-------|-------------|
| Command | `bats tests/agtoosa.bats -f "DEV-057|MR-"` |
| Exit code | Not executed |
| Pass/fail | Not captured |
| Cross-repo mutation guard | Not captured |
| Security fixture result | Not captured |
| Partial-failure result | Not captured |
| Recorded | Not recorded |

### Per-repo handoff/import evidence — Task 4

| Repo ID | Story ID | Handoff pointer + digest | Import pointer | Local verification + exit | Evidence ledger + digest | State |
|---------|----------|--------------------------|----------------|---------------------------|--------------------------|-------|
| Not selected | Not selected | Not recorded | Not recorded | Not executed | Not recorded | unavailable |
| Not selected | Not selected | Not recorded | Not recorded | Not executed | Not recorded | unavailable |

### Aggregate regression and claim review — Task 4

| Field | Placeholder |
|-------|-------------|
| Aggregate index pointer | Not created |
| Full regression command | `bats tests/agtoosa.bats` |
| Exit code | Not executed |
| `git diff --check` | Not executed |
| Member working-tree hashes unchanged | Not captured |
| Distributed transaction claim | Must remain `none` |
| Claim-boundary reviewer | Not assigned |
