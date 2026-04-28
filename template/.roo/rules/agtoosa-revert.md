# AgToosa Revert Rules

When running agtoosa-revert or any rollback, follow `Docs/AgToosa_Revert.md` precisely.

## Key constraints

- Identify the exact commit or deployment to roll back to before taking any action.
- Create a Linear issue documenting the reason for the revert.
- After reverting, run the full test suite to confirm stability.
- Update `Docs/AgToosa_Changelog.md` with a revert entry.
