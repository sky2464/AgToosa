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

AgToosa requires these tools:

- **bash** 4.0+
- **git** (any recent version)
- **curl** (any recent version)
- **tar** (any recent version)
- **jq** 1.6+ — strongly recommended; required for all `--registry` commands (list, search, info, install, publish)

**Fresh macOS:** install Xcode Command Line Tools (`xcode-select --install`) to get `git` and other build tools. **Fresh Windows:** install [Git for Windows](https://git-scm.com/download/win) before the PowerShell bootstrap — it provides Git Bash, which the installer runs under the hood.

If any tool is missing, the bootstrap script prints OS-specific install guidance. Install `jq` via `brew install jq` (macOS) or `sudo apt-get install jq` (Debian/Ubuntu).

### Quick Start

Start with the [15-minute proof walkthrough](../examples/first-15-minutes.md) for the full install → proof repo → init → spec → build → verify path.

### Alternative install paths

Use these when you already know AgToosa and only need an install command.

**Development only (full repository — not for end users):**

```bash
git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
bash agtoosa.sh --version
```

Use clone when contributing to AgToosa, running bats, or changing generator code. End users and corporate installs should use a **pinned release artifact** (below), not the full repo tree.

**macOS & Linux:**

```bash
# Recommended: pinned release via pipe (works in bash/zsh; no process substitution).
curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh | bash -s -- --ref v5.3.61

# Bash process-substitution alternative (bash or zsh only — fails under plain sh)
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v5.3.61

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
curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh | bash -s --
```

> **Pinned installs fail closed.** `--ref vX.Y.Z` never silently falls back to a branch. Each release publishes `bootstrap.sh` and a `SHA256SUMS` asset — verify with `--sha256 <hex>` for high-assurance installs.

**Day 1 (after install):** open your AI assistant and run five commands — `/agtoosa-init` (once) → `/agtoosa-spec` → `/agtoosa-build` → `/agtoosa-review` → `/agtoosa-ship`. Everything else is optional utilities.

**Windows (native):**

```powershell
# Recommended: download bootstrap.ps1 to disk, then run (AV/EDR-friendly).
$Ref = "v5.3.61"
$BootstrapPath = Join-Path $env:TEMP "agtoosa-bootstrap.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sky2464/AgToosa/$Ref/bootstrap.ps1" -OutFile $BootstrapPath -UseBasicParsing
& $BootstrapPath -Ref $Ref

# Manual verification path for local source checkouts
git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
.\agtoosa.ps1 -Version
```

> **Do not use `iex` or `[scriptblock]::Create` on downloaded bootstrap content.** Endpoint protection products commonly block in-memory script execution. Save to a file and invoke with `-File` / `& $path` instead.

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

### Managed devices and corporate networks

Managed laptops often block **remote script execution** (`curl | bash`, `iex`, or in-memory PowerShell). AgToosa is local-first: it copies markdown workflows into your repo. It does not install a background agent, daemon, or telemetry channel.

**Do not use `git clone` for production installs** — the repository includes maintainer tests, fixtures, and docs you do not need to run the generator. Use a **pinned release artifact** instead.

**1. Pinned release tarball + checksum (recommended for corporate networks)**

Download from [GitHub Releases](https://github.com/sky2464/AgToosa/releases) (often allowed when `raw.githubusercontent.com` is blocked). Verify against the release `SHA256SUMS` asset, then run bootstrap from local files only — no in-memory script execution:

```bash
VERSION=v5.3.61
curl -fsSL -o AgToosa.tar.gz "https://github.com/sky2464/AgToosa/archive/refs/tags/${VERSION}.tar.gz"
curl -fsSL -o SHA256SUMS "https://github.com/sky2464/AgToosa/releases/download/${VERSION}/SHA256SUMS"
sha256sum -c SHA256SUMS --ignore-missing   # or: shasum -a 256 -c SHA256SUMS --ignore-missing
curl -fsSL -o bootstrap.sh "https://github.com/sky2464/AgToosa/releases/download/${VERSION}/bootstrap.sh"
bash bootstrap.sh --ref "${VERSION}" --archive AgToosa.tar.gz
```

```powershell
$Ref = "v5.3.61"
$Archive = Join-Path $env:TEMP "AgToosa.tar.gz"
$BootstrapPath = Join-Path $env:TEMP "agtoosa-bootstrap.ps1"
Invoke-WebRequest -Uri "https://github.com/sky2464/AgToosa/archive/refs/tags/$Ref.tar.gz" -OutFile $Archive -UseBasicParsing
Invoke-WebRequest -Uri "https://github.com/sky2464/AgToosa/releases/download/$Ref/SHA256SUMS" -OutFile (Join-Path $env:TEMP "SHA256SUMS") -UseBasicParsing
Invoke-WebRequest -Uri "https://github.com/sky2464/AgToosa/releases/download/$Ref/bootstrap.ps1" -OutFile $BootstrapPath -UseBasicParsing
& $BootstrapPath -Ref $Ref -Archive $Archive
```

> **Roadmap:** a dedicated **runtime-only** release asset (`agtoosa-runtime-vX.Y.Z.tar.gz` with just `agtoosa.sh`, `agtoosa.ps1`, `lib/`, `template/`) will replace the full source archive for end-user installs. Tracked in [#89](https://github.com/sky2464/AgToosa/issues/89).

**2. Package manager (macOS — minimal install surface)**

Homebrew installs only the generator binary plus `lib/` and `template/`:

```bash
brew install sky2464/agtoosa/agtoosa
```

**3. File-on-disk bootstrap (when only a one-liner is practical)**

See the [Quick install](../README.md#quick-install) commands — pipe-based Bash and `Invoke-WebRequest -OutFile` PowerShell avoid the patterns EDR tools most often block.

**For IT / security reviewers**

| Topic | Detail |
|-------|--------|
| Network egress | GitHub Releases / archive URLs only; no AgToosa-hosted service or phone-home |
| Persistence | None — generator runs on demand and exits |
| Telemetry | None |
| Install scope | Writes markdown workflow files and platform adapters into the target repo |
| Integrity | Pinned `--ref` (fail-closed); release `SHA256SUMS`; optional minisign soft-warn ([SECURITY.md](../../SECURITY.md)) |
| Allowlist URLs | `github.com/sky2464/AgToosa/releases`, `github.com/sky2464/agtoosa-registry`, `github.com/sky2464/homebrew-agtoosa` |
| Not recommended | Full `git clone` for end users (ships maintainer tree, tests, and fixtures) |

### Troubleshooting

If you see an error like `Missing: curl`, the bootstrap script will print installation instructions for your OS. Follow them and try again.

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `Syntax error: "(" unexpected` (Bash) | One-liner run under `sh`/`dash`, not `bash` | Use the **pipe** command: `curl … \| bash -s -- --ref vX.Y.Z` |
| `Missing: git` on a new Mac | Xcode Command Line Tools not installed | Run `xcode-select --install`, then retry |
| PowerShell blocked by antivirus/EDR | `iex` / `[scriptblock]::Create` on downloaded script | Download `bootstrap.ps1` to a file and run `& $path -Ref vX.Y.Z` (see Windows install above) |
| `Git Bash not found` (Windows) | Git for Windows not installed | Install from https://git-scm.com/download/win |
| Installer stops at “Where is your project?” then exits (no input) | Piped bootstrap (`curl \| bash`) leaves stdin on the script, not the terminal | Fixed in v5.3.62+; press **Enter** or type **`.`** for the current folder. Workaround: `bash agtoosa.sh --path . --platforms cursor --yes`. Windows `bootstrap.ps1` runs Git Bash → same fix applies |
| Installer stops at “Where is your project?” (waiting) | Expected — bootstrap launched the interactive generator | Enter your repo path, **`.`** or **Enter** for the current folder, or `cd` into your project first |
| `Unable to download … archive` with `--ref` | Tag typo or unreleased version | Check https://github.com/sky2464/AgToosa/releases for the exact tag |
| `forwarded_args[@]: unbound variable` (macOS) | Default macOS **bash 3.2** + `set -u` + empty forwarded args after `--ref` only | Fixed in v5.3.61+; upgrade bootstrap or use `brew install sky2464/agtoosa/agtoosa` |
| `bash version 3.2 detected` (warning) | macOS system bash is older than 4.0 | Warning only for bootstrap; install bash 4+ via Homebrew if you hit script errors |

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
