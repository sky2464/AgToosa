# AgToosa Quickref

> One-page contract. Load this first; open the deep docs only when a command needs them.
> Canonical detail lives in `docs/AgToosa_Agent.md` — this file never contradicts it.

## Day 1 — the 5-command lifecycle

| Step | Command | Deep doc (read on use) |
|------|---------|------------------------|
| 0. Once per project | `/agtoosa-init` | `docs/AgToosa_Init.md` |
| 1. Spec & plan | `/agtoosa-spec <idea>` | `docs/AgToosa_Spec.md` |
| 2. TDD build | `/agtoosa-build` | `docs/AgToosa_Build.md` |
| 3. Review gate | `/agtoosa-review` | `docs/AgToosa_Review.md` |
| 4. Ship & archive | `/agtoosa-ship` | `docs/AgToosa_Ship.md` |

Utilities (load on demand): `/agtoosa-status`, `/agtoosa-task`, `/agtoosa-qa`,
`/agtoosa-goal`, `/agtoosa-update`, `/agtoosa-debug`, `/agtoosa-revert`,
`/agtoosa-concise`, `/agtoosa-help` — each maps to `docs/AgToosa_<Name>.md`.

## Non-negotiables

1. **`docs/Master-Plan.md` is the only PM source of truth.** Update it first;
   external trackers are mirrors created only on explicit request.
2. **Spec before build.** No implementation without an approved spec
   (`## ✅ Spec Approved` in `docs/archived/spec-<id>.md`).
3. **TDD with evidence.** RED (captured failing run) → GREEN (captured passing
   run) → REFACTOR. Claims without terminal evidence don't count.
4. **Phase order.** spec → build → review → ship. Out-of-order runs warn and
   abort (see `docs/AgToosa_Governance.md`).
5. **Stop at phase boundaries.** Finish the phase, report, wait for the user
   unless they explicitly asked to chain phases.
6. **Scope discipline.** Stay inside the spec's Build Scope; new ideas go to
   the Master-Plan Backlog, not into the current diff.

## State files

| File | Role |
|------|------|
| `docs/Master-Plan.md` | Stories, tasks, status, update log |
| `docs/archived/spec-<id>.md` | Story spec (active until shipped, then stays archived) |
| `docs/AgToosa_TestPlan-<id>.md` | AC-to-test mapping + RED/GREEN evidence |
| `docs/archived/review-<id>.md` | Review verdicts |
| `docs/agtoosa-events.jsonl` | Append-only phase-event log (one JSON line per transition) |
| `docs/Context/*.md` | Product, tech-stack, workflow context |

## Verification

Deterministic, no-AI gate — run any time, and in CI:

```bash
bash docs/agtoosa-verify.sh            # gates: context, specs, ACs, evidence
bash docs/agtoosa-verify.sh --strict   # warnings fail too
bash docs/agtoosa-verify.sh stats      # cycle analytics
```

CI template: copy `docs/agtoosa-gate.yml.example` to
`.github/workflows/agtoosa-gate.yml` to block PRs on verifier failures.

## Phase-event logging

At every phase transition append one line to `docs/agtoosa-events.jsonl`:

```json
{"ts":"2026-01-01T00:00:00Z","phase":"build","event":"complete","story":"DEV-012","by":"AgToosa"}
```

`phase` ∈ init|spec|build|review|ship|qa|task; `event` ∈ start|complete|blocked.
