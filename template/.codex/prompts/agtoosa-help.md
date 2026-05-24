## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-help`. When the user invokes `/agtoosa-help`, execute the AgToosa help workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Agent.md` for the command reference and provide static help.

Dispatch based on any arguments after the command: `next`, `commands`, or a specific AgToosa command name.

Do not auto-run other workflow commands from help output.
