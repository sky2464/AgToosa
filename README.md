<div align="center">

<a href="docs/media/agtoosa-hero/agtoosa-hero.mp4">
  <img src="docs/media/agtoosa-hero/agtoosa-hero.gif" alt="AgToosa workflow: init, spec, build, review, ship, status, and next" width="720"/>
</a>

[▶ Watch the 44-second AgToosa film with sound](docs/media/agtoosa-hero/agtoosa-hero.mp4)

# AgToosa

**A lightweight, repo-native control plane for spec-driven AI development**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-5.3.34-green.svg)](https://github.com/sky2464/AgToosa/releases)
[![CI Status](https://github.com/sky2464/AgToosa/actions/workflows/ci.yml/badge.svg)](https://github.com/sky2464/AgToosa/actions/workflows/ci.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Discussions](https://img.shields.io/badge/Discussions-GitHub-blue.svg)](https://github.com/sky2464/AgToosa/discussions)

*Turn your AI coding assistant into a disciplined, security-aware dev team — with specs, evidence, and machine verification.*

**Primary: 15-minute proof journey**

Follow one path to see AgToosa value: install → open the [proof repository](https://github.com/sky2464/agtoosa-first-15-proof) → init → spec → build → verify.

[Start the first 15 minutes proof walkthrough](docs/examples/first-15-minutes.md) for a clean-repo guide with expected spec, test-plan, review, and ship-check artifacts.

**Public launch status:** AgToosa is public — bootstrap, releases, registry, and the [proof repository](https://github.com/sky2464/agtoosa-first-15-proof) are anonymously accessible.

</div>

---

## Why AgToosa?

- **Spec first** — research, architecture, and STRIDE threat modeling before code
- **Evidence, not vibes** — deterministic `agtoosa-verify.sh` checks what the chat claimed
- **Any assistant** — Cursor, Claude Code, Copilot, Windsurf, Codex, and more from one repo-native workflow

**No target-app runtime. No SDK to link.** AgToosa installs markdown workflows and platform adapters into your repo. **Generator prerequisites:** the installer uses standard CLI tools such as Bash or PowerShell, Git, curl/web requests, tar, and jq for registry commands.

Security and scan guidance is **Workflow guidance** — your AI runs the checks; AgToosa does not execute them. The lifecycle verifier and registry containment are **Generator enforces** controls. See [enforcement comparison](docs/enforcement-comparison.md).

## Quick install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v5.3.34
```

Then open your AI assistant and run **Day 1:** `/agtoosa-init` → `/agtoosa-spec` → `/agtoosa-build` → `/agtoosa-review` → `/agtoosa-ship`.

## Lifecycle at a glance

```mermaid
flowchart LR
    classDef spec fill:#0284c7,stroke:#0369a1,color:#fff
    classDef build fill:#059669,stroke:#047857,color:#fff
    classDef review fill:#d97706,stroke:#b45309,color:#fff
    classDef ship fill:#dc2626,stroke:#b91c1c,color:#fff
    INIT["/agtoosa-init"] --> S["/agtoosa-spec"] --> B["/agtoosa-build"] --> R["/agtoosa-review"] --> SH["/agtoosa-ship"]
    class S spec
    class B build
    class R review
    class SH ship
```

<img src="docs/media/agtoosa-hero/lifecycle-accent.svg" alt="" width="480"/>

[Full architecture diagram →](docs/guides/architecture-overview.md)

## Trust, but verify

```bash
bash Docs/agtoosa-verify.sh    # spec approval, EARS ACs, threat model, TDD evidence
```

## Read more

| Topic | Link |
|-------|------|
| Full install matrix, flags, Windows, troubleshooting | [README reference](docs/guides/readme-reference.md) |
| Architecture deep dive | [architecture-overview.md](docs/guides/architecture-overview.md) |
| First 15 minutes + proof video `[manual]` | [first-15-minutes.md](docs/examples/first-15-minutes.md) · [public launch proof](docs/examples/public-launch-proof.md) |
| Compare to alternatives | [readme-reference § How it differs](docs/guides/readme-reference.md#how-it-differs) |
| Subagent & audience guides | [handoff](docs/examples/subagent-handoff-review.md) · [subagent-heavy](docs/guides/subagent-heavy-workflows.md) · [security-sensitive](docs/guides/security-sensitive-projects.md) · [solo-dev](docs/guides/solo-developer-workflows.md) |
| Team assurance roadmap | [AgToosa_Team_Trust_Roadmap.md](docs/AgToosa_Team_Trust_Roadmap.md) |
| Authoring | [extension-authoring-guide.md](docs/extension-authoring-guide.md) · [registry-pack-authoring.md](docs/registry-pack-authoring.md) · [core contract](docs/AgToosa_Core_Contract.md) |
| Wiki | [GitHub Wiki](https://github.com/sky2464/AgToosa/wiki) |

### Alternative install paths

Use these when you already know AgToosa and only need an install command.

**macOS & Linux:**

```bash
# Public launch: pinned release (alternative to the proof walkthrough).
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v5.3.34

brew install sky2464/agtoosa/agtoosa
npx agtoosa

git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
bash agtoosa.sh --version

# development-only main branch command; may include unreleased changes
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh)
```

> **Windows tip:** Native PowerShell redirects registry publishing to the maintainer workflow. Use WSL2 or Git Bash when you need the Bash-backed registry publish operation. Full Windows paths: [readme-reference](docs/guides/readme-reference.md#installation).

## Contributing & support

See [CONTRIBUTING.md](CONTRIBUTING.md). Community help and sponsorship: [`.github/SUPPORT.md`](.github/SUPPORT.md). Security: [SECURITY.md](SECURITY.md).

---

<div align="center">

**Built for the agentic AI era — verify the artifacts, not the chat.**

[Report Bug](https://github.com/sky2464/AgToosa/issues) · [Discussions](https://github.com/sky2464/AgToosa/discussions)

</div>

<!-- AGTOOSA PRODUCT TRUTH START: claims.surface.readme -->
<!-- Static conformance and freshness only; not behavioral or provenance proof. -->
| Claim ID | Target | Status | Evidence class | Expires |
| --- | --- | --- | --- | --- |
| `claim.adapter.cursor` | `cursor.project-commands` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.windsurf` | `windsurf.workflows` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.claude` | `anthropic.claude-code` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.gemini` | `google.gemini-cli` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.copilot-vscode` | `github.copilot-vscode` | verified | static-conformance | 2026-10-12 |
| `claim.adapter.codex` | `openai.codex-cli` | verified | static-conformance | 2026-10-12 |
| `claim.windows.bootstrap-ref` | `windows-native` | verified | static-conformance | 2026-10-12 |
| `claim.product-truth.local` | `maintainer` | verified | static-conformance | 2026-10-12 |
<!-- AGTOOSA PRODUCT TRUTH END: claims.surface.readme -->
