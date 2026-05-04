<div align="center">

# 🤖 AgToosa

**The Spec-Driven Agentic AI Framework for Software Development**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-3.1.0-green.svg)](https://github.com/sky2464/AgToosa/releases)
[![CI Status](https://github.com/sky2464/AgToosa/actions/workflows/ci.yml/badge.svg)](https://github.com/sky2464/AgToosa/actions/workflows/ci.yml)
[![Security Scan](https://github.com/sky2464/AgToosa/actions/workflows/security-scan.yml/badge.svg)](https://github.com/sky2464/AgToosa/actions/workflows/security-scan.yml)
[![Semantic Release](https://github.com/sky2464/AgToosa/actions/workflows/release.yml/badge.svg)](https://github.com/sky2464/AgToosa/actions/workflows/release.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Discussions](https://img.shields.io/badge/Discussions-GitHub-blue.svg)](https://github.com/sky2464/AgToosa/discussions)

*Turn your AI coding assistant into an autonomous, security-first development team.*

**One-time usage (pinned release):**

```bash
# Replace vX.Y.Z with the latest release tag
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref vX.Y.Z
```

**Or clone and run:**

```bash
git clone https://github.com/sky2464/AgToosa.git && cd AgToosa && bash agtoosa.sh
```

</div>

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

**macOS & Linux:**
```bash
# Using a specific release (recommended)
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v3.1.0

# Or using latest main branch
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh)
```

**Windows (native):**
```powershell
# Run in PowerShell (Admin recommended, but not required)
powershell -ExecutionPolicy Bypass -Command "iex (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1')"

# Or pin a specific release:
powershell -ExecutionPolicy Bypass -Command "`$Ref='v2.8.0'; iex (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1')"
```

**Windows (WSL2 alternative):**
1. [Set up WSL2 on Windows](https://docs.microsoft.com/en-us/windows/wsl/install)
2. Open your WSL2 terminal and run the macOS/Linux command above

> **Note:** Windows native installation requires Git for Windows. Both native and WSL2 paths are fully supported.

### Platform Notes

| Platform | Generator | Registry list/search/info | Registry install | Registry publish | Smart merge |
|----------|-----------|--------------------------|-----------------|-----------------|-------------|
| macOS / Linux (bash) | ✅ Full | ✅ (requires `jq`) | ✅ | ✅ | ✅ |
| Windows native (PowerShell) | ✅ Full | ✅ | ✅ | ❌ Not supported | ✅ |
| Windows WSL2 | ✅ Full | ✅ (requires `jq`) | ✅ | ✅ | ✅ |

> **Windows tip:** For full feature parity including `--registry publish`, use WSL2 or Git Bash instead of native PowerShell.

**Or clone and run:**
```bash
git clone https://github.com/sky2464/AgToosa.git && cd AgToosa && bash agtoosa.sh
```

### Troubleshooting

If you see an error like `Missing: curl`, the bootstrap script will print installation instructions for your OS. Follow them and try again.

For more help, open a [discussion](https://github.com/sky2464/AgToosa/discussions) or [issue](https://github.com/sky2464/AgToosa/issues).

---

## What is AgToosa?

AgToosa is a **framework of markdown instructions** that transforms any AI coding assistant into a structured, spec-driven development team. Run the local generator, tell it your project path, and your AI assistant gains a complete Software Development Lifecycle — from research and planning to building, testing, reviewing, and shipping.

**No SDK. No runtime. No dependencies. Just markdown.**

### Key Principles

- 🔒 **Security by Design** — STRIDE threat modeling, SBOM generation, PII redaction, sandboxed execution
- 📋 **Spec-Driven** — Every feature starts with research, a formal specification, and an architectural plan
- 🧪 **Test-Driven Development** — Red-Green-Refactor cycle enforced during build
- 🧠 **Context-Aware** — The AI maintains project state in Linear, with `Docs/Master-Plan.md` as the workspace mirror
- 🔄 **4-Phase Lifecycle** — Spec → Build → Review → Ship (after a one-time `/agtoosa-init` setup)
- 🛡️ **Observable** — OpenTelemetry, structured logging, and distributed tracing by default

---

## Architecture

AgToosa organizes development into **4 core phases**, executed via slash commands. Every feature follows the same lifecycle — from research to deployment — with mandatory review gates and a continuous loop back to the next story.

```mermaid
flowchart TD
    classDef setup   fill:#6366f1,stroke:#4338ca,color:#fff,font-weight:bold
    classDef spec    fill:#0284c7,stroke:#0369a1,color:#fff,font-weight:bold
    classDef build   fill:#059669,stroke:#047857,color:#fff,font-weight:bold
    classDef review  fill:#d97706,stroke:#b45309,color:#fff,font-weight:bold
    classDef gate    fill:#7c3aed,stroke:#6d28d9,color:#fff,font-weight:bold
    classDef ship    fill:#dc2626,stroke:#b91c1c,color:#fff,font-weight:bold

    INIT(["🚀  /agtoosa-init
    ─────────────────────
    Scan · Validate · Configure
    ‹ run once per project ›"])

    subgraph SPEC ["📋  PHASE 1 — SPEC & PLANNING"]
        direction TB
        S1["🔍 Context Research
        Codebase scan · Web analysis
        Clarifying Q&A"]
        S2["📝 Executable Specification
        Architecture blueprint
        Acceptance criteria"]
        S3["⚠️ STRIDE Threat Model
        DFD generation
        Security requirements"]
        S1 --> S2 --> S3
    end

    subgraph BUILD ["🏗️  PHASE 2 — BUILD & TEST"]
        direction TB
        B1["📌 Scope Declaration
        Task breakdown
        Out-of-scope boundary"]
        B2["🔴  RED
        Write failing test first"]
        B3["🟢  GREEN
        Minimal implementation"]
        B4["🔵  REFACTOR
        Clean · lint · &lt;500 LOC"]
        B5["🔬 Test Army
        Unit · Integration · SAST · DAST"]
        B1 --> B2 --> B3 --> B4 --> B5
    end

    subgraph REVIEW ["🔍  PHASE 3 — MULTI-PERSONA REVIEW"]
        direction LR
        R1["🛡️ Security Officer
        OWASP Top 10
        STRIDE audit"]
        R2["📊 Eng Manager
        Architecture · Coverage
        500-line gate"]
        R3["💼 CEO
        Product alignment
        Scope check"]
        R4["🧪 QA Lead
        Test quality
        Edge cases"]
    end

    GATE{{"All Reviews
    Passed?"}}

    subgraph SHIP ["🚢  PHASE 4 — SHIP & ARCHIVE"]
        direction TB
        SH1["✅ Readiness Gate
        All checks pass
        No open blockers"]
        SH2["📦 Deploy
        Zero-downtime · Changelog
        GitHub Release"]
        SH3["🗄️ Archive
        Specs → Docs/archived/
        Master-Plan updated"]
        SH4["💡 Next Story
        Retro · Suggest
        next feature"]
        SH1 --> SH2 --> SH3 --> SH4
    end

    INIT        --> SPEC
    SPEC        --> BUILD
    BUILD       --> REVIEW
    R1 & R2 & R3 & R4 --> GATE
    GATE        -- "✅  Approved"  --> SHIP
    GATE        -- "🔴  Changes needed" --> BUILD
    SH4         -- "🔄  Next story" --> SPEC

    class INIT setup
    class S1,S2,S3 spec
    class B1,B2,B3,B4,B5 build
    class R1,R2,R3,R4 review
    class GATE gate
    class SH1,SH2,SH3,SH4 ship
```

| Phase | Command | What It Does |
|-------|---------|-------------|
| **0. Setup** | `/agtoosa-init` | **One-time:** Scan codebase, validate AI configs, establish context |
| **1. Spec & Planning** | `/agtoosa-spec` | Research, specify, architect, and STRIDE threat model |
| **2. Build & Test** | `/agtoosa-build` | Scope → TDD Red-Green-Refactor → full test army |
| **3. Multi-Persona Review** | `/agtoosa-review` | Security · Architecture · Product · QA review gate |
| **4. Ship & Cleanup** | `/agtoosa-ship` | Deploy, archive, changelog, suggest next story |

---

## Command Reference

### Core Commands

| Command | Description |
|---------|-------------|
| `/agtoosa-init` | **One-time setup.** Scan codebase, validate AI config files, generate context files, configure TDD preferences |
| `/agtoosa-spec` | Research and create an **Executable Specification** with embedded architectural plan and STRIDE threat modeling |
| `/agtoosa-build` | Break spec into atomic tasks, implement with **TDD Red-Green-Refactor**, run full test suite with SAST/DAST |
| `/agtoosa-review` | Multi-persona review (Security Officer, Eng Manager, CEO, QA Lead) + code simplification |
| `/agtoosa-ship` | **Zero-downtime deployment**, archive specs to `Docs/archived/`, update changelog, suggest next story |

### Optional Utility

| Command | Description |
|---------|-------------|
| `/agtoosa-revert` | **Git-aware logical rollback** by phase/task. Most modern AI tools have built-in checkpoints — use this when you need deeper rollback control. |

---

## Installation

### Option 1: Persistent Installation (Recommended)

Install once and use everywhere:

```bash
brew install sky2464/agtoosa/agtoosa
```

Then verify:

```bash
agtoosa --version
```

Run the generator:

```bash
agtoosa
```

Upgrade later:

```bash
brew upgrade agtoosa
```

> **Note:** If the Homebrew tap (`sky2464/agtoosa`) is not available in your environment yet, use Option 2.

### Option 2: One-time Usage (No Installation)

Run directly without installing. Recommended approach is to pin a release tag:

```bash
# Replace vX.Y.Z with the latest release tag
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref vX.Y.Z
```

Or use the latest from `main` (may include unreleased changes):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh)
```

You can pass generator flags by adding `--` before script arguments:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref vX.Y.Z -- --dry-run
```

### Option 3: Manual Install (Clone + Run)

```bash
git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
bash agtoosa.sh
```

### Windows

One-time usage in Git Bash / WSL:

```bash
# Git Bash or WSL
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref vX.Y.Z
```

Native PowerShell (clone + run):

```powershell
git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
./agtoosa.ps1
```

Enter your project path when prompted — the generator copies the workflow files directly into your project.

### Flags

```bash
bash agtoosa.sh --force    # Overwrite existing files
bash agtoosa.sh --update /path/to/project  # Update an existing install
bash agtoosa.sh --version  # Print version
bash agtoosa.sh --help     # Show help
```

---

## Quick Start

1. **Run** `bash agtoosa.sh` and enter your project path
2. **Select** your AI assistant(s) — only necessary config files are generated
3. **Open** your AI assistant (Cursor, Windsurf, Claude Code, Gemini CLI, etc.)
4. **Run** `/agtoosa-init` to set up your project (one-time)
5. **Run** `/agtoosa-spec Create a user authentication system` to start building!

The AI will guide you through each phase — asking smart questions, researching best practices, and generating specifications before writing a single line of code.

---

## Smart Init (`/agtoosa-init`)

The init command is intelligent — it doesn't just scaffold files, it validates your entire AI setup:

- **Detects** existing AI config files (`.cursorrules`, `CLAUDE.md`, `AGENTS.md`, etc.)
- **Validates** that each config is correctly wired to AgToosa's workflow
- **Creates** any missing config files for your selected AI tool(s)
- **Understands** that different platforms have different init mechanisms (Cursor auto-loads `.cursorrules`, Claude Code auto-loads `CLAUDE.md`, etc.)
- **Configures** TDD preferences, test framework detection, and project context

---

## TDD Enforcement

AgToosa integrates Test-Driven Development principles directly into its workflow:

| TDD Phase | What Happens | When |
|-----------|-------------|------|
| 🔴 **RED** | Write a failing test that describes expected behavior | Before ANY implementation |
| 🟢 **GREEN** | Write minimal code to make the test pass | After test is written |
| 🔵 **REFACTOR** | Clean up, lint, ensure <500 LOC per file | After test passes |

TDD is configured during `/agtoosa-init` and enforced during every `/agtoosa-build` cycle. This ensures no implementation code is written without a corresponding test.

---

## Security Features

AgToosa embeds enterprise-grade security into every phase:

| Feature | Phase | Description |
|---------|-------|-------------|
| **STRIDE Threat Modeling** | `/agtoosa-spec` | DFD generation and threat analysis before code |
| **Sandboxed Execution** | `/agtoosa-build` | Ephemeral Docker/Firecracker environments |
| **SBOM Generation** | `/agtoosa-build` | Software Bill of Materials for supply chain security |
| **SAST/DAST Scanning** | `/agtoosa-build` `/agtoosa-review` | Semgrep, CodeQL, Gitleaks integration |
| **IaC Scanning** | `/agtoosa-build` | Checkov/tfsec for cloud infrastructure |
| **PII Redaction** | Always | Scrub sensitive data before LLM context |
| **Prompt Injection Guard** | Always | Sanitize inputs from untrusted sources |
| **Zero-Trust Architecture** | Always | Principle of least privilege throughout |

---

## Supported AI Platforms

AgToosa works with any AI coding assistant. The generator creates only the configs you need:

| Platform | Config File | Selection |
|----------|-------------|-----------|
| **Cursor** | `.cursorrules` | Option 1 |
| **Windsurf** | `.windsurfrules` | Option 2 |
| **Claude Code** | `CLAUDE.md` | Option 3 |
| **Gemini CLI / Jules** | `AGENTS.md` | Option 4 |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Option 5 |
| **Any other AI** | `Docs/AgToosa_Agent.md` | Always included |

> `/agtoosa-init` will also detect and validate any existing AI config files in your project.

---

## Project Structure

After running `agtoosa.sh`, your project will have:

```
your-project/
├── .cursorrules              # AI entry point (Cursor) — if selected
├── .windsurfrules            # AI entry point (Windsurf) — if selected
├── AGENTS.md                 # AI entry point (Gemini CLI) — if selected
├── CLAUDE.md                 # AI entry point (Claude Code) — if selected
├── .github/
│   └── copilot-instructions.md  # AI entry point (Copilot) — if selected
└── Docs/
    ├── AgToosa_Agent.md    # Core instructions & command reference
    ├── AgToosa_Init.md     # /agtoosa-init workflow
    ├── AgToosa_Spec.md     # /agtoosa-spec workflow
    ├── AgToosa_Build.md    # /agtoosa-build workflow (TDD + testing)
    ├── AgToosa_Review.md   # /agtoosa-review workflow
    ├── AgToosa_Ship.md     # /agtoosa-ship workflow
    ├── AgToosa_Revert.md   # /agtoosa-revert (optional utility)
    ├── AgToosa_Skills.md   # Subagent skill mapping
    ├── AgToosa_Claude.md   # Claude-specific config
    ├── AgToosa_Gemini.md   # Gemini-specific config
    ├── Master-Plan.md        # Workspace mirror of the Linear project state
    ├── AgToosa_Changelog.md    # Auto-maintained changelog
    ├── Context/              # Project context (created by /agtoosa-init)
    └── archived/             # Completed specs & plans
```

---

## How It Differs

| Feature | AgToosa v2 | Spec-Kit | Conductor | GStack |
|---------|-------------|----------|-----------|--------|
| Spec-driven workflow | ✅ | ✅ | ❌ | ❌ |
| TDD enforcement | ✅ | ❌ | ❌ | ❌ |
| Smart init (AI config validation) | ✅ | ❌ | ✅ | ❌ |
| Security by design (STRIDE) | ✅ | ❌ | ❌ | ❌ |
| Virtual specialist personas | ✅ | ❌ | ❌ | ✅ |
| Real browser QA | ✅ | ❌ | ❌ | ✅ |
| SBOM & supply chain | ✅ | ❌ | ❌ | ❌ |
| Zero dependencies | ✅ | ✅ | ❌ | ❌ |
| Multi-platform AI support | ✅ | ❌ | ❌ | ❌ |
| Local-first (no curl install) | ✅ | ❌ | ❌ | ❌ |
| One-click project copy | ✅ | ❌ | ❌ | ❌ |

---

## GitHub Automation & Workflow

AgToosa ships with comprehensive GitHub automation to keep your project healthy and contributors engaged:

### Automated Workflows

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| **Semantic Release** | Auto-publish releases from git tags with changelog extraction | `git tag v*` |
| **Stale Issues** | Auto-close inactive issues after 30 days | Daily schedule |
| **Auto-Label** | Automatically label issues and PRs by keywords | Issue/PR opened |
| **Security Scan** | SAST, dependency vulnerabilities, secret scanning | Push to main, weekly schedule |
| **Wiki Sync** | Keep GitHub Wiki in sync with `template/Docs/` | Push to main |
| **Contributor Welcome** | Greet first-time contributors, suggest good-first-issues | PR/Issue opened |
| **Project Auto-Assign** | Assign new issues to GitHub Project backlog | Issue opened |
| **Dependabot** | Automated dependency updates for Actions and tools | Weekly |

### Community Features

- **Discussions** — Q&A, Ideas, Show & Tell categories for community engagement
- **GitHub Projects** — Public project board synced with Linear (AgToosa)
- **Issue Templates** — Structured bug/feature forms (`.github/ISSUE_TEMPLATE/`)
- **Discussion Templates** — Q&A, Ideas, Show & Tell templates (`.github/discussion_templates/`)

### Release Management

- **Semantic Versioning** — Enforced tag format validation
- **CHANGELOG Extraction** — Release notes automatically extracted from CHANGELOG.md
- **Milestone Auto-Creation** — Next version milestone created automatically
- **Pre-release Support** — `prerelease` flag for release candidates

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Security

For security concerns, please see our [Security Policy](SECURITY.md).

## License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

**Built with ❤️ for the agentic AI era.**

[Report Bug](https://github.com/sky2464/AgToosa/issues) · [Request Feature](https://github.com/sky2464/AgToosa/issues) · [Discussions](https://github.com/sky2464/AgToosa/discussions)

</div>
