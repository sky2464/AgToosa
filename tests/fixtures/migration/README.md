# Migration fixtures (DEV-091 / MWZ)

Helpers for MAJOR-version migration wizard bats.

| File | Purpose |
|------|---------|
| `claude-outside-markers.md` | Platform entry with user prose **outside** AgToosa markers (AC-004 preserve) |
| `orphan-AgToosa_LegacyRemoved.md` | Workflow path present in project but absent from template (plan `manual`) |

Bats seed a temp install via `agtoosa.sh`, rewrite `Docs/.agtoosa-version` to `4.9.0` for MAJOR (4→5), or `5.3.0` for MINOR same-major, then overlay these files as needed.
