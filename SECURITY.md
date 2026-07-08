# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| 5.2.x   | Active support     |
| < 5.2   | No support unless a maintainer explicitly backports a fix |

## Reporting a Vulnerability

**Please do NOT report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability in AgToosa, please report it responsibly:

1. **Email**: Send details to **security@agtoosa.dev** (or open a private security advisory on GitHub)
2. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact assessment
   - Suggested fix (if any)

We will acknowledge receipt within **48 hours** and provide a timeline for resolution.

## Security Model

AgToosa is a framework of markdown instructions — it does not execute code itself. However, the instructions it provides to AI agents include enterprise-grade security practices:

### Built-In Security Features

AgToosa is markdown workflow guidance for AI assistants. **Workflow instructions** describe security steps; the **generator** only copies template files — it does not execute scans, sandboxes, or SBOM tools. Generated projects document the split in `Docs/AgToosa_Readiness.md`.

| Feature | Workflow instructions | Generator enforces |
|---------|----------------------|-------------------|
| **STRIDE Threat Modeling** | Required in `/agtoosa-spec` (except `quick`) | No |
| **Sandboxed Execution** | `/agtoosa-build` instructs isolated runs when applicable | No |
| **SBOM Generation** | `/agtoosa-build` instructs SBOM and dependency audit | No |
| **SAST/DAST Scanning** | `/agtoosa-build` and `/agtoosa-review security` instruct tool runs | No |
| **IaC Security Scanning** | `/agtoosa-build` instructs Checkov/tfsec when IaC exists | No |
| **PII Redaction** | Agent instructions mandate scrubbing before LLM context | No |
| **Optional minisign soft-warn** | Registry/bootstrap attempt verify when `.minisig` present | Soft-warn only (DEV-054); not fail-closed |

### Supply-chain surfaces

- Pack tarballs: SHA-256 + verified flag (fail-closed on hash mismatch / unverified without opt-in).
- Optional signatures: minisign primary (`docs/security/agtoosa.minisign.pub` or `AGTOOSA_MINISIGN_PUBKEY`); cosign future alternate.
- Release assets: `SHA256SUMS` required; `.minisig` sidecars optional soft-warn.
- Private keys: never commit; see Manual/Deferred `DEV-054 M-1`.

| **Prompt Injection Guard** | Input sanitization guidance in workflow docs | Partially — registry packs are screened (see below) |
| **Core template integrity** | — | Yes — `agtoosa.sh` installs files from a fixed, maintainer-controlled allowlist |
| **Registry pack containment** | — | Yes — SHA-256 pin, pre-extraction member scan, file-type allowlist, hook/CI destination denylist (`.claude/settings.json`, `.claude/hooks/`, `.github/workflows/`), verified-flag enforcement, and a content preview before consent |
| **Lifecycle verification** | `/agtoosa-status readiness` instructs checks | Yes — `Docs/agtoosa-verify.sh` is a deterministic script (CI-enforceable via `Docs/agtoosa-gate.yml.example`) |

> **Registry trust boundary:** core template files are maintainer-controlled and allowlisted. Registry packs are third-party content installed with explicit user consent — they are screened and contained as above, but their markdown still instructs your AI assistant. Review the preview before confirming any pack.

### Scope

**In scope:**
- Vulnerabilities in the AgToosa template instructions that could lead to insecure code generation
- Issues with `agtoosa.sh`, `agtoosa.ps1`, `bootstrap.sh`, `bootstrap.ps1`, `lib/registry.sh`, release assets, or template installation behavior
- Missing security controls in the workflow documentation

**Out of scope:**
- Vulnerabilities in third-party AI assistants (Cursor, Claude, Gemini, etc.)
- Issues with user-generated specifications or plans
- Security of the AI models themselves

## Acknowledgments

We gratefully acknowledge security researchers who help improve AgToosa. Contributors will be credited in our changelog (with permission).
