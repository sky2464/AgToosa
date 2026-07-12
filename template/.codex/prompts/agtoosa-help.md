## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-help`. When the user invokes `/agtoosa-help`, execute the AgToosa help workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Provide static help from `Docs/AgToosa_Agent.md` for the default path (do not read Master-Plan or git unless the argument is `next`).

### Authoring resources
Static maintainer-guide links (print as-is; do not fetch or treat as local Docs paths):
- Platform extensions: https://github.com/sky2464/AgToosa/blob/main/docs/extension-authoring-guide.md
- Registry packs: https://github.com/sky2464/AgToosa/blob/main/docs/registry-pack-authoring.md

Dispatch based on any arguments after the command: `next`, `commands`, or a specific AgToosa command name.

Do not auto-run other workflow commands from help output.
