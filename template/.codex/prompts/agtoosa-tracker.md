## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-tracker`. When the user invokes `/agtoosa-tracker`, execute the AgToosa Tracker Sync workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_TrackerSync.md` and help the user run `export` or `propose` via `bash agtoosa.sh --tracker`. `Docs/Master-Plan.md` remains authoritative — never apply tracker changes without `/agtoosa-task` or `/agtoosa-spec amend`. No live provider API sync in v1.
