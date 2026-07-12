# Official Security Pack — Workflow Starter

Use this pack when the primary domain is **security-sensitive delivery**: threat modeling, evidence expectations, and trust-boundary review — not generic web UI or API scaffolds.

## Intended use

- Spec features with STRIDE and explicit security acceptance criteria
- Distinguish guided vs evidenced vs enforced security controls
- Document generator-enforced registry boundaries (allowlist, denylist, preview, consent)

## Prerequisites

- AgToosa `>=5.0.0 <6.0.0` installed in the host project
- At least one of: Cursor or Claude Code platform surfaces
- Human review before production policy or trust-boundary changes

## Non-goals

- Duplicating stack-agnostic web guidance (`official-web`) or API scaffolds (`official-api`)
- Infrastructure/IaC topology as the primary domain (`official-infra`)
- Implying AgToosa fails CI on scanner findings without recorded command evidence
- Weakening registry allowlist, denylist, preview, or consent gates
- Writing into `.github/workflows/` or `.claude/settings.json` via packs
- Fail-closed signature mode (tracked separately; not this pack)

## Security control map (pilot)

| Control | Classification |
|---------|----------------|
| File-type allowlist (`.md` `.json` `.toml` `.mdc`) | Generator-enforced |
| Sensitive-path denylist (hooks/CI) | Generator-enforced |
| Content preview + consent | Generator-enforced |
| SHA-256 / verified flag (registry installs) | Generator-enforced |
| STRIDE / threat-model story ACs | Guided / evidenced in lifecycle docs |
| External SAST/DAST tooling | Manual / stack-dependent — not claimed as deterministic AgToosa enforcement |
| External registry approval | Manual / external |

## Suggested story shape

1. `/agtoosa-spec` — STRIDE + security ACs with claim-boundary honesty
2. `/agtoosa-build` — prove preview/queue/merge without denylist hits; record evidence for any scanner runs
3. `/agtoosa-review` — security persona on trust-boundary and overclaim checks
4. `/agtoosa-ship` — never mark externally published without confirmed registry record
