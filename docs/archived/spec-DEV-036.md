# Spec: DEV-036 - Windows and registry parity

> **Story ID:** DEV-036
> **Epic:** DEV-001 - Core Generator Engine / DEV-003 - Community Template Registry
> **Status:** 🏁 Shipped (v5.2.6 — 2026-06-07)
> **Estimate:** M
> **Spec created:** 2026-06-07
> **Launch specs:** LRS-003, LRS-006, LRS-010

## Context

The launch review found two parity risks that directly weaken trust: PowerShell `-Update` can report success while leaving platform files and `Docs/.agtoosa-version` stale, and registry publish/install shape can produce nested pack paths. It also found inconsistent PowerShell registry publish documentation.

DEV-036 makes Windows and registry behavior defensible before launch.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Bring PowerShell update and registry behavior into parity with Bash where advertised, and state any remaining PowerShell boundary clearly. |
| User outcome | Windows users can update installed AgToosa assets without silent drift, and registry packs install into a predictable layout. |
| Success condition | PowerShell update detects installed platforms, preserves user content, updates managed files/version marker, registry publish/install archive shape is canonical, and help/docs agree on PowerShell publish support. |
| Proof / evidence | Focused DEV-036 Bats/PowerShell tests, registry publish-to-install smoke, PowerShell parser/analyzer checks where applicable, and `git diff --check` pass. |
| Non-goals | Public repo publication, Homebrew hardening, README competitive positioning, or signed registry index. |
| Assumptions | Native PowerShell publish may remain unsupported if documented and tested consistently. |
| Risks | Fixing registry shape can break existing test fixtures. Mitigate by documenting canonical shape and updating tests to cover real publish output. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN `agtoosa.ps1 -Update` runs THE SYSTEM SHALL detect installed platform adapters instead of passing an empty platform list. |
| AC-002 | WHEN PowerShell update touches context files THE SYSTEM SHALL preserve user-authored content and update AgToosa-managed blocks. |
| AC-003 | WHEN PowerShell update succeeds THE SYSTEM SHALL write current version to `Docs/.agtoosa-version`. |
| AC-004 | WHEN a pack is published and then installed THE SYSTEM SHALL NOT create duplicate nested `<pack>/<pack>/` paths. |
| AC-005 | WHEN Bash and PowerShell install the same registry pack THE SYSTEM SHALL produce equivalent `.agtoosa/pack-queue/<pack>/...` layout. |
| AC-006 | WHEN PowerShell help, comments, and README describe registry commands THE SYSTEM SHALL list the same supported native commands. |
| AC-007 | WHEN `publish` is not supported natively in PowerShell THE SYSTEM SHALL fail with a clear Bash/WSL/Git Bash alternative. |

## Design

Implement a PowerShell installed-platform detector equivalent to Bash update detection. Pass detected platforms into PowerShell staging/install. Update the version marker only after successful update.

Define one canonical registry archive contract. Either publish root files inside the tarball or normalize one top-level directory during install; tests must cover the real publish path, not a hand-built fixture that hides layout drift.

Normalize PowerShell registry publish docs and runtime behavior.

## Build Scope

Files in scope: `agtoosa.ps1`, `lib/registry.sh`, `README.md`, `docs/AgToosa_Registry.md`, `tests/agtoosa.bats`, `docs/AgToosa_TestPlan-DEV-036.md`, and related registry fixtures.

## Task Tree

- [ ] **1.** Add failing PowerShell update parity tests - _AC-001-AC-003_
- [ ] **2.** Implement PowerShell installed-platform detection and version marker update - _AC-001-AC-003_
- [ ] **3.** Add failing registry publish-to-install shape test - _AC-004, AC-005_
- [ ] **4.** Align registry publish/install canonical shape - _AC-004, AC-005_
- [ ] **5.** Normalize PowerShell registry publish help/docs/runtime behavior - _AC-006, AC-007_
- [ ] **6.** Run focused Bats, PowerShell parser/analyzer, registry smoke, full Bats, and `git diff --check` - _AC-001-AC-007_

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-036.md`
