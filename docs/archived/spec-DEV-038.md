# Spec: DEV-038 - Distribution hardening and release readiness gate

> **Story ID:** DEV-038
> **Epic:** DEV-004 - Testing & QA Harness
> **Status:** 🏁 Shipped (v5.2.6 — 2026-06-07)
> **Estimate:** M
> **Spec created:** 2026-06-07
> **Launch specs:** LRS-008, LRS-011, LRS-013

## Context

Public launch needs distribution paths that are verifiable. The launch review found Homebrew is advertised before the public tap is ready, release workflows use deprecated release actions, and launch-critical checks are not part of CI or release readiness.

DEV-038 hardens distribution and release gates after DEV-035 establishes private/public readiness mode.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make advertised distribution paths and release automation verifiable before public announcement. |
| User outcome | Maintainers can prove the release, raw bootstrap, registry, and Homebrew surfaces are ready before launch. |
| Success condition | Homebrew docs/formula are public-ready or clearly gated, deprecated release action usage is removed, and launch readiness checks cover advertised public URLs and docs/security drift. |
| Proof / evidence | Release-readiness command, workflow/static checks, Homebrew verification or explicit private-staging gate, and `git diff --check` pass. |
| Non-goals | Making the repo public, changing PowerShell update behavior, rewriting competitor positioning, or adding signed registry index. |
| Assumptions | Public URL checks may remain manual or env-gated until repo publication. |
| Risks | Public checks can fail in private staging. Mitigate with explicit `private` and `public` modes. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN Homebrew is advertised THE SYSTEM SHALL either verify `brew install sky2464/agtoosa/agtoosa` or mark Homebrew unavailable until tap publication. |
| AC-002 | WHEN the formula is public-ready THE SYSTEM SHALL use a tagged release archive or stable release asset with concrete SHA-256. |
| AC-003 | WHEN release workflows are inspected THE SYSTEM SHALL NOT use deprecated `actions/create-release@v1`. |
| AC-004 | WHEN release automation runs THE SYSTEM SHALL have a dry-run or non-publishing validation path for private staging. |
| AC-005 | WHEN launch-readiness checks run in public mode THE SYSTEM SHALL check repo, releases, raw bootstrap, registry, issues/discussions/support, badges, security policy, and Homebrew if advertised. |
| AC-006 | WHEN release docs are read THE SYSTEM SHALL explain required permissions and failure recovery. |

## Design

Extend the DEV-035 launch checker or release workflow with public-mode URL checks. Modernize release creation to `gh release create` or a maintained action. Gate Homebrew docs behind either a verified public tap or explicit private-staging language.

## Build Scope

Files in scope: `Formula/agtoosa.rb`, `README.md`, `.github/workflows/release.yml`, `.github/workflows/release-advanced.yml`, `.github/RELEASE.md`, `scripts/check-launch-readiness.sh`, `tests/agtoosa.bats`, and `docs/AgToosa_TestPlan-DEV-038.md`.

## Task Tree

- [ ] **1.** Add failing distribution/release-readiness tests - _AC-001-AC-006_
- [ ] **2.** Gate or verify Homebrew installation docs and formula source - _AC-001, AC-002_
- [ ] **3.** Replace deprecated release action usage - _AC-003, AC-004_
- [ ] **4.** Extend launch-readiness checks for public surfaces and docs/security drift - _AC-005_
- [ ] **5.** Update release docs with permissions and recovery steps - _AC-006_
- [ ] **6.** Run focused checks, workflow static checks, shellcheck, and `git diff --check` - _AC-001-AC-006_

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-038.md`
