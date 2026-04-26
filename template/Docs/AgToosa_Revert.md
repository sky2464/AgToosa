# AgToosa /agtoosa-revert Workflow

## Objective
Safely rollback to a previous state of the project based on logical units of work (Tracks, Phases, or Tasks) rather than simple git commit hashes.

## Workflow

1.  **Logical Unit Identification:**
    *   The agent identifies the specific Phase (e.g., `/agtoosa-build`, `/agtoosa-review`) or Task (e.g., "Implement User Authentication") the user wishes to revert.
2.  **Git-Aware State Reversal:**
    *   The agent maps the logical unit back to the corresponding git commits and branches.
    *   It safely runs the necessary `git revert` or `git reset` commands to undo the code changes related *only* to that logical unit, minimizing impact on parallel tracks.
3.  **Context & Plan Synchronization:**
    *   After reverting the code, the agent updates Linear first.
    *   Mirror the reverted status in `Docs/Master-Plan.md` and any relevant `AgToosa_Spec-*.md` files.
    *   Ensures that the AI PM context is in perfect sync with the source code.

## Output
*   Confirm the code and context have been successfully reverted.
*   Present the current clean state to the user and ask for next steps.
