# Spec: DEV-041 - Public launch publication proof

> **Story ID:** DEV-041
> **Epic:** DEV-003 - Community Template Registry / DEV-004 - Testing & QA Harness
> **Status:** Blocked on public publication
> **Estimate:** M
> **Spec created:** 2026-06-07
> **Launch specs:** LRS-017

## Context

DEV-035 through DEV-040 made the private-staging release honest and internally verifiable. The next launch risk is not local generator behavior; it is public distribution proof. AgToosa must prove that an anonymous developer can discover the repo, run the pinned install path, resolve the registry, inspect support/security pages, and see a concrete demo project without private permissions.

DEV-041 covers the publication proof stage after the repository is made public. It explicitly keeps public URL checks as a manual/public gate while the repository remains private.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Prove AgToosa can be installed and evaluated from public GitHub surfaces without private access. |
| User outcome | A new developer can run the public quickstart, verify the registry/support links, and inspect a demo project that shows first-run value. |
| Success condition | `scripts/check-launch-readiness.sh --mode public` passes after publication, release/tag/bootstrap/registry/Homebrew/support URLs are anonymous-accessible, and a public proof project demonstrates the first-15-minute workflow. |
| Proof / evidence | Public-mode checker output, anonymous curl/GitHub checks, release asset/tag evidence, registry JSON evidence, Homebrew tap evidence, demo project link, and updated launch docs. |
| Non-goals | Changing core generator behavior, adding enterprise signed registry, or making private launch claims before public access exists. |
| Assumptions | Repo visibility, release publication, registry publication, and Homebrew tap publication require owner-controlled GitHub actions outside local-only validation. |
| Risks | Public announcement before anonymous install works; stale README pins; registry or tap 404; demo project too artificial to prove value. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN the repo is public THE SYSTEM SHALL pass `scripts/check-launch-readiness.sh --mode public` from a clean network environment. |
| AC-002 | WHEN a developer follows README quickstart THE SYSTEM SHALL install from a pinned public release tag, not only the `main` branch. |
| AC-003 | WHEN public bootstrap URLs are checked THE SYSTEM SHALL expose both Bash and PowerShell bootstrap files anonymously from `main` and the current release tag where applicable. |
| AC-004 | WHEN registry distribution is checked THE SYSTEM SHALL expose `registry.json` anonymously and verify listed pack URLs/SHA fields for at least one public example or document that no public packs are published yet. |
| AC-005 | WHEN Homebrew is advertised THE SYSTEM SHALL either provide an anonymous-accessible tap/formula or clearly keep Homebrew marked private-staging/not launched. |
| AC-006 | WHEN support/community links are advertised THE SYSTEM SHALL expose issues, discussions, security policy, release page, and CI/security badges anonymously. |
| AC-007 | WHEN the launch proof is published THE SYSTEM SHALL include a public demo project or proof repo showing the first-15-minute workflow artifacts: generated files, spec, test plan, review, and ship/readiness evidence. |
| AC-008 | WHEN launch docs are updated THE SYSTEM SHALL preserve the enforcement boundary language: generator-enforced vs CI-enforced vs agent-instructed vs manual. |

## Design

Use the existing launch checker as the canonical automated gate. Add only narrowly scoped checks if public publication reveals missing surfaces. Keep private-staging wording until every public link passes. Create a demo/proof project that is small, inspectable, and repeatable from the first-15-minute guide.

Recommended proof flow:

1. Publish or confirm `sky2464/AgToosa` is public.
2. Publish release `v5.2.6` with bootstrap files and matching changelog.
3. Publish or confirm `sky2464/agtoosa-registry` and `registry.json`.
4. Publish or confirm `sky2464/homebrew-agtoosa`, or keep Homebrew explicitly gated.
5. Run public-mode launch readiness from a clean environment.
6. Create a public demo project from the first-15-minute walkthrough.
7. Update README launch wording only after anonymous checks pass.

## Build Scope

Likely files in scope after publication: `scripts/check-launch-readiness.sh`, `README.md`, `.github/RELEASE.md`, registry docs, Homebrew formula/tap notes, `docs/examples/first-15-minutes.md`, `docs/AgToosa_Team_Trust_Roadmap.md`, `docs/Master-Plan.md`, and focused Bats coverage if the checker changes.

## Task Tree

- [ ] **1.** Publish/confirm anonymous repo and release surfaces - _AC-001, AC-002, AC-003, AC-006_ `[manual/publication blocked]`
- [x] **2.** Run public-mode launch readiness and capture output - _AC-001, AC-006_
- [x] **3.** Verify registry and Homebrew distribution status - _AC-004, AC-005_
- [ ] **4.** Create or link public first-15-minute proof project - _AC-007_ `[manual/publication blocked]`
- [ ] **5.** Update README launch wording only after public checks pass - _AC-002, AC-005, AC-008_ `[manual/publication blocked]`
- [x] **6.** Add or update focused tests if checker/docs behavior changes - _AC-001-AC-008_
- [x] **7.** Record validation evidence in the DEV-041 test plan - _AC-001-AC-008_

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-041.md`
