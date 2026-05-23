# AgToosa /agtoosa-ship Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-ship` | Full flow: readiness gate → WIP squash → deploy → archive → changelog → suggest next |
| `/agtoosa-ship check` | Readiness gate only — verify all pre-ship conditions without deploying |
| `/agtoosa-ship docs` | Docs only — archive completed specs, update changelog and Master-Plan |
| `/agtoosa-ship retro` | Sprint retrospective — what shipped vs. planned, quality trends, keep/stop/start |

## Objective
Deploy the completed feature, clean up the workspace, archive completed work, and suggest the next logical development story.

> **Prerequisites:** `/agtoosa-review` must be approved. Verify that `Docs/archived/review-[story-id].md` exists and contains no unresolved 🔴 Critical findings. If any Critical findings remain, resolve them via `/agtoosa-build` and re-run `/agtoosa-review`.

## Workflow

### Part 0 — Ship Readiness Gate (`/agtoosa-ship check` runs this exclusively)

Before any deployment, verify all of the following. If **any** check fails, list the failures, block deployment, and tell the user which command resolves each.

| Check | How to Verify |
|-------|--------------|
| ✅ Goal Contract satisfied | Active spec contains `### Goal Contract`; Success condition and Proof / evidence are satisfied by tests, review report, smoke result, demo, metric, or shipped artifact |
| ✅ Spec was approved | `Docs/archived/spec-*.md` contains a `## ✅ Spec Approved` section with a timestamp |
| ✅ Acceptance criteria exist | `Docs/archived/spec-*.md` contains `## Acceptance Criteria` with at least one Must-priority row |
| ✅ `/agtoosa-review` completed | `Docs/archived/review-*.md` exists and contains no unresolved 🔴 Critical findings |
| ✅ All tests pass | Run full test suite and confirm green |
| ✅ Smoke tests tagged | Test plan or test suite has at least one `@smoke`-tagged test per Must-priority AC |
| ✅ Changelog entry drafted | `Docs/AgToosa_Changelog.md` has an entry for this feature |
| ✅ No `WIP:` commits remain | `git log` shows no commits prefixed with `WIP:` |

Only proceed to Part 1 after all checks pass. Present the approval gate:

```
✅ Ready to deploy — All pre-ship checks passed
Branch: [branch name] · Story: [ID] · Goal: ✅ · Smoke tests: [N] tagged · Changelog: ✅
→ Approve to deploy to [staging/production]  |  Cancel or investigate below
```

Wait for explicit user approval before deploying.

### Part 1 — Pre-Deploy: WIP Commit Squash

Before deploying, clean the branch history:

1.  **WIP Commit Squash:**
    *   Identify all `WIP:` commits on the current branch since branching from main/master: `git log main..HEAD --oneline`
    *   Interactively squash/fixup all `WIP:` commits into clean, atomic, logically grouped commits
    *   Each final commit message must follow Conventional Commits: `[type]([scope]): [description]`
    *   Run the full test suite after squash to confirm nothing broke

### Part 2 — Deployment & Rollbacks

2.  **Deployment (Zero-Downtime):**
    *   Initiate deployment logic targeting the environment (e.g., staging or production).
    *   Monitor post-deployment automated health checks.
    *   Trigger automated rollbacks if error rates or latencies spike to ensure zero-downtime. If automated rollback is unavailable, use `/agtoosa-revert` for manual git-aware rollback.

3.  **Post-Deploy Smoke Tests:**
    *   Run all `@smoke`-tagged tests against the deployed environment.
    *   Verify that every Must-priority AC from the spec is reachable in production.
    *   Verify that the Goal Contract Success condition is satisfied by production behavior or the declared Proof / evidence.
    *   Verify the health endpoint returns 200 (if applicable).
    *   **If smoke tests pass:**
        - Transition the Story issue status to `Done` in Linear.
        - Update `Docs/Master-Plan.md`: move the Story row from `## Active Cycle` to `## Completed This Cycle`.
        - Post a Linear comment on the Story issue:

            ```
            Ship 🚀 Deployed
            Date: [YYYY-MM-DD HH:MM]

            Smoke tests: PASS. All Must-priority ACs verified in production. Spec archived to Docs/archived/.

            Next: Story closed. See /agtoosa-ship retro to close the sprint loop.
            ```

    *   **If any smoke test fails:** halt immediately, do NOT archive specs, trigger `/agtoosa-revert`, and post:

            ```
            Rollback 🔙 Triggered
            Date: [YYYY-MM-DD HH:MM]

            Smoke test failure: [brief description of failing test]. Deployment rolled back. Story reset to In Review.

            Next: /agtoosa-build tdd to fix the failure, then re-run /agtoosa-ship.
            ```

        Transition the Story status back to `In Review` in Linear and update `Docs/Master-Plan.md`.
    *   Capture smoke test pass/fail status in the changelog entry.

### Part 3 — Workspace Cleanup & Archiving (`/agtoosa-ship docs` runs Parts 3 + 4)

3.  **Archive Completed Work:** Spec and review artifacts are already saved to `Docs/archived/` (as `spec-[story-id].md` and `review-[story-id].md`). Verify both files exist there before proceeding.

4.  **Changelog Update:** Update `Docs/AgToosa_Changelog.md` with a summary entry: `[date] - [type] - [short description] - [spec reference]`.

5.  **Master-Plan Pruning:** Update `Docs/Master-Plan.md` — keep only the Epic description with a reference to the archived spec; clear completed tasks; move the story row to `## Completed This Cycle`.

### Part 4 — Suggest Next Story

6.  **Next Steps Suggestion:**
    *   Based on the overarching project goals in `Docs/Master-Plan.md`, suggest the next logical Spec/Story for the team to tackle.
    *   Consider: open bugs, pending features, technical debt, and security improvements.

### Part 5 — Sprint Retrospective (`/agtoosa-ship retro`)

Run this after shipping to close the feedback loop on the sprint.

7.  **Sprint Review:**
    *   Read `Docs/AgToosa_Changelog.md` and compare entries against the original spec acceptance criteria.
    *   List: what was planned, what shipped, what was deferred — and why.
    *   Scan `Docs/archived/` for all specs closed this sprint.

8.  **Quality & Process Health:**
    *   Did test coverage improve or regress vs. prior sprint?
    *   How many 🔴 Critical findings appeared in `/agtoosa-review`? Trend improving?
    *   Note phases that required re-runs (spec → build loopbacks) as friction signals.

9.  **Keep / Stop / Start:**

    Ask the user these three questions sequentially:
    1. What went well this sprint that we should **keep** doing?
    2. What slowed us down that we should **stop** doing?
    3. What should we **start** trying next sprint?

10. **Retro Output:**
    *   Append a retro entry to `Docs/AgToosa_Changelog.md` under a `## Retrospective — [date]` section.
    *   Update `Docs/Master-Plan.md` with process improvement action items from the retro.
    *   If a process change was agreed (e.g., enabling TDD, adjusting the 500-line limit), update `Docs/Context/workflow.md`.

### Part 6 — Compact Master-Plan.md

Run this step when `Docs/Master-Plan.md` exceeds approximately 200 lines **or** after closing an active cycle. Compaction keeps the shared context document within AI context-window limits.

11. **Archive the Completed Cycle:**
    *   Copy the full `## Active Cycle` table to a new snapshot file: `Docs/archived/cycle-[YYYY-MM-DD].md`.
    *   In `Master-Plan.md`, replace the `## Active Cycle` table body with an empty placeholder row and a reference comment:

        ```
        <!-- Archived to Docs/archived/cycle-[YYYY-MM-DD].md -->
        ```

    *   Remove all `Done` rows from `## Active Tasks` — these are already tracked in Linear.
    *   If `Master-Plan.md` still exceeds 200 lines after pruning, collapse `## Backlog` to titles only (drop Estimate and Epic columns) until the next `/agtoosa-init zoom-out` refresh.

## Output
*   Confirm archiving and changelog updates are successful.
*   Present the suggested next Spec to the user.
*   Print the closure line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
*   Ask if they want to run `/agtoosa-spec` for the next story.
