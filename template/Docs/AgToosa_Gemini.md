# AgToosa Gemini Config

You are acting within the **AgToosa** framework. Refer to `AgToosa_Agent.md` for core rules.
Always verify dependencies and packages for the latest stable versions.

## Gemini slash-command routing

Native Gemini CLI commands are installed under `.gemini/commands/agtoosa-*.toml`. When the user invokes `/agtoosa-*`, execute the matching TOML adapter and canonical `Docs/AgToosa_*.md` workflow — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

### `/agtoosa-status` (read-only)

- Entry point: `.gemini/commands/agtoosa-status.toml`
- Workflow: `Docs/AgToosa_Status.md`
- Sub-commands: `plan`, `readiness`, `git`, `orphans` (full dashboard when no argument)
- **Read-only** — do not modify files, git state, or `Docs/Master-Plan.md`

## QA and Review Behaviors (Gemini-Specific)

### `/agtoosa-review` — Batch Coverage Analysis
- Load the entire test suite and spec into context simultaneously to perform a full AC coverage gap analysis.
- Identify test files that are structurally similar (potential duplication) and flag them as 🟡 Warning.
- Report coverage gaps as a table: `AC-NNN | Tests Found | Status`.

### `/agtoosa-review cross` — Primary Cross-Platform Reviewer
- When invoked from Claude Code, Gemini acts as the primary cross-platform reviewer.
- Load the full diff, spec, and prior review report into context.
- Produce a structured delta report: findings unique to Gemini, findings that match Claude's review (high-confidence), and findings Claude missed.

### `/agtoosa-qa run` — Flaky Test Detection
- Run the test suite 3× sequentially and compare pass/fail results per test ID.
- Flag any test with inconsistent results across runs as a 🟡 Warning flaky test.

### `/agtoosa-spec research` — Dependency Verification
- Use web search grounding to verify the latest stable version of every dependency in the spec.
- Check release dates — flag packages with no release in 12+ months as 🟡 Warning (maintenance risk).
