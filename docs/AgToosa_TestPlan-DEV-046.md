# Test Plan: DEV-046 — Optional Worktree Isolation

> **Spec:** `docs/archived/spec-DEV-046.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "WT-001|WT-002|WT-004|WT-006"`
> **Status:** ⬜ Backlog
> **Prerequisite gate:** DEV-045 must ship before DEV-046 enrollment
> **Execution state:** Planned only — no DEV-046 validation or worktree dogfood command has been executed

## Coverage Target

The future build must prove that worktree isolation is optional, manually controlled, installed through the normal generator inventory, and consumed consistently by Build/Handoff/Import. Automated tests cover documentation and wiring. They cannot prove that Git created isolated trees; that proof is a separate manual dogfood record.

### AC Mapping

| AC | Test ID(s) | Type | Planned assertion | Automated |
|----|------------|------|-------------------|-----------|
| AC-001 | WT-001 | Docs contract | Both Worktree guide copies define use/skip criteria and enforcement classes | planned `@smoke` |
| AC-002 | WT-002 | Docs/Security | Guide includes exact add/list/status/remove/prune flows, preferred sibling path, ignored in-repo alternative, and no secret-copying | planned `@smoke` |
| AC-003 | WT-003 | Docs/Integration | Handoff's Worktree Hint is conditional, package-scoped, and read-only | planned |
| AC-004 | WT-004 | Docs/Integration | Import requires clean status, package verification, merge order, accepted-result integration, then cleanup | planned `@smoke` |
| AC-005 | WT-005 | Docs/Regression | Build/Handoff/Import contain the exact sequential same-branch fallback and only read `AgToosa_AgentCapability.md` | planned |
| AC-006 | WT-001, WT-005 | Docs contract | Claim Boundary distinguishes generator, CI, agent, manual, and roadmap controls without isolation guarantees | planned |
| AC-007 | WT-006 | Bats/Regression | Doc inventory and lifecycle cross-links are dual-path, safety fields are present, and DEV-055 files are not required in scope | planned `@smoke` |

### Planned Test Cases

| Test ID | Scope | Positive assertion | Negative / edge assertion | State |
|---------|-------|--------------------|---------------------------|-------|
| WT-001 | Worktree guide copies | M+ multi-package use case, XS/S single-lane skip case, and honest enforcement classes are present | Mandatory wording or automatic-isolation claims fail | planned — not authored or run |
| WT-002 | Worktree guide copies | Commands, path checks, ignore guidance, secret boundary, and cleanup sequence are complete | Missing remove/prune, in-repo path without ignore, or env-copy instruction fails | planned — not authored or run |
| WT-003 | Handoff copies | Optional hint maps known package ID to suggested path/branch and states no creation occurs | Unconditional hint, Git mutation, or unknown package mapping fails | planned — not authored or run |
| WT-004 | Import copies | Every branch gets clean-status and package verification checks before ordered integration and cleanup | Cleanup before integration or merge before verification fails | planned — not authored or run |
| WT-005 | Build/Handoff/Import copies | Exact fallback string is present and the AgentCapability reference is read-only | Parallel same-branch wording or an instruction to edit DEV-055 surfaces fails | planned — not authored or run |
| WT-006 | `lib/config.sh`, canonical docs, test plan | New guide is registered; cross-links, smoke set, and evidence placeholders exist | Missing dual-path copy, unregistered doc, or platform adapter duplication fails | planned — not authored or run |

## Smoke Set

- `WT-001` — optional-use decision and Claim Boundary
- `WT-002` — safe command and cleanup contract
- `WT-004` — ordered Import integration gate
- `WT-006` — installation and cross-surface regression

Smoke is a future focused subset, not current execution evidence.

## Planned Manual Dogfood Record

| Check | Planned command / observation | Required future result | Current state |
|-------|-------------------------------|------------------------|---------------|
| Baseline | `git worktree list --porcelain` | Primary checkout identified before creation | not executed |
| Lane A | `git -C "../AgToosa-PKG-1.1" status --short --branch` | Expected branch; clean before package work | not executed |
| Lane B | `git -C "../AgToosa-PKG-1.2" status --short --branch` | Different expected branch; clean before package work | not executed |
| Package checks | Run each DEV-045 package's exact `verification` command in its assigned tree | Both commands exit 0 and outputs are recorded | not executed |
| Integration | Record branches integrated in DEV-045 `merge_order` | Dependent package is not integrated early | not executed |
| Cleanup | `git worktree list --porcelain` after documented remove/prune steps | Temporary worktrees absent; primary checkout retained | not executed |

The future manual record must include the actual worktree paths and branches. It must not include tokens, environment values, or copied credential files.

## TDD Evidence Placeholders

Every block below is deliberately unexecuted. Replace bracketed fields only with observed future output after DEV-045 has shipped and DEV-046 has been enrolled and approved.

### Task 1.1 — RED contract tests

**RED evidence — Task 1.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-046"`
- Expected RED: newly authored `WT-001`–`WT-006` assertions fail against the pre-implementation tree
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 1.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-046"`
- Expected GREEN: all focused Worktree tests pass after Tasks 1.2–3.2
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 1.2 — Canonical guide and safety contract

**RED evidence — Task 1.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "WT-001|WT-002|WT-005"`
- Expected RED: guide, safety fields, or exact fallback is absent
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 1.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "WT-001|WT-002|WT-005"`
- Expected GREEN: both guide copies satisfy decision, safety, fallback, and Claim Boundary assertions
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 2.1 — Registration and discoverability

**RED evidence — Task 2.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "WT-006"`
- Expected RED: the new guide is not yet registered or discoverable
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 2.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "WT-006"`
- Expected GREEN: config inventory and thin canonical cross-links pass without adapter duplication
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 2.2 — Build/Handoff/Import wiring

**RED evidence — Task 2.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "WT-003|WT-004|WT-005"`
- Expected RED: hints, ordered Import checks, or sequential fallback are missing
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 2.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "WT-003|WT-004|WT-005"`
- Expected GREEN: all lifecycle wiring is optional, manual-safe, and consistent
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 3.1 — Manual two-worktree dogfood

**RED evidence — Task 3.1**

- Status: **PLANNED MANUAL PRECONDITION — NOT EXECUTED**
- Command: `git worktree list --porcelain`
- Expected RED/precondition: no DEV-046 dogfood record yet proves two isolated package lanes and ordered integration
- Observed result: `[not captured]`

**GREEN evidence — Task 3.1**

- Status: **PLANNED MANUAL EVIDENCE — NOT EXECUTED**
- Command: `git worktree list --porcelain`
- Expected GREEN/evidence: the test plan records two distinct package worktrees, per-package verification, ordered integration, and completed cleanup
- Observed result: `[not captured]`

### Task 3.2 — GREEN closure

**RED evidence — Task 3.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "WT-006"`
- Expected RED: closure fails while manual evidence or cross-surface wiring remains incomplete
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 3.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-046"`
- Expected GREEN: `WT-001`–`WT-006` pass and all evidence placeholders are replaced truthfully
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

## Exact Future Validation Commands

Do not run these while DEV-046 is Backlog or before DEV-045 ships. Run them after DEV-046 is enrolled, approved, implemented, and the manual dogfood record is complete.

```bash
bats tests/agtoosa.bats -f "DEV-046"
bats tests/agtoosa.bats -f "WT-"
bats tests/agtoosa.bats -f "WT-001|WT-002|WT-004|WT-006"
bash agtoosa.sh --list-template-files
bash agtoosa.sh --verify .
bash docs/agtoosa-verify.sh --strict
bats tests/agtoosa.bats
git diff --check
```
