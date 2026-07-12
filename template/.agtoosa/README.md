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

1. **Policy (Gate 6)** — validate optional `.agtoosa/policy.yaml` / Context policy (DEV-059). Missing policy is never a finding.
2. **Evidence profile (Gate 7, DEV-089)** — when `.agtoosa/evidence.yml` is absent → healthy `no evidence profile configured`. When present: schema WARN on invalid YAML; deterministic presence/path/exit-code checks for required tokens; guided/evidenced rows never upgrade to enforced FAIL without a wired command; SAST/dependency-scan checks never claim vulnerability absence; missing evidence ledger → WARN citing DEV-049 (not FAIL). `--strict` promotes Gate 7 WARN to FAIL.
3. **Lifecycle gates** — context, Master-Plan, spec approval, ACs, tests, threat model, TDD evidence (Gates 1–4 in current verifier numbering; Gate 7 runs after Gate 6 before summary).

Do not conflate `policy.yaml` (agent boundaries) with `evidence.yml` (delivery artifact minimums).

## Related docs

- `Docs/AgToosa_GovernancePolicy.md` — policy schema vocabulary
- `Docs/AgToosa_Delivery_Evidence_Contract.md` — Guided / Evidenced / Enforced + profiles
- `Docs/AgToosa_Agent.md` — Terminal Evidence Contract (per-task output; distinct)
- `Docs/agtoosa-policy-check.sh` / `Docs/agtoosa-evidence-profile-check.sh` — local schema checkers (Gate 7 enforcement lives in `Docs/agtoosa-verify.sh`)
