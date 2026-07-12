# Official React Pack — Workflow Starter

Use this pack when the primary delivery surface is a **React**, **Next.js**, or **Vite + React** frontend. For stack-agnostic SPA/web guidance, use `official-web` instead.

## Intended use

- Spec and build React/Next/Vite features with AgToosa lifecycle gates
- Capture component, route, and hydration ACs mapped to UI tests
- Keep Cursor/Claude adapters aligned with Docs/ workflows for React apps

## Prerequisites

- AgToosa `>=5.0.0 <6.0.0` installed in the host project
- At least one of: Cursor or Claude Code platform surfaces
- A React, Next.js, or Vite+React host (or intent to create one)

## Non-goals

- Stack-agnostic SPA guidance (see `official-web`)
- Native mobile (use a mobile-focused pack instead)
- API/backend service scaffolds (see `official-api`)
- Infrastructure/IaC hardening (see `official-infra`)
- Security-evidence workflow as primary domain (see `official-security`)
- External marketplace publication or billing

## Suggested story shape

1. `/agtoosa-spec` — declare React routes/components, data-fetch boundaries, and acceptance criteria
2. `/agtoosa-build` — TDD against component and route contract tests (React Testing Library / Playwright as fit)
3. `/agtoosa-review` — include STRIDE for XSS, CSRF, and client-side secret leakage
4. `/agtoosa-ship` — archive evidence; do not claim registry publication from this pack alone
