# Review: DEV-077 — Authoring Guide and Onboarding Surface

> **Story:** DEV-077  
> **Date:** 2026-07-11  
> **Verdict:** ✅ PASS  
> **Suggested release:** PATCH **5.3.8 → 5.3.9** (ADR-005 patch-first; Chore S — may batch with remaining-specs wave 1 peers)

## Summary

Docs/discovery chore: refreshed `docs/extension-authoring-guide.md`, new canonical `docs/registry-pack-authoring.md` readiness handbook, Registry/README/help discovery pointers only, and AUTH-001–AUTH-008 contract bats. Goal Contract satisfied within documentation + CI-when-run claim boundary. No registry install/publish behavior changed.

| Persona | 🔴 Critical | 🟡 Warning | 🟢 Passed |
|---------|-------------|------------|-----------|
| Security Officer | 0 | 0 | 7 |
| Engineering Manager | 0 | 2 | 5 |
| CEO / Product Owner | 0 | 0 | 7 |
| QA Lead | 0 | 2 | 6 |
| **Unresolved Critical** | **0** | — | — |

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Standard (routine docs/chore; threat model is documentation integrity only; no auth/secrets/supply-chain Must ACs implementing trust boundaries) |
| Reviewer identity | — |
| Model/platform | — |
| Outcome | skipped |
| Skip rationale | Standard tier per `docs/AgToosa_CrossModelReview.md` — virtual personas + AUTH contract bats sufficient. Cross-model optional; not strongly recommended. |

### Cross-model evidence: sequential-virtual-personas
- **Reviewer identity:** Security / EM / CEO / QA virtual personas (orchestrator)
- **Model/platform:** Cursor Composer (single session)
- **Findings:** No Critical; Warnings limited to verifier pattern/Master-Plan Active Tasks housekeeping
- **Files read:** `docs/archived/spec-DEV-077.md`, `docs/AgToosa_TestPlan-DEV-077.md`, `docs/registry-pack-authoring.md`, `docs/extension-authoring-guide.md`, Registry mirrors, help adapters, AUTH bats
- **Commands:** `bats tests/agtoosa.bats -f "DEV-077"` (0); `bash docs/agtoosa-verify.sh` (0)
- **Warnings/errors:** Verifier WARNs for Wave Plan pattern + missing Active Tasks tree (accepted)
- **Recommendations:** Ship as PATCH; keep Master-Plan updates deferred per review enrollment constraint
- **Spec sections affected:** Goal Contract | ACs | Threat model | Test plan
- **Confidence tier:** virtual-persona-only

## Findings

| Sev | Persona | Finding | Disposition |
|-----|---------|---------|-------------|
| 🟢 | Security Officer | STRIDE §2.3 present; spoofing mitigated by repo-owned GitHub/canonical paths; tampering by single checklist owner | Accepted |
| 🟢 | Security Officer | Handbook forbids tokens, private registry URLs, and signing private keys in examples | Accepted |
| 🟢 | Security Officer | Allowlist/denylist reminder blocks documenting pack writes to protected settings/CI | Accepted |
| 🟢 | Security Officer | Claim Boundary distinguishes documentation, CI-when-run AUTH checks, generator-enforced pack controls, manual registry approval, and roadmap | Accepted |
| 🟢 | Security Officer | Help adapters use absolute GitHub blob URLs — no generated-project-local `docs/` paths (FM-005) | Accepted |
| 🟢 | Security Officer | No registry install/publish/trust implementation changed | Accepted |
| 🟢 | Security Officer | AUTH-008 guards against labeling manual registry approval as CI-enforced | Accepted |
| 🟢 | EM | Scope matches build boundary: guides, Registry mirrors, README, help adapters, AUTH bats | Accepted |
| 🟢 | EM | New/changed docs under 500 lines (handbook 50; extension guide 238; help adapters ≤71) | Accepted |
| 🟢 | EM | Discovery surfaces link-only; substantive instructions owned by two canonical guides | Accepted |
| 🟢 | EM | AUTH bats provide deterministic inventory/link/parity/non-duplication checks | Accepted |
| 🟢 | EM | No new ADR required — documentation discovery anchored to existing registry/extension contracts | Accepted |
| 🟡 | EM | Verifier WARN: `DEV-077: no task tree under ## Active Tasks` — enrollment deferred Master-Plan mutation | Accepted — ship/orchestration housekeeping |
| 🟡 | EM | Verifier WARN: `spec has no ### Wave Plan section` — spec has `### 3.2 Wave Plan`; known pattern mismatch (same as DEV-075) | Accepted |
| 🟢 | CEO / PO | Goal: extension + pack guides discoverable from README and help without content fork | Accepted |
| 🟢 | CEO / PO | User outcome: contributor finds guides, completes readiness checklist, returns to owning handbook | Accepted |
| 🟢 | CEO / PO | Success: handbook exists; Registry/README/help point without copying full checklist (AUTH-003/004/005) | Accepted |
| 🟢 | CEO / PO | Non-goals respected: no new registry commands, pack generation, marketplace, or onboarding workflow | Accepted |
| 🟢 | CEO / PO | AC-001–AC-006 Must covered; AC-007 Should covered by AUTH-008 | Accepted |
| 🟢 | CEO / PO | Failure modes FM-001–FM-007 addressed by inventory, non-duplication, URL policy, and claim-boundary checks | Accepted |
| 🟢 | CEO / PO | Proof: AUTH-001–AUTH-008 green with RED/GREEN evidence in test plan | Accepted |
| 🟢 | QA | `bats tests/agtoosa.bats -f "DEV-077"` → exit 0, 8/8 AUTH-001–AUTH-008 | Accepted |
| 🟢 | QA | All Must ACs mapped: AC-001→001, AC-002→002, AC-003→003, AC-004→004, AC-005→005/006, AC-006→007 | Accepted |
| 🟢 | QA | Smoke set green: AUTH-002, AUTH-005, AUTH-007 | Accepted |
| 🟢 | QA | `bash docs/agtoosa-verify.sh` → PASS (40 pass, 20 warn, 0 fail); DEV-077 Gate 3 PASS | Accepted |
| 🟢 | QA | Spec approved (`## ✅ Spec Approved`); test plan GREEN evidence recorded | Accepted |
| 🟢 | QA | No web/mobile/a11y/performance matrix applicable — docs/adapter contract story | Accepted |
| 🟡 | QA | Verifier Active Tasks / Wave Plan WARNs (see EM) — do not block docs contract | Accepted |
| 🟡 | QA | Coverage threshold in `docs/Context/workflow.md` is product-oriented (100%); AUTH contract suite is the applicable proof for this chore | Accepted |

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Pass — authoring guides discoverable; single canonical owners |
| User outcome | 🟢 Pass — extension guide + pack checklist + discovery pointers |
| Success condition | 🟢 Pass — handbook + Registry/README/help links without duplicated checklists |
| Proof / evidence | 🟢 Pass — AUTH-001–AUTH-008 green; review + evidence ledger |
| Non-goals | 🟢 Pass — no registry behavior, pack publish, or new onboarding command |

## Terminal Evidence — QA

| Check | Command | Exit | Result |
|-------|---------|------|--------|
| DEV-077 AUTH suite | `bats tests/agtoosa.bats -f "DEV-077"` | 0 | ✅ 8/8 pass |
| Maintainer verifier | `bash docs/agtoosa-verify.sh` | 0 | ✅ PASS (40 pass · 20 warn · 0 fail) |
| Spec approval | `docs/archived/spec-DEV-077.md` | — | ✅ `## ✅ Spec Approved` |
| AC coverage (Must) | AC-001–AC-006 | — | ✅ AUTH-001–AUTH-007 |
| AC coverage (Should) | AC-007 | — | ✅ AUTH-008 |

## Part 2 — Simplification

Docs/discovery scope. Shared “Authoring resources” pointer across seven help adapters is intentionally duplicated static text (link-only) so adapters stay self-contained without fetching. No refactor required.

## Part 4 — Cross-Platform Second Opinion

Optional for this Standard-tier docs story. AUTH bats and virtual personas cover the contract; cross-platform second opinion not required.

## ✅ Review Approved

Approved: 2026-07-11 21:30  
Unresolved 🔴 Critical: 0

Next: `/agtoosa-ship` for DEV-077 as **v5.3.9** (PATCH+1) or batched with remaining-specs wave 1 peers per release policy.

> Note: Master-Plan Update Log / status mutation intentionally skipped this review pass (explicit enrollment constraint). Record approval at ship or when Master-Plan updates are authorized.
