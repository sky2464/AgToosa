# Compatibility — Official React Pack

## Supported

| Dimension | Value |
|-----------|-------|
| AgToosa | `>=5.0.0 <6.0.0` |
| Platforms | `cursor`, `claude` |
| Frontend conventions | React, Next.js, Vite+React |

## Domain boundary vs official-web

| Pack | Role |
|------|------|
| `official-web` | Stack-agnostic SPA / generic web workflow (retain; no rename) |
| `official-react` | React/Next/Vite-specific ACs, tooling hooks, and example repo |

Do not fold React-primary guidance into `official-web`. Prefer this pack when React conventions are the delivery surface.

## Untested / incompatible

| Combination | Status |
|-------------|--------|
| AgToosa `>=6.0.0` | incompatible (major boundary) |
| AgToosa `<5.0.0` | incompatible |
| Windsurf-only host | untested |
| Gemini-only host | untested |
| Copilot-only host | untested |
| Non-React SPA stacks (Vue/Svelte/etc.) | use `official-web` instead |

Do not imply support for untested platform combinations.
