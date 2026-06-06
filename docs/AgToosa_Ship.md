# AgToosa /agtoosa-ship Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-ship` | Full flow: readiness gate → WIP squash → deploy → archive → changelog → suggest next |
| `/agtoosa-ship check` | Part 0 only — **read-only** readiness audit; reports pass/fail and stops (no deploy, archive, or changelog mutation) |
| `/agtoosa-ship docs` | Docs only — archive completed specs, update changelog and Master-Plan |
| `/agtoosa-ship retro` | Sprint retrospective — what shipped vs. planned, quality trends, keep/stop/start |

## Objective
Deploy the completed feature, clean up the workspace, archive completed work, and suggest the next logical development story.

> **Prerequisites:** `/agtoosa-review` must be approved. Verify that `docs/archived/review-[story-id].md` exists and contains no unresolved 🔴 Critical findings. If any Critical findings remain, resolve them via `/agtoosa-build` and re-run `/agtoosa-review`.

## Workflow

### Part 0 — Ship Readiness Gate (`/agtoosa-ship check` runs this exclusively)

> **`/agtoosa-ship check` contract (read-only):** Execute **Part 0 only**. Read `docs/Master-Plan.md`, archived spec/review, changelog, and git history as needed. **Do not** deploy, squash WIP commits, archive specs, bump versions, or mutate any file. **Do not** present the full-flow deployment approval gate. Stop after printing the readiness output below.

> **`/agtoosa-ship` full flow:** Run Part 0 first. Only after all checks pass, present the **Deploy approval gate** and wait for explicit user approval before Part 1.

Before any deployment, verify all of the following. If **any** check fails, list each failure on its own line with a **Fix with:** command or **Manual action:** when no AgToosa command applies.

| Check | How to Verify | Fix with (on failure) |
|-------|--------------|----------------------|
| ✅ Goal Contract satisfied | Active spec contains `### Goal Contract` (or `### 1.1 Goal Contract`); Success condition and Proof / evidence are satisfied by tests, review report, smoke result, demo, metric, or shipped artifact | `/agtoosa-build` or `/agtoosa-spec` |
| ✅ Spec was approved | `docs/archived/spec-*.md` contains a `## ✅ Spec Approved` section with a timestamp | `/agtoosa-spec` |
| ✅ Acceptance criteria exist | `docs/archived/spec-*.md` contains acceptance criteria with at least one Must-priority row | `/agtoosa-spec` |
| ✅ `/agtoosa-review` completed | `docs/archived/review-*.md` exists and contains no unresolved 🔴 Critical findings | `/agtoosa-review` |
| ✅ All tests pass | Run full test suite and confirm green | `/agtoosa-build test` |
| ✅ Smoke tests tagged | Test plan or test suite has at least one `@smoke`-tagged test per Must-priority AC | `/agtoosa-spec` or `/agtoosa-build` |
| ✅ Changelog entry drafted | `docs/AgToosa_Changelog.md` has an entry for this feature | `/agtoosa-ship docs` or manual changelog edit |
| ✅ No `WIP:` commits remain | `git log` shows no commits whose **subject line** starts with `WIP:` | `/agtoosa-ship` (Part 1 squash) or manual squash |

**Evidence rules:** Report pass/fail summaries, command names, artifact paths, and test counts. When citing deploy or test logs, **redact** secrets, tokens, API keys, and private URLs before including evidence in chat or review artifacts.

#### Readiness failure output (both `check` and full flow)

For each failed row, print:

```
🔴 [Check name] — [brief reason]
   Fix with: `/agtoosa-[command]` — [one-line action]
```

or, when no command applies:

```
🔴 [Check name] — [brief reason]
   Manual action: [what the human must do]
```

Stop after listing all failures. Do not proceed to deployment or file mutation.

#### `/agtoosa-ship check` — success output (read-only stop)

When all checks pass and the user invoked **`check`** only:

```
✅ Readiness audit passed — story [ID] is ready for a full ship (read-only check complete)
Branch: [branch] · Story: [ID] · Goal: ✅ · Smoke tests: [N] tagged · Changelog: ✅

This command does not deploy or mutate project state.
Next: Run full `/agtoosa-ship` when you want deployment approval and release steps.
```

**Stop here.** Do not show the deploy approval gate.

#### Full `/agtoosa-ship` — Part 0 success → Deploy approval gate

When all checks pass and the user invoked the **full** ship flow (no `check` sub-command), present:

```
✅ Ready to deploy — All pre-ship checks passed (Part 0 complete)
Branch: [branch name] · Story: [ID] · Goal: ✅ · Smoke tests: [N] tagged · Changelog: ✅
→ Approve to deploy to [staging/production]  |  Cancel or investigate below
```

Wait for explicit user approval before Part 1 (WIP squash, deploy, archive).

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
    *   Verify the health endpoint returns 200 (if applicable).
    *   **If smoke tests pass:**
        - Transition the Story issue status to `Done` in Linear.
        - Update `docs/Master-Plan.md`: move the Story row from `## Active Cycle` to `## Completed This Cycle`.
        - Post a Linear comment on the Story issue:

            ```
            Ship 🚀 Deployed
            Date: [YYYY-MM-DD HH:MM]

            Smoke tests: PASS. All Must-priority ACs verified in production. Spec archived to docs/archived/.

            Next: Story closed. See /agtoosa-ship retro to close the sprint loop.
            ```

    *   **If any smoke test fails:** halt immediately, do NOT archive specs, trigger `/agtoosa-revert`, and post:

            ```
            Rollback 🔙 Triggered
            Date: [YYYY-MM-DD HH:MM]

            Smoke test failure: [brief description of failing test]. Deployment rolled back. Story reset to In Review.

            Next: /agtoosa-build tdd to fix the failure, then re-run /agtoosa-ship.
            ```

        Transition the Story status back to `In Review` in Linear and update `docs/Master-Plan.md`.
    *   Capture smoke test pass/fail status in the changelog entry.

### Part 3 — Workspace Cleanup & Archiving (`/agtoosa-ship docs` runs Parts 3 + 4)

3.  **Archive Completed Work:** Spec and review artifacts are already saved to `docs/archived/` (as `spec-[story-id].md` and `review-[story-id].md`). Verify both files exist there before proceeding.

#### Version bump (maintainer dogfood)

Before changing version pins or CHANGELOG release headings, apply the **patch-first** bump decision tree in `docs/adr/ADR-005-release-cadence.md` and `docs/agtoosa-maintainer.md` → Release Checklist:

| Story profile | Bump | Example (from 5.2.0) |
|---------------|------|----------------------|
| Fix, Chore, docs-only, estimate **S** | **PATCH** (default) | 5.2.1 |
| Feature **S**, same MINOR train, non-breaking | **PATCH** | 5.2.1 |
| New MINOR train, multi-story batched release | **MINOR** (Z=0) | 5.3.0 |
| Breaking per ADR-004 | **MAJOR** | 6.0.0 |

- Default to **PATCH+1** on the current MINOR — do not bump MINOR for every small story.
- Sync `AGTOOSA_VERSION` in `agtoosa.sh` and `agtoosa.ps1`, README badge, install `--ref` pins, bats `--version` expectation, and `## [X.Y.Z]` in `CHANGELOG.md`.
- Set `docs/Master-Plan.md` **Milestone** to the **next PATCH** on the active MINOR (e.g. `v5.2.1 (next)` after shipping `5.2.0`).

4.  **Changelog Update:** Update `docs/AgToosa_Changelog.md` with a summary entry: `[date] - [type] - [short description] - [spec reference]`.

5.  **Master-Plan Pruning:** Update `docs/Master-Plan.md` — keep only the Epic description with a reference to the archived spec; clear completed tasks; move the story row to `## Completed This Cycle`.

### Part 4 — Suggest Next Story

6.  **Next Steps Suggestion:**
    *   Based on the overarching project goals in `docs/Master-Plan.md`, suggest the next logical Spec/Story for the team to tackle.
    *   Consider: open bugs, pending features, technical debt, and security improvements.

### Part 5 — Sprint Retrospective (`/agtoosa-ship retro`)

Run this after shipping to close the feedback loop on the sprint.

7.  **Sprint Review:**
    *   Read `docs/AgToosa_Changelog.md` and compare entries against the original spec acceptance criteria.
    *   List: what was planned, what shipped, what was deferred — and why.
    *   Scan `docs/archived/` for all specs closed this sprint.

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
    *   Append a retro entry to `docs/AgToosa_Changelog.md` under a `## Retrospective — [date]` section.
    *   Update `docs/Master-Plan.md` with process improvement action items from the retro.
    *   If a process change was agreed (e.g., enabling TDD, adjusting the 500-line limit), update `docs/Context/workflow.md`.

### Part 6 — Compact Master-Plan.md

Run this step when `docs/Master-Plan.md` exceeds approximately 200 lines **or** after closing an active cycle. Compaction keeps the shared context document within AI context-window limits.

11. **Archive the Completed Cycle:**
    *   Copy the full `## Active Cycle` table to a new snapshot file: `docs/archived/cycle-[YYYY-MM-DD].md`.
    *   In `Master-Plan.md`, replace the `## Active Cycle` table body with an empty placeholder row and a reference comment:

        ```
        <!-- Archived to docs/archived/cycle-[YYYY-MM-DD].md -->
        ```

    *   Remove all `Done` rows from `## Active Tasks` — these are already tracked in Linear.
    *   If `Master-Plan.md` still exceeds 200 lines after pruning, collapse `## Backlog` to titles only (drop Estimate and Epic columns) until the next `/agtoosa-init zoom-out` refresh.

## Output
*   Confirm archiving and changelog updates are successful.
*   Present the suggested next Spec to the user.
*   Print the closure line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
*   Ask if they want to run `/agtoosa-spec` for the next story.
