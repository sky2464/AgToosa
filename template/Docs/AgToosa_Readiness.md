# AgToosa Initial Product Readiness

> **Reference doc.** Use this checklist after `/agtoosa-init` and before `/agtoosa-build` on a new story. `/agtoosa-status readiness` audits these items read-only.

## Checklist

| # | Gate | Pass when | Fix with |
|---|------|-----------|----------|
| 1 | **Context files populated** | `Docs/Context/product.md`, `tech-stack.md`, and `workflow.md` exist and contain no template placeholders (`[name]`, `[url]`, `[e.g.`, `[N]`, `[YYYY-MM-DD]`) | `/agtoosa-init` |
| 2 | **Epics present** | `Docs/Master-Plan.md` `## Epics` has at least one real Epic row (not only placeholder `[DEV-XX]` rows) | `/agtoosa-init` |
| 3 | **Active story has approved spec** | Each 🟨 In Progress (or 🟦 Todo) story in `## Active Cycle` has a matching `Docs/archived/spec-[story-id].md` containing `## ✅ Spec Approved` | `/agtoosa-spec` |
| 4 | **Must ACs mapped to tests** | `Docs/AgToosa_TestPlan-*.md` for the active story exists; every **Must**-priority `AC-NNN` in the spec appears in the test plan AC coverage table | `/agtoosa-spec tasks` or `/agtoosa-qa plan` |
| 5 | **Security / threat model present** | Active spec includes a threat model section (`## Threat Model`, `STRIDE`, or equivalent per `Docs/SPEC-FORMAT.md`) | `/agtoosa-spec plan` |
| 6 | **Task tree and wave plan present** | `Docs/Master-Plan.md` `## Active Tasks` has a checkbox tree for the In Progress story; active spec `## 3. Tasks` includes `### Wave Plan` | `/agtoosa-spec tasks` |
| 7 | **Release / version parity** | Shipped version matches latest `## [X.Y.Z]` in `Docs/AgToosa_Changelog.md` (ignore leading `v`); **Milestone** may be the **next PATCH** on the active MINOR (e.g. `v5.2.1 (next)` while shipped is `5.2.0`) per ADR-005 patch-first cadence | Align manually or `/agtoosa-ship docs` after correcting versions |

## Workflow guidance vs enforcement

AgToosa is markdown instructions for your AI assistant — not a runtime. The generator **installs** workflow docs, platform entry points, and a deterministic verifier; it does **not** execute builds, scans, or PM sync. The verifier (`Docs/agtoosa-verify.sh`) machine-checks lifecycle state locally and becomes **CI-enforced** once `Docs/agtoosa-gate.yml.example` is copied into `.github/workflows/`.

| Capability | Required by workflow instructions | Machine-checked |
|------------|-----------------------------------|-----------------|
| `Docs/Master-Plan.md` as PM source of truth | Yes — every command reads/writes it | Partially — verifier checks Epics, story↔spec↔test-plan integrity |
| STRIDE / threat model at spec time | Yes (`/agtoosa-spec`, except `quick`) | Yes — verifier Gate 3 fails specs without a threat-model section |
| Spec approval before build | Yes (`/agtoosa-build` prerequisites) | Yes — verifier Gate 3 fails active stories without `## ✅ Spec Approved` |
| EARS acceptance criteria | Yes (`Docs/SPEC-FORMAT.md`) | Yes — verifier lints AC rows for EARS keywords |
| TDD Red-Green-Refactor | Yes (`/agtoosa-build`) | Partially — verifier warns when RED evidence blocks are missing from the test plan |
| Must AC → test mapping | Yes (spec tasks + QA plan) | Yes — verifier warns on ACs absent from the test plan (`--strict` fails) |
| OpenTelemetry / structured observability | Yes (`/agtoosa-build` refactor step) | No |
| SBOM + dependency audit | Yes (`/agtoosa-build` Part 2) | No |
| SAST / DAST / secrets scanning | Yes (`/agtoosa-build`, `/agtoosa-review security`) | No |
| Browser / E2E QA | Yes when stack supports it (`/agtoosa-qa`, review QA persona) | No |
| Sandboxed execution (Docker / Firecracker) | Yes when applicable — workflow instructs isolated runs | No |
| Initial readiness gates (this checklist) | Yes — `/agtoosa-status readiness` | Yes — `bash Docs/agtoosa-verify.sh` (CI-enforced via the gate workflow) |
| Ship readiness gate | Yes (`/agtoosa-ship check`) | Partially — verifier covers spec/review/test-plan rows; deploy evidence stays agent-reported |
| Agent result import gate / Async handoff packs | Yes — `/agtoosa-import` gates Tracking updates on repo-local verification; `/agtoosa-handoff` instructs context export before dispatch | No (agent-instructed) |
| File inventory on install / update | — | Yes — `agtoosa.sh` copies registered template files |
| Version parity (bash vs PowerShell generator) | — | Yes — maintainer CI only |

Treat marketing copy and README tables as **aspirational workflow coverage** unless this doc marks a row as machine-checked or generator-enforced.
