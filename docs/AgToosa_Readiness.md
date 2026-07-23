# AgToosa Initial Product Readiness

> **Reference doc (Maintainer Dogfood Mode).** Use this checklist after `/agtoosa-init` and before `/agtoosa-build` on a new story in the AgToosa generator repository. `/agtoosa-status readiness` audits these items read-only. See `docs/agtoosa-maintainer.md`.

## Checklist

| # | Gate | Pass when | Fix with |
|---|------|-----------|----------|
| 1 | **Context files populated** | `docs/Context/product.md`, `tech-stack.md`, and `workflow.md` exist and contain no template placeholders (`[name]`, `[url]`, `[e.g.`, `[N]`, `[YYYY-MM-DD]`) | `/agtoosa-init` |
| 2 | **Epics present** | `docs/Master-Plan.md` `## Epics` has at least one real Epic row (not only placeholder `[DEV-XX]` rows) | `/agtoosa-init` |
| 3 | **Active story has approved spec** | Each 🟨 In Progress (or 🟦 Todo) story in `## Active Cycle` has a matching `docs/archived/spec-*.md` containing `## ✅ Spec Approved` | `/agtoosa-spec` |
| 4 | **Must ACs mapped to tests** | `docs/AgToosa_TestPlan-*.md` for the active story exists; every **Must**-priority `AC-NNN` in the spec appears in the test plan AC coverage table | `/agtoosa-spec tasks` or `/agtoosa-qa plan` |
| 5 | **Security / threat model present** | Active spec includes a threat model section (`Threat Model`, `STRIDE`, or equivalent per `docs/SPEC-FORMAT.md`) | `/agtoosa-spec plan` |
| 6 | **Task tree and wave plan present** | `docs/Master-Plan.md` `## Active Tasks` has a checkbox tree for the In Progress story; active spec `## 3. Tasks` includes `### Wave Plan` | `/agtoosa-spec tasks` |
| 7 | **Release / version parity** | `AGTOOSA_VERSION` in `agtoosa.sh` and `agtoosa.ps1` matches the latest **released** `## [X.Y.Z]` in root `CHANGELOG.md` (ignore leading `v`); **Milestone** may be the **next PATCH** on the active MINOR (e.g. `v5.2.1 (next)` while shipped is `5.2.0`) per `docs/adr/ADR-005-release-cadence.md` | Align manually or `/agtoosa-ship docs` |

## Workflow guidance vs enforcement

AgToosa is markdown instructions for your AI assistant — not a runtime. The generator **installs** workflow docs, platform entry points, and a deterministic verifier; it does **not** execute builds, scans, or PM sync. The verifier (`docs/agtoosa-verify.sh` in this repo) is a **local machine check**. `docs/agtoosa-gate.yml.example` is **template only** until copied, pushed, and a real workflow run is observed — only then is the gate **CI-enforced**. See [docs/examples/verifier-ci-adoption.md](examples/verifier-ci-adoption.md).

| Capability | Required by workflow instructions | Machine-checked |
|------------|-----------------------------------|-----------------|
| `docs/Master-Plan.md` as PM source of truth | Yes — every command reads/writes it | Partially — verifier checks Epics, story↔spec↔test-plan integrity |
| STRIDE / threat model at spec time | Yes (`/agtoosa-spec`, except `quick`) | Yes — verifier Gate 3 fails specs without a threat-model section |
| Spec approval before build | Yes (`/agtoosa-build` prerequisites) | Yes — verifier Gate 3 fails active stories without `## ✅ Spec Approved` |
| EARS acceptance criteria | Yes (`docs/SPEC-FORMAT.md`) | Yes — verifier lints AC rows for EARS keywords |
| TDD Red-Green-Refactor | Yes (`/agtoosa-build`) | Partially — verifier warns when RED evidence blocks are missing from the test plan |
| Must AC → test mapping | Yes (spec tasks + QA plan) | Yes — verifier warns on ACs absent from the test plan (`--strict` fails) |
| OpenTelemetry / structured observability | Yes (`/agtoosa-build` refactor step) | No |
| SBOM + dependency audit | Yes (`/agtoosa-build` Part 2) | No |
| SAST / DAST / secrets scanning | Yes (`/agtoosa-build`, `/agtoosa-review security`) | No |
| Browser / E2E QA | Yes when stack supports it (`/agtoosa-qa`, review QA persona) | No |
| Sandboxed execution (Docker / Firecracker) | Yes when applicable — workflow instructs isolated runs | No |
| Initial readiness gates (this checklist) | Yes — `/agtoosa-status readiness` | Yes — `bash docs/agtoosa-verify.sh` (local machine check; CI-enforced only after observed gate run — see verifier-ci-adoption) |
| Ship readiness gate | Yes (`/agtoosa-ship check`) | Partially — verifier covers spec/review/test-plan rows; deploy evidence stays agent-reported |
| Agent result import gate / Async handoff packs | Yes — `/agtoosa-import` gates Tracking updates on repo-local verification; `/agtoosa-handoff` instructs context export before dispatch | No (agent-instructed) |
| Evidence ledger (per-story proof index) | Yes — required at review and ship phases (`/agtoosa-evidence review` · `ship`); `docs/archived/evidence-[story-id].md` must exist before marking Shipped | No (agent-instructed) |
| Optional minisign soft-warn (packs + release sidecars) | Yes — when `.minisig` / `signature.url` present; warn-and-continue on failure | Soft generator path (does not fail install); fail-closed require-signatures = roadmap |
| File inventory on install / update | — | Yes — `agtoosa.sh` copies registered template files |
| Version parity (bash vs PowerShell generator) | — | Yes — `AGTOOSA_VERSION` must match in both entrypoints |

Treat marketing copy and README tables as **aspirational workflow coverage** unless this doc marks a row as machine-checked or generator-enforced.

### Claim boundary — signed provenance (DEV-054)

| Control | Classification |
|---------|----------------|
| Optional minisign verify when signature present | generator-enforced (soft-warn) |
| Private-key generation / release signing | manual (`DEV-054 M-1`) |
| Fail-closed `AGTOOSA_REQUIRE_SIGNATURES`, SBOM, cosign verify | roadmap |
| Repo-local PM source of truth | `docs/Master-Plan.md` |

<!-- AGTOOSA PRODUCT TRUTH START: claims.surface.readiness -->
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
<!-- AGTOOSA PRODUCT TRUTH END: claims.surface.readiness -->
