# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| 1.0.x   | ✅ Active support  |
| < 1.0   | ❌ No support      |

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

| Feature | Description |
|---------|-------------|
| **STRIDE Threat Modeling** | Every `/plan` phase requires Data Flow Diagrams and STRIDE analysis before code is written |
| **Sandboxed Execution** | `/build` and `/test` phases mandate ephemeral, isolated environments (Docker/Firecracker) |
| **SBOM Generation** | Software Bill of Materials generated during `/build` for supply chain transparency |
| **SAST/DAST Scanning** | Static and dynamic analysis (Semgrep, CodeQL, Gitleaks) integrated in `/test` and `/review` |
| **IaC Security Scanning** | Checkov/tfsec for infrastructure-as-code compliance |
| **PII Redaction** | Agent instructions mandate scrubbing of PII and secrets before LLM context |
| **Prompt Injection Guard** | Input sanitization to protect against malicious prompt injection |
| **Zero-Trust Architecture** | Principle of least privilege enforced throughout the workflow |

### Scope

**In scope:**
- Vulnerabilities in the AgToosa template instructions that could lead to insecure code generation
- Issues with the `install.sh` script (e.g., download integrity, path traversal)
- Missing security controls in the workflow documentation

**Out of scope:**
- Vulnerabilities in third-party AI assistants (Cursor, Claude, Gemini, etc.)
- Issues with user-generated specifications or plans
- Security of the AI models themselves

## Acknowledgments

We gratefully acknowledge security researchers who help improve AgToosa. Contributors will be credited in our changelog (with permission).
