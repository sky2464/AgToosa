# Compatibility — Official Web Pack

## Supported

| Dimension | Value |
|-----------|-------|
| AgToosa | `>=5.0.0 <6.0.0` |
| Platforms | `cursor`, `claude` |
| Frontend scope | Stack-agnostic SPA / generic web workflow |

## Domain boundary vs official-react

| Pack | Role |
|------|------|
| `official-web` | Stack-agnostic SPA / generic web (this pack — retain; no rename) |
| `official-react` | React/Next/Vite-specific ACs and tooling hooks |

Do not treat React-specific hooks as primary guidance here — use `official-react` for that domain.

## Untested / incompatible

| Combination | Status |
|-------------|--------|
| AgToosa `>=6.0.0` | incompatible (major boundary) |
| AgToosa `<5.0.0` | incompatible |
| Windsurf-only host | untested |
| Gemini-only host | untested |
| Copilot-only host | untested |

Do not imply support for untested platform combinations.
