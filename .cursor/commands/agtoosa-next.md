---
description: AgToosa next lifecycle dispatcher (maintainer dogfood)
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-next` in **Maintainer Dogfood Mode**. When the user invokes `/agtoosa-next`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `docs/AgToosa_Next.md` and execute the `/agtoosa-next` workflow. See `docs/agtoosa-maintainer.md` for path conventions.

**Mandatory:** run `bash agtoosa.sh --status-line [path] --route-hint --format json` before dispatch.

Dispatch based on any arguments after the command: `dry`, `pick`, `fix`, `test`, or `docs`.

**Phase stop:** dispatch exactly **one** lifecycle workflow per invocation. Do **not** auto-chain Spec → Build → Review → Ship.

**Sequential approval:** when Next dispatches a phase, the user's invocation counts as approval at spec/review/ship gates when readiness checks pass. See `docs/AgToosa_Next.md` → Sequential Approval Contract.

**Distinct from `/agtoosa-help next`:** this command **executes** workflows; help next is read-only suggestions only.
