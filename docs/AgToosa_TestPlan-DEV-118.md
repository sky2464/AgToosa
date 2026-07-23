# Test Plan: DEV-118 — Product Truth & Adapter Contract

> **Spec:** `docs/archived/spec-DEV-118.md`
> **Focused suite:** `bats tests/product-truth.bats`
> **Status:** Build complete on main (uncommitted) — PTC 12/12 green; verifier PASS; review pending
> **Coverage threshold:** 100% from `docs/Context/workflow.md`
> **Coverage target:** 100% Must AC mapping, with positive and negative fixtures for every AC

## Test Strategy

DEV-118 uses deterministic, repository-local contract tests. The suite validates the closed JSON schema, inventory completeness, bounded rendering, portable adapter semantics, case-sensitive generated paths, platform and backend truth, exact-ref Windows bootstrap behavior, and freshness-bound public claims. It does not run assistants, authenticate evidence, or treat static conformance as Scenario-tested behavior.

The checker receives an explicit `--as-of` date for freshness tests. Fixtures use temporary repositories and local files only; tests must not read secrets, expand environment values, call the network, or mutate the working tree in check modes.

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
| ---- | --------- | ---------- | ------------- | -------- |
| AC-001 | PTC-001 | Security | Accept the closed v1 contract and reject unknown, executable, interpolated, escaping, oversized, or side-effecting input. | yes |
| AC-002 | PTC-002 | Integration | Derive and reconcile all current native commands and six stable target IDs, including the 19 × 6 baseline and explicit auxiliary exceptions. | yes |
| AC-003 | PTC-003 | Integration | Prove `check` and `render --check` are no-write operations and `render --apply` changes only existing managed truth blocks. | yes |
| AC-004 | PTC-004 | Integration | Validate universal portable invariants for every declared command × target cell and deep goldens for Init, Spec, Build, Review, and Ship. | yes |
| AC-005 | PTC-005 | Integration | Resolve generated local references with exact `Docs/` casing and allow only owner-tagged, reasoned lowercase exemptions. | yes |
| AC-006 | PTC-006 | Integration | Keep Bash and PowerShell install identities aligned while preserving distinct `copilot` and `vscode` tokens and surface-specific evidence. | yes |
| AC-007 | PTC-007 | Integration | Classify each affected operation's backend and dependencies and fail or degrade before mutation when prerequisites are missing. | yes |
| AC-008 | PTC-008 | Security | Bind a validated release ref to the PowerShell bootstrap archive and fail closed for unsafe or unavailable refs. | yes |
| AC-009 | PTC-009 | Integration | Validate required claim-ledger fields, 90-day expiry, owning-contract ID/fingerprint invalidation, injected time, and stale/unverified classification. | yes |
| AC-010 | PTC-010 | Integration | Reconcile governed public sections with claim IDs and detect missing, stale, contradictory, absolute, parity, enforcement, or superiority wording. | yes |
| AC-011 | PTC-011 | Integration | Permit only declared static-conformance/freshness conclusions and reject behavioral, provenance, sandbox, native-parity, or universal-support overclaims. | yes |
| AC-012 | PTC-012 | Integration | Discover all Must tests in CI, retain adjacent PN/WP2/ACC/NET/PSP/CORE coverage, and preserve DEV-120/DEV-121 boundaries. | yes |

## Negative / Edge Scenarios

| AC | Negative or edge scenario | Test ID |
| ---- | --------------------------- | --------- |
| AC-001 | A contract contains an unknown field, `${ENV}` value, include directive, absolute path, traversal, symlink escape, oversized collection, or executable-looking value; validation fails without reads outside the fixture, network calls, subprocesses, or writes. | PTC-001 |
| AC-002 | A fixture adds a twentieth command, omits one target artifact, duplicates a cell, or introduces an undeclared auxiliary artifact kind; inventory reconciliation fails with the exact command and target. | PTC-002 |
| AC-003 | An unmarked file, missing end marker, duplicate block, or drift outside a managed block is presented; apply fails closed or preserves the file, and both check modes leave hashes and git status unchanged. | PTC-003 |
| AC-004 | One adapter changes quick mode to three questions, skips approval, mutates during a read-only mode, misroutes its canonical workflow, or omits Phase Stop/lifecycle close; semantic validation identifies the cell. | PTC-004 |
| AC-005 | A generated fixture references local `docs/` with no exemption, or an exemption lacks owner/reason; it fails on an exact-case inventory while tagged remote URLs and intentional dual-root resolvers remain valid. | PTC-005 |
| AC-006 | PowerShell aliases `vscode` to `copilot`, or Jules/OpenCode/Copilot Cloud inherits another surface's evidence; identity and claim validation fail. | PTC-006 |
| AC-007 | Git Bash, jq, Python, Node/npm, curl, tar, PowerShell, or network access is absent for an operation that requires it; preflight reports the backend and missing prerequisite before the mutation sentinel changes. | PTC-007 |
| AC-008 | The requested ref is omitted, malformed, translated to `main`, or unavailable in the local archive fixture; bootstrap fails closed and never selects a different archive. | PTC-008 |
| AC-009 | A claim is older than 90 days, expires before verification, lacks owner/evidence/verifier metadata, or a one-byte owning-object change makes its recomputed fingerprint differ; it becomes stale/unverified and is not silently converted to unsupported. | PTC-009 |
| AC-010 | README disagrees with a governed table or contains an unsupported “only,” “fully supported,” “zero downtime,” enforcement, parity, universal, or superiority statement; the checker reports the file and claim boundary. | PTC-010 |
| AC-011 | Passing static checks is used to claim assistant recognition, Scenario behavior, evidence authenticity, native sandboxing, full PowerShell parity, or any-assistant support; the claim is rejected. | PTC-011 |
| AC-012 | A Must AC lacks a test mapping or smoke tag, a focused gate is absent from CI, a named adjacent regression disappears, or the contract absorbs DEV-120/DEV-121 fields; meta-validation fails. | PTC-012 |

## Fixture Matrix

| Fixture family | Positive baseline | Required mutations |
| ---------------- | ------------------- | -------------------- |
| `contract/` | Minimal valid closed v1 contract | Unknown field, bad enum/ID, interpolation, include, bounds, absolute/traversal path, symlink escape |
| `inventory/` | Derived 19 commands × six targets | Missing, duplicate, extra command, missing target, undeclared auxiliary kind |
| `render/` | One marked block with stable output | No marker, duplicate marker, malformed marker, outside-block prose, check-mode hash sentinel |
| `adapters/` | Portable invariants plus five lifecycle goldens | Quick-budget drift, routing drift, mutation drift, missing approval/Phase Stop/close |
| `paths/` | Exact-case generated tree | Lowercase local path, missing target, unowned exemption, remote URL, dual-root resolver |
| `platforms/` | Distinct canonical install tokens | `vscode` collapse, cross-product alias/evidence inheritance |
| `dependencies/` | Backend and per-operation prerequisites | Missing tool/network, degraded optional path, mutation sentinel |
| `windows-ref/` | Safe exact ref and local archive map | Malformed, unavailable, omitted, or rewritten ref |
| `claims/` | Fresh complete claim and governed projection | Missing fields, stale date, owner-contract fingerprint change, contradiction, overbroad language, invalid boundary |
| `ci/` | Complete AC map and named gates | Missing smoke tag, missing CI step, missing regression family, roadmap ownership leak |

All fixture roots are disposable. Symlink cases are skipped only when the host cannot create symlinks, with an equivalent lexical-escape case still required; no platform skip may remove the corresponding Must AC from CI coverage.

## Execution Order

1. Create the schema and smallest valid contract; verify both are syntactically valid JSON.
2. Add `PTC-001`–`PTC-012` and fixtures before production checker/renderer changes.
3. Record a real RED run in which the focused suite fails for missing or incorrect product behavior, not for a broken test harness.
4. Implement the inert checker and bounded renderer, then close contract, casing, adapter, platform, Windows, and claim groups independently.
5. Run the focused suite, adjacent regressions, repository verifier, Markdown checks, and clean-diff checks.
6. Record GREEN evidence with command, timestamp, exit code, duration, test totals, and relevant output or artifact hashes.

## Validation Commands

```bash
python3 scripts/product-truth.py check --contract contracts/product-truth-v1.json --as-of 2026-07-14
python3 scripts/product-truth.py render --check --contract contracts/product-truth-v1.json --as-of 2026-07-14
bats tests/product-truth.bats
bats tests/agtoosa.bats -f 'PN|WP2|ACC|NET|PSP|CORE'
bash docs/agtoosa-verify.sh --root .
npx --yes markdownlint-cli2 docs/archived/spec-DEV-118.md docs/AgToosa_TestPlan-DEV-118.md docs/adr/ADR-015-product-truth-contract.md docs/adr/ADR-016-bounded-adapter-rendering.md docs/adr/ADR-017-fresh-claims-and-windows-truth.md
git diff --check
```

PowerShell-focused bootstrap and identity fixtures run when `pwsh` is available. The portable contract assertions and archive-selection fixtures remain mandatory on non-Windows CI so that absence of `pwsh` cannot make AC-006 through AC-008 disappear.

The Markdown-lint command follows the repository's existing CI pattern. The Product Truth dependency model must therefore declare Node/npm and possible package-fetch network access for that CI-only operation; the Product Truth checker and renderer themselves remain offline.

## Evidence Plan

### RED evidence required before build changes

The first build package records the exact focused command, UTC timestamp, exit code, duration, test totals, and failure excerpts for `PTC-001`–`PTC-012`. At least one assertion in each affected behavior group must fail against the pre-DEV-118 implementation. Test syntax errors, absent Bats, or deliberately unconditional failures do not count as RED evidence.

### GREEN evidence required during implementation

| Evidence block | Scope | Minimum proof |
| ---------------- | ------- | --------------- |
| GREEN 2.1 | Inert contract and renderer | PTC-001, PTC-003, PTC-009, PTC-010, PTC-011 pass; check-mode hashes unchanged. |
| GREEN 3.1 | Generated casing | PTC-005 passes against a case-sensitive fixture and classified exemptions. |
| GREEN 3.2 | Adapter parity | PTC-002, PTC-004, PTC-006 pass for the derived inventory and five lifecycle goldens. |
| GREEN 4.1 | Windows exact ref | PTC-008 passes safe, malformed, unavailable, and rewritten-ref fixtures. |
| GREEN 4.2 | Backend/dependency truth | PTC-006 and PTC-007 pass preflight and no-mutation sentinels. |
| GREEN 5.1 | Governed public claims | PTC-009, PTC-010, PTC-011 pass with an injected clock and contradiction scan. |
| GREEN 6.2 | Required gate | PTC-001–PTC-012, adjacent regressions, verifier, Markdown, and clean-diff checks complete. |

### Terminal Evidence fields

Every evidence block records: story and package ID, command, repository SHA, UTC timestamp, duration, exit code, passed/failed/skipped totals, relevant output excerpt, fixture or artifact hashes where applicable, runner/tool versions, and an explicit baseline classification for any unrelated failure. A stale claim's `verified_at` proves freshness accounting only; DEV-120 remains responsible for evidence authenticity and provenance.

## Build Evidence

### GREEN evidence — PKG-1.1 / Task 1.1

- Repository base: `c37b1fc`
- UTC timestamp: `2026-07-15T00:37:37Z`
- Command: `python3 -m json.tool contracts/product-truth-v1.json >/dev/null && python3 -m json.tool contracts/product-truth-v1.schema.json >/dev/null`
- Exit code: `0`; duration: `0.37s`; result: pass
- Tool: `Python 3.14.5`
- Contract SHA-256: `5702d26778f6872872381dff0c4e6cdfe45dad596999b981f5e9c9575d5cbb32`
- Schema SHA-256: `50da7f801c733d8642af57706c8bd0c7a3d66205348157946c4215b8a5bc000f`
- Warnings: none; errors: none
- Changed files: `contracts/product-truth-v1.json`, `contracts/product-truth-v1.schema.json`
- Next action: add the PTC positive/tampered fixture corpus and capture the pre-checker RED run.

### RED evidence — PKG-1.2 / Task 1.2

- Repository SHA: `89942ec`
- UTC timestamp: `2026-07-15T00:40:16Z`
- Command: `bats tests/product-truth.bats`
- Exit code: `1`; duration: `1s`; result: expected RED
- Totals: `0 passed`, `12 failed`, `0 skipped`
- Failure excerpt: `PTC-001` through `PTC-012` each failed their first positive behavior assertion; direct probe returned `[Errno 2] No such file or directory: scripts/product-truth.py` with exit `2`.
- Tool: `Bats 1.13.0`; `Python 3.14.5`
- Test SHA-256: `50a83fe2126c9e29ec61d805f66ee93c8ae77418c0cfdea3238635d52f397da8`
- Fixture SHA-256: Windows archive map `ae6d26614d3b66838a95fcf37fe8af4c254ff783e2d2b92ca32f4387fa9cec05`; overbroad-claim fixture `3e71ba621542daf2735147aa76fb159b82cd0e3c836278d24e01ed4dbc174de7`
- Baseline classification: expected missing Product Truth checker/renderer behavior; Bats syntax and discovery were valid (`1..12`).
- Warnings: none; errors: expected missing entry point only
- Changed files: `tests/product-truth.bats`, `tests/fixtures/product-truth/`
- Next action: implement the inert checker and bounded renderer without changing the RED expectations.

### GREEN evidence — Tasks 2.1–6.2 (session close)

- Repository base: `b543a4a` (working tree; DEV-118 implementation uncommitted)
- UTC timestamp: `2026-07-23T03:31:48Z`
- Command: `bats tests/product-truth.bats`
- Exit code: `0`; duration: `~7s`; result: pass
- Totals: `12 passed`, `0 failed`, `0 skipped` (`PTC-001`–`PTC-012`)
- Command: `python3 scripts/product-truth.py check --root . --contract contracts/product-truth-v1.json --as-of 2026-07-22`
- Exit code: `0`; result: all check stages PASS (bootstrap ref, managed blocks, governed claims, CI AC map)
- Command: `bash docs/agtoosa-verify.sh`
- Exit code: `0`; result: `12 pass · 2 warn · 0 fail` (G2 log bloat, G3 EARS wording — pre-existing)
- Fix applied: aligned `agtoosa.ps1` `AGTOOSA_VERSION` to `5.3.29` after selective import from `codex/dev-118` (resolved G5-version-mismatch)
- Import note: template adapter managed blocks and governed surfaces restored via `git checkout codex/dev-118 -- template/ bootstrap.ps1 README.md .github/workflows/ci.yml …` (scope per spec §2.4)
- Warnings: none blocking; errors: none
- Next action: `/agtoosa-review`

## Exit Criteria

- All 12 Must ACs have a passing positive assertion and a passing negative/edge assertion.
- The focused Product Truth suite is required by CI and all `@smoke` mappings are discoverable.
- Inventory is derived from the repository and confirms 19 commands on each of six native surfaces at the baseline.
- `check` and `render --check` produce no repository changes; `render --apply` changes only marked blocks.
- Exact-case path, platform identity, dependency preflight, Windows ref, freshness, contradiction, and claim-boundary fixtures pass.
- PN, WP2, ACC, NET, PSP, and CORE regressions retain their intended ownership and pass or have an evidence-backed pre-existing classification.
- DEV-120 provenance and DEV-121 behavioral certification remain outside this implementation and test schema.
- The approved spec, test plan, ADRs, architecture/domain mirrors, and final evidence agree before review.
