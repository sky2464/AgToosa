# Review: DEV-053 — Extension and Preset Catalog

> **Story:** DEV-053  
> **Date:** 2026-07-11  
> **Verdict:** ✅ PASS  
> **Suggested release:** PATCH **5.3.7 → 5.3.8** (ADR-005 patch-first; may batch with DEV-075 / DEV-078 / DEV-081 parallel cycle)

## Summary

Catalog discovery and non-executing preset planning over registry-backed packs: `lib/catalog.sh`, `catalog/catalog.json` + schema, `--catalog` CLI (Bash + PS1 Bash delegation), canonical `AgToosa_Catalog.md`, thin platform adapters, three maintained production entries, and PC-001–PC-008 bats. Registry remains install authority; trust/provenance fields render separately. Goal Contract satisfied.

| Persona | 🔴 Critical | 🟡 Warning | 🟢 Passed |
|---------|-------------|------------|-----------|
| Security Officer | 0 | 2 | 8 |
| Engineering Manager | 0 | 3 | 6 |
| CEO / Product Owner | 0 | 0 | 8 |
| QA Lead | 0 | 2 | 7 |
| Independent Cross-Model Reviewer | 0 | 1 | 12 |
| **Unresolved Critical** | **0** | — | — |

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Recommended (STRIDE supply-chain/registry surfaces; Must ACs AC-004–AC-007, AC-009) |
| Reviewer identity | Independent Security Review subagent |
| Model/platform | Composer 2.5 / Cursor |
| Outcome | completed |
| Skip rationale | — |

### Cross-model evidence: security-reviewer (DEV-053)

- **Reviewer identity:** Independent Security Review subagent (cross-model lane)
- **Model/platform:** Composer 2.5 / Cursor
- **Findings:** 0 Critical · 1 Warning (W-001) · 12 Passed STRIDE controls
- **Files read:** `lib/catalog.sh`, `catalog/catalog.json`, `catalog/catalog.schema.json`, `agtoosa.sh`, `agtoosa.ps1`, `lib/registry.sh`, `docs/AgToosa_Catalog.md`, `template/.cursor/commands/agtoosa-catalog.md`, `tests/agtoosa.bats` (PC-001–PC-008), `tests/fixtures/catalog/*`, `docs/archived/spec-DEV-053.md`
- **Commands:** None executed (read-only; bats/verifier run by orchestrator)
- **Warnings/errors:** W-001 — `catalog info` may call `fetch_registry` when cache is cold (network I/O; not pack-content download)
- **Recommendations:** Document cache-only behavior in `AgToosa_Catalog.md` or restrict `info` to cache-only registry lookup in a follow-up patch
- **Spec sections affected:** Goal Contract · ACs · Architecture · Threat model · Test plan
- **Confidence tier:** `reviewer-only`

**Merged finding (reviewer-only):**

| Sev | Finding | Disposition |
|-----|---------|-------------|
| 🟡 | W-001: `catalog info` can invoke `fetch_registry` when `REGISTRY_CACHE_FILE` is absent — network I/O on a discovery command | **Accepted** — AC-006 forbids pack-content download/queue/merge/execute; registry index metadata fetch is bounded and does not bypass install gates; offline path reports `unknown`; optional doc/hardening follow-up |

## Findings

| Sev | Persona | Finding | Disposition |
|-----|---------|---------|-------------|
| 🟡 | Security | W-001: cold-cache `info` may network-fetch registry index (cross-model) | **Accepted** — see Cross-Model Review |
| 🟡 | Security | `jq` required for catalog commands — supply-chain dependency consistent with registry flows | **Accepted** |
| 🟢 | Security | Forbidden `command`/`shell`/`exec` fields rejected; shell metacharacters and credential URLs blocked | **Passed** — PC-007 |
| 🟢 | Security | Plan commands derived only from validated `registry_name` + semver tokens | **Passed** — PC-005, PC-007 |
| 🟢 | Security | Registry snapshot reconciliation marks stale entries; plan withholds ready commands | **Passed** — PC-004 |
| 🟢 | Security | Trust fields separate; “not a security guarantee” in output and docs | **Passed** — PC-003 |
| 🟢 | Security | Size/cycle/member bounds; traversal rejection | **Passed** — PC-007 |
| 🟢 | Security | No catalog install path; delegates to `--registry install` | **Passed** — PC-005, PC-008 |
| 🟢 | Security | STRIDE mitigations from spec §2.3 implemented in `lib/catalog.sh` | **Passed** |
| 🟡 | EM | `lib/catalog.sh` is 665 lines (exceeds 500-line soft limit) | **Accepted** — cohesive module; split deferred unless reuse grows |
| 🟡 | EM | `docs/Context/CONTEXT.md` absent — domain-language lint skipped | **Accepted** — catalog meta-surface; no user-domain API |
| 🟡 | EM | PowerShell `-Catalog` delegates to Bash implementation | **Accepted** — spec allows Bash-first; PS1 wrapper present |
| 🟢 | EM | Schema + CLI interfaces match spec blueprint (`list`, `search`, `info`, `validate`, `plan`) | **Passed** |
| 🟢 | EM | Canonical Catalog doc links Registry; does not duplicate denylist/tar-slip rules | **Passed** — PC-008 |
| 🟢 | EM | Config registration and thin adapters installed | **Passed** — PC-008 |
| 🟢 | EM | No contradictory architecture boundaries vs registry install authority | **Passed** |
| 🟢 | CEO / PO | Goal: versioned catalog for discovery with registry install authority preserved | **Passed** |
| 🟢 | CEO / PO | User outcome: search/info/plan with compatibility and trust transparency | **Passed** |
| 🟢 | CEO / PO | Success: CLI subcommands + three maintained entries + PC-001–PC-008 green | **Passed** |
| 🟢 | CEO / PO | Non-goals respected: no marketplace, auto-install, or registry override | **Passed** — PC-003, PC-008 |
| 🟢 | CEO / PO | Three production entries with distinct owners (`ext-ml-pipeline`, `ext-react-native`, `preset-fullstack-ml`) | **Passed** — PC-006 |
| 🟢 | CEO / PO | Claim boundary honest in `AgToosa_Catalog.md` | **Passed** |
| 🟢 | CEO / PO | Install plans non-executing; per-pack registry consent remains mandatory | **Passed** — PC-005 |
| 🟢 | CEO / PO | Proof captured in test plan GREEN blocks | **Passed** |
| 🟢 | QA | `bats tests/agtoosa.bats -f "DEV-053"` → exit 0, 9/9 pass (CW-016 + PC-001–PC-008) | **Passed** |
| 🟢 | QA | All 12 Must ACs mapped to PC-001–PC-008 with passing automation | **Passed** |
| 🟢 | QA | Smoke set green: PC-001, PC-002, PC-004, PC-005, PC-006 | **Passed** |
| 🟢 | QA | Read-only mutation check: pack-queue file count unchanged (PC-005) | **Passed** |
| 🟢 | QA | `bash docs/agtoosa-verify.sh` → PASS (27 pass · 5 warn · 0 fail) | **Passed** |
| 🟡 | QA | Verifier WARN: `DEV-053: spec has no ### Wave Plan section` — spec has `### 3.2 Wave Plan`; known pattern mismatch | **Accepted** |
| 🟡 | QA | `git diff --check` not run in test plan regression block | **Accepted** — ship housekeeping |

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Pass — versioned catalog with registry install authority and explicit trust boundaries |
| User outcome | 🟢 Pass — discover extensions/presets, evaluate compatibility, receive safe registry-backed plan |
| Success condition | 🟢 Pass — `list`/`search`/`info`/`validate`/`plan`; stale/incompatible fail safe; three entries + PC-001–PC-008 green |
| Proof / evidence | 🟢 Pass — fixtures, production entries, bats GREEN, review + evidence ledger |
| Non-goals | 🟢 Pass — no marketplace, silent preset install, or catalog registry authority |

## Terminal Evidence — QA

| Check | Command | Exit | Result |
|-------|---------|------|--------|
| DEV-053 PC suite | `bats tests/agtoosa.bats -f "DEV-053"` | 0 | ✅ 9/9 pass |
| Maintainer verifier | `bash docs/agtoosa-verify.sh` | 0 | ✅ PASS (27 pass · 5 warn · 0 fail) |
| Spec approval | `docs/archived/spec-DEV-053.md` | — | ✅ `## ✅ Spec Approved` |
| AC coverage (Must) | AC-001–AC-012 | — | ✅ PC-001–PC-008 |

## Part 2 — Simplification

`lib/catalog.sh` is long but single-purpose (validate → discover → evaluate → plan). No refactor required for ship; consider extracting compatibility/plan helpers if catalog grows beyond v1.

## Part 4 — Cross-Platform Second Opinion

Optional. Cross-model security lane completed on Composer 2.5. Cross-platform manual review optional for supply-chain stories; not blocking given green bats + cross-model STRIDE pass.

## ✅ Review Approved

Approved: 2026-07-11 20:55  
Unresolved 🔴 Critical: 0
