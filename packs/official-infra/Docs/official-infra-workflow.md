# Official Infrastructure / Security Pack — Workflow Starter

Use this pack when the primary domain is **infrastructure or security controls** (deploy topology, least-privilege, secrets handling, CI boundaries).

## Intended use

- Spec infra changes with STRIDE and least-privilege ACs
- Keep pack merges out of denylisted CI/hook destinations
- Document generator-enforced vs manual security controls

## Prerequisites

- AgToosa `>=5.0.0 <6.0.0` installed in the host project
- At least one of: Cursor or Claude Code platform surfaces
- Human review before any production policy change

## Non-goals

- Weakening registry allowlist, denylist, preview, or consent gates
- Writing into `.github/workflows/` or `.claude/settings.json` via packs
- Fail-closed signature mode (tracked separately; not this pack)

## Security control map (pilot)

| Control | Enforced by |
|---------|-------------|
| File-type allowlist (`.md` `.json` `.toml` `.mdc`) | Generator (`validate_pack_files`) |
| Sensitive-path denylist (hooks/CI) | Generator (preview + merge) |
| Content preview + consent | Generator |
| SHA-256 / verified flag (registry installs) | Generator |
| External registry approval | Manual / external |
| Ongoing content review cadence | Manual governance |

## Suggested story shape

1. `/agtoosa-spec` — STRIDE + least-privilege ACs
2. `/agtoosa-build` — prove preview/queue/merge without denylist hits
3. `/agtoosa-review` — security persona on trust boundary claims
4. `/agtoosa-ship` — never mark externally published without confirmed registry record
