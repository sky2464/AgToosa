# Official API / Service Pack — Workflow Starter

Use this pack when the primary delivery surface is an **API or backend service** (REST/gRPC/workers) without a first-class web UI in scope.

## Intended use

- Spec service contracts, auth boundaries, and error envelopes
- Map ACs to integration/contract tests
- Keep threat modeling focused on injection, authZ, and data exposure

## Prerequisites

- AgToosa `>=5.0.0 <6.0.0` installed in the host project
- At least one of: Cursor or Claude Code platform surfaces

## Non-goals

- Full-stack web UI scaffolding (see `official-web`)
- Cluster/IaC policy packs (see `official-infra`)
- Claiming external registry publication from a local install

## Suggested story shape

1. `/agtoosa-spec` — freeze OpenAPI/proto or route contracts in ACs
2. `/agtoosa-build` — RED contract tests before handlers
3. `/agtoosa-review` — authN/authZ and secrets handling
4. `/agtoosa-ship` — record evidence; keep registry state honest
