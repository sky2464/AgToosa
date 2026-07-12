# Official Web Pack — Workflow Starter

Use this pack when the primary delivery surface is a **stack-agnostic web application** (browser UI, SSR/SPA, or static front-end with API clients). For React/Next/Vite-specific guidance, use `official-react` instead.

## Intended use

- Spec and build web features with AgToosa lifecycle gates
- Capture browser/accessibility QA expectations in story ACs
- Keep platform adapters (Cursor/Claude) aligned with Docs/ workflows

## Prerequisites

- AgToosa `>=5.0.0 <6.0.0` installed in the host project
- At least one of: Cursor or Claude Code platform surfaces

## Non-goals

- React/Next/Vite-primary tooling hooks (see `official-react`)
- Native mobile (use a mobile-focused pack instead)
- Infrastructure/IaC hardening (see `official-infra`)
- External marketplace publication or billing

## Suggested story shape

1. `/agtoosa-spec` — declare UI surfaces, routes, and acceptance criteria
2. `/agtoosa-build` — TDD against mapped UI/API contract tests
3. `/agtoosa-review` — include STRIDE for XSS/CSRF/session threats
4. `/agtoosa-ship` — archive evidence; do not claim registry publication from this pack alone
