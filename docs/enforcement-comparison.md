# Enforcement Boundary Comparison — SDD frameworks

Most spec-driven frameworks describe discipline; few can prove where it is enforced. This table classifies **who/what enforces each control** per framework: `machine` (deterministic tool/CI fails), `agent` (LLM is instructed), `process` (humans review), or `—` (absent/not claimed).

AgToosa publishes its own boundary honestly (see `docs/AgToosa_Readiness.md` and the Team Trust Roadmap matrix). This comparison applies the same standard to alternatives, based on their public docs as of 2026-06-09 — corrections welcome via issue/PR, and rows must be re-validated each release.

| Control | AgToosa | GitHub Spec Kit | OpenSpec | BMAD-METHOD |
|---------|---------|-----------------|----------|-------------|
| Spec exists before code | machine (`agtoosa-verify.sh` Gate 3) + agent | agent (workflow order) | machine (`validate` requires proposal) + agent | agent (persona flow) |
| Spec approval recorded | machine (approval marker checked) | agent | agent (archive step) | agent |
| Acceptance-criteria structure | machine (EARS keyword lint) | agent | machine (`validate --strict` scenario checks) | agent |
| Threat model present | machine (verifier fails without it) | — | — | agent (personas) |
| AC → test traceability | machine (verifier cross-checks test plan) | agent | — | agent |
| TDD failing-test evidence | machine-warn (RED evidence blocks) + agent | — | — | — |
| Review artifact before ship | machine-warn (verifier Gate 4) + agent | agent | — | agent (QA persona) |
| CI gate shipped in-box | yes (`agtoosa-gate.yml.example`) | via GitHub ecosystem (assemble yourself) | no first-party | no first-party |
| Supply chain: pinned installs | pinned tags fail closed; pinned brew formula; SHA-256-verified packs | uv/PyPI channel | npm channel | npm channel |
| Third-party extension containment | machine (pack denylist, verified flag enforced, preview consent) | n/a (no registry) | n/a | community expansion packs (process) |
| Enforcement boundary published | yes — this doc + Readiness matrix | no | no | no |

## How to read this honestly

- "machine" for AgToosa means `bash Docs/agtoosa-verify.sh` exits non-zero (or warns; `--strict` fails) — locally and in CI via the gate workflow. It does **not** mean an LLM cannot ignore instructions elsewhere.
- Spec Kit's `/analyze` and constitution checks are agent-executed; they are valuable but an LLM is the judge.
- OpenSpec's `validate --strict` is a documented machine control for spec structure.
- Empty cells mean we found no equivalent documented control; it does not mean the framework cannot be extended to add one.

<!-- AGTOOSA PRODUCT TRUTH START: claims.surface.enforcement -->
<!-- Static conformance and freshness only; not behavioral or provenance proof. -->
| Claim ID | Target | Status | Evidence class | Expires |
| --- | --- | --- | --- | --- |
| `claim.adapter.cursor` | `cursor.project-commands` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.windsurf` | `windsurf.workflows` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.claude` | `anthropic.claude-code` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.gemini` | `google.gemini-cli` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.copilot-vscode` | `github.copilot-vscode` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.codex` | `openai.codex-cli` | verified | static-conformance | 2026-10-12 |
| `claim.windows.bootstrap-ref` | `windows-native` | verified | static-conformance | 2026-10-12 |
| `claim.product-truth.local` | `maintainer` | verified | static-conformance | 2026-10-12 |
<!-- AGTOOSA PRODUCT TRUTH END: claims.surface.enforcement -->
