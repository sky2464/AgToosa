# AgToosa Help


## Windsurf workflow routing

This file is the native Windsurf project workflow for `/agtoosa-help`. When the user invokes `/agtoosa-help`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Display the AgToosa command reference from `Docs/AgToosa_Agent.md` for the default path (static table; do not read Master-Plan or git unless the argument is `next`).

### Authoring resources
Static maintainer-guide links (print as-is; do not fetch or treat as local Docs paths):
- Platform extensions: https://github.com/sky2464/AgToosa/blob/main/docs/extension-authoring-guide.md
- Registry packs: https://github.com/sky2464/AgToosa/blob/main/docs/registry-pack-authoring.md

If the argument is `next`, perform a read-only status/context review and recommend the next AgToosa command. Do not run mutating commands automatically.
