/agtoosa-build

Verified: `docs/archived/spec-cleanup-001.md` has `## ✅ Spec Approved`. Proceeding.

---

## Part 1 — Scope Boundary

```
✅ Ready to proceed — Scope Boundary (S1-05)

Files in scope:
  TASKS.md                    (root)       → archive
  GEMINI.md                   (root)       → update
  docs/plan.md                             → archive
  docs/firebase.md                         → delete
  docs/Master-Plan.md                      → update (status + log)
  docs/archived/              (destination for archives)

Out of scope (must NOT be touched):
  lib/          test/          — all source code
  docs/backend-research.md    — active sprint reference
  docs/test-coverage-dependency-maintenance.md
  docs/CHECKLIST-dependency-maintenance.md
  docs/OPERATIONS-dependency-maintenance.md
  All AgToosa_*.md workflow files

→ Approve scope  |  Correct anything below
```

---

## Task Breakdown & Test Plan

**5 atomic tasks — Tasks 1–4 can run in parallel (no shared state):**

| ID | Task | Type |
|----|------|------|
| T-CLEANUP-01 | Move `TASKS.md` → `docs/archived/tasks-sprint-1-pre-masterplan.md` | File op |
| T-CLEANUP-02 | Move `docs/plan.md` → `docs/archived/plan-pre-launch-v1.5.0.md` | File op |
| T-CLEANUP-03 | Delete `docs/firebase.md` | File op |
| T-CLEANUP-04 | Rewrite `GEMINI.md` with AgToosa command table, correct paths, no emoji | Update |
| T-CLEANUP-05 | Update `docs/Master-Plan.md` — set S1-05 In Progress, append Update Log | Tracking |

**Test plan (no TDD cycle — docs chore; verification replaces Red-Green-Refactor):**

| Test ID | AC | Verification | Category |
|---------|----|-------------|----------|
| V-001 `@smoke` | AC-001 | `TASKS.md` absent from root; exists in `docs/archived/` | File check |
| V-002 `@smoke` | AC-002 | `docs/plan.md` absent from `docs/`; exists in `docs/archived/` | File check |
| V-003 `@smoke` | AC-003 | `docs/firebase.md` does not exist | File check |
| V-004 `@smoke` | AC-004 | `GEMINI.md` contains AgToosa command table, no emoji headers | Content check |
| V-005 `@smoke` | AC-005 | `docs/Master-Plan.md` S1-05 row = In Progress; Update Log has new entry | Content check |
| V-006 `@smoke` | AC-006 | `dart analyze` exits 0; `flutter test` exits 0 | CI gate |

```
✅ Ready to build — Task Breakdown & Test Plan
5 tasks. 6 verification checks mapped to 6 ACs. All Must-priority.
Tasks 1–4 dispatched in parallel; Task 5 runs after.
→ Approve to start build  |  Remove, add, or reorder tasks below
```