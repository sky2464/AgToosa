# Changelog

All notable changes to AgToosa will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioned per [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [5.3.27] — 2026-07-12

Patch release: DEV-115 — `--cleanup` safety follow-up.

### Added

- **DEV-115 — `--cleanup` safety follow-up.** `--only backups` limits housekeeping to merge backups; preserve deep-merged `.claude/settings.json` when Claude is deselected; CLN-015–CLN-017 bats; `AgToosa_Update.md` guidance.

## [5.3.26] — 2026-07-12

Patch release: DEV-113 — Cursor intake hardening + fixture parity.

### Changed

- **DEV-113 — Cursor intake hardening.** FIX-001 exercises `scripts/cursor-intake-fixture.sh`; CIT-002–CIT-004 bats; `template/CLAUDE.md` NL Intent Map parity; install bats use `$AGTOOSA_SHIP_DIR` for ship isolation.

## [5.3.25] — 2026-07-12

Patch release: DEV-114 — `--cleanup` false-positive hotfix.

### Fixed

- **DEV-114 — `--cleanup` false positives.** Symmetric Copilot/VS Code shared-path guard (`.github/prompts`, `.github/agents`); preserve `Docs/AgToosa_TestPlan-*` story test plans; CLN-012–CLN-014 bats; `AgToosa_Update.md` cleanup guidance.

## [5.3.24] — 2026-07-12

Patch release: DEV-112 — Smart Apply UX polish + `--cleanup` + Cursor NL intent routing.

### Added

- **DEV-112 — `--cleanup` housekeeping.** `lib/cleanup.sh` removes merge backups (`*.bak.*`), orphan workflow docs, and deselected platform files; `--dry-run`, `--format json` (`cleanup-result-v1`), `--yes`; post install/upgrade offer; `--doctor` `DR-stale-files` hint; PS1 `-Cleanup` parity; `vscode` platform modeling; CLN-001–CLN-011 bats; `AgToosa_Update.md` cleanup section.
- **Smart Apply UX polish.** Quiet upgrade output (`APPLY_QUIET`); numbered platform legend with installed checkmarks; spaced `Found:` line; grouped Copilot agents line; summary pluralization; context-aware next steps; clearer merge labels; hash-aware `AgToosa_Claude.md` / `AgToosa_Gemini.md`; per-test `AGTOOSA_SHIP_DIR` for bats isolation.
- **Cursor NL intent map.** Natural-language routing for "plan and code" / "build it" in `AgToosa_Agent.md`, `agtoosa-core.mdc`, and `template/.cursorrules`; blocks Cursor native Plan mode for in-scope work.
- **Maintainer Cursor dogfood.** `.cursor/rules/agtoosa-maintainer-core.mdc`, `/agtoosa-spec` + `/agtoosa-build` commands (`docs/` paths), `scripts/cursor-intake-fixture.sh`; FIX-001 + NLM-001–NLM-006 bats.

### Changed

- `AGTOOSA_SHIP_DIR` override for isolated staging; post-install cleanup hint via `offer_cleanup_after_apply`.

## [5.3.23] — 2026-07-12

Patch release: DEV-111 — Smart One-Command Install UX.

### Added

- **DEV-111 — Smart One-Command Install UX.** Auto-detect upgrade on re-run; `Found:` platform detect + optional add; `smart_apply()` unified path; smart per-file preserve/refresh (Master-Plan, Context placeholders); human summary buckets (Updated/Preserved/Unchanged/Merged); `--force` hidden from interactive UX; PS1 parity; SAU-001–SAU-010 bats.

## [5.3.22] — 2026-07-12

Patch release: DEV-110 — AgToosa Project Intake.

### Added

- **DEV-110 — AgToosa Project Intake.** Dual-mode freeform PM classifier (soft expedite + hard gate); always-on `agtoosa-core.mdc`; Project Intake Protocol in Agent.md; Standing Corrections in `workflow.md`; ADR-013; INT-001–INT-012 bats.

## [5.3.21] — 2026-07-12

Patch release: DEV-109 — Lifecycle Next-Step Sync + Multi-Spec Clarity.

### Added

- **DEV-109 — Lifecycle Next-Step Sync + Multi-Spec Clarity.** Dual-line phase close (`Next:` lifecycle command + `SYNC:` pulse); `agtoosa.sh --status-line` and `agtoosa.ps1 -StatusLine` read-only Master-Plan parse; multi-spec intake + clarity tags (`ready` · `sa-ready` · `needs-interview`); repeating soft-cap interview budget; ADR-012; LNS-001–LNS-010 bats.

## [5.3.20] — 2026-07-12

Patch release: DEV-107 + Rev4 Wave 3 (DEV-095, DEV-096, DEV-098, DEV-099, DEV-101, DEV-102, DEV-103, DEV-104, DEV-106).

### Added

- **DEV-107 — Agent-Instructed Orchestration Brain.** Canonical `AgToosa_Orchestration.md` (inventory → lane plan → merge); step-0 hooks in Spec/Build/Review/Ship/Agent/Quickref/subagent guide; `lib/config.sh` registration; ORB-001–ORB-008 bats.
- **DEV-096 — Pack Validation CI.** `pack-validate.yml` + `scripts/validate-official-packs.sh`; manifest/SHA/fixture parity; PV-001–008 bats.
- **DEV-095 — Official Pack Expansion (5-pack max).** `official-react` + `official-security` pilots; inventory/checklist updates; OPE-001–010 bats.
- **DEV-104 — `--reinstall --clean` (ADR-004 Option C).** `lib/reinstall.sh`; archive + confirmation gate; bash/PS1 parity; RCL-001–008 bats.
- **DEV-098 — Navigation by User Job.** `docs/index.md` Start/Use/Trust/Adapt/Maintain nav; NAV-001–008 bats.
- **DEV-099 — Core vs Optional Pack Boundary.** `AgToosa_Core_Contract.md`; CORE-001–006 bats.
- **DEV-101 — Verified vs Community Pack Labeling.** Registry trust surface; TRUST-001–006 bats.
- **DEV-102 — Offline and Network-Dependency Matrix.** `AgToosa_Network_Matrix.md`; NET-001–006 bats.
- **DEV-103 — External Registry Publication Runbook.** `registry-external-publication-runbook.md`; PUB-001–007 bats.
- **DEV-106 — Built with AgToosa Showcase.** `built-with-agtoosa.md`; SHOW-001–007 bats.

## [5.3.19] — 2026-07-12

_Superseded by [5.3.20] batched ship — DEV-107 included in 5.3.20._

## [5.3.18] — 2026-07-12

Patch release: Rev4 Wave 1b/2 remainder (DEV-089, DEV-091, DEV-093, DEV-100).

### Added

- **DEV-089 — Evidence-Profile Verifier Gates.** Verifier Gate 7 after Gate 6; opt-in `.agtoosa/evidence.yml`; guided/evidenced WARN semantics; EPV-001–009 bats.
- **DEV-091 — Migration Wizard + Rollback Manifest.** MAJOR update gate; `--accept-breaking`; `.agtoosa/rollback/` manifests; MWZ-001–010 bats.
- **DEV-093 — Install State File + Lock Reconciliation.** `lib/state.sh` + `lib/lock.sh`; gitignored `.agtoosa/state.json`; STF-001–009 bats.
- **DEV-100 — Shared JSON Output for Install/Registry.** Catalog plan/info `--format json` reusing DEV-090 schema; JIO-001–007 bats.

## [5.3.17] — 2026-07-12

Patch release: Rev4 Wave 1a (DEV-086, DEV-090, DEV-105).

### Added

- **DEV-086 — Canonical Proof Product Experience.** README primary proof CTA; first-15 verifier success step; `tests/fixtures/proof-journey/`; launch-readiness proof-journey checks; PRF-001–009 bats.
- **DEV-090 — Unified Install/Update Plan Engine.** `lib/plan.sh` shared categorization; dry-run/`--format json` plan schema; Init/Update lock path `Docs/agtoosa-lock.json`; PLN-001–009 bats.
- **DEV-105 — PowerShell Maintain + Update Parity.** `-Verify`/`-Doctor`/`-Uninstall`; `-Update` delegates to bash `run_update`; Pester maintain suite; PSP bats.

## [5.3.16] — 2026-07-12

Patch release: Rev4 Wave 2 (DEV-092, DEV-094, DEV-097).

### Added

- **DEV-092 — Transactional Apply + Idempotency.** `lib/apply.sh` staging/hash-skip/summary helpers; install/update Docs path uses `apply_copy_if_changed`; TAP-001–008 bats.
- **DEV-094 — Assistant Compatibility Contract.** `AgToosa_Compatibility_Contract.md` Install/Render/Scenario tiers; AgentCapability cross-link (no matrix merge); ACC-001–008 bats.
- **DEV-097 — Framework Supply-Chain Threat Model.** `docs/security/framework-supply-chain-threat-model.md` + security README index; honest soft-warn signing boundary; FST-001–006 bats.

## [5.3.15] — 2026-07-12

Patch release: Rev4 Wave 1b (DEV-087, DEV-088).

### Added

- **DEV-087 — Delivery Evidence Contract + Profiles.** `AgToosa_Delivery_Evidence_Contract.md`; `.agtoosa/evidence.yml.example` + config index README; schema-only `agtoosa-evidence-profile-check.sh`; DEC-001–009 bats. Full profile gate enforcement remains DEV-089.
- **DEV-088 — Verifier and Doctor Machine Output.** `verify-result-v1` JSON schema; `agtoosa-verify.sh` / doctor `--format json`; Problem/Impact/Fix human findings; gate JSON step; VFJ-001–010 bats. VF-001/002 regression retained.

## [5.3.14] — 2026-07-11

Patch release: DEV-051 Tracker Sync Bridge.

### Added

- **DEV-051 — Tracker Sync Bridge.** `lib/tracker.sh` + `--tracker export|propose` CLI; `AgToosa_TrackerSync.md`; provider-neutral schema; six platform adapters; TS-001–TS-008 bats. Local export + proposal-only import — no live API sync.

## [5.3.13] — 2026-07-11

Patch release: post-ship hygiene (DEV-085).

### Changed

- **DEV-085 — Post-v5.3.12 release hygiene.** Restores ship-regression bats coverage (`bb8a8bd`) and reconciles `docs/Master-Plan.md` Completed This Cycle / Update Log / Epics after v5.3.12 ship drift.

## [5.3.12] — 2026-07-11

Patch release: wave 4 (DEV-058).

### Added

- **DEV-058 — Local Dashboard.** `agtoosa-dashboard.sh` Markdown/HTML stdout-only projection; `AgToosa_Dashboard.md`; DB-001–DB-008 bats. Read-only local; no hosted/CDN/telemetry.

## [5.3.11] — 2026-07-11

Patch release: wave 3 (DEV-052, DEV-056).

### Added

- **DEV-052 — Hook Automation Pack.** `AgToosa_Hooks.md`, Init/Update preview+approval, secret-safe exemplar, HK-001–HK-007 bats. No silent hook install.
- **DEV-056 — Retrospective Learning Loop.** `AgToosa_Retro.md` structured ship retro; proposal routing only via task/spec/amend; RL-001–RL-008 bats. No telemetry/ML/auto-enrollment.

## [5.3.10] — 2026-07-11

Patch release: wave 2 dependents (DEV-046, DEV-059).

### Added

- **DEV-046 — Optional Worktree Isolation.** `AgToosa_Worktree.md` dual-path; Build/Handoff/Import wiring; WT-001–WT-006 bats. Optional/agent-instructed (no automatic git worktree execution).
- **DEV-059 — Governance Policy-as-Code.** `AgToosa_GovernancePolicy.md`, inert example, deterministic checker, Handoff Applicable Policy, optional verifier WARN; GP-001–GP-009 bats. Missing policy stays healthy.

## [5.3.9] — 2026-07-11

Patch release: remaining-specs fan-out wave 1 (DEV-045, DEV-076, DEV-077, DEV-079, DEV-080, DEV-082, DEV-083, DEV-084).

### Added

- **DEV-045 — Work Package Wave DAG.** Normative `### 3.4 Work Package DAG` schema; Spec/Build/Handoff/Import wiring; DAG-001–DAG-007 bats. Agent-instructed dispatch (no runtime scheduler).
- **DEV-076 — Static Documentation Site Proof (spike).** Jekyll/Pages build-only proof from canonical `docs/`; SITE-001–SITE-008 bats; optional owner enablement.
- **DEV-077 — Authoring Guide and Onboarding Surface.** Extension + registry-pack authoring guides; Registry/README/help discovery pointers; AUTH-001–AUTH-008 bats.
- **DEV-079 — Verifier and CI Adoption Examples.** `docs/examples/verifier-ci-adoption.md`; gate/Quickref/Readiness alignment; VCA-001–VCA-009 bats.
- **DEV-080 — Official Registry Pack Pilot.** Local candidates `packs/official-{web,api,infra}`; OPP-001–OPP-010 bats; external publish manual-deferred.
- **DEV-082 — High-Assurance Signature Mode Validation (spike).** Decision **Defer**; HAS/HSV bats; no `AGTOOSA_REQUIRE_SIGNATURES`.
- **DEV-083 — Voluntary Workflow Metrics Kit.** MetricsKit + CaseStudy template; MET-001–MET-010 bats; no telemetry.
- **DEV-084 — Open-Source Sustainability Boundary.** Canonical SUPPORT.md boundary; OSS-001–OSS-007 bats; Sponsors live enablement manual-deferred.

## [5.3.8] — 2026-07-11

Patch release: four-epic parallel cycle (DEV-075, DEV-053, DEV-078, DEV-081).

### Added

- **DEV-075 — Subagent and Persona Guide Suite.** Walkthrough plus three audience guides (`docs/guides/`, `docs/examples/subagent-handoff-review.md`); README discovery; ADP-001–ADP-009 bats. Agent-instructed (not runtime-enforced).
- **DEV-053 — Extension and Preset Catalog.** `lib/catalog.sh`, `catalog/`, `--catalog` CLI, `AgToosa_Catalog.md`, three curated entries, platform adapters; PC-001–PC-008 bats.
- **DEV-078 — First-15-Minutes Maintenance Gate.** `scripts/check-launch-readiness.sh` deterministic release-pin drift checks; scoped doc pin repairs; F15-001–F15-008 bats.
- **DEV-081 — Optional Local DX Add-on Validation (spike).** `docs/spikes/DEV-081-local-dx-validation.md`; all three DX options deferred; DXV-001–DXV-008 bats; no production code.

---

## [5.3.7] — 2026-07-11

Patch release: Agent Capability Matrix (DEV-055).

### Added

- **DEV-055 — Agent Capability Matrix.** Canonical `AgToosa_AgentCapability.md` lifecycle routing matrix; Handoff/Review/Build/Help workflow hooks; Specialists cross-link; `lib/config.sh` registration; AM-001–AM-007 bats. Agent-instructed (not runtime-enforced).

---

## [5.3.6] — 2026-07-11

Patch release: Cross-Model Review Gate (DEV-050).

### Added

- **DEV-050 — Cross-Model Review Gate.** Optional writer/reviewer separation via `/agtoosa-review cross-model`; canonical `AgToosa_CrossModelReview.md`; Review Part 5 + Specialists `review` phase orchestration; Evidence `cross-model` row; GitHub `agtoosa-cross-model-reviewer` agent; CM-001–CM-007 bats. Agent-instructed (not runtime-enforced).

---

## [5.3.5] — 2026-07-08

Patch release: Signed Registry Provenance (DEV-054).

### Added

- **DEV-054 — Signed Registry Provenance.** Optional minisign soft-warn verify for registry packs and release/bootstrap sidecars; provenance schema (minisign primary, cosign documented); ADR-011; bundled pubkey path + `AGTOOSA_MINISIGN_PUBKEY`; SP-001–SP-006 bats. Private-key generation remains Manual/Deferred (M-1); fail-closed require-signatures / SBOM / cosign verify remain roadmap.

---

## [Unreleased]

---

## [5.3.4] — 2026-07-08

Patch release: Evidence Ledger (DEV-049).

### Added

- **DEV-049 — Evidence Ledger.** Canonical `/agtoosa-evidence` workflow (`AgToosa_Evidence.md`) with per-story `evidence-[id].md` schema and optional `agtoosa-evidence.jsonl` mirror; Review/Ship require ledger updates; platform adapters; EL-001–EL-005 bats. Agent-instructed (not generator/CI-enforced).

---

## [5.3.3] — 2026-07-08

Patch release: async agent handoff packs + agent result import gate (DEV-047, DEV-048).

### Added

- **DEV-047 — Async Agent Handoff Packs.** Canonical `/agtoosa-handoff` workflow (`AgToosa_Handoff.md`) exports bounded packs (story, ACs, files, allowed actions, verification, return contract); Build/Agent/Quickref wiring; platform adapters; HO-001–HO-005 bats.
- **DEV-048 — Agent Result Import Gate.** Canonical `/agtoosa-import` Import Checklist + IMPORT evidence mapping; Build external/async detection before Tracking; Ship soft readiness row; Readiness/Roadmap agent-instructed classification; IR-001–IR-005 bats.

---

## [5.3.2] — 2026-07-08

Patch release: PowerShell non-interactive install parity (DEV-074).

### Added

- **DEV-074 — PS1 non-interactive install parity.** `agtoosa.ps1` supports `-Path`, `-Platforms`, and `-Yes` for CI/devcontainer installs without TTY prompts; `ConvertTo-PlatformList` matches bash token validation; Pester suite `tests/pester/agtoosa-install.Tests.ps1` and bats DEV-074 CT-001–CT-004.

---

## [5.3.1] — 2026-07-08

Patch release: accumulated Unreleased supply-chain and install fixes.

### Fixed

- **Pack lock provenance.** Merging queued registry packs no longer writes an empty `packs` array to `Docs/agtoosa-lock.json` — metadata is snapshotted before the queue directory is removed (bash + PowerShell).
- **Re-install data loss.** `agtoosa.sh --path --yes` on an existing project no longer overwrites project-owned `Docs/Master-Plan.md` or `Docs/AgToosa_Changelog.md` (parity with `--update`).
- **Multi-root pack tarball smuggle.** Registry installs reject archives with sibling top-level directories that bypass single-pack validation.
- **npm wrapper cwd and pack queue.** `npx agtoosa` runs from the user's cwd and stages registry packs in a durable `~/.cache/agtoosa/pack-queue` (not the ephemeral extract dir).
- **Bootstrap durable pack queue.** `bootstrap.sh` exports `AGTOOSA_PACK_QUEUE_DIR` so registry pack staging survives ephemeral extract-dir cleanup (PR #64).
- **PowerShell settings.json hooks.** Claude installs deep-merge AgToosa guardrail hooks into existing `.claude/settings.json` instead of skipping or overwriting user hooks.
- **PowerShell merge containment.** `Merge-PackFromDirectory` now uses separator-aware canonical-path checks so sibling-directory prefix traps (e.g. `evil-pack` vs `evil-pack-stuff`) cannot bypass merge-time containment.

---

## [5.3.0] — 2026-06-10

MINOR release: proof engine + supply chain wave (DEV-042, DEV-043, DEV-061–DEV-073; 458 bats tests).

### Added

- **DEV-042 — Spec Quality Analyzer.** Agent-instructed checklist in `/agtoosa-spec` flags weak specs before build; claim boundaries explicit.
- **DEV-043 — Brownfield Spec Drift Baseline.** Current-state baseline step for existing codebases during spec authoring.
- **DEV-061 — Deterministic lifecycle verifier.** New `Docs/agtoosa-verify.sh` ships with every install: validates context files, Master-Plan integrity, spec approval markers, EARS acceptance-criteria structure, AC-to-test-plan mapping, threat-model presence, task tree + wave plan, review artifacts, version parity, and RED/GREEN TDD evidence — no AI, no network. Wired into the generator as `agtoosa.sh --verify [path]`; `--strict` promotes warnings; `stats` mode reports cycle analytics.
- **DEV-062 — AgToosa Gate CI template.** `Docs/agtoosa-gate.yml.example` runs the verifier on PRs/pushes; copy it to `.github/workflows/` to convert agent-instructed gates into CI-enforced checks (AgToosa never writes CI workflows automatically).
- **DEV-063 — Phase-event log + Update Log rotation.** Workflows append one JSON line per phase transition to `Docs/agtoosa-events.jsonl`; `/agtoosa-ship` rotates Update Log rows beyond 150 into `Docs/archived/updatelog-<year>.md` (rows are preserved, never lost).
- **DEV-070 — `Docs/AgToosa_Quickref.md`.** One-page command/rules contract as the cheapest context entry point; the Cursor core rule is no longer `alwaysApply` (scoped to Docs/ and `/agtoosa-*` runs); template default flips to `tdd: true`.
- **DEV-071 — Non-interactive CLI + npm wrapper.** `agtoosa.sh --path <dir> --platforms cursor,claude --yes` installs with no TTY (CI/devcontainers); new `npm/` wrapper (`npx agtoosa`) downloads the release pinned to the package version with archive-safety screening.
- **DEV-072 — Spec change control + living capability specs.** `/agtoosa-spec amend` with a `## Spec Revision Log` (Must-AC changes require re-approval); `## Capability Delta` (ADDED/MODIFIED/REMOVED) merges into living system specs under `Docs/specs/system/` at ship.
- **DEV-073 — `--doctor` and `--uninstall`.** Install diagnostics (version skew, wiring, context health) and clean removal that preserves Master-Plan, Context/, archived/, and merged entry-point files.
- **DEV-060 — Benchmark suite + enforcement comparison.** Reproducible B1–B3 challenge tasks with deterministic scoring (`docs/benchmarks/`) and a published enforcement-boundary comparison across SDD frameworks (`docs/enforcement-comparison.md`).

### Fixed

- **DEV-064 — Tar-slip hardening.** Registry pack installs and both bootstraps now scan archive member lists and reject absolute or `..` paths **before** extraction (previously validation ran post-extract); packs extract to an isolated staging dir before queueing.
- **DEV-065 — Registry pack containment.** The registry `verified` flag is enforced (unverified packs require `--allow-unverified` / `AGTOOSA_ALLOW_UNVERIFIED=1`); installs show a full content preview flagging AI-instruction surfaces before consent; packs can no longer write `.claude/settings.json`, `.claude/hooks/`, or `.github/workflows/` (denylisted at merge with re-validation and `find -L` containment); PowerShell port gains `Test-SafeTarArchive`/`Test-PackFiles`/`Test-PackPathDenied` parity.
- **DEV-066 — Pinned install chain fails closed.** `bootstrap.sh --ref vX.Y.Z` no longer falls back to a same-name branch when the tag is missing; new `--sha256 <hex>` verifies downloads; `Formula/agtoosa.rb` pins the tagged tarball + sha256 (was `branch: "main"`); releases publish versioned `bootstrap.sh`/`bootstrap.ps1` + `SHA256SUMS`; release publishing runs in a protected `release` environment; CI pins the bats tarball checksum; `bootstrap.ps1` passes the source dir via environment (quoting-injection fix).
- **DEV-067 — Workflows are executable by non-interactive agents.** RED evidence (captured failing run) is mandatory before GREEN, with evidence blocks recorded in the story test plan; WIP commits stage explicit paths (no `git add -p`); ship squash is non-interactive (`git reset --soft` + backup ref); deployment branches on documented `tech-stack.md` targets or becomes `[manual]` (never hallucinated); `/agtoosa-revert` mandates a backup branch, prefers `git revert`, and gates `reset --hard` behind explicit confirmation; `/agtoosa-build` executes the spec's Wave Plan wave by wave.
- **DEV-068 — Adapter drift.** Copilot core instructions no longer invert the PM source of truth (Master-Plan-first restored); all six entry points expose `init zoom-out` and `spec amend`; spec file naming unified on `Docs/archived/spec-[story-id].md` across Build/QA/Status/Master-Plan; stale maintainer mirrors (Linear-era Ship/Review copies) regenerated from canonical templates.
- **DEV-069 — Governance wiring.** Phase-order abort strings from `AgToosa_Governance.md` now appear in Review/Ship prerequisites; Master-Plan template gains `## Active Diagnosis` / `## Hypotheses` for `/agtoosa-debug`; ship readiness gains QA-cleared and verifier-green rows; `/agtoosa-qa` reads the correct AC heading from SPEC-FORMAT; flake detection scoped to changed tests instead of 3× full-suite runs.

---

## [5.2.7] — 2026-06-08

Patch release: DEV-041 public launch publication proof.

### Added

- **DEV-041 — Public launch publication proof.** Publish and verify anonymous access to the public repo, `v5.2.7` release, raw bootstrap files, registry index, Homebrew tap, support/community surfaces, and first-15-minute proof repository; harden release workflows to update existing releases, remove the invalid Dependency-Check folded `others` argument, and bound long-running CI setup steps.

---

## [5.2.6] — 2026-06-07

Patch release: DEV-035 through DEV-040 (387 bats tests; DEV-035–DEV-040 focused slices).

- **DEV-035-DEV-040 — Launch readiness buildout.** Add private/public launch readiness gating, PowerShell update parity, registry archive normalization, truthful launch docs and security policy refresh, distribution hardening, first-15-minutes proof walkthrough, and team trust roadmap. Focused launch spec bats DEV-035-DEV-040 pass.

---

## [5.2.6] — 2026-06-06

Patch release: DEV-035 (361 bats tests; DEV-035 PA-001–PA-003).

### Added

- **DEV-035 — PSScriptAnalyzer CI gate for agtoosa.ps1.** Add blocking `PSUseApprovedVerbs` check to `windows-smoke` with pinned PSScriptAnalyzer 1.21.0; DEV-035 PA-001–PA-003 bats green. Closes DEV-033 manual-only analyzer verification gap.

---

## [5.2.5] — 2026-06-05

Patch release: DEV-034 (358 bats tests; DEV-034 LR-001–LR-006).

### Changed

- **DEV-034 — Maintainer release-state reconciliation.** Reconcile `docs/Master-Plan.md` active cycle, backlog, and completed-cycle pointers after the `5.2.4` ship; preserve DEV-029 manual-deferred PR-path row; add focused ledger/version bats (LR-001–LR-006).

---

## [5.2.4] — 2026-06-05

Patch release: DEV-030 + DEV-033 (352 bats tests; DEV-030 T-001–T-011; DEV-033 PV-001–PV-003).

### Fixed

- **DEV-030 — `/agtoosa-update` self-target uncertainty.** Stage 1a operating-context detection in canonical `AgToosa_Update.md` (template + maintainer mirror); Maintainer Dogfood stop-before-Apply; extended Bash/PowerShell self-target guidance including interactive install path. Bats DEV-030 T-001–T-011 green; DEV-027 T-001–T-009 regression green.

- **DEV-033 — agtoosa.ps1 approved PowerShell verbs.** Rename script-private helpers to `Copy-StageFiles`, `Initialize-PackQueueDir`, and `Move-ShipPacksToQueue`; update audit doc reference; DEV-033 PV-001–PV-003 bats green.

---

## [5.2.3] — 2026-05-25

Patch release: DEV-031 (344 bats tests; DEV-031 T-001–T-015).

### Added

- **DEV-031 — Project-specific specialist subagents.** Canonical `Docs/AgToosa_Specialists.md`; init Phase E specialist discovery + Phase F skill discovery; update Specialist Compatibility Check; spec step 1a orchestration; Codex init/update/spec skill routing; ADR-010 Accepted. Bats DEV-031 T-001–T-015 green; K4 regression pass.

---

## [5.2.2] — 2026-05-25

Patch release: DEV-032 (patch-first release cadence; DEV-032 VP-001–VP-005).

### Added

- **DEV-032 — Patch-first release versioning (5.x line).** ADR-005 default PATCH bumps on the active MINOR train; bump decision tree in `docs/agtoosa-maintainer.md`, `docs/AgToosa_Ship.md`, `docs/AgToosa_Review.md`, and template mirrors; Master-Plan Milestone tracks next PATCH. Bats DEV-032 VP-001–VP-005 green.

---

## [5.2.1] — 2026-05-25

Patch release: DEV-029 (329 bats tests; DEV-029 T-001–T-005).

### Fixed

- **DEV-029 — Branch-protection push-safe workflow.** Add `push` trigger and `push-main-ok` job on `.github/workflows/branch-protection.yml` so pushes to `main` no longer produce empty failed runs; guard PR hygiene jobs to `pull_request` only; rename workflow display name to **PR Hygiene Checks**. Guard PR-only step `if` expressions with `github.event_name == 'pull_request'` so push events pass workflow validation. Bats DEV-029 T-001–T-005 green. Manual post-merge verification (M-001/M-002) remains in Master-Plan.

---

## [5.2.0] — 2026-05-24

Minor release: DEV-028 (306 bats tests; DEV-028 T-001–T-010 + version pin).

### Added

- **DEV-028 — Plan-mode spec interview for `/agtoosa-spec`.** Add **Plan-Mode Spec Interview Contract** to generated `Docs/AgToosa_Spec.md`: research-first, infer-before-ask, one question at a time with contextual options, adaptive cap **8** (quick cap **2**), budget-exhaustion gate, and decision-complete checklist. Native spec adapters and maintainer mirrors aligned; phase-stop preserved (no auto-build). Bats DEV-028 T-001–T-010 green. Smoke: T-001–T-009 all green.

---

## [5.1.0] — 2026-05-24

Minor release: DEV-027 (306 bats tests; T-001–T-009 + version pin).

### Added

- **DEV-027 — Agentic `/agtoosa-update`.** Redefine generated `Docs/AgToosa_Update.md` as Detect → Plan → Apply → Verify with ask-then-apply, explicit approval before mutation, and `bash agtoosa.sh --update` as the CLI source of truth; read-only `check` sub-command retained. Platform adapters and maintainer mirrors aligned. Bats T-001–T-009 green. Smoke: T-001–T-007 all green.

---

## [5.0.1] — 2026-05-24

Patch release: DEV-026 (287 bats tests).

### Fixed

- **DEV-026 — Codex agent mode spec workflow execution.** Add **Agent Mode Execution Contract** to generated `.codex/skills/agtoosa-spec/SKILL.md` and `.codex/prompts/agtoosa-spec.md` so Codex agent mode runs research, Goal Contract, Smart Interview, spec/architecture, task planning, test plan skeleton, and approval gating — without duplicating `Docs/AgToosa_Spec.md` or auto-chaining `/agtoosa-build`. Bats CS1–CS5 green; K2/K3/W1/CX1 regressions unchanged. Smoke: CS1–CS5 all green.

---

## [5.0.0] — 2026-05-24

Release **5.0** cycle: DEV-025 (282 bats tests).

### Changed

- **DEV-025 — Maintainer docs path normalization.** Normalize `Docs/` → `docs/` in maintainer `docs/AgToosa_*.md` workflow mirrors and format guides; **Path conventions** in `docs/agtoosa-maintainer.md`; `template/Docs/` citations preserved in Skills; bats PN1–PN5 green. Regression: MD1–MD5, B1, R4 unchanged. Smoke: PN1–PN5 all green.

---

## [4.14.1] — 2026-05-24

Release **4.15** cycle: DEV-024 (277 bats tests).

### Fixed

- **DEV-024 — Maintainer status readiness doc parity.** Sync `docs/AgToosa_Status.md` Part 1.5 readiness + `docs/AgToosa_Readiness.md` for maintainer dogfood; Maintainer Dogfood Mode callout; gate 7 uses `AGTOOSA_VERSION` / `CHANGELOG.md`. Bats MD1–MD5 green; R4 template regression unchanged. Smoke: MD1–MD5 all green.

---

## [4.14.0] — 2026-05-24

Release **4.14** cycle: DEV-023 (272 bats tests).

### Fixed

- **DEV-023 — Workflow template native slash parity audit.** Matrix bats WP1–WP5 verify 14 commands × six native surfaces (Claude, Cursor, Gemini, GitHub, Windsurf, Codex) against `lib/config.sh` inventory; ship `check` Part 0 delegation on all ship adapters; six-surface collision guardrails in Init/Spec/Skills; OPENCODE Codex prompt reservation. Template: add `.claude/commands` to reserved-name lists; Codex ship prompt Part 0 wording. Smoke: WP1–WP5 all green.

---

## [4.13.0] — 2026-05-24

Release **4.13** cycle: DEV-019 (267 bats tests).

### Added

- **DEV-019 — Master Architecture document.** `Docs/Master-Architecture.md` is a first-class template and install artifact with C4-style Mermaid sections; `/agtoosa-init` and `/agtoosa-update` guidance; `AgToosa_Agent`, spec, and arch-review references; ADR-009 and domain language in `Docs/Context/CONTEXT.md`; update preserves existing architecture memory. Smoke: MA1–MA8 all green.

---

## [4.12.2] — 2026-05-24

Patch release: DEV-022 (259 bats tests).

### Fixed

- **DEV-022 — Registry publish PS1 + offline cache hardening.** PowerShell `--registry publish` prints a Bash redirect instead of "Unknown registry command"; maintainer and template registry docs add **Offline cache and trust** (cache paths, HTTPS trust model, high-assurance SHA-256 verification); `fetch_registry` security comment; bats RC1–RC3. Smoke: RC1–RC3 all green.

---

## [4.12.1] — 2026-05-24

Patch release: DEV-021 (256 bats tests).

### Fixed

- **DEV-021 — E2E pinned registry install test (RV6).** Network-free integration test exercises full Bash `--registry install pack@version` through `file://` download, SHA-256 verification, pack queue staging, and `.pack-meta.json` version; closes DEV-020 review gap (RV1–RV5 were resolver/CLI-only). Smoke: `bats tests/agtoosa.bats -f "RV6:"` green; RV1–RV6 slice green with clean `ship/` teardown.

---

## [4.12.0] — 2026-05-24

Release **4.12** cycle: DEV-018, DEV-020 (255 bats tests).

### Fixed

- **DEV-020 — Registry install version pinning.** `pack-name@version` is enforced in Bash via `registry_resolve_pack_entry()` (jq `name` + `version`); pinned mismatch fails before download with available version(s) listed; PowerShell fails closed on mismatch (no warn-and-proceed); registry docs updated; RV1–RV5 bats coverage. Smoke: RV1–RV5 all green.

- **DEV-018 — Registry pack queue.** `--registry install` stages packs in durable `.agtoosa/pack-queue/` (outside ephemeral `ship/`); project install merges the queue and clears entries; legacy `ship/packs/` is salvaged before `ship/` rebuild; PowerShell parity for queue staging and merge; PK1–PK5 bats coverage. Smoke: PK1–PK5 all green.

---

## [4.11.0] — 2026-05-24

Release **4.11** cycle: DEV-003, DEV-016, DEV-017 (246 bats tests).

### Fixed

- **DEV-003 — Registry prod-readiness (audit closure).** Case B `--update` merge via `inject_version` without double-wrapping pre-injected sources; registry `info` exits 1 on unknown pack; search no-results + safe jq probe handling; `registry_publish` manifest via `jq -n`; PS1 `@(ConvertFrom-Json)` on registry paths; RG1–RG8 bats coverage. Smoke: RG1–RG8 all green.

- **DEV-016 — Gemini slash-command routing.** Native `/agtoosa-*` routing and no-`/create-skill` guardrails on all 14 `.gemini/commands/agtoosa-*.toml` adapters; `AGENTS.md` + `AgToosa_Gemini.md` reservation; Init/Spec/Skills synthesis collision guardrails; GM1–GM5 bats coverage. Smoke: GM1–GM5 all green.

- **DEV-017 — Codex AgToosa slash discoverability.** Native `/agtoosa-*` routing via 14 `.codex/prompts/agtoosa-*.md` adapters; `CODEX_PROMPT_FILES` generator inventory; platform 7 install/update/dry-run wiring; `OPENCODE.md` documents prompts + skills; Init/Spec/Skills synthesis collision guardrails; CX1–CX5 bats coverage. Smoke: CX1–CX5 all green.

---

## [4.9.0] — 2026-05-24

Release **4.9** cycle: DEV-015 (228 bats tests).

### Fixed

- **DEV-015 — Windsurf slash-command routing.** Explicit native `/agtoosa-*` workflow routing and no-`/create-skill` guardrails on all 14 `.windsurf/workflows/agtoosa-*.md` adapters; `agtoosa-core.md` and `agtoosa-status.md` rules reserve workflow command names; Init/Spec/Skills synthesis docs reject `.windsurf/workflows/agtoosa-*.md` collisions; WS1–WS5 bats coverage. Smoke: WS1–WS5 all green.

---

## [4.8.0] — 2026-05-24

Release **4.8** cycle: DEV-014 (223 bats tests).

### Fixed

- **DEV-014 — Cursor slash-command routing.** Explicit native `/agtoosa-*` workflow routing and no-`/create-skill` guardrails on all 14 `.cursor/commands/agtoosa-*.md` adapters; `agtoosa-core.mdc` and `agtoosa-status.mdc` reserve workflow command names; Init/Spec/Skills synthesis docs reject `.cursor/commands/agtoosa-*.md` collisions; CU1–CU5 bats coverage. Smoke: CU1–CU5 all green.

---

## [4.7.0] — 2026-05-24

Release **4.7** cycle: DEV-013 (223 bats tests).

### Fixed

- **DEV-013 — `/agtoosa-ship check` cleanup.** Part 0 is a read-only readiness audit with separated success output from full-flow deploy approval; maintainer and template `AgToosa_Ship.md` parity (Goal Contract gate, per-check Fix with / Manual action, log redaction); eight native ship adapters delegate `check` to Part 0 with no-deploy/no-mutation wording; C1–C6 bats coverage. Smoke: C1–C6 all green.

---

## [4.6.0] — 2026-05-24

Release **4.6** cycle: DEV-012 (212 bats tests).

### Added

- **DEV-012 — GitHub slash-command routing.** Explicit `name: agtoosa-*` frontmatter on all 14 `.github/prompts/agtoosa-*.prompt.md` adapters; Copilot instructions and AgToosa GitHub agent route `/agtoosa-*` to workflow prompts (not `/create-skill`); reserved `agtoosa-*` names in Init/Spec/Skills synthesis docs; G1–G5 bats coverage. Smoke: G1–G5 all green.

---

## [4.5.0] — 2026-05-24

Release **4.5** cycle: DEV-011 (207 bats tests).

### Added

- **DEV-011 — Product vs dogfood operating contexts.** **Generated Project Mode** and **Maintainer Dogfood Mode** documented in `docs/agtoosa-maintainer.md`, ADR-008, `Docs/AgToosa_Agent.md`, and Init/Spec/Status workflow callouts; spec/status platform adapters aligned; B1–B5 bats coverage. Smoke: B1–B5 all green.

---

## [4.4.0] — 2026-05-24

Release **4.4** cycle: DEV-010 (202 bats tests).

### Added

- **DEV-010 — Workflow reliability (phase gates and terminal evidence).** Shared Phase Stop and Terminal Evidence contracts in `AgToosa_Agent.md`; wired into Spec, Build, Review, and QA workflow docs; platform adapter parity for spec and build entry points; W1–W5 bats coverage. Smoke: W1–W5 all green.

---

## [4.3.0] — 2026-05-23

Release **4.3** cycle: DEV-009 (197 bats tests).

### Added

- **DEV-009 — Product promise alignment and initial readiness gates.** `Docs/Master-Plan.md` is consistently the PM source of truth in README and workflow docs; `Docs/AgToosa_Readiness.md` separates workflow guidance from generator enforcement; `/agtoosa-status readiness` audits seven initial gates with deterministic Fix-with commands; R1–R8 bats coverage; status typo helper now includes `readiness` sub-command.

### Changed

- Removed stale Linear PM language from template workflow docs (`Spec`, `Build`, `Review`, `Ship`, `Debug`, `DEEPENING`, platform rules).
- README and `SECURITY.md` distinguish workflow guidance from generator-enforced behavior.

---

## [4.2.0] — 2026-05-23

Release **4.2** cycle: DEV-005 through DEV-008 (189 bats tests).

### Added

- **Manual task support across the full workflow.** Tasks that require human action outside the agent can be tagged `[manual]`; `/agtoosa-build` detects them and offers mark-done, defer, or show-then-defer without blocking the cycle. Deferred tasks use `[manual-deferred: YYYY-MM-DD]` and appear in **Manual / Deferred** in Master-Plan and `/agtoosa-status`.
- **`🔧 Awaiting Manual` story status** — non-blocking when automated work is done but manual steps remain.
- **M1–M4 bats parity tests** for manual-task template semantics. Ref: `docs/archived/spec-DEV-005.md`.
- **AgToosa Status Guide sub-agent** for GitHub Copilot plus `Docs/AgToosa_StatusGuide.md` (read-only status + authorization before fix commands). Ref: `docs/archived/spec-DEV-006.md`.
- **Model-agnostic `/agtoosa-goal` sub-workflow** with portable Goal Contracts.
- **Native workflow discoverability adapters** for Cursor (`.cursor/commands/`), Windsurf (`.windsurf/workflows/`), and Codex (`.codex/skills/`).
- **`/agtoosa-help next`** — on-demand read-only assistance across Claude, Gemini, Copilot, and Cursor/Windsurf fallbacks. Ref: `docs/archived/spec-DEV-007.md`.
- **Workflow skill synthesis (DEV-008)** — 14 Codex AgToosa workflow skills with frontmatter and execution guidance; Project Skill Discovery in `/agtoosa-init`; Story Skill Opportunity Synthesis in `/agtoosa-spec`; bats K1–K7. Ref: `docs/archived/spec-DEV-008.md`, ADR-007.

### Changed

- **`/agtoosa-status` health score** no longer penalizes manual-deferred tasks; Update Log staleness relaxed when all stories are `🔧 Awaiting Manual`.
- **Status key** in `Master-Plan.md` and `SPEC-FORMAT.md` includes `🔧 Awaiting Manual`.
- **CHANGELOG backlog cleanup** for 4.2.0 planned items.
- **Platform selector option 7** clarified as Codex / OpenCode / Other (option 8 remains All of the above).

### Files updated

- `template/Docs/SPEC-FORMAT.md`, `AgToosa_Build.md`, `AgToosa_Status.md`, `Master-Plan.md` — manual-task lifecycle and status dashboard.
- `template/.codex/skills/agtoosa-*/`, `template/.cursor/commands/`, `template/.windsurf/workflows/` — workflow discoverability and skill synthesis (DEV-008).
- `tests/agtoosa.bats` — M1–M4, H1–H7, K1–K7, S1–S2 parity (189 tests).

---

## [4.1.0] — 2026-05-11

### Added

- **Deterministic "Recommended Next Actions" algorithm** in `Docs/AgToosa_Status.md` Part 5.5. Status now generates the same ranking every run: Errors → aged Warnings (oldest first) → other Warnings → Orphans → Info, deduplicated by `Fix with` command, capped at 5 actions with overflow line, and including a 🎯 Quick wins call-out for findings that take <5 min (charter placeholders, task-counter mismatches, missing spec for the In Progress story).
- **Aging escalation prefix** on findings promoted from Warning → Error by age. Blocked items and stale Update Log entries now carry `(escalated to Warning on day 7)` or `(escalated to Error on day 30)` so users see *why* the severity changed instead of a static label.
- **Sub-command typo helper** for `/agtoosa-status`. Unknown sub-commands (e.g. `/agtoosa-status check`) now prepend `Note: '<token>' is not a defined sub-command. Did you mean: plan, git, orphans? Falling back to full dashboard.` before running the dashboard.

### Changed

- **Closure-loop directive** on every fix command. `/agtoosa-init`, `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-task`, and `/agtoosa-ship` now print `✅ Done. Run /agtoosa-status to verify findings cleared.` on successful completion, closing the status → fix → verify loop. Wired across all 5 platform variants for `build`/`task`/`spec`/`ship` and across the 3 init platform variants plus the cursor/windsurf `agtoosa-core` fallback rules (which carry the rule for `init`/`help` since those commands have no `.cursor/rules` or `.windsurf/rules` variant).
- **README version badge + install snippet** bumped from `3.1.0` → `4.1.0`. The badge had been stale across the entire `4.0.0` release.

### Fixed

- Status report no longer relies on the agent improvising next-action ordering, deduplication, or priority every run. Output is now deterministic across runs and across platform variants.

### Files updated

- `template/Docs/AgToosa_Status.md` — Part 5.5 (Next Actions generation algorithm) and Part 5.6 (typo helper) added; aging escalation prefix wired into Part 1 step 5 (Blocked) and step 7 (Update Log).
- `template/Docs/AgToosa_{Build,Task,Spec,Ship,Init}.md` — closure line added to each Output section (canonical source of truth).
- `template/.{claude,cursor,gemini,github,windsurf}/...agtoosa-{build,task,spec,ship}.{md,mdc,toml,prompt.md}` — 20 platform variants updated with the closure-line directive.
- `template/.{claude,gemini,github}/...agtoosa-init.{md,toml,prompt.md}` — 3 init platform variants updated.
- `template/.cursor/rules/agtoosa-core.mdc`, `template/.windsurf/rules/agtoosa-core.md` — closure-loop rule added (covers init/help fallback on cursor/windsurf).
- `template/.{claude,cursor,gemini,github,windsurf}/...agtoosa-status.{md,mdc,toml,prompt.md}` — 5 status variants updated with the typo helper and a pointer to the Part 5.5 algorithm.
- `docs/agtoosa-maintainer.md` — closure-line and typo-helper strings added to the user-facing-strings parity list; init/help asymmetry (3 variants, not 5) documented in the parity checklist.
- `tests/agtoosa.bats` — new parity tests for D1 (algorithm anchor), D2 (closure-line matrix), and D3 (typo-helper matrix).
- `agtoosa.sh` · `agtoosa.ps1` — version bump to 4.1.0.
- `README.md` — badge and install-ref bumped to 4.1.0.

---

## [4.0.0] — 2026-05-11

### Added

- **Kiro-style spec format (`SPEC-FORMAT.md`)** — new reference doc defining the canonical single-file spec layout: `## 1. Requirements` (User Stories + EARS ACs + Out of Scope), `## 2. Design` (Architecture Blueprint + Data Flow + STRIDE + Build Scope), `## 3. Tasks` (hierarchical checkbox tree + Wave Plan + Test Plan reference). Sibling to `CONTEXT-FORMAT.md` and `ADR-FORMAT.md`.
- **EARS acceptance criteria** — `/agtoosa-spec` Part 3 now generates ACs in EARS notation (`WHEN [condition] THE SYSTEM SHALL [behavior]`, `WHILE/WHEN/SHALL`, `IF/THEN/WHEN/SHALL`) instead of the Given/When/Then table.
- **Hierarchical task tree** — `/agtoosa-spec` Part 4 now emits a numbered checkbox tree (`- [ ] **1.** Group / - [ ] 1.1 sub-task — _Requirements: AC-NNN_`) into both the spec file and `Master-Plan.md ## Active Tasks`, replacing the flat table.
- **Wave Plan** — `/agtoosa-spec` Part 4 appends a `### Wave Plan` subsection grouping parallel-runnable sub-tasks (`**Wave 1 (parallel):** 1.1, 2.1`).
- **Progress bar in Master-Plan.md** — `## Active Cycle` now shows a unicode progress bar (`▰▰▰▱▱▱▱▱ N/M tasks`) updated by `/agtoosa-build` after each task completes.
- **Checkbox tick tracking** — `/agtoosa-build` now ticks `- [ ]` → `- [x]` in both the spec's `## 3. Tasks` tree and `Master-Plan.md ## Active Tasks` after each completed task.

### Changed

- **Master-Plan.md template** — visual refresh: Project Charter converted to a key-value table with backtick values; sections reordered to active-first (Active Cycle → Active Tasks → Blocked → Backlog → Epics → Completed → Update Log); status emojis standardised (⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🏁 Shipped); `## Completed This Cycle` explicitly marked as pointer-rows-only with `Docs/archived/` as the authoritative store.
- **`/agtoosa-spec` Part 3 output** — spec files now follow the SPEC-FORMAT.md section order; `Docs/SPEC-FORMAT.md` is referenced in the generation step.

### Migration notes

- Existing `Docs/archived/spec-*.md` files continue to work — `/agtoosa-build` and `/agtoosa-ship` do not validate the internal section structure of archived specs.
- The new format applies to specs generated after upgrading to v4.0.0. Re-running `/agtoosa-spec` on an existing approved story will regenerate the spec in the new format.
- Running `/agtoosa-update` ships `SPEC-FORMAT.md` and updates `AgToosa_Spec.md` / `AgToosa_Build.md`. Existing `Docs/Master-Plan.md` is smart-merged — user customisations are preserved. The new section order is a manual one-time tidy.

### Files updated

- `template/Docs/SPEC-FORMAT.md` — new file
- `template/Docs/Master-Plan.md` — visual refresh
- `template/Docs/AgToosa_Spec.md` — Part 3 (EARS ACs, section order) · Part 4 (hierarchical task tree, Wave Plan)
- `template/Docs/AgToosa_Build.md` — tracking update per completed task (checkbox tick, progress bar)
- `lib/config.sh` — `SPEC-FORMAT.md` added to `DOCS_FILES`
- `agtoosa.sh` · `agtoosa.ps1` — version bump to 4.0.0

---

## [3.4.1] — 2026-05-05

### Fixed

- **Registry: local pack install staged contents in a nested directory** — `_install_local_pack()` ran `cp -r "$pack_path" "$pack_dir"` against an already-created `$pack_dir`, which placed pack files at `ship/packs/<name>/<name>/...` instead of `ship/packs/<name>/...`. Switched to `cp -R "$pack_path"/. "$pack_dir"/` so contents land at the documented path.
- **Registry: `--registry install <relative-path>` ignored existing directories** — the local-pack branch only matched `./` or `/` prefixes, so paths like `tests/fixtures/mock-pack` fell through to the network registry and 404'd. The check now also routes any existing-directory argument to the local installer.
- **Registry: cache directory was not overridable** — `lib/registry.sh` hard-coded `$HOME/.cache/agtoosa`, which prevented offline tests and CI from pre-seeding `registry.json`. The cache dir now respects `AGTOOSA_REGISTRY_CACHE_DIR` when set.
- **Registry: `validate_pack_files` missed symlink-based path traversal** — `find ... -type f` skips symlinks by default, so a pack containing a symlink to `/etc/hosts` passed validation. Switched to `find -L ... -type f` so symlinks are resolved and rejected when their canonical path escapes the pack root.
- **Registry: `--registry publish` hung or exited silently with no input** — the publish wizard always called `read` for the pack directory, which fails noisily under `set -e` in non-interactive contexts. `registry_publish` now accepts the directory as a positional argument, only prompts when stdin is a TTY, and prints a clear usage error otherwise.

### Files updated

- `lib/registry.sh` — local pack copy, install routing, cache dir override, symlink-aware validation, publish argument support
- `agtoosa.sh` — pass `REGISTRY_ARG` to `registry_publish`
- `agtoosa.sh` / `agtoosa.ps1` — version bump to 3.4.1
- `tests/agtoosa.bats` — version-pin updates

---

## [3.4.0] — 2026-05-05

### Changed

- **Restored Spec/Build responsibility boundary** — Task planning (atomic task breakdown, scope boundary declaration, test plan skeleton) has moved from `/agtoosa-build` Part 1 into a new `/agtoosa-spec` Part 4. `/agtoosa-build` now starts directly in the TDD Red-Green-Refactor cycle without any planning gates or scope-approval prompts. The drift that caused `/agtoosa-build` to ask for task approval mid-build is fixed at the source.
- **`/agtoosa-spec` workflow signature** — Full flow is now Parts 1 + 2 + 3 + 4 (research → spec → architecture/threat-model → task planning). The single approval gate at the end now covers spec, atomic tasks, and the test plan skeleton in one shot.
- **`/agtoosa-build` workflow signature** — Three parts: TDD Build Cycle, Comprehensive Testing, Tracking. Prerequisites now require both spec approval AND tasks present in `Master-Plan.md` under `## Active Tasks`. If tasks are missing, the workflow redirects to `/agtoosa-spec tasks`.

### Added

- **`/agtoosa-spec tasks` sub-command** — Re-runs Part 4 only (scope boundary + atomic task breakdown + test plan skeleton) against an already-approved spec. Use this to regenerate the task list without re-running the full spec workflow.

### Removed

- **`/agtoosa-build scope` sub-command** — Repurposed as a redirect to `/agtoosa-spec tasks`. The hard scope-approval gate that had bled into the full-flow build is gone — the build no longer pauses for scope confirmation because scope is declared during `/agtoosa-spec`.

### Migration notes

If you have an in-flight Story where `/agtoosa-spec` was already approved but task planning was never run, run `/agtoosa-spec tasks` once to populate `## Active Tasks` in `Master-Plan.md`, then run `/agtoosa-build` as normal.

### Files updated for cross-platform parity

- `template/Docs/AgToosa_Spec.md` (new Part 4) · `template/Docs/AgToosa_Build.md` (Part 1 removed, parts renumbered)
- Per-platform command surfaces: Claude (`commands/agtoosa-{spec,build,help}.md`), Gemini (`commands/agtoosa-{spec,build,help}.toml`), GitHub Copilot (`prompts/agtoosa-{spec,build,help}.prompt.md` + `copilot-instructions.md`)
- Entry-point command tables: `template/CLAUDE.md`, `template/AGENTS.md`, `template/OPENCODE.md`, `template/.cursorrules`, `template/.windsurfrules`
- Reference docs: `template/Docs/AgToosa_Agent.md` (sub-command reference, question budgets, Linear hierarchy), `template/Docs/Master-Plan.md` (Active Tasks creation source), `README.md` (phase descriptions)

---

## [3.3.0] — 2026-05-04

### Added

- **Cross-platform native `/agtoosa-update` command wiring** — Added missing native command/rule/prompt files so `/agtoosa-update` is available not just in entry-point docs but in platform-native command surfaces for Claude Code, Gemini CLI, Cursor, Windsurf, and GitHub Copilot.

### Changed

- **Help command parity across platforms** — Updated native help references to include `/agtoosa-update` in:
  - `template/.claude/commands/agtoosa-help.md`
  - `template/.gemini/commands/agtoosa-help.toml`
  - `template/.github/prompts/agtoosa-help.prompt.md`
- **Version parity restored** — `agtoosa.ps1` now matches `agtoosa.sh` at `3.3.0`.

### Tests

- Added regression coverage ensuring `/agtoosa-update` exists in all platform-native templates and appears in help output where applicable.
- Verified focused suite: `bats tests/agtoosa.bats -f "agtoosa-update"`.

---

## [3.2.1] — 2026-05-04

### Fixed

- **`/agtoosa-build` full-flow blocked on approval gate** — The Part 1 scope and task-plan gates in `AgToosa_Build.md` were unconditional, causing the AI to pause and wait for user approval even when the user ran `/agtoosa-build` (full flow, which should auto-proceed into TDD). Both gates are now sub-command-aware: `/agtoosa-build scope` keeps a hard approval stop; `/agtoosa-build` (full flow) presents an informational summary and immediately continues into Part 2 without waiting.

---

## [3.2.0] — 2026-05-04

### Fixed

- **Linear hardcoded as project management source of truth** — `Docs/Master-Plan.md` was always the intended PM source of truth (replacing Linear, Jira, GitHub Projects, Trello, etc.), but 30+ template files across all platforms contained directives to create Linear issues, sync Linear, and treat Linear as canonical. All references replaced with `Docs/Master-Plan.md`-centered language. Affected files: `AgToosa_Init.md`, `AgToosa_Spec.md`, `AgToosa_Build.md`, `AgToosa_Task.md`, `AgToosa_QA.md`, `AgToosa_Ship.md`, `AgToosa_Revert.md`, `AgToosa_Governance.md`, `AgToosa_Agent.md`, `AgToosa_Skills.md`, `AgToosa_Update.md`, `Master-Plan.md` template, all platform entry files (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.windsurfrules`, `OPENCODE.md`, `.github/copilot-instructions.md`), and all platform rule/skill/command files for Cursor, Windsurf, Claude, Gemini, GitHub Copilot.

### Tests

- All 127 existing bats tests pass (5 pre-existing registry failures unaffected)

---

## [3.1.1] — 2026-05-04

### Fixed

- **`-h` flag rejected as unknown option** — `agtoosa.sh` flag parser now accepts `-h` as an alias for `--help`; previously emitted `❌ Error: Unknown option '-h'` and exited 1
- **`--update` showed `vunknown` after fresh install** — `install_files()` in `lib/install.sh` now writes `Docs/.agtoosa-version` at the end of every install; previously only `run_update()` wrote this file, so the first `--update` after a fresh install always read "unknown"
- **Misleading post-update hint** — `print_update_summary()` in `lib/update.sh` now includes the full target project path in the `/agtoosa-update` instruction; previously the generic phrasing caused a user to run `/agtoosa-update` inside the AgToosa source repo instead of their project

### Tests

- `bats`: `-h` shows usage and exits 0 (DEV-187)
- `bats`: fresh install writes `Docs/.agtoosa-version` with correct version (DEV-187)
- `bats`: `--update` after fresh install shows real version, not `vunknown` (DEV-187)

---

## [3.1.0] — 2026-05-04

### Added
- Repo-native maintainer guide in `docs/agtoosa-maintainer.md` for working on the AgToosa generator itself
- Native repo entry files for Claude (`CLAUDE.md`), AGENTS-style tools (`AGENTS.md`), Cursor (`.cursorrules`), and Windsurf (`.windsurfrules`) pointing to the shared maintainer guide
- File-type allowlist enforcement in `lib/registry.sh` (`.md`, `.json`, `.toml`, `.mdc` only); rejected files print: `Rejected: <file> — only .md/.json/.toml/.mdc are permitted`
- `agtoosa-lock.json` written on install and updated on `--update`; records pack name, version, sha256
- `--registry publish` contribution wizard for submitting community packs
- Pack staging merge from `ship/packs/` during install
- `template/Docs/AgToosa_Governance.md` — phase-gate protocol and Linear comment strings
- Formal deprecation policy in `CONTRIBUTING.md` (1-release notice before removal)
- 9 new bats tests (122 total)

### Changed
- `GEMINI.md` now contains maintainer guidance instead of remaining empty
- `.github/agents/agtoosa.agent.md` delegates to shared maintainer guide
- `agtoosa.ps1` brought to v3.0.0 feature parity (registry commands, DOCS_FILES expansion, version marker)
- CI now asserts version parity between `agtoosa.sh` and `agtoosa.ps1`
- `--update` now bumps `agtoosa_version` in existing `agtoosa-lock.json`; first run on a 3.0.0 install creates `agtoosa-lock.json` automatically in the project root

---

## [3.0.0] — 2026-05-02

### Added
- v3 Community Template Registry Phase 1 (read path):
  - `bash agtoosa.sh --registry list` — discover available community packs
  - `bash agtoosa.sh --registry search <keyword>` — filter packs by keyword
  - `bash agtoosa.sh --registry info <name>` — show pack details
  - `bash agtoosa.sh --registry install <name>` — download, verify (SHA-256), and install packs
  - Support for local pack installation: `--registry install ./local-pack` (offline mode)
  - Version pinning: `--registry install pack@1.2.0`
  - Registry caching (1 hour) to reduce GitHub load
  - Markdown-only pack constraint for security (no executable code)
  - `Docs/AgToosa_Registry.md` — user-facing registry workflow documentation
- Native Windows installation via PowerShell (`bootstrap.ps1`):
  - Dependency checking for git, bash, curl, tar
  - Automated Git for Windows discovery
  - Direct execution from PowerShell (no bash.exe required for bootstrap)
- Smart dependency checking in `bootstrap.sh`: detects missing bash/git/curl/tar and prints platform-specific install guidance
- Platform detection in bootstrap (macOS, Linux distros, WSL2, Windows) with contextual error messages
- `System Requirements` section in README documenting required tools (bash 4+, git, curl, tar)
- Git availability check in `agtoosa.sh` with helpful error messages if missing

### Changed
- Installation guidance in README now includes native Windows instructions (PowerShell one-liner)
- Bootstrap script exits gracefully with clear instructions if dependencies are missing (instead of silent/cryptic failures)
- Windows users can now choose: native PowerShell installer or WSL2 terminal

### Removed
- Stale plan files from `docs/superpowers/` directory (self-update planning artifacts)

---

## [2.7.0] — 2026-05-01

### Added
- 7 mattpocock/skills integrated: `/agtoosa-diagnose` (6-phase debugging), `/agtoosa-caveman` (token-efficient mode), `grill` (domain language alignment), `to-issues` (vertical-slice issue decomposition), `zoom-out` (codebase context), git-guardrails hook, and reference docs (CONTEXT-FORMAT, ADR-FORMAT, DEEPENING, LANGUAGE)
- All 6 platform support expanded with new command files: Claude Code, Cursor, Windsurf, Gemini CLI, GitHub Copilot, and OpenCode
- `Docs/AgToosa_Diagnose.md`, `Docs/AgToosa_Caveman.md`, `Docs/AgToosa_Skills.md` workflow documentation
- Reference documentation: `Docs/CONTEXT-FORMAT.md`, `Docs/ADR-FORMAT.md`, `Docs/DEEPENING.md`, `Docs/LANGUAGE.md`

### Changed
- **Breaking:** `/agtoosa-caveman` renamed to `/agtoosa-concise` for AgToosa-native branding (token-efficient communication mode)
- **Breaking:** `/agtoosa-diagnose` renamed to `/agtoosa-debug` for AgToosa-native branding (6-phase debugging workflow)
- **Breaking:** `grill` removed as standalone `/agtoosa-spec grill` sub-command; **domain language alignment now integrated into `/agtoosa-spec` Part 1** (Context Gathering & Domain Language Alignment). Context.md validation, terminology alignment, and ADR creation are part of the main spec research flow.
- All platform entry-point files and documentation updated to reference renamed commands and integrated domain language alignment
- `/agtoosa-spec` workflow enhanced with mandatory domain language checks in Part 1
- `/agtoosa-review` architecture checks enhanced with deep module analysis and ubiquitous language validation
- 32 new BATS tests added for new commands and platform coverage (113 total tests, all passing)

### Fixed
- Template file references corrected across all platform-specific command/rule files to match renamed documentation files
- Platform descriptions updated to use AgToosa-native command names throughout
- Spec command descriptions updated to reflect integrated domain language alignment (no longer mentions removed `grill` sub-command)

---

## [2.6.0] — 2026-04-28

### Added
- `--update` mode in `agtoosa.sh` to update an existing project install non-interactively: `bash agtoosa.sh --update /path/to/project`
- New workflow file `Docs/AgToosa_Update.md` and `/agtoosa-update` utility wiring across platform entry-point templates
- Expanded bats coverage for update mode, including error paths, preservation rules, dry-run behavior, and platform merge detection

### Changed
- Update flow now sources and uses `lib/update.sh` end-to-end from the main entrypoint
- CI now installs a pinned bats-core version instead of using an unversioned distro package

### Fixed
- `detect_installed_platforms()` in `lib/update.sh` now returns success explicitly to avoid `set -e` exits during update runs
- Removed deprecated Roo template artifacts (`template/.roorules`, `template/.roo/`) from active template surface

---

## [2.5.0] — 2026-04-28

### Added
- `.mdc` files (Cursor rules) now linted by CI markdownlint step
- Bats test for VS Code + Copilot combo (`5 6`) verifying `.github/` deduplication

### Changed
- Platform option 7 renamed from "OpenCode / Roo / Other" to "OpenCode / Other" — Roo Code sunsets 2026-05-15
- `OPTIONAL_TEMPLATE_FILES` and `ROO_RULE_FILES` array removed; `.roorules` and `.roo/rules/` are no longer generated or installed
- Platform entry-point files `AGENTS.md` and `OPENCODE.md` updated: optional utilities line now includes "Read" prefix to match all other platform files
- `count_existing_files()` in `lib/install.sh` now correctly counts VS Code-specific files when option 6 is selected without option 5
- Bats test for platform selection 6 renamed and strengthened with positive assertions for `.github/copilot-instructions.md`, prompts, and agent file
- `CLAUDE_HOOK_FILES` dead config array removed from `lib/config.sh`
- v2.4.0 CHANGELOG date corrected from 2026-05-14 to 2026-04-28

---

## [2.4.0] — 2026-04-28

### Added
- `/agtoosa-task` command (`Docs/AgToosa_Task.md`): lightweight Linear issue capture for bugs, chores, spikes, and fixes without a full spec cycle; includes type-specific DoD checklists and Discovery Triage origin tracking (DEV-167)
- Platform-native command files for `/agtoosa-task` on all 6 platforms: `.claude/commands/agtoosa-task.md`, `.cursor/rules/agtoosa-task.mdc`, `.gemini/commands/agtoosa-task.toml`, `.github/prompts/agtoosa-task.prompt.md`, `.windsurf/rules/agtoosa-task.md`, `.roo/rules/agtoosa-task.md`
- Linear Issue Standard anatomy in `AgToosa_Agent.md`: canonical title format `[Type]: [description]`, required description sections (Context, Scope, ACs, DoD, Related), Epic→Story→Task hierarchy table, field defaults, Phase Comment Protocol, and Discovery Triage Protocol (DEV-164, DEV-165)
- Epic creation instructions in `/agtoosa-init` Step 9: agent now creates Linear Epic issues with correct labels/status and records IDs in `Docs/Master-Plan.md` (DEV-165)
- Story creation with T-shirt sizing and cycle enrollment in `/agtoosa-spec` Steps 9–10: agent creates a Linear Story issue (parent: Epic), records estimate, and enrolls in the active cycle if selected (DEV-165, DEV-168)
- Task sub-issue creation in `/agtoosa-build` Part 1 Step 6: agent creates Linear Task issues (parent: Story) per build task; transitions Story to `In Progress`; posts "Build 🏗️ Started" phase comment (DEV-165, DEV-166, DEV-171)
- Discovery Triage Protocol in `/agtoosa-build`: classify out-of-scope findings, size them, and route to create-issue / expand-scope / ignore — preventing silent scope creep (DEV-169)
- Status transition protocol across phase commands: Story moves `Todo → In Progress → In Review → Done` (or back) at Build/Review/Ship boundaries; rollback resets to `In Review` (DEV-166)
- Phase progress comments on Linear Story issues at every phase transition: Spec ✅ Approved, Build 🏗️ Started, Task 🟢 N/M complete, Review 🔍 Started, Review ✅/🔴 verdict, Ship 🚀 Deployed / Rollback 🔙 Triggered (DEV-171)
- Rich `Docs/Master-Plan.md` template: replaced stub with 8-section structured template (Project Charter, Epics, Active Cycle, Active Tasks, Backlog, Blocked, Completed This Cycle, Update Log) (DEV-170)
- `/agtoosa-task` added to Utility Commands table in `AgToosa_Agent.md` and to all platform entry-point "Optional utilities" lines

### Changed
- All 7 platform entry-point files updated: "Optional utility" → "Optional utilities" with both `/agtoosa-revert` and `/agtoosa-task` listed
- Help command files (`.claude/commands/agtoosa-help.md`, `.github/prompts/agtoosa-help.prompt.md`, `.gemini/commands/agtoosa-help.toml`) updated with `/agtoosa-task` row
- `lib/config.sh` `OPTIONAL_TEMPLATE_FILES` expanded with all 6 new agtoosa-task platform files; all specific platform arrays updated to match

---

## [2.3.0] — 2026-04-27

### Added
- Platform-native command files for Claude Code: `.claude/commands/` (8 slash commands — init, spec, build, qa, review, ship, revert, help), `.claude/settings.json` (Stop / PreToolUse / PostToolUse hooks), `.claude/skills/agtoosa-review.md`
- Platform-native rule files for Cursor: `.cursor/rules/` (7 MDX files — core, spec, build, qa, review, ship, revert)
- Platform-native command files for Gemini CLI: `.gemini/commands/` (8 TOML files)
- Platform-native rule files for Windsurf: `.windsurf/rules/` (7 MD files)
- Platform-native rule files for Roo: `.roo/rules/` (7 MD files)
- Platform-native prompt files for GitHub Copilot: `.github/prompts/` (8 prompt files) and `.github/agents/agtoosa.agent.md`
- Generator expansion: `lib/generate.sh` stages all new platform file sets into `ship/`; `lib/install.sh` installs them into the target project
- `lib/config.sh` — 7 new file-list arrays (`WINDSURF_RULE_FILES`, `ROO_RULE_FILES`, `GEMINI_COMMAND_FILES`, `COPILOT_PROMPT_FILES`, `COPILOT_AGENT_FILES`, `CLAUDE_HOOK_FILES`, `CLAUDE_SKILL_FILES`) and expanded `OPTIONAL_TEMPLATE_FILES`
- `merge_settings_json()` in `lib/copy.sh` — deep-merges AgToosa hooks into an existing `.claude/settings.json` without touching user settings, deduplicating by command string
- 48-test bats suite (up from ~15 at v2.2.0): coverage for all per-platform copy paths, `.claude/settings.json` hook deduplication, dry-run display, `inject_version`, `version_lt`, `backup_file`, `copy_platform_file`, and `merge_platform_file`

### Fixed
- `print_template_files()` no longer emits duplicate paths — removed redundant per-platform arrays already covered by `OPTIONAL_TEMPLATE_FILES`; CI template validation now passes (DEV-160)
- `AGTOOSA_VERSION` correctly set to `2.3.0` (regression from `2.2.0` → `2.1.1` in post-release commit) (DEV-161)

---

## [2.2.0] — 2026-04-27

### Added
- Smart merge/append for platform entry-point files (DEV-156): `inject_version()` wraps content in AgToosa START/END delimiters; `merge_platform_file()` handles 4 cases — new file, in-place block update, old-format migration, and append-to-user-file
- `.bak` backup creation and "✅ (up to date)" no-skip messaging for `merge_platform_file` (DEV-157)
- `/agtoosa-qa` slash command and `AgToosa_QA.md` workflow file
- Sub-command architecture across all four main AgToosa commands (`/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, `/agtoosa-ship`)
- Gemini CLI / Jules platform support (`AGENTS.md`, `template/AGENTS.md`, `GEMINI.md`)
- OpenCode platform support (`template/OPENCODE.md`)
- `lib/config.sh` — extracted file-list arrays and `print_usage` / `print_template_files` helpers
- `lib/version.sh` — extracted `inject_version`, `extract_version`, and `version_lt` helpers
- CI workflow updates: shellcheck action version bump, non-portable `grep -P` fix (DEV-114)

### Fixed
- 12 generator bugs (DEV-128–139): template pollution, dotfile copy, version badge, security versions, and related issues
- Consistency fixes across README phase clarity, ship revert wording, and platform file alignment (DEV-124–126)
- `/agtoosa-build` test sub-command scope and removed broken TDD guard external link (DEV-118–119)
- Replaced bare `/plan` `/build` `/test` `/review` with `/agtoosa-*` throughout `SECURITY.md` (DEV-116)
- Defined canonical approval and review artifacts for ship readiness gate (DEV-113)
- Bug report template updated to reference `--version` flag correctly

### Changed
- ~20% token reduction across all workflow markdown files (verbosity pass)
- Linear set as canonical source of truth for all project tracking
- `Master-Plan.md` updated to reflect Linear project state and backlog management

---

## [2.1.0] — 2026-04-01

### Added
- Initial AgToosa framework: `agtoosa.sh` interactive generator
- Core workflow files: `AgToosa_Agent.md`, `AgToosa_Spec.md`, `AgToosa_Build.md`, `AgToosa_Review.md`, `AgToosa_Ship.md`, `AgToosa_Init.md`
- Platform entry points: `CLAUDE.md`, `.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md`, `AGENTS.md`
- `--force`, `--dry-run`, `--version`, `--help` flags
- `install.sh` deprecated stub directing users to `agtoosa.sh`
