# AgToosa Public Benchmark Suite

Reproducible challenge tasks comparing spec-to-test-to-ship outcomes across spec-driven development (SDD) frameworks. Scores come from **deterministic checks** (`docs/agtoosa-verify.sh`-style gates), not vibes.

> **Claim boundary:** results may only be published with full logs, the exact prompts, framework versions, and model versions used. No superiority claims without published evidence (per DEV-060's Goal Contract).

## Frameworks under test

| Framework | Version pin | Install command |
|-----------|------------|-----------------|
| AgToosa | this repo @ tag | `bash agtoosa.sh --path <repo> --platforms <tool> --yes` |
| GitHub Spec Kit | record at run time | `uvx specify init` |
| OpenSpec | record at run time | `npx @fission-ai/openspec init` |
| BMAD-METHOD | record at run time | per BMAD docs |

## Reference tasks

Each task runs in a fresh fixture repo with the same agent, same model, same prompt budget. Three runs per framework; report the median.

### Task B1 — Greenfield feature with security surface
Build "user API-token management" (create/list/revoke) in a provided Express + SQLite fixture.

Scored checks (1 point each):
1. A written spec exists before any implementation diff (commit order proves it).
2. Spec contains testable acceptance criteria (EARS or GIVEN/WHEN/THEN).
3. A threat model or explicit security analysis exists for the token surface.
4. A failing test was captured before the implementing change (RED evidence in history or logs).
5. Every Must/primary AC maps to at least one test that exists and passes.
6. Tokens are hashed at rest (deterministic grep + test).
7. No file exceeds 500 lines; lint passes.
8. Final state passes the framework's own validation command (where one exists) — `agtoosa --verify`, `openspec validate --strict`, Spec Kit `/analyze` transcript.

### Task B2 — Brownfield change with drift trap
Fixture repo ships v1 behavior plus an intentionally stale spec/README. Task: change pagination from offset to cursor.

Scored checks:
1. Framework surfaces the stale-spec drift before coding (any documented mechanism).
2. Delta vs current state is recorded (changed/added/removed requirements).
3. Old behavior's tests updated, not deleted-without-replacement.
4. System-level documentation reflects the new behavior after ship.
5. Regression: untouched endpoints still pass their tests.

### Task B3 — Interrupted-session recovery
Kill the agent session mid-build (after ~50% of tasks). Resume in a fresh session with only the repo as context.

Scored checks:
1. New session identifies remaining work without human re-explanation.
2. No completed work is redone or clobbered.
3. Task/progress state file accuracy vs actual diff (audit by hand).
4. Time/tokens to productive resumption (report, lower is better).

## Scoring and publication

- Publish per-task scorecards + raw transcripts under `docs/benchmarks/results/<date>/`.
- Record: framework version, agent (e.g. Cursor x.y / Claude Code x.y), model, date.
- Honest-limitations section is mandatory in every published result (what the benchmark cannot measure: long-horizon maintainability, team dynamics).

## Why this design favors no one

Checks 1–8 in B1 are capabilities every SDD framework claims. The benchmark only verifies the claims each framework already markets. AgToosa's bet: machine-checkable evidence (RED runs, AC-test mapping, verifier exit codes) wins when measured — see `docs/enforcement-comparison.md`.
