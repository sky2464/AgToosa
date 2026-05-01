Read @Docs/AgToosa_Debug.md and execute the debug workflow.

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → execute the full 6-phase debug loop.
- `quick` → execute Phases 1–3 only: establish feedback loop, reproduce, minimise.
- `deep` → execute the full loop with an extended instrumentation pass (try all 3 hypotheses in sequence).
- `feedback-loop` → execute Phase 1 only: find the fastest deterministic way to reproduce the issue.

If no arguments were given, run the full flow from Docs/AgToosa_Debug.md.
