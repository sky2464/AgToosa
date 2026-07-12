# Examples — Official Web Pack

## Prerequisites

- Host project with AgToosa installed (`Docs/` or maintainer `docs/` layout)
- AgToosa version in range `>=5.0.0 <6.0.0`
- Cursor and/or Claude Code platform surfaces present (Windsurf/Gemini untested for this pilot)

## Intended use

Adopt web-application workflow guidance: UI/route ACs, browser QA expectations, and lifecycle gates without assembling unrelated pack examples.

## Runnable example

From the AgToosa maintainer repository (isolated project recommended):

```bash
# Stage into an isolated queue (preview + consent)
QUEUE=$(mktemp -d)
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./packs/official-web
# Expect: Pack contents preview, then queue at $QUEUE/official-web/
ls "$QUEUE/official-web/Docs/official-web-workflow.md"
```

Fixture path for CI (same install surface):

```bash
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./tests/fixtures/registry-packs/official-web
```

Merge into a throwaway project:

```bash
# After queueing, run a normal install against an isolated project path so
# _merge_pack_queue copies Docs/official-web-workflow.md into the host.
```

Evidence for DEV-080 lives in `docs/AgToosa_TestPlan-DEV-080.md` (OPP-005) — README commands alone are not install proof.

## Non-goals

- Treating this README as executed install evidence
- External registry publication (pilot status: **local candidate**)
- Guaranteeing fit for every web stack
