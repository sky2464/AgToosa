# AgToosa /agtoosa-ship Workflow

## Objective
Deploy the completed feature, clean up the workspace, archive completed work, and suggest the next logical development story.

## Workflow

### Part 1 — Deployment & Rollbacks

1.  **Deployment (Zero-Downtime):**
    *   Initiate deployment logic targeting the environment (e.g., staging or production).
    *   Monitor post-deployment automated health checks.
    *   Trigger automated rollbacks (`/agtoosa-revert` equivalent) if error rates or latencies spike to ensure zero-downtime.

### Part 2 — Workspace Cleanup & Archiving

2.  **Archive Completed Work:**
    *   Automatically move all completed `AgToosa_Spec-*.md` files from `/Docs` into `/Docs/archived/`.
    *   This ensures the main Docs folder remains clean and focused only on in-progress work, while allowing the Project Management AI to query historical context.

3.  **Changelog Update:**
    *   Automate the update of `Docs/AgToosa_Changelog.md` with a summary of the completed feature, fix, chore, or bug.
    *   Format: `[date] - [type] - [short description] - [spec reference]`.

4.  **Master-Plan Pruning:**
    *   Update `Docs/Master-Plan.md`.
    *   Keep only the high-level Epic description with a reference to the archived spec and changelog entry.
    *   Clear out the completed Tasks to reset for the next iteration.

### Part 3 — Suggest Next Story

5.  **Next Steps Suggestion:**
    *   Based on the overarching project goals (from `Docs/Context/product.md`) and the current state of `Master-Plan.md`, suggest the next logical Spec/Story for the team to tackle.
    *   Consider: open bugs, pending features, technical debt, and security improvements.

## Output
*   Confirm archiving and changelog updates are successful.
*   Present the suggested next Spec to the user.
*   Ask if they want to run `/agtoosa-spec` for the next story.
