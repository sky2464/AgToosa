# Spec: DEV-022 — Registry Publish Parity & Offline Cache Hardening

> **Story ID:** DEV-022
> **Epic:** DEV-003 — Community Template Registry
> **Status:** 🔍 In Review (review approved — pending ship)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

Post–DEV-020 registry work still has audit leftovers (v3.1 prod-readiness):

- **MF-4:** PowerShell `--registry publish` is not implemented; users get "Unknown registry command".
- **Offline cache:** `AGTOOSA_REGISTRY_CACHE_DIR` and cached `registry.json` work for tests, but production docs lack explicit trust/offline guidance (audit SI-5): HTTPS-only trust, when to refresh, stale-cache behavior.

DEV-003 fixed Bash `registry_publish` JSON via `jq -n` (RG5). This story does **not** re-litigate publish JSON — it closes PS1 parity and documents/tests offline cache contracts.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | PS1 registry users get a clear, correct `publish` path; offline/cache behavior is documented and regression-tested. |
| User outcome | Windows-first developers are not dead-ended on publish; air-gapped or cached registry use is predictable. |
| Success condition | PS1 `publish` subcommand handled; cache trust note in registry docs; bats **RC1–RC3** green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "RC[1-3]:"` green. |
| Non-goals | Full PS1 publish wizard parity with Bash; GPG-signed registry; `agtoosa-lock.json`; changing fetch URL or index schema. |
| Assumptions | Bash remains the canonical publish implementation for v1. |
| Risks | Over-scoping PS1 wizard → keep redirect/message only unless trivial. |

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a user runs `agtoosa.ps1 --registry publish` THE SYSTEM SHALL not fail with an unknown-command error; THE SYSTEM SHALL print actionable guidance to use Bash publish (or implement minimal wizard — team choice at build: **redirect only** for S estimate) | Must |
| AC-002 | WHEN registry docs describe offline use THE SYSTEM SHALL state cache location, HTTPS trust model, and that users should verify SHA-256 for high-assurance installs | Must |
| AC-003 | WHEN `fetch_registry` uses a valid `AGTOOSA_REGISTRY_CACHE_DIR` with fresh `registry.json` THE SYSTEM SHALL read cache without network (existing behavior) — bats proves cache hit path | Must |
| AC-004 | WHEN DEV-022 ships THE SYSTEM SHALL add bats **RC1–RC3** for PS1 publish message, doc trust note, and cache-dir isolation | Must |

### 1.3 Out of Scope

- Interactive PS1 publish wizard (defer unless estimate raised to M)
- Registry server or signed manifests
- Changing DEV-020 version pinning logic

## 2. Design

### 2.1 Architecture Blueprint

| Layer | Files | Change |
|-------|-------|--------|
| PowerShell | `agtoosa.ps1` | Add `publish` case: print message + exit 0 or 1 with `bash agtoosa.sh --registry publish` instruction |
| Bash registry | `lib/registry.sh` | Optional: comment at `fetch_registry` for HTTPS trust (if not already present) |
| Docs | `docs/AgToosa_Registry.md`, `template/Docs/AgToosa_Registry.md` | Offline cache + trust subsection |
| Tests | `tests/agtoosa.bats` | RC1: PS1 publish guidance; RC2: doc grep; RC3: cache dir used without fetch when file present |

### 2.2 STRIDE (abbreviated)

| Threat | Mitigation |
|--------|------------|
| Stale malicious cache trusted forever | Document refresh via `--registry update` / delete cache; SHA-256 still verified per pack |
| PS1 users publish via broken path | Explicit redirect to Bash |

### 2.3 Build Scope

Files in scope: `agtoosa.ps1`, `lib/registry.sh` (comments only), registry docs, `tests/agtoosa.bats`

Out of scope: `registry_publish` Bash rewrite, generator template platform files

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** PowerShell publish parity
  - [x] 1.1 Add `publish` branch in `Invoke-Registry` with clear Bash redirect — _AC-001_
- [x] **2.** Offline cache documentation
  - [x] 2.1 Add cache location, HTTPS trust, SHA-256 verification note to maintainer + template registry docs — _AC-002_
  - [x] 2.2 Optional trust comment in `fetch_registry` — _AC-002_
- [x] **3.** Tests RC1–RC3
  - [x] 3.1 RC1 PS1 publish output; RC2 doc grep; RC3 cache-only registry read — _AC-003, AC-004_
  - [x] 3.2 `docs/AgToosa_TestPlan-DEV-022.md` — _AC-004_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2

**Wave 2:** 3.1, 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-022.md`

## ✅ Spec Approved

Approved: 2026-05-24
