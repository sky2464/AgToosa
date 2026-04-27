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

## Workflow

### Part 0 — Ship Readiness Gate (`/agtoosa-ship check` runs this exclusively)

Before any deployment, verify all of the following. If **any** check fails, list the failures, block deployment, and tell the user which command resolves each.

| Check | How to Verify |
|-------|--------------|
| ✅ Spec was approved | `Docs/AgToosa_Spec-*.md` contains a `## ✅ Spec Approved` section with a timestamp |
| ✅ `/agtoosa-review` completed | `Docs/AgToosa_Review-*.md` exists and contains no unresolved 🔴 Critical findings |
| ✅ All tests pass | Run full test suite and confirm green |
| ✅ Changelog entry drafted | `Docs/AgToosa_Changelog.md` has an entry for this feature |
| ✅ No `WIP:` commits remain | `git log` shows no commits prefixed with `WIP:` |

Only proceed to Part 1 after all checks pass.

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
    *   Trigger automated rollbacks (`/agtoosa-revert` equivalent) if error rates or latencies spike to ensure zero-downtime.

### Part 3 — Workspace Cleanup & Archiving (`/agtoosa-ship docs` runs Parts 3 + 4)

3.  **Archive Completed Work:** Move all completed `AgToosa_Spec-*.md` from `Docs/` to `Docs/archived/`.

4.  **Changelog Update:** Update `Docs/AgToosa_Changelog.md` with a summary entry: `[date] - [type] - [short description] - [spec reference]`.

5.  **Master-Plan Pruning:** Update Linear first, then mirror in `Docs/Master-Plan.md` — keep only the Epic description with a reference to the archived spec; clear completed tasks.

### Part 4 — Suggest Next Story

6.  **Next Steps Suggestion:**
    *   Based on the overarching project goals in Linear and the current mirrored state of `Master-Plan.md`, suggest the next logical Spec/Story for the team to tackle.
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

## Output
*   Confirm archiving and changelog updates are successful.
*   Present the suggested next Spec to the user.
*   Ask if they want to run `/agtoosa-spec` for the next story.
