# Security-Sensitive Projects

## Audience

Teams working on auth, registry, secrets, supply chain, CI, credentials, or agent-configuration surfaces where delegation must not expand blast radius.

## Recommended Lifecycle Path

1. Complete spec with a STRIDE threat model before build.
2. Tag Must ACs that touch protected surfaces.
3. Use bounded handoff packs with least-privilege scopes.
4. Require `/agtoosa-import` with redacted logs before closure.
5. Run `/agtoosa-review cross-model` at **recommended** or **strongly recommended** tier.
6. Treat protected-surface changes as separate, explicitly authorized steps.

## Trust Boundary

| Control | Classification |
|---------|----------------|
| Secret handling in packs and prompts | agent-instructed |
| STRIDE review in spec | agent-instructed |
| Protected CI / credentials / agent settings | manual authorization required |
| Verifier and CI gates | CI-enforced when configured |

Delegated agents must not silently change `.github/workflows/`, repository secrets, cloud credentials, or agent settings files.

## Fallback

When a second model is unavailable, use sequential virtual personas with documented rationale, or `/agtoosa-review cross` (cross-platform manual review). Record **Skip rationale** if cross-model is skipped — never imply an independent review occurred without disclosure.

## Least-Privilege Delegation

### Secret redaction

- **Redact** tokens, API keys, passwords, and private URLs from handoff packs, import logs, screenshots, and reviewer prompts.
- Cite file paths and process steps only — never paste secret values.
- Use the Handoff secret-safety rules in the canonical [`docs/AgToosa_Handoff.md`](../AgToosa_Handoff.md).

### STRIDE review

Before delegating security-sensitive work:

1. Read the active spec STRIDE table.
2. Confirm each lane's allowed actions do not exceed its mapped ACs.
3. Record which threats the lane could worsen (spoofing, tampering, information disclosure, elevation of privilege).

### Protected surfaces

These surfaces require **explicit authorization** from a human or orchestrator before any delegated or reviewing agent may change them:

| Surface | Examples |
|---------|----------|
| CI workflows | `.github/workflows/` |
| Credentials | repository secrets, `.env`, key files, cloud credential stores |
| Agent settings | `.claude/settings.json`, hook configs, MCP auth surfaces |

Reviewers remain **read-only** during cross-model review. If CI, credentials, or agent settings must change, stop the review gate and run a separate authorized fix — do not bundle protected edits into a delegated lane return.

### Handoff pack hygiene

- List files in scope — do not embed secret values.
- Verification commands should use local fixtures, not production credentials.
- Return contract should reference redacted log paths, not raw secret-bearing output.

## Canonical Workflow References

- **Handoff secret safety:** [`docs/AgToosa_Handoff.md`](../AgToosa_Handoff.md)
- **Import redaction and closure gate:** [`docs/AgToosa_Import.md`](../AgToosa_Import.md)
- **Cross-model read-only reviewer:** [`docs/AgToosa_CrossModelReview.md`](../AgToosa_CrossModelReview.md)
- **Routing and fallbacks:** [`docs/AgToosa_AgentCapability.md`](../AgToosa_AgentCapability.md)

## Related Guides

- [Subagent-heavy workflows](subagent-heavy-workflows.md)
- [Solo-developer workflows](solo-developer-workflows.md)
- [End-to-end walkthrough](../examples/subagent-handoff-review.md)
