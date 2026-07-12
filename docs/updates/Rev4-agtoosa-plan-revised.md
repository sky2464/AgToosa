# Rev4 — AgToosa Practical Owner Plan

> **Enrolled DEV stories:** DEV-086–DEV-106 — see `docs/Master-Plan.md` and `docs/updates/roadmap-spec-index.md`.

## Non-Negotiable Product Rules

- **Shell/PowerShell remain the core.** No rewrite unless measured evidence proves an unavoidable limitation.
- **Local-first and Git-native.** No account, hosted control plane, or telemetry is required for normal use.
- **Evidence over prompt claims.** AgToosa must clearly distinguish guided, evidenced, and deterministically enforced behavior.
- **Core stays small.** Lifecycle primitives belong in core; stack, compliance, and specialty behavior belongs in packs.
- **Open source earns trust first.** Sponsors, consulting, training, and support come before feature-gated commercial plans.

## The One-Sentence Position

**AgToosa is a lightweight, repo-native control plane that makes AI-assisted development more disciplined through specs, evidence, and deterministic verification.**

## Must Ship First

### 1. Canonical 15-Minute Proof

Make this the main README CTA:

`install → open proof repo → init → spec one tiny feature → build → verify`

Deliverables:
- Tiny maintained proof repository
- Single onboarding page
- 3–5 minute terminal video
- Expected output screenshots / golden artifacts
- Clear success condition: `agtoosa verify` passes

### 2. Evidence Contract

Add `Docs/AgToosa_Evidence_Contract.md` and `.agtoosa/evidence.yml`.

Use three labels everywhere:
- **Guided:** the assistant is asked to do it
- **Evidenced:** an artifact must exist
- **Enforced:** local or CI command can fail

Never imply that an LLM review is a deterministic security control. Deterministic checks, tests, and measured evals are what create reliable boundaries around non-deterministic agent outputs.[web:98][web:102]

### 3. Verifier as Flagship

Improve the verifier before adding commands:
- `--format json`
- Stable exit codes
- Human-friendly `Problem / Impact / Fix` messages
- GitHub Action template
- Evidence summary with each check classified as guided/evidenced/enforced

### 4. Safe Upgrade and Rollback

Prioritize the migration wizard.

Required behavior:
- Detect major version upgrades
- `--dry-run` shows overwrite / merge / preserve / manual action
- Back up generated files and write rollback manifest
- Never overwrite custom content outside AgToosa markers
- `--json` output for automation

### 5. Compatibility Contract

Publish actual support levels per assistant:
- **Install-tested** — generator output created correctly
- **Render-tested** — target assistant recognizes command/rule files
- **Scenario-tested** — fixed proof task yields expected artifacts

This is more credible than a generic “supported” badge.

### 6. Small Trusted Pack Set

Start with 5 packs maximum:
- FastAPI service
- Node/TypeScript API
- React frontend
- Terraform/IaC
- Security-sensitive app

A pack is official only when it has:
- versioned manifest
- supported-platform declaration
- file allowlist + checksum
- example repo
- tests
- owner/maintenance policy

### 7. Docs by User Job

Restructure existing docs into:
- Start
- Use
- Trust
- Adapt
- Maintain

Use a static site only as a rendering/navigation layer over existing Markdown. No backend.

## Do Not Build Yet

- Go/Rust rewrite
- Required binary installer
- SaaS dashboard
- Marketplace
- Enterprise RBAC/SSO product
- Paid tier that hides essential functionality
- Large registry/federation
- Complex multi-agent orchestration runtime

These do not solve the immediate problems: proof, safety, adoption, and trust.

## Business Plan

### Now
- Enable GitHub Sponsors
- Create simple recognition tiers
- Publish monthly release/progress notes
- Offer paid implementation workshops and security-aware workflow customization

### Later, only after demand
- Paid support SLA
- Private reviewed-pack service
- Team onboarding package
- Private registry hosting or collaboration feature

Services, support, training, sponsorship, and later hosted convenience are established open-source monetization paths; they allow the core project to stay open and useful.[web:101][web:103][web:105]

## 90-Day Backlog

### Days 1–30
- [ ] Rewrite README around one proof CTA
- [ ] Create proof repo/video
- [ ] Add Evidence Contract
- [ ] Add verifier JSON and better doctor messages
- [ ] Publish assistant compatibility matrix

### Days 31–60
- [ ] Build migration dry-run + backup manifest
- [ ] Add transactional/atomic generation where possible
- [ ] Publish first two official packs
- [ ] Reorganize docs navigation

### Days 61–90
- [ ] Release five-pack maximum set
- [ ] Add pack validation CI
- [ ] Enable Sponsors
- [ ] Publish first case study/tutorial
- [ ] Offer one paid workshop/consulting pilot

## Decision Gates

Do not add a major product surface without evidence:

| Proposal | Evidence required |
|---|---|
| Native binary | Documented Shell/PowerShell limitation that blocks adoption |
| Pro tier | Repeated inbound demand for a paid capability |
| SaaS | Users explicitly need collaboration/hosting that Git cannot provide |
| Marketplace | Sustainable high-quality community pack submissions |
| Enterprise product | Multiple qualified teams request SSO, audit, and policy controls |

## Success Definition

AgToosa is winning when a developer can install it, complete a proof feature, see a passing verification result, understand its security boundaries, safely update it later, and recommend it without needing an account or a sales call.
