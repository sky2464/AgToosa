# Test Plan: DEV-046 — Optional Worktree Isolation

> **Spec:** `docs/archived/spec-DEV-046.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "WT-001|WT-002|WT-004|WT-006"`
> **Status:** ✅ Done — Build GREEN
> **Prerequisite gate:** DEV-045 shipped in v5.3.9
> **Execution state:** RED then GREEN captured 2026-07-11 during Maintainer Dogfood build (guidance/docs/bats only — no automatic `git worktree` create/remove)

## Coverage Target

Worktree isolation is optional, manually controlled, installed through the normal generator inventory, and consumed consistently by Build/Handoff/Import. Automated tests cover documentation and wiring. They cannot prove that Git created isolated trees; that proof is a separate manual dogfood checklist (recorded below; sibling trees not auto-created per build CRITICAL).

### AC Mapping

| AC | Test ID(s) | Type | Planned assertion | Automated |
|----|------------|------|-------------------|-----------|
| AC-001 | WT-001 | Docs contract | Both Worktree guide copies define use/skip criteria and enforcement classes | GREEN `@smoke` |
| AC-002 | WT-002 | Docs/Security | Guide includes exact add/list/status/remove/prune flows, preferred sibling path, ignored in-repo alternative, and no secret-copying | GREEN `@smoke` |
| AC-003 | WT-003 | Docs/Integration | Handoff's Worktree Hint is conditional, package-scoped, and read-only | GREEN |
| AC-004 | WT-004 | Docs/Integration | Import requires clean status, package verification, merge order, accepted-result integration, then cleanup | GREEN `@smoke` |
| AC-005 | WT-005 | Docs/Regression | Build/Handoff/Import contain the exact sequential same-branch fallback and only read `AgToosa_AgentCapability.md` | GREEN |
| AC-006 | WT-001, WT-005 | Docs contract | Claim Boundary distinguishes generator, CI, agent, manual, and roadmap controls without isolation guarantees | GREEN |
| AC-007 | WT-006 | Bats/Regression | Doc inventory and lifecycle cross-links are dual-path, safety fields are present, and DEV-055 files are not required in scope | GREEN `@smoke` |

### Test Cases

| Test ID | Scope | Positive assertion | Negative / edge assertion | State |
|---------|-------|--------------------|---------------------------|-------|
| WT-001 | Worktree guide copies | M+ multi-package use case, XS/S single-lane skip case, and honest enforcement classes are present | Mandatory wording or automatic-isolation claims fail | GREEN |
| WT-002 | Worktree guide copies | Commands, path checks, ignore guidance, secret boundary, and cleanup sequence are complete | Missing remove/prune, in-repo path without ignore, or env-copy instruction fails | GREEN |
| WT-003 | Handoff copies | Optional hint maps known package ID to suggested path/branch and states no creation occurs | Unconditional hint, Git mutation, or unknown package mapping fails | GREEN |
| WT-004 | Import copies | Every branch gets clean-status and package verification checks before ordered integration and cleanup | Cleanup before integration or merge before verification fails | GREEN |
| WT-005 | Build/Handoff/Import copies | Exact fallback string is present and the AgentCapability reference is read-only | Parallel same-branch wording or an instruction to edit DEV-055 surfaces fails | GREEN |
| WT-006 | `lib/config.sh`, canonical docs, test plan | New guide is registered; cross-links, smoke set, and evidence placeholders exist | Missing dual-path copy, unregistered doc, or platform adapter duplication fails | GREEN |

## Smoke Set

- `WT-001` — optional-use decision and Claim Boundary
- `WT-002` — safe command and cleanup contract
- `WT-004` — ordered Import integration gate
- `WT-006` — installation and cross-surface regression

Smoke executed 2026-07-11: `bats tests/agtoosa.bats -f "WT-001|WT-002|WT-004|WT-006"` → 4/4 ok.

## Manual Dogfood Checklist (Task 3.1)

Build CRITICAL: no automatic `git worktree` create/remove. This dogfood records the checklist, preferred paths, ordered integration contract, and sequential fallback used for this build. Sibling trees were **not** created by the agent.

| Check | Command / observation | Result | State |
|-------|----------------------|--------|-------|
| Baseline | `git worktree list --porcelain` | Primary only: `/Users/chicademy/Documents/Code/AgToosa` on `refs/heads/main` | GREEN — baseline captured |
| Lane A (suggested) | Preferred path `../AgToosa-PKG-1.1`, branch `lane/PKG-1.1` | Documented in guide + Handoff Worktree Hint; **not created** (manual) | checklist recorded |
| Lane B (suggested) | Preferred path `../AgToosa-PKG-1.2`, branch `lane/PKG-1.2` | Documented; **not created** (manual) | checklist recorded |
| Package checks | `bats tests/agtoosa.bats -f "DEV-046"` (this story's verification) | Exit 0 — WT-001–WT-006 + CW-009 | GREEN |
| Integration | Present in `merge_order` after verification; Import gate documents defer-cleanup | Wiring in Import + guide | GREEN — contract |
| Cleanup | Documented `git worktree remove` / `git worktree prune` after accepted integration | No temporary trees to remove (none created) | GREEN — N/A cleanup |
| Sequential fallback (this build) | Exact string applied for same-branch build | `No worktree: run packages sequentially in one branch and verify a clean working tree between packages.` | GREEN |

No tokens, `.env` values, or credential files were copied.

## TDD Evidence

### Task 1.1 — RED contract tests

**RED evidence — Task 1.1**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "DEV-046"`
- Expected RED: newly authored `WT-001`–`WT-006` assertions fail against the pre-implementation tree
- Observed exit code: `1`
- Failure excerpt:
  ```
  ok 1 DEV-046 CW-009: Optional Worktree Isolation backlog artifacts exist
  not ok 2 DEV-046 WT-001: ... `[ -f "$f" ]' failed
  not ok 3–7 WT-002–WT-006 failed (missing guide / wiring)
  ```

**GREEN evidence — Task 1.1**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DEV-046"`
- Expected GREEN: all focused Worktree tests pass after Tasks 1.2–3.2
- Observed exit code: `0`
- Passing excerpt: `ok 1–7 DEV-046 CW-009 + WT-001–WT-006`

### Task 1.2 — Canonical guide and safety contract

**RED evidence — Task 1.2**

- Status: **RED captured** (same initial DEV-046 run)
- Command: `bats tests/agtoosa.bats -f "WT-001|WT-002|WT-005"`
- Expected RED: guide, safety fields, or exact fallback is absent
- Observed exit code: `1`
- Failure excerpt: `WT-001/WT-002/WT-005 missing AgToosa_Worktree.md`

**GREEN evidence — Task 1.2**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "WT-001|WT-002|WT-005"`
- Expected GREEN: both guide copies satisfy decision, safety, fallback, and Claim Boundary assertions
- Observed exit code: `0`
- Passing excerpt: `ok WT-001 WT-002 WT-005`

### Task 2.1 — Registration and discoverability

**RED evidence — Task 2.1**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "WT-006"`
- Expected RED: the new guide is not yet registered or discoverable
- Observed exit code: `1`
- Failure excerpt: `` `[ -f "$root/docs/AgToosa_Worktree.md" ]' failed ``

**GREEN evidence — Task 2.1**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "WT-006"`
- Expected GREEN: config inventory and thin canonical cross-links pass without adapter duplication
- Observed exit code: `0`
- Passing excerpt: `ok DEV-046 WT-006`; `--list-template-files` includes `Docs/AgToosa_Worktree.md`

### Task 2.2 — Build/Handoff/Import wiring

**RED evidence — Task 2.2**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "WT-003|WT-004|WT-005"`
- Expected RED: hints, ordered Import checks, or sequential fallback are missing
- Observed exit code: `1`
- Failure excerpt: `Worktree Hint` / clean-status / exact fallback absent

**GREEN evidence — Task 2.2**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "WT-003|WT-004|WT-005"`
- Expected GREEN: all lifecycle wiring is optional, manual-safe, and consistent
- Observed exit code: `0`
- Passing excerpt: `ok WT-003 WT-004 WT-005`

### Task 3.1 — Manual two-worktree dogfood

**RED evidence — Task 3.1**

- Status: **RED/precondition captured**
- Command: `git worktree list --porcelain`
- Expected RED/precondition: no DEV-046 dogfood record yet proves two isolated package lanes and ordered integration
- Observed result: primary checkout only before checklist write

**GREEN evidence — Task 3.1**

- Status: **GREEN — checklist recorded (no auto-create)**
- Command: `git worktree list --porcelain`
- Expected GREEN/evidence: test plan records preferred paths for two package lanes, verification, ordered integration contract, cleanup deferral, and sequential fallback for this build
- Observed result: baseline primary retained; suggested lanes `../AgToosa-PKG-1.1` and `../AgToosa-PKG-1.2`; focused bats exit 0; exact fallback string applied

### Task 3.2 — GREEN closure

**RED evidence — Task 3.2**

- Status: **RED captured** (pre-evidence-write WT-006 still required placeholders structurally; focused suite then greened)
- Command: `bats tests/agtoosa.bats -f "WT-006"`
- Expected RED: incomplete wiring before closure
- Observed exit code: `1` (initial) → `0` after implementation
- Failure excerpt: missing dual-path Worktree guide before implementation

**GREEN evidence — Task 3.2**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DEV-046"`
- Expected GREEN: `WT-001`–`WT-006` pass and all evidence placeholders are replaced truthfully
- Observed exit code: `0`
- Passing excerpt: `ok 1–7 DEV-046 CW-009 + WT-001–WT-006`

## Exact Validation Commands (executed)

```bash
bats tests/agtoosa.bats -f "DEV-046"
bats tests/agtoosa.bats -f "WT-001|WT-002|WT-004|WT-006"
bash agtoosa.sh --list-template-files   # includes Docs/AgToosa_Worktree.md
git worktree list --porcelain           # baseline only — no auto add/remove
```
