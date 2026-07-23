# Spec: DEV-118 — Product Truth & Adapter Contract

> **Story ID:** DEV-118
> **Epic:** DEV-001 — Core Generator Engine · DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness
> **Status:** 🟨 In Progress — Spec Approved and enrolled (main)
> **Estimate:** L
> **Clarity:** ready
> **Spec created:** 2026-07-14
> **ADRs:** `docs/adr/ADR-015-product-truth-contract.md` · `docs/adr/ADR-016-bounded-adapter-rendering.md` · `docs/adr/ADR-017-fresh-claims-and-windows-truth.md`
> **Parents:** DEV-037 (truthful positioning) · DEV-094 (compatibility tiers) · DEV-102 (network matrix) · DEV-105 (PowerShell maintenance)

## Context

AgToosa's cross-surface product facts are currently distributed across `lib/config.sh`, generator templates, six native command surfaces, Bash and PowerShell entry points, README tables, and compatibility/trust documents. The 2026-07-14 competitive audit found four P0 credibility defects:

1. Generated-project workflow files under `template/Docs/` contain local lowercase `docs/` references even though downstream installs use `Docs/` on case-sensitive filesystems.
2. Native `/agtoosa-spec quick` adapters contradict the canonical two-question limit: Gemini and Copilot say three; Claude says two-to-three.
3. Public claims include stale backlog rows and unsupported “only,” “fully supported,” enforcement, any-assistant, and zero-downtime language.
4. Windows guidance hides Bash-backed operations and dependencies, while the advertised pinned PowerShell bootstrap example does not bind the selected ref to the downloaded script.

The interview selected one versioned, inert JSON Product Truth Contract as authority for cross-surface facts. Stable contract-owned fields will be rendered into bounded managed blocks; platform-specific prose remains native but must normalize to the same portable invariants. Validation stays local, check-only in CI, and separate from DEV-121 behavioral Scenario execution and DEV-120 evidence provenance.

**Inventory correction:** the interview was initially presented with the existing WP2 expectation of 18 commands. A complete repository audit found **19** command files on each of the six native command surfaces. This spec preserves the user's decision to govern every current command and corrects the stale number to 19 (114 command × target cells at the baseline).

### Research Basis

- [GitHub Spec Kit workflows](https://github.github.com/spec-kit/reference/workflows.html) use versioned workflow definitions with typed fields and gates.
- [OpenSpec customization](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md) validates versioned artifact schemas and dependencies.
- [Git `core.ignoreCase`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-coreignoreCase) and [Microsoft WSL case sensitivity](https://learn.microsoft.com/en-us/windows/wsl/case-sensitivity) explain why casing defects can remain hidden on one filesystem and fail on another.
- Official target documentation confirms format/surface distinctions for [Claude Code](https://code.claude.com/docs/en/slash-commands), [Gemini CLI](https://geminicli.com/docs/cli/custom-commands/), and [GitHub Copilot custom agents](https://docs.github.com/en/copilot/reference/custom-agents-configuration).

### Smart Interview Decisions (2026-07-14)

| Decision | Confirmed choice |
| ---------- | ------------------ |
| Authority | Versioned JSON Product Truth Contract is canonical for modeled facts. |
| Projection | Render stable fields into bounded managed blocks; validate target-specific content. |
| Command breadth | Govern every current command on six native targets; corrected baseline is 19 × 6, not stale 18 × 6. |
| Semantic depth | Universal invariants on all 114 baseline cells; deep goldens first for Init, Spec, Build, Review, and Ship. |
| Windows boundary | Fix pinned-ref and preflight behavior; classify native/Bash-backed operations; defer pure PowerShell rewrites. |
| Claim freshness | Active public claims expire after 90 days and revalidate when their owning contract changes. |
| Governed claims | README plus Compatibility, Network, Readiness, enforcement-comparison, and Team Trust documents; scan other public docs for unsupported absolutes. |
| Trust boundary | Contract is inert local data: no execution, interpolation, environment expansion, network access, path escape, or implicit writes. |
| Estimate and split | L; retain one DEV-118 child inside the confirmed seven-story portfolio. |
| Enrollment | Initially approved backlog-only; separately authorized and enrolled on 2026-07-14 in isolated branch `codex/dev-118`. DEV-117 review state remains unchanged. |

### Specialist and Skill Decisions

- No approved `docs/Context/specialists.md` roster exists; no specialist files are generated.
- Parallel read-only lanes covered local truth, architecture/test design, and primary-source research.

| Skill name | Trigger | Purpose | Decision | Reason |
| ------------ | --------- | --------- | ---------- | -------- |
| `product-truth-audit` | Maintainer changes adapters or public claims | Run Product Truth checks | Do not generate | The deterministic script and CI check are the reusable surface; a new agent skill would duplicate normal maintainer validation. |

### Spec Quality Analyzer (2026-07-14)

| Check | Result |
| ------- | -------- |
| Must ACs testable and unambiguous | Pass |
| Goal / non-goals / scope / AC / task alignment | Pass |
| Must AC to test-plan mapping | Pass — AC-001 through AC-012 mapped in `docs/AgToosa_TestPlan-DEV-118.md` |
| Claim Boundary classified | Pass — section 1.6 |
| Brownfield baseline and drift resolution | Pass — section 1.5 |
| `docs/Master-Plan.md` authority preserved | Pass |
| Placeholders or unresolved Must decisions | Pass — none |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
| ------- | ------- |
| Goal | Establish one auditable Product Truth Contract that repairs generated-path casing, command/adapter semantics, Windows/dependency truth, and public capability claims, then blocks those defects from recurring. |
| User outcome | Maintainers can change a command or claim once and detect every affected adapter/document; downstream users receive resolvable generated paths, consistent lifecycle semantics, honest Windows prerequisites, and evidence-bounded public claims. |
| Success condition | A closed v1 contract and bounded renderer/checker cover all 19 baseline commands × six native targets; case-sensitive generated fixtures resolve local paths; Windows ref/preflight/parity fixtures pass; governed claims are fresh and non-contradictory; `PTC-001`–`PTC-012` plus adjacent regressions pass in CI. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-118.md`; `tests/product-truth.bats`; focused PN/WP/ACC/NET/PSP/CORE regressions; PowerShell tests when `pwsh` is available; repository verifier; RED/GREEN blocks recorded during build. |
| Non-goals | New assistant adapters; assistant Scenario execution or behavioral certification; hosted checks; telemetry; automatic network evidence refresh; full native PowerShell rewrite; registry publish parity; DEV-120 evidence authenticity; replacing workflow prose or `docs/Master-Plan.md`. |
| Assumptions | Existing six native command target families remain supported; Python 3 standard library is acceptable for a maintainer-only deterministic checker and becomes an explicit affected-operation dependency; adapter-specific prose remains useful outside managed blocks. |
| Risks | Broad casing edits corrupt intentional references; managed rendering overwrites user-authored prose; time-based claim checks become flaky; surface aliases inherit unsupported claims; hidden dependencies still fail late. Mitigations are explicit exemptions, marked-block writes, injected test clock, surface-specific IDs, and per-operation preflight. |
| Unresolved questions | None. |

### 1.2 User Stories

**As an** AgToosa maintainer, **I want** one machine-checkable authority for cross-surface command facts **so that** adding or changing a command cannot silently drift across assistants.

**As a** downstream user on a case-sensitive filesystem, **I want** generated workflow references to use the installed `Docs/` casing **so that** commands resolve outside case-insensitive development machines.

**As a** Windows user, **I want** each operation to disclose whether it is native, Bash-backed, redirected, unsupported, or degraded before mutation **so that** I can install the real prerequisites or choose a supported path.

**As a** prospective adopter, **I want** dated, evidence-bounded capability claims **so that** public tables do not imply support or enforcement beyond observed proof.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
| ---- | ------ | ---------- |
| AC-001 | WHEN `contracts/product-truth-v1.json` is loaded THE SYSTEM SHALL validate it against a closed, versioned schema; reject unknown fields, executable expressions, interpolation, dynamic includes, absolute repository paths, traversal, symlink escape, and bounded-size violations; and perform no environment expansion, command execution, network access, or writes. | Must |
| AC-002 | WHEN command and target inventory is checked THE SYSTEM SHALL reconcile every current native command—19 at the baseline—across six stable target IDs, fail on missing, duplicate, or unreviewed cells, and require explicit artifact-kind exceptions for auxiliary layers such as Codex skills. | Must |
| AC-003 | WHEN contract-owned adapter or public-document fields are rendered THE SYSTEM SHALL update only existing bounded managed truth blocks through explicit `render --apply`, preserve platform-specific content outside those blocks, and provide `render --check` and default check modes that make no writes. | Must |
| AC-004 | WHEN native adapters are checked THE SYSTEM SHALL validate portable routing, modes/subcommands, question budgets, mutation classes, approval gates, Phase Stop, generated path casing, and lifecycle close for every declared command × target cell, plus deeper semantic goldens for Init, Spec, Build, Review, and Ship. | Must |
| AC-005 | WHEN a generated-project local reference is checked THE SYSTEM SHALL require exact `Docs/` casing against the tracked/generated file inventory, while allowing lowercase `docs/` only for owner-tagged remote URLs, explicit Maintainer Dogfood text, safe examples, or intentional dual-root resolvers with a reason. | Must |
| AC-006 | WHEN Bash and PowerShell parse the same install platform selection THE SYSTEM SHALL preserve the same canonical platform identity—including distinct `copilot` and `vscode` tokens—and public claims SHALL NOT inherit Gemini CLI evidence to Jules, Codex CLI evidence to OpenCode, or Copilot VS Code evidence to Copilot Cloud. | Must |
| AC-007 | WHEN an operation requires Bash, Git, curl, tar, jq, Python, Node/npm, PowerShell, or network access THE SYSTEM SHALL classify the backend as `native`, `bash-delegated`, `redirect-only`, `unsupported`, or `optional/degraded`, disclose dependencies and missing behavior before mutation, and keep human help and machine-checkable contract facts consistent. | Must |
| AC-008 | WHEN the published Windows install path specifies a release ref THE SYSTEM SHALL bind that exact ref to `bootstrap.ps1`, validate the ref grammar, fail closed on an unavailable ref, and prove through a deterministic fixture that archive selection uses the requested ref without claiming artifact provenance. | Must |
| AC-009 | WHEN an active governed capability claim is recorded THE SYSTEM SHALL require stable capability/target IDs, owner, status, evidence class, evidence reference, governed surfaces, `owner_contract_id`, `owner_contract_fingerprint`, `verified_at`, `expires_at`, and verifier metadata; SHALL expire it after 90 days or an owning-contract fingerprint change; and SHALL classify expiry as stale/unverified rather than unsupported. | Must |
| AC-010 | WHEN README or a governed Compatibility, Network, Readiness, enforcement-comparison, or Team Trust section is rendered or checked THE SYSTEM SHALL reject missing, expired, contradictory, or overbroad claim IDs and SHALL scan remaining public documentation for unsupported absolute, enforcement, parity, or superiority wording. | Must |
| AC-011 | WHEN Product Truth validation passes THE SYSTEM SHALL limit the claim to declared static conformance and freshness; SHALL NOT claim host recognition, Scenario-tested behavior, authenticated provenance, native sandboxing, full PowerShell parity, or universal assistant support without the separately required evidence. | Must |
| AC-012 | WHEN DEV-118 verification runs THE SYSTEM SHALL cover every Must AC with positive and negative fixtures, run the focused Product Truth suite in CI, retain PN/WP/ACC/NET/PSP/CORE regressions, preserve 100% AC-to-test mapping, and leave DEV-120/DEV-121 ownership unchanged. | Must |

**Failure modes (Must ACs):**

| AC | Failure mode |
| ---- | -------------- |
| AC-001 | A crafted contract executes code, expands secrets, escapes the repository, reaches the network, or bypasses a misspelled field. |
| AC-002 | A twentieth command or seventh target ships on only some surfaces while a stale file-count test remains green. |
| AC-003 | Rendering overwrites target-specific prose or CI mutates protected repository content. |
| AC-004 | Files exist everywhere but adapters disagree on quick limits, mutation, approval, or Phase Stop semantics. |
| AC-005 | A blanket `docs/` replacement corrupts external URLs or dual-root tooling, or a generated local path fails only on Linux. |
| AC-006 | PowerShell collapses VS Code into Copilot or one vendor product inherits another surface's evidence. |
| AC-007 | A user discovers Bash, jq, Python, or network requirements only after state has changed. |
| AC-008 | A “pinned” Windows command downloads `main`, accepts an unsafe ref, or overclaims integrity from ref propagation alone. |
| AC-009 | An old evidence date remains publicly current or stale evidence is mislabeled as proof of unsupported behavior. |
| AC-010 | README and canonical trust tables contradict one another or unsupported absolutes bypass governed claim IDs. |
| AC-011 | Static checks are marketed as behavioral, cryptographic, sandbox, or universal compatibility proof. |
| AC-012 | The new gate displaces existing compatibility/network tests or absorbs DEV-120/DEV-121 work. |

### 1.4 Out of Scope

- Adding or removing assistant integrations solely to satisfy parity
- Running assistants, models, prompts, or Scenario tasks
- Promoting Install-tested or Render-tested rows to Scenario-tested
- Authenticating evidence pointers, commands, commits, or artifact digests
- Whole-file adapter generation or unmarked-file rewrites
- Automatic writes from CI or protected workflow mutation by the renderer
- Network access, telemetry, hosted dashboards, or remote claim refresh
- Full native PowerShell maintenance/catalog/tracker implementation
- Native PowerShell registry publish
- Replacing detailed workflow Markdown, the Compatibility Contract, Network Matrix, or `docs/Master-Plan.md`
- Fixing historical update documents that are explicitly labeled snapshots

### 1.5 Brownfield Drift Baseline

| Field | Current evidence and intended delta |
| ------- | ------------------------------------- |
| User outcome and ship proof | Current product truth depends on repeated prose and file counts. DEV-118 ships only when the canonical contract, case-sensitive path fixture, 19 × 6 adapter checks, Windows fixtures, claim freshness checks, and adjacent regressions are green. |
| Repo evidence inventory | `lib/config.sh`; `lib/generate.sh`; `agtoosa.sh`; `agtoosa.ps1`; `bootstrap.sh`; `bootstrap.ps1`; six `template/` native command trees; `template/Docs/`; README; Compatibility, Network, Readiness, enforcement, and Team Trust docs; DEV-094/102/105 specs; PN/WP/ACC/NET/PSP/CORE bats. |
| Generated-path baseline | A raw current scan finds 337 lowercase `docs/` occurrences across 20 `template/Docs/` files, including 244 across the five central lifecycle docs. Raw matches include intentional contexts, so every exception must be classified rather than globally replaced. |
| Adapter baseline | Each of six native command surfaces contains 19 files; WP2 still expects 18. Canonical quick mode caps at two questions while Gemini/Copilot say three and Claude says two-to-three. Codex skills are a separate auxiliary layer with explicit gaps. |
| Platform baseline | Bash exposes distinct `copilot` and `vscode` install identities; PowerShell maps `vscode` to `copilot`. Public rows also conflate Gemini/Jules and Codex/OpenCode beyond surface-specific evidence. |
| Windows/dependency baseline | `bootstrap.ps1` requires and launches Git Bash; several PowerShell operations delegate to Bash; registry publish redirects; jq requirements differ by backend; Python is used by important JSON/merge paths but is absent from the global requirements story; current CI Markdown lint uses Node/npm and may fetch over the network; the pinned README snippet does not bind its ref. |
| Public-claim baseline | README contains stale backlog rows, duplicate Windows tips, under-described installed surfaces, and unsupported “fully supported,” “only,” enforcement, any-assistant, and zero-downtime wording. Canonical trust docs do not share one freshness-bound ledger. |
| Intended deltas | Add inert contract/schema; bounded renderer/checker; repair classified casing/semantic/platform drift; correct pin/preflight behavior; add per-operation backend truth; govern claims with 90-day freshness; wire focused CI. |
| Source-of-truth boundary | `docs/Master-Plan.md` remains lifecycle authority. The Product Truth Contract is authoritative only for modeled product facts and never for story state. |

**Classified generated-path candidate set (20 files at draft time):**

```text
template/Docs/AgToosa_Agent.md
template/Docs/AgToosa_Build.md
template/Docs/AgToosa_CrossModelReview.md
template/Docs/AgToosa_Dashboard.md
template/Docs/AgToosa_GovernancePolicy.md
template/Docs/AgToosa_MetricsKit.md
template/Docs/AgToosa_Network_Matrix.md
template/Docs/AgToosa_Orchestration.md
template/Docs/AgToosa_Readiness.md
template/Docs/AgToosa_Registry.md
template/Docs/AgToosa_Retro.md
template/Docs/AgToosa_Review.md
template/Docs/AgToosa_Ship.md
template/Docs/AgToosa_Spec.md
template/Docs/AgToosa_Update.md
template/Docs/SPEC-FORMAT.md
template/Docs/agtoosa-dashboard.sh
template/Docs/agtoosa-gate.yml.example
template/Docs/agtoosa-policy-check.sh
template/Docs/agtoosa-verify.sh
```

If build-time inventory finds another affected file, the approved scope must be amended before editing it.

### 1.6 Claim Boundary

| Control | Classification |
| --------- | ---------------- |
| Corrected templates copied into downstream `Docs/` paths | generator-enforced |
| Windows ref validation, dependency preflight, and Bash/PowerShell platform identity behavior | generator-enforced |
| Product Truth schema, adapter/path/claim checks, managed-block comparison, and regressions when wired to required CI | CI-enforced |
| Running `render --apply`, reviewing evidence, assigning claim owners, and refreshing dates | manual |
| Detailed platform workflow prose outside managed blocks | agent-instructed plus CI-checked portable invariants |
| Assistant recognition and Scenario behavior | roadmap — DEV-121 |
| Evidence authenticity and execution-bound provenance | roadmap — DEV-120 |
| Hosted validation, automatic network refresh, or native sandbox enforcement | roadmap / out of scope |

## 2. Design

### 2.1 Architecture Blueprint

**Files to create during build:**

| File | Responsibility |
| ------ | ---------------- |
| `contracts/product-truth-v1.json` | Canonical commands, targets, platform identities, path policy, dependencies, backend classes, claims, and managed projections. |
| `contracts/product-truth-v1.schema.json` | Closed v1 shape, bounds, enums, identifiers, path formats, and namespaced extension rules. |
| `scripts/product-truth.py` | Python-standard-library `check`, `render --check`, and explicit `render --apply`; no subprocess, eval, dynamic import, network, or implicit writes; keep the entry point at or below 500 lines or split cohesive modules before review. |
| `tests/product-truth.bats` | Focused PTC positive/negative contract suite. |
| `tests/fixtures/product-truth/` | Tampered schema, inventory, adapter, casing, claim, identity, dependency, and Windows-ref fixtures. |

**Modeled contract sections:**

| Section | Required facts |
| --------- | ---------------- |
| Root | `$schema`, `schema_version`, `contract_id`, `contract_version`, `path_policy`, `commands`, `targets`, `platforms`, `dependencies`, `claims` |
| Command | ID, phase, invocation, modes, canonical workflow ref, operating context, question budget, state reads/writes, side effects, dependencies, failure policy, approval gate, next phase, portable invariants |
| Target | Stable target ID, format/version, artifact kinds, output paths, renderer/version, supported/unsupported fields, namespaced extensions |
| Platform | Install token, target associations, preserved identity, aliases, evidence inheritance boundary |
| Dependency | ID, affected operations/platforms, command names, version constraint when proven, preflight probe, missing behavior, backend classification |
| Claim | Capability/target IDs, status, owner, evidence class/ref, evidence commit/tool version when known, governed surfaces, owner-contract ID/fingerprint, verified/expiry dates, verifier version, notes |

`owner_contract_id` resolves to one local modeled command, target, platform, dependency, or path-policy object. The checker recomputes `owner_contract_fingerprint` as SHA-256 over that object's canonical UTF-8 JSON (sorted keys, stable separators, and no claim freshness fields); a mismatch invalidates freshness without fetching evidence or implying lack of support.

**Stable native target IDs:**

1. `cursor.project-commands`
2. `windsurf.workflows`
3. `anthropic.claude-code`
4. `google.gemini-cli`
5. `github.copilot-vscode`
6. `openai.codex-cli`

Jules, Copilot Cloud, OpenCode, and other adjacent products receive separate unverified claim identities if retained publicly; they do not inherit evidence from the six command targets.

**Files/directories expected to change during build:**

- Six native command trees under `template/`
- Classified generated references under `template/Docs/`
- `README.md`, `docs/AgToosa_Compatibility_Contract.md`, `docs/AgToosa_Network_Matrix.md`, `docs/AgToosa_Readiness.md`, `docs/enforcement-comparison.md`, `docs/AgToosa_Team_Trust_Roadmap.md`, and applicable template mirrors
- `bootstrap.ps1`, targeted `bootstrap.sh`, `agtoosa.sh`, `agtoosa.ps1`, and `lib/config.sh` parity/preflight surfaces
- `.github/workflows/ci.yml`, `tests/agtoosa.bats`, and the new focused test suite
- `docs/Master-Architecture.md` and maintainer `docs/Context/CONTEXT.md` for the new product-maintenance boundary; no Product Truth architecture/domain content is copied into downstream project templates

### 2.2 Data Flow

1. A maintainer changes a modeled command, target, dependency, backend classification, path rule, or public claim in the canonical JSON.
2. `product-truth.py check` loads bounded JSON, validates the closed shape and security rules, and builds normalized command/target/platform/claim indexes.
3. The checker inventories tracked native files and configuration, requiring every current command × target cell or an explicit artifact-kind exception.
4. Extractors normalize managed fields and portable invariants from Markdown/TOML adapters; five lifecycle extractors additionally compare deep semantic goldens.
5. Path validation resolves generated local references against exact tracked/generated casing and applies only owner-tagged, reasoned exemptions.
6. Dependency and backend validation compares Bash/PowerShell help, preflight, install identities, and public matrices.
7. Claim validation evaluates governed IDs against an injected `--as-of` date, owning-contract fingerprints, evidence class, and 90-day expiry; it never fetches the pointer.
8. `render --check` derives managed blocks and tables in memory and reports drift. CI stops here and never writes.
9. An explicit maintainer `render --apply` updates existing marked regions only; a second `render --check` must be clean.
10. Focused PTC tests and adjacent regressions gate merge. Static success is labeled conformance/freshness only.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
| -------- | ---------- | ------------ |
| Crafted contract injects commands or reads environment/secrets | Elevation of Privilege / Information Disclosure | Closed schema; inert stdlib loader; forbid interpolation, dynamic includes/imports, subprocess, environment expansion, and secret-shaped embedded values. |
| Repository path escapes through absolute paths, `..`, or symlinks | Tampering | POSIX relative path grammar; canonical root resolution; reject symlink escape before read/write. |
| Renderer overwrites target-specific or protected content | Tampering | Existing managed markers only; explicit apply; scope allowlist; atomic diff preview; CI check-only. |
| False support identity inherits evidence across adjacent products | Spoofing | Stable surface-specific IDs; explicit non-inheritance; stale/unverified downgrade. |
| Claim owner disputes verification history | Repudiation | Owner, evidence reference, evidence commit/tool version, deterministic dates, and reviewable contract diff. |
| Malformed or huge JSON/regex causes resource exhaustion | Denial of Service | File/entry/string bounds; no contract-supplied regex; single-pass indexes; deterministic maximum findings. |
| “Pinned” ref injects shell syntax or silently selects `main` | Tampering / Elevation of Privilege | Strict ref grammar, argument binding without string evaluation, fail-closed archive selection fixtures. |
| Static conformance is marketed as assistant behavior or provenance | Spoofing | AC-011 claim boundary; DEV-120/121 ownership; forbidden-claim scan. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `contracts/product-truth-v1.json`, `contracts/product-truth-v1.schema.json`, `scripts/product-truth.py`, `tests/product-truth.bats`, `tests/agtoosa.bats`, `.github/workflows/ci.yml`, `bootstrap.sh`, `bootstrap.ps1`, `agtoosa.sh`, `agtoosa.ps1`, `lib/config.sh`, `README.md`, the six governed trust documents and three named template mirrors in PKG-5.1, the 20 classified generated-path files named by the DEV-118 baseline, `docs/Master-Architecture.md`, `docs/Context/CONTEXT.md`, ADR-015–ADR-017, and DEV-118 spec/test/evidence records
Directories in scope: `contracts/`, `tests/fixtures/product-truth/`, `template/.claude/commands/`, `template/.cursor/commands/`, `template/.gemini/commands/`, `template/.github/prompts/`, `template/.windsurf/workflows/`, `template/.codex/prompts/`
Out of scope        : new adapters, assistant execution, DEV-120 provenance, DEV-121 conformance lab, full PowerShell rewrite, registry publish parity, hosted/network validator, telemetry, automatic CI writes, whole-file adapter generation, unrelated historical snapshots

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Authority and RED baseline: establish the contract boundary before implementation.
  - [x] 1.1 Implement accepted ADR-015–ADR-017 through the closed schema and canonical Product Truth Contract with the corrected 19-command baseline — _Requirements: AC-001, AC-002, AC-006, AC-007, AC-009, AC-011_
  - [x] 1.2 Add PTC positive/tampered fixtures and capture a real RED run for every Must AC before product fixes — _Requirements: AC-001 through AC-012_
- [x] **2.** Deterministic checker and bounded renderer: implement inert validation and managed projections.
  - [x] 2.1 Implement `check`, `render --check`, and explicit managed-block `render --apply` with stable diagnostics, injected clock, path bounds, and no execution/network behavior — _Requirements: AC-001, AC-003, AC-009, AC-010, AC-011_
- [x] **3.** Generated paths and adapters: repair cross-surface truth.
  - [x] 3.1 Classify and repair generated `Docs/` references with owner-tagged exemptions and a case-sensitive generated fixture — _Requirements: AC-005_
  - [x] 3.2 Add managed adapter fields, dynamic 19 × 6 inventory checks, universal portable invariants, five lifecycle goldens, and explicit auxiliary-layer exceptions — _Requirements: AC-002, AC-003, AC-004, AC-006_
- [x] **4.** Windows and operation dependencies: correct behavior before correcting claims.
  - [x] 4.1 Fix PowerShell release-ref binding/validation and prove fail-closed archive selection with deterministic fixtures — _Requirements: AC-008, AC-011_
  - [x] 4.2 Reconcile Bash/PowerShell install identities; add per-operation backend/dependency preflight and consistent human/machine facts — _Requirements: AC-006, AC-007_
- [x] **5.** Public product truth: derive and validate evidence-bounded claims.
  - [x] 5.1 Add claim-ledger ownership/freshness, render governed tables/blocks, correct current public contradictions, and add the unsupported-absolute scan — _Requirements: AC-009, AC-010, AC-011_
- [x] **6.** Architecture, CI, and evidence: integrate without displacing the active cycle.
  - [x] 6.1 Update maintainer Master Architecture and domain language with the Product Truth boundary and claim classifications, without installing maintainer-only concepts downstream — _Requirements: AC-001, AC-006, AC-007, AC-009, AC-011_
  - [x] 6.2 Wire check-only CI; finalize PTC and adjacent regression coverage; record RED/GREEN and analyzer evidence with 100% AC mapping — _Requirements: AC-012_

### Wave Plan

**Wave 1 (sequential authority):** 1.1
**Wave 2 (RED after Wave 1):** 1.2
**Wave 3 (checker after RED):** 2.1
**Wave 4 (parallel after Wave 3):** 3.1, 3.2, 4.1, 4.2
**Wave 5 (parallel after Wave 4):** 5.1, 6.1
**Wave 6 (integration after Wave 5):** 6.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-118.md`
AC coverage: 12 Must ACs mapped to PTC-001 through PTC-012
Smoke set: at least one `@smoke` path per Must AC

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
| ------------ | ------ | ------------ | ------------- | -------- | --------- | ------------- | -------------- |
| PKG-1.1 | 1 | — | `contracts/` | Approved DEV-118 spec and accepted ADR-015–ADR-017 | Schema and canonical contract | 1 | `python3 -m json.tool contracts/product-truth-v1.json >/dev/null && python3 -m json.tool contracts/product-truth-v1.schema.json >/dev/null` |
| PKG-1.2 | 2 | PKG-1.1 | `tests/product-truth.bats`, `tests/fixtures/product-truth/` | Contract/schema | PTC RED corpus and evidence | 2 | `test -s tests/product-truth.bats && test -d tests/fixtures/product-truth` |
| PKG-2.1 | 3 | PKG-1.1, PKG-1.2 | `scripts/product-truth.py` | Contract, schema, RED fixtures | Inert checker and bounded renderer | 3 | `bats tests/product-truth.bats -f 'PTC-00[139]' && bats tests/product-truth.bats -f 'PTC-01[01]'` |
| PKG-3.1 | 4 | PKG-2.1 | `template/Docs/**` | Path policy | Correct generated casing and exemptions | 4 | `bats tests/product-truth.bats -f 'PTC-005'` |
| PKG-3.2 | 4 | PKG-2.1 | `template/.claude/commands/**`, `template/.cursor/commands/**`, `template/.gemini/commands/**`, `template/.github/prompts/**`, `template/.windsurf/workflows/**`, `template/.codex/prompts/**` | Command/target contract | Managed fields, 19 × 6 invariants, lifecycle goldens | 4 | `bats tests/product-truth.bats -f 'PTC-00[2346]'` |
| PKG-4.1 | 4 | PKG-2.1 | `bootstrap.ps1` | Ref contract and fixtures | Safe exact-ref PowerShell bootstrap | 4 | `bats tests/product-truth.bats -f 'PTC-008'` |
| PKG-4.2 | 4 | PKG-2.1 | `bootstrap.sh`, `agtoosa.sh`, `agtoosa.ps1`, `lib/config.sh` | Dependency/platform contract | Backend preflight and identity parity | 4 | `bats tests/product-truth.bats -f 'PTC-00[67]'` |
| PKG-5.1 | 5 | PKG-3.1, PKG-3.2, PKG-4.1, PKG-4.2 | `README.md`, `docs/AgToosa_Compatibility_Contract.md`, `docs/AgToosa_Network_Matrix.md`, `docs/AgToosa_Readiness.md`, `docs/enforcement-comparison.md`, `docs/AgToosa_Team_Trust_Roadmap.md`, `template/Docs/AgToosa_Compatibility_Contract.md`, `template/Docs/AgToosa_Network_Matrix.md`, `template/Docs/AgToosa_Readiness.md` | Claim ledger and corrected product behavior | Fresh managed claims and absolute scan | 5 | `bats tests/product-truth.bats -f 'PTC-009' && bats tests/product-truth.bats -f 'PTC-01[01]'` |
| PKG-6.1 | 5 | PKG-3.1, PKG-3.2, PKG-4.2 | `docs/Master-Architecture.md`, `docs/Context/CONTEXT.md` | Implemented contract boundary | Maintainer architecture/domain references | 5 | `rg -n 'Product Truth Contract' docs/Master-Architecture.md docs/Context/CONTEXT.md && rg -n 'Backend classification' docs/Master-Architecture.md docs/Context/CONTEXT.md` |
| PKG-6.2 | 6 | PKG-5.1, PKG-6.1 | `.github/workflows/ci.yml`, `tests/product-truth.bats`, `tests/agtoosa.bats`, `docs/AgToosa_TestPlan-DEV-118.md` | All prior outputs | CI gate, regression proof, RED/GREEN evidence | 6 | `bats tests/product-truth.bats && bash docs/agtoosa-verify.sh --root .` |

### 3.5 Story Skill Opportunity

No story-specific skill will be generated. A deterministic, repeatable checker plus CI gate is the appropriate reusable mechanism; AgToosa's existing lifecycle skills already route specification, build, review, and ship work.

## Capability Delta

Capability: product-truth

| Change | Requirement | Notes |
| -------- | ------------- | ------- |
| Canonical product facts | AC-001, AC-002 | Maintainer-only inert JSON; Master Plan authority unchanged. |
| Adapter semantic conformance | AC-003, AC-004 | Static invariants, not Scenario behavior. |
| Generated path correctness | AC-005 | Context-aware exact casing with reasoned exemptions. |
| Platform and dependency truth | AC-006 through AC-008 | Per-operation backend labels; no pure PowerShell rewrite. |
| Fresh public claims | AC-009 through AC-011 | Ninety-day freshness; no provenance claim. |
| Required proof | AC-012 | Focused CI plus adjacent regressions. |

## Spec Revision Log

| Revision | Date | Change | Reason | Approval |
| ---------- | ------ | -------- | -------- | ---------- |
| R0 | 2026-07-14 | Initial decision-complete draft; correct stale 18-command assumption to verified 19-command inventory | User approved every-current-command coverage; repository audit established the actual count | Approved 2026-07-14 18:31 |

## Approval Gate

Approval was recorded on 2026-07-14. DEV-118 enrolled on `main` 2026-07-22 after DEV-117 shipped v5.3.29; isolated branch `codex/dev-118` retains exploratory RED evidence only.

## ✅ Spec Approved

Approved: 2026-07-14 18:31
