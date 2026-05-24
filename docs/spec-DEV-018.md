# Spec: DEV-018 — Registry Pack Queue

> **Story ID:** DEV-018
> **Epic:** DEV-003 — Community Template Registry
> **Status:** In progress
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

See implementation plan: durable `PACK_QUEUE_DIR`, helpers in `lib/registry.sh` and `lib/install.sh`, salvage hook in `agtoosa.sh` / `agtoosa.ps1`.

Test plan: [`docs/AgToosa_TestPlan-DEV-018.md`](AgToosa_TestPlan-DEV-018.md).
