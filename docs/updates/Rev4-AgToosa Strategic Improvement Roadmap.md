# Rev4 — AgToosa Owner Review and Strategic Improvement Roadmap

> **Enrolled DEV stories:** DEV-086–DEV-106 — see `docs/Master-Plan.md` and `docs/updates/roadmap-spec-index.md`.

## Decision

If I owned AgToosa, I would **not rewrite its Shell/PowerShell core, build a SaaS platform, or chase an “agent OS” identity**. I would make it the most credible, local-first, verifiable workflow kit for developers who use coding agents but do not trust prompt-only process claims.

AgToosa already has a meaningful foundation: a public, markdown-first workflow, multi-assistant adapters, pinned release installation, a proof-project path, documented security boundaries, and deterministic verification/CI concepts. The highest-return work now is to turn those assets into a sharply proven product rather than to add conceptual breadth.

## Owner Thesis

**Positioning:** *A repo-native control plane for disciplined AI-assisted delivery.*

- **Repo-native:** artifacts live in Git and survive model/vendor churn.
- **Model-neutral:** the workflow should work whether a team uses Claude, Cursor, Codex, Copilot, Gemini, or a future assistant.
- **Evidence-led:** guidance is useful, but release confidence must come from deterministic checks, test output, policy checks, and reviewer decisions.
- **Local-first:** the core should remain inspectable Shell/PowerShell and should not require an account, hosted service, telemetry, or a proprietary runtime.

This resolves a central market issue: coding-agent output is non-deterministic, so reliable teams need deterministic contracts, tests, and evaluation evidence around it rather than more elaborate prompts.[web:98][web:102]

## What I Would Preserve

| Preserve | Why |
|---|---|
| Shell and PowerShell generators | They are transparent, auditable, portable, easy to fork, and coherent with a local-first product. |
| Markdown workflow artifacts | They are human-reviewable, Git-native, assistant-independent, and low friction. |
| Spec → Build → Review → Ship lifecycle | It is understandable, teachable, and maps to real delivery work. |
| STRIDE/security-first posture | It differentiates AgToosa from generic prompt packs, especially for security-conscious developers. |
| No-target-runtime principle | It protects adoption: users add workflow files instead of another application dependency. |
| Open-source-first distribution | It is the right way to build credibility, contributor trust, and consulting opportunities before commercial complexity. |

## What I Would Change

### 1. Turn “proof” into the product’s main experience

**Problem:** A strong framework can still feel abstract. Users should not have to read a long README before seeing the before/after result.

**Change:** Make one canonical proof journey the first thing every visitor sees:

1. Install a pinned release.
2. Clone or open the tiny proof repository.
3. Run `/agtoosa-init`.
4. Create one small feature spec.
5. Build it.
6. Run `--verify` and inspect the resulting evidence.
7. Open the generated artifacts in Git.

**Acceptance criteria:**
- A new user reaches a successful verification result in 15 minutes or less.
- The proof repo stays intentionally small and version-pinned.
- README has one primary CTA, not several competing install paths.
- A short terminal recording demonstrates the entire flow.

**Why:** The SDD space is crowded; users compare tools by time-to-value and evidence, not feature-count claims.[web:42][web:72]

### 2. Make deterministic verification the product wedge

**Problem:** “Multi-persona review” and “security-first” are valuable but can sound like prompt marketing unless the repo demonstrates what is actually enforced.

**Change:** Define an explicit three-level assurance model in docs and CLI output:

| Level | Meaning | Examples |
|---|---|---|
| Guided | The AI workflow asks for an action | STRIDE analysis, architecture discussion, QA persona |
| Evidenced | The action must produce an artifact | Spec, test-plan, review record, SBOM reference |
| Enforced | A local/CI check can fail deterministically | required files, phase state, test command, lint/SAST exit code |

Add `agtoosa verify --format json` and a stable machine-readable schema, then ship a GitHub Action that consumes it.

**Why:** Tests and deterministic evaluation are the correct counterpart to non-deterministic agent behavior; modular and inspectable controls are preferable to one opaque prompt loop.[web:98][web:102]

### 3. Replace generic claims with an Evidence Contract

**Problem:** “Secure,” “tested,” and “ship-ready” can be interpreted differently by every model and user.

**Change:** Add `Docs/AgToosa_Evidence_Contract.md` and a small `.agtoosa/evidence.yml` configuration format. It should define the minimum evidence for each delivery class:

```yaml
profiles:
  standard:
    required: [spec, tests, review]
  security-sensitive:
    required: [spec, threat-model, tests, sast, dependency-scan, review]
  release:
    required: [spec, tests, review, changelog, rollback-note]
```

The verifier should validate **presence, provenance, and command outcomes**, not pretend to judge semantic correctness. Human/agent semantic reviews remain explicitly guided/evidenced.

**Why:** This is an honest boundary that improves trust without creating a complicated platform.

### 4. Make a small “core” and move optional complexity into packs

**Problem:** A growing framework can bury its simple value proposition under commands, personas, adapters, and templates.

**Change:** Establish a core contract with only:
- Init
- Spec
- Build
- Review
- Ship
- Verify
- Doctor

Everything else should be optional: specialty reviewers, compliance guidance, framework conventions, deployment patterns, and integration recipes belong in packs.

**Rule:** A new feature enters core only if it is model-neutral, local-first, broadly useful, testable in Shell/PowerShell, and required by most users. Otherwise it is a pack.

### 5. Treat the registry as a curated trust surface, not a growth metric

**Problem:** A registry grows risk faster than value if arbitrary templates can alter repository guidance.

**Change:** Start with 5–8 maintained official packs and a strict pack contract:
- `manifest.json` with name, version, supported platforms, compatibility, file allowlist, SHA-256, maintainer.
- Documentation, example repo, tests, and a security review checklist.
- A `verified` designation only for packs maintained or reviewed by project maintainers.
- Community packs remain possible but clearly labeled.

Suggested initial packs:
- FastAPI service
- Node/TypeScript API
- React frontend
- Terraform/IaC
- Security-sensitive application
- Python CLI

Defer federation, marketplace payments, pagination work, and broad pack quantity until actual use proves demand.

### 6. Finish safe upgrades before adding new capabilities

**Problem:** Installation into another repository creates a trust obligation: users need to know updates will not overwrite local customization silently.

**Change:** Make the migration wizard/major-version update flow a top product item:
- Detect major version deltas.
- Dry-run displays an exact categorized plan: overwrite / merge / preserve / manual action.
- Write a timestamped rollback manifest.
- Require explicit confirmation for generated-file replacement.
- Provide `--json` output for CI and fleet scripting.

This is a stronger near-term investment than a binary rewrite, SaaS dashboard, or expanded agent orchestration.

### 7. Build a real compatibility contract for assistants

**Problem:** “Supported platform” can mean installation works, commands are generated, or the assistant reliably follows the workflow. Those are different promises.

**Change:** Publish a compatibility matrix with three test levels:

| Test | Meaning |
|---|---|
| Install | Generator creates/merges expected files correctly |
| Render | Commands/rules parse and appear in the target assistant |
| Scenario | A fixed proof task produces required workflow artifacts |

Run install tests on every PR and scenario tests on a scheduled cadence or release candidate. Keep tests small and public.

### 8. Simplify documentation around user jobs

**Problem:** Mature markdown projects often become well documented but hard to navigate.

**Change:** Organize docs by job, not command/file name:
- **Start:** 15-minute proof, install, first project
- **Use:** feature lifecycle, daily loop, common mistakes
- **Trust:** verification, security boundary, evidence contract
- **Adapt:** packs, custom rules, multi-assistant repos
- **Maintain:** upgrades, doctor, uninstall, contributing

A static GitHub Pages site is worthwhile only if it is generated from the same Markdown source and carries no operational backend.

### 9. Create a community flywheel before a commercial product

**Problem:** Donations appear only after users understand the project’s value and believe it will be maintained.

**Change:** For the next year, prioritize reputation assets:
- GitHub Sponsors with modest recognition-based tiers.
- Transparent public roadmap and monthly changelog post.
- One proof-quality blog/video per month.
- A “Built with AgToosa” showcase.
- Two well-scoped contributor paths: adapter improvements and official-pack contributions.
- Security disclosure and response expectations.

**Business sequence:** reputation → adoption proof → sponsors → consulting/training → paid support → only then optional enterprise conveniences. Support, services, training, and sponsorship are standard ways to monetize open-source tools without restricting the core.[web:101][web:103][web:105]

### 10. Do not sell a Pro tier until a paid problem exists

**Problem:** A Pro tier that merely gates docs or small conveniences damages goodwill and creates support work before demand exists.

**Decision:** Do not launch Pro in the immediate roadmap. First validate one of these paid offers with actual inbound demand:
- Team workflow adoption workshop
- Security/SDLC customization engagement
- Paid support response SLA
- Private pack authoring/review
- Company-specific onboarding

If repeated demand appears, sell **services and support around the free core**, not the core itself. A later paid feature should be something genuinely costly to provide: hosted collaboration, policy management, private registry hosting, or enterprise support.

## Architecture Decisions

### Keep the current implementation model

Continue modular Bash libraries and PowerShell parity. Improve through discipline:
- Shared behavioral test cases for Bash and PowerShell.
- A declared command-output contract for `--json` modes.
- ShellCheck/PSScriptAnalyzer, Bats/Pester, and golden-file tests.
- One canonical template source where practical; generated target adapters remain thin.
- Minimize external dependencies; provide graceful capability detection.

### Do not rewrite in Go/Rust now

A rewrite would consume maintainer capacity, create dual behavior risk, reduce inspectability, and not address the current bottlenecks: proof, safe updates, quality signals, and adoption. Reconsider only if measured evidence shows Shell/PowerShell prevents a specific required capability (for example, performance on large fleets or cryptographic verification unavailable through supported OS tools).

### Optional binary rule

A future binary may be a **distribution convenience only**. It must call the same public contract, keep scripts usable directly, be reproducibly released, and never become the exclusive implementation.

## Core Logic Improvements

1. **State file:** maintain `.agtoosa/state.json` with installed version, selected adapters, pack versions, generated-file hashes, and lifecycle evidence references.
2. **Idempotency:** every install/update operation must be repeatable and show no change on a second run.
3. **Transactional writes:** stage generated files in a temp directory; validate; then atomically apply where the platform permits.
4. **Merge markers:** use stable, versioned AgToosa markers in assistant entry files and preserve user content outside markers.
5. **Machine output:** add `--json` to doctor, verify, update dry-run, registry info, and install.
6. **Explicit offline behavior:** document which commands need network access and provide offline/package-cache behavior where feasible.
7. **Threat-model the framework:** keep pack/template injection, remote bootstrap, merge behavior, and supply chain risks in the project’s own security model.

## 12-Month Execution Plan

### Quarter 1 — Trust and onboarding
- Ship one canonical proof flow and screen recording.
- Add Evidence Contract and assurance-level taxonomy.
- Improve doctor output and add JSON result formats.
- Publish compatibility matrix and minimal scenario suite.

### Quarter 2 — Safe maintenance
- Ship interactive major-version migration and rollback manifest.
- Add transactional generation and stronger generated-file provenance.
- Release 3 official packs with examples and tests.
- Publish a static docs experience organized by user job.

### Quarter 3 — Community proof
- Expand to 5–8 official packs only if quality gates hold.
- Launch Sponsors and monthly project update.
- Publish 3 case studies/proof videos.
- Offer one paid workshop/implementation engagement.

### Quarter 4 — Decide from evidence
- Review usage signals, sponsor interest, consulting demand, update failure rate, and contributor throughput.
- Choose one: stay focused on OSS + services; build private registry/support package; or build a narrowly scoped paid team feature.
- Do not build SaaS, a native-core rewrite, or a marketplace without proven pull.

## Scorecard

| Outcome | Metric |
|---|---|
| Onboarding | Proof walkthrough completion time; install-to-first-verify success rate |
| Trust | Verifier false-positive/false-negative issues; upgrade rollback success rate |
| Quality | Adapter compatibility pass rate; official-pack test pass rate |
| Adoption | Active installs/proof repo forks, discussion quality, repeat contributors |
| Sustainability | Sponsors, qualified consulting inquiries, paid workshop conversions |
| Simplicity | Core command count, mandatory dependency count, generated-file footprint |

## Final Owner Priorities

1. Preserve the inspectable Shell/PowerShell core.
2. Make proof and deterministic verification unmistakably central.
3. Add an Evidence Contract that honestly separates guidance from enforceable controls.
4. Finish safe updates and rollback before expanding features.
5. Curate a small trusted pack ecosystem.
6. Publish real assistant compatibility scenarios.
7. Grow reputation through proof, content, contributors, sponsors, and services.
8. Defer binaries, SaaS, marketplace, enterprise controls, and a Pro tier until evidence proves they are needed.
