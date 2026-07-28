# AgToosa README Reference

> **Read more:** full install matrix, command reference, security tables, and competitive positioning. The [README](../README.md) is the first-visit onboarding path — tagline, quick install, demo, and essentials.

## `/agtoosa-next` — sequential driver

**One command keeps the project moving.** `/agtoosa-next` is AgToosa's repo-aware sequential driver. Run `/agtoosa-init` once, then repeat Next: it reads the repository's SYNC state, routes to the correct lifecycle phase, and executes exactly one workflow per invocation while preserving phase stops.

Use explicit phase commands (`/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, `/agtoosa-ship`) only when you need advanced control. Freeform `next` / `okay` / `do it` utterances route to `/agtoosa-next`, not `/agtoosa-help next`.

## Public launch status

AgToosa is public — bootstrap, releases, registry, and the [proof repository](https://github.com/sky2464/agtoosa-first-15-proof) are anonymously accessible. See [public launch proof](../examples/public-launch-proof.md) for the publication checklist.

---

## Installation

### System Requirements

AgToosa requires these tools (all present by default on modern macOS/Linux):

- **bash** 4.0+
- **git** (any recent version)
- **curl** (any recent version)
- **tar** (any recent version)
- **jq** 1.6+ — strongly recommended; required for all `--registry` commands (list, search, info, install, publish)

If any are missing, the bootstrap script will tell you how to install them. Install `jq` via `brew install jq` (macOS) or `sudo apt-get install jq` (Debian/Ubuntu).

### Quick Start

Start with the [15-minute proof walkthrough](../examples/first-15-minutes.md) for the full install → proof repo → init → spec → build → verify path.

### Alternative install paths

Use these when you already know AgToosa and only need an install command.

**macOS & Linux:**

```bash
# Public launch: pinned release (alternative to the proof walkthrough).
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v5.3.53

# Homebrew alternative (formula pinned to the tagged release tarball)
brew install sky2464/agtoosa/agtoosa

# npm alternative (downloads the release pinned to the package version)
npx agtoosa

# Non-interactive (CI, devcontainers, scripted rollouts)
bash agtoosa.sh --path /path/to/project --platforms cursor,claude --yes

# Clone-and-run alternative for local source checkouts:
git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
bash agtoosa.sh --version

# development-only main branch command; may include unreleased changes
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh)
```

> **Pinned installs fail closed.** `--ref vX.Y.Z` never silently falls back to a branch. Each release publishes `bootstrap.sh` and a `SHA256SUMS` asset — verify with `--sha256 <hex>` for high-assurance installs.

**Day 1 (after install):** open your AI assistant and run five commands — `/agtoosa-init` (once) → `/agtoosa-spec` → `/agtoosa-build` → `/agtoosa-review` → `/agtoosa-ship`. Everything else is optional utilities.

**Windows (native):**

```powershell
# Public launch: pinned release.
$Ref = "v5.3.53"
$Bootstrap = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/sky2464/AgToosa/$Ref/bootstrap.ps1"
& ([scriptblock]::Create($Bootstrap)) -Ref $Ref
.\agtoosa.ps1 -Version

# Manual verification path for local source checkouts
git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
.\agtoosa.ps1 -Version
```

**Windows (WSL2 alternative):**

1. [Set up WSL2 on Windows](https://docs.microsoft.com/en-us/windows/wsl/install)
2. Open your WSL2 terminal and run the macOS/Linux command above

> **Note:** Windows native installation requires Git for Windows. Native PowerShell and WSL2 are supported installation paths with different backend and dependency boundaries; see the [Network & API Matrix](../AgToosa_Network_Matrix.md#backend-classification).

### Platform Notes

| Platform | Generator | Registry list/search/info | Registry install | Registry publish | Smart merge |
|----------|-----------|--------------------------|-----------------|-----------------|-------------|
| macOS / Linux (bash) | ✅ Full | ✅ (requires `jq`) | ✅ | ✅ | ✅ |
| Windows native (PowerShell) | ✅ Full | ✅ | ✅ | ❌ Not supported | ✅ |
| Windows WSL2 | ✅ Full | ✅ (requires `jq`) | ✅ | ✅ | ✅ |

> **Windows tip:** Native PowerShell redirects registry publishing to the maintainer workflow. Use WSL2 or Git Bash when you need the Bash-backed registry publish operation.

**Clone-and-run alternative:**

```bash
git clone https://github.com/sky2464/AgToosa.git && cd AgToosa && bash agtoosa.sh
```

### Troubleshooting

If you see an error like `Missing: curl`, the bootstrap script will print installation instructions for your OS. Follow them and try again.

**Install health check:**

```bash
bash agtoosa.sh --doctor /path/to/project
```

| Finding | Fix |
|---------|-----|
| Installed version ≠ generator version | `bash agtoosa.sh --update /path/to/project` |
| Context files contain template placeholders | Run `/agtoosa-init` in your AI assistant |
| Core workflow docs missing | `bash agtoosa.sh --update /path/to/project` |
| Platform dir exists but entry point missing | Re-run install for that platform, or restore from `.bak.*` backup |
| Queued pack(s) pending merge | Run `bash agtoosa.sh` in the project to merge queued registry packs |

**Clean removal:**

```bash
bash agtoosa.sh --uninstall /path/to/project
```

---

## Command Reference

### Core Commands

| Command | Description |
|---------|-------------|
| `/agtoosa-init` | **One-time setup.** Scan codebase, validate AI config files, generate context files, configure TDD preferences |
| `/agtoosa-spec` | Research and create an **Executable Specification** with embedded architectural plan, STRIDE threat modeling, and atomic task breakdown |
| `/agtoosa-build` | Implement the planned task list with **TDD Red-Green-Refactor** and run the full test suite with SAST/DAST |
| `/agtoosa-review` | Multi-persona review (Security Officer, Eng Manager, CEO, QA Lead) + code simplification |
| `/agtoosa-ship` | Run approval-gated deployment guidance, archive specs to `Docs/archived/`, update changelog, and suggest the next story |

### Optional Utility

| Command | Description |
|---------|-------------|
| `/agtoosa-goal` | Clarify project or story outcomes into a Goal Contract before spec/build/review/ship work depends on them |
| `/agtoosa-revert` | **Git-aware logical rollback** by phase/task |

### Flags

```bash
bash agtoosa.sh --path <dir> --platforms cursor,claude --yes   # Non-interactive install
bash agtoosa.sh --update /path/to/project   # Update an existing install
bash agtoosa.sh --verify /path/to/project   # Deterministic lifecycle verification (read-only, no AI)
bash agtoosa.sh --doctor /path/to/project   # Diagnose install health, version skew, wiring
bash agtoosa.sh --uninstall /path/to/project # Clean removal (keeps Master-Plan, Context, archived)
bash agtoosa.sh --force     # Overwrite existing files (creates .bak backups)
bash agtoosa.sh --dry-run   # Preview without writing
bash agtoosa.sh --allow-unverified  # Permit unverified registry packs (off by default)
bash agtoosa.sh --version   # Print version
bash agtoosa.sh --help      # Show help
```

---

## Verification

```bash
bash Docs/agtoosa-verify.sh            # context, spec approval, EARS ACs, AC→test mapping, threat model, TDD evidence
bash Docs/agtoosa-verify.sh --strict   # warnings fail too
bash Docs/agtoosa-verify.sh stats      # cycle analytics from your Master-Plan and phase events
```

CI adoption: [verifier and CI adoption guide](../examples/verifier-ci-adoption.md). See [enforcement comparison](../enforcement-comparison.md) and [benchmarks](../benchmarks/README.md).

---

## Smart Init (`/agtoosa-init`)

- **Detects** existing AI config files (`.cursorrules`, `CLAUDE.md`, `AGENTS.md`, etc.)
- **Validates** that each config is correctly wired to AgToosa's workflow
- **Creates** any missing config files for your selected AI tool(s)
- **Clarifies** the project Goal Contract in `Docs/Master-Plan.md`
- **Configures** TDD preferences, test framework detection, and project context

---

## TDD Enforcement

| TDD Phase | What Happens | When |
|-----------|-------------|------|
| 🔴 **RED** | Write a failing test that describes expected behavior | Before ANY implementation |
| 🟢 **GREEN** | Write minimal code to make the test pass | After test is written |
| 🔵 **REFACTOR** | Clean up, lint, ensure <500 LOC per file | After test passes |

---

## Security Features

AgToosa **instructs** your AI assistant to apply these practices. The generator does not run scans or sandboxes itself. See `template/Docs/AgToosa_Readiness.md` for the full workflow-vs-enforcement matrix.

| Feature | Phase | Workflow guidance | Generator enforces |
|---------|-------|-------------------|-------------------|
| **STRIDE Threat Modeling** | `/agtoosa-spec` | DFD and threat analysis before code | No |
| **Sandboxed Execution** | `/agtoosa-build` | Ephemeral Docker/Firecracker when applicable | No |
| **SBOM Generation** | `/agtoosa-build` | Software Bill of Materials and dependency audit | No |
| **SAST/DAST Scanning** | `/agtoosa-build` `/agtoosa-review` | Semgrep, CodeQL, Gitleaks when installed | No |
| **Deterministic lifecycle verifier** | `Docs/agtoosa-verify.sh` | Spec approval, EARS lint, AC→test mapping, threat model, TDD evidence | Yes — machine-checked script, no AI involved |
| **Registry pack containment** | `--registry install` | SHA-256 pin, safe extraction, verified-flag enforcement | Yes |
| **Template file install** | `agtoosa.sh` | Copies registered workflow docs to your project | Yes |

---

## Supported AI Platforms

| Platform | Config Files | Selection |
|----------|-------------|-----------|
| **Cursor** | `.cursorrules`, `.cursor/rules/`, `.cursor/commands/` | Option 1 |
| **Windsurf** | `.windsurfrules`, `.windsurf/rules/`, `.windsurf/workflows/` | Option 2 |
| **Claude Code** | `CLAUDE.md` | Option 3 |
| **Gemini CLI / Jules** | `AGENTS.md` | Option 4 |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Option 5 |
| **Codex / OpenCode / Other** | `OPENCODE.md`, `.codex/skills/`, `Docs/AgToosa_Agent.md` | Option 7 |
| **Any other AI** | `Docs/AgToosa_Agent.md` | Always included |

---

## Project Structure

After running `agtoosa.sh`, your project will have workflow docs under `Docs/` — see [architecture overview](architecture-overview.md) and the README project-structure summary.

---

## How It Differs

Comparison last reviewed: 2026-07-06.

### Use AgToosa when

- You are a solo or indie developer using multiple AI coding assistants and want one repo-native SDLC workflow contract.
- You want specs, test-plan mapping, review, and ship discipline without adding a target-app SDK or hosted service.
- You prefer markdown workflows and platform adapters over a heavier runtime, MCP server, task database, or IDE-specific system.

### Use another tool when

- Use **GitHub Spec Kit** when you want the largest ecosystem, organizational catalogs, presets, and first-party GitHub-scale integrations.
- Use **OpenSpec** when brownfield current-state specs and change-delta modeling are the primary need.
- Use **BMAD-METHOD** when you want a mature role/agent ecosystem with many specialized workflows.
- Use **Task Master** when active task execution, task dependencies, and MCP/editor task management are more important than repo-local workflow files.
- Use **Spec Kitty** when worktree orchestration, missions, and agent work packages are the main value.
- Use **metaswarm** when you want deeper multi-agent orchestration and are comfortable adopting a more opinionated system.

AgToosa's wedge is narrower: lightweight, repo-native, multi-assistant workflow installation for developers who want stronger launch discipline than ad-hoc prompts.

### Competitive execution wave

DEV-042 through DEV-060 are roadmap specs, not current guarantees. The Competitive execution wave strengthens repo-native proof gates that alternatives often handle through heavier runtimes, hosted task systems, or single-IDE workflows. **v5.3.0 shipped the proof-engine core**; remaining stories stay on the Master-Plan backlog until enrolled with passing evidence.

**Shipped (v5.3.0 and earlier in this wave):**

| Story | Capability | Enforcement |
|-------|------------|-------------|
| DEV-042 | Spec quality analyzer in `/agtoosa-spec` | agent-instructed |
| DEV-043 | Brownfield current-state baseline in `/agtoosa-spec` | agent-instructed |
| DEV-044 | EARS-to-test + RED/GREEN TDD evidence gates | machine-checked (+ agent) |
| DEV-060 | Public benchmark suite (`docs/benchmarks/`) | manual runs; deterministic scoring |
| DEV-061–073 | Lifecycle verifier, CI gate template, phase-event log, supply-chain hardening, spec amend/living specs, `--doctor`/`--uninstall` | generator-enforced + machine-checked |

AgToosa's guarantee is explicit per control: generator-enforced, CI-enforceable, agent-instructed, manual, or roadmap — see [enforcement-comparison.md](../enforcement-comparison.md) and [Team Trust Roadmap](../AgToosa_Team_Trust_Roadmap.md).

---

## GitHub Automation & Workflow

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| **Semantic Release** | Auto-publish releases from git tags | `git tag v*` |
| **Security Scan** | SAST, dependency vulnerabilities, secret scanning | Push to main, weekly |
| **Wiki Sync** | Keep GitHub Wiki in sync with `template/Docs/` | Push to main |
| **Dependabot** | Automated dependency updates | Weekly |

---

## Authoring & guides

- [Platform extension authoring](../extension-authoring-guide.md)
- [Registry pack authoring](../registry-pack-authoring.md)
- [Core vs optional pack boundary](../AgToosa_Core_Contract.md)
- [Subagent handoff walkthrough](../examples/subagent-handoff-review.md)
- [Subagent-heavy workflows](subagent-heavy-workflows.md)
- [Security-sensitive projects](security-sensitive-projects.md)
- [Solo-developer workflows](solo-developer-workflows.md)

Canonical command contracts: `docs/AgToosa_Handoff.md`, `docs/AgToosa_Import.md`, `docs/AgToosa_CrossModelReview.md`, `docs/AgToosa_AgentCapability.md`.

---

## More install notes

- **Homebrew lifecycle:** `brew upgrade agtoosa` to update; `agtoosa --version` to verify.
- **Bootstrap pass-through:** `bash <(curl -fsSL …/bootstrap.sh) --ref vX.Y.Z -- --dry-run`
