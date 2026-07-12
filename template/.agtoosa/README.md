# AgToosa `.agtoosa/` config index

Optional project-local YAML for AgToosa governance and delivery evidence. Files here are **not** auto-active until you copy an example to the live name and commit intentionally.

| File | Purpose | Story |
|------|---------|-------|
| `policy.yaml` | Agent governance / boundary rules (paths, tools, secrets, approvals) | DEV-059 |
| `policy.yaml` example | Prefer `Docs/Context/agtoosa-policy.example.yaml` — copy to `.agtoosa/policy.yaml` after review | DEV-059 |
| `evidence.yml` | Delivery evidence profiles (`standard`, `security-sensitive`, `release`) | DEV-087 |
| `evidence.yml.example` | Commented profile templates — copy to `evidence.yml` to activate | DEV-087 |

## Verifier gate order

**policy (Gate 6) → evidence profile (Gate 7, DEV-089) → lifecycle gates**

When the verifier grows profile enforcement:

1. **Policy (Gate 6)** — validate optional `.agtoosa/policy.yaml` / Context policy (DEV-059)
2. **Evidence profile (Gate 7)** — validate delivery profile requirements (**DEV-089**; schema-only checker ships in DEV-087)
3. **Lifecycle gates** — context, Master-Plan, spec approval, ACs, tests, threat model, TDD evidence

Do not conflate `policy.yaml` (agent boundaries) with `evidence.yml` (delivery artifact minimums).

## Related docs

- `Docs/AgToosa_GovernancePolicy.md` — policy schema vocabulary
- `Docs/AgToosa_Delivery_Evidence_Contract.md` — Guided / Evidenced / Enforced + profiles
- `Docs/AgToosa_Agent.md` — Terminal Evidence Contract (per-task output; distinct)
- `Docs/agtoosa-policy-check.sh` / `Docs/agtoosa-evidence-profile-check.sh` — local schema checkers
