# Spec: DEV-018 — Registry Pack Queue

> **Story ID:** DEV-018
> **Epic:** DEV-003 — Community Template Registry
> **Status:** 🏁 Shipped (v4.12.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

DEV-003 fixed **CB-1**: `KEEP_SHIP=true` so `--registry install` does not delete `ship/packs/` on EXIT. The documented two-step flow is still broken when the user runs interactive `bash agtoosa.sh`: the generator rebuilds ephemeral `ship/` (`rm -rf ship` before `stage_files`), which erases staged packs before `install_files` can merge them.

`ship/` is intentionally non-durable ([`docs/agtoosa-maintainer.md`](agtoosa-maintainer.md)). Packs must stage outside `ship/`.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Registry pack installs survive until the next project install/merge. |
| User outcome | `bash agtoosa.sh --registry install <pack>` then `bash agtoosa.sh` merges pack files into the target project. |
| Success condition | Queue under `.agtoosa/pack-queue/`; merge on install; legacy `ship/packs` salvaged; bash + PS1 parity; PK1–PK5 bats green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "PK"` + manual smoke in test plan. |
| Non-goals | `--registry install --project` one-shot; registry hosting changes. |
| Assumptions | Same extension allowlist as existing `_merge_pack`. |
| Risks | PS1 pack merge is new behavior — must match bash allowlist. |

### 1.2 User Stories

**As a** developer installing a community pack, **I want** staged files to persist after `bash agtoosa.sh` rebuilds `ship/` **so that** packs merge into my project on the next install.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `--registry install` stages a pack THE SYSTEM SHALL write to `${SCRIPT_DIR}/.agtoosa/pack-queue/<name>/`, not only `ship/packs/` | Must |
| AC-002 | WHEN interactive install runs THE SYSTEM SHALL merge queued packs into `PROJECT_PATH` and remove queue entries on success | Must |
| AC-003 | WHEN `ship/packs/` exists before `ship/` wipe THE SYSTEM SHALL salvage packs into the queue | Must |
| AC-004 | WHEN DEV-018 ships THE SYSTEM SHALL add bats PK1–PK5 | Must |
| AC-005 | WHEN using `agtoosa.ps1` THE SYSTEM SHALL stage to the queue and merge packs on install | Must |

## 2. Design

### 2.1 Architecture

| Layer | Files | Change |
|-------|-------|--------|
| Queue path | `agtoosa.sh`, `agtoosa.ps1` | `PACK_QUEUE_DIR` default `${SCRIPT_DIR}/.agtoosa/pack-queue`; override `AGTOOSA_PACK_QUEUE_DIR` |
| Stage / salvage | `lib/registry.sh` | `registry_install` and `_install_local_pack` stage to queue; `_salvage_ship_packs_to_queue` before `ship/` wipe |
| Merge | `lib/install.sh` | `_merge_pack_queue` + legacy `_merge_ship_staged_packs` from `install_files` |
| Docs | `docs/AgToosa_Registry.md`, `template/Docs/AgToosa_Registry.md`, `docs/agtoosa-maintainer.md` | Two-step flow documents durable queue |
| Tests | `tests/agtoosa.bats` | PK1–PK5 |

### 2.2 Build Scope

✅ Ready to proceed — Scope Boundary

Files in scope: `agtoosa.sh`, `agtoosa.ps1`, `lib/registry.sh`, `lib/install.sh`, `docs/AgToosa_Registry.md`, `template/Docs/AgToosa_Registry.md`, `docs/agtoosa-maintainer.md`, `.gitignore`, `tests/agtoosa.bats`, `CHANGELOG.md`

Directories in scope: `lib/`, `tests/`, `docs/`, `template/Docs/`

Out of scope: `agtoosa-lock.json` auto-pinning; remote registry hosting; one-shot `--registry install --project`

### 2.3 Test Plan

Test plan: [`docs/AgToosa_TestPlan-DEV-018.md`](AgToosa_TestPlan-DEV-018.md)

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Pack queue core (bash)
  - [x] 1.1 `PACK_QUEUE_DIR` + `_ensure_pack_queue_dir` / `_pack_queue_dir_for` — _AC-001_
  - [x] 1.2 Stage registry and local installs to queue — _AC-001_
  - [x] 1.3 `_salvage_ship_packs_to_queue` before `rm -rf ship` — _AC-003_
- [x] **2.** Merge on project install
  - [x] 2.1 `_merge_packs_under_root` + `_merge_pack_queue` in `install_files` — _AC-002_
  - [x] 2.2 Legacy `ship/packs/` merge retained — _AC-003_
- [x] **3.** PowerShell parity
  - [x] 3.1 Queue staging, salvage, `Install-Files` merge + lock update — _AC-005_
- [x] **4.** Documentation
  - [x] 4.1 Registry docs + maintainer note; `.gitignore` for `.agtoosa/` — _AC-001–AC-003_
- [x] **5.** Tests
  - [x] 5.1 PK1–PK5 bats — _AC-004_
  - [x] 5.2 Run PK filter + registry smoke; record evidence — _AC-004_

## ✅ Spec Approved

Approved: 2026-05-24
