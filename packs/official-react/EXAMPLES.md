# Examples — Official React Pack

## Prerequisites

- Host project with AgToosa installed (`Docs/` or maintainer `docs/` layout)
- AgToosa version in range `>=5.0.0 <6.0.0`
- Cursor and/or Claude Code platform surfaces present (Windsurf/Gemini untested for this pilot)
- React, Next.js, or Vite+React project (or intent to create one)

## Intended use

Adopt React/Next/Vite workflow guidance: component and route ACs, hydration boundaries, and lifecycle gates. Use `official-web` when you need stack-agnostic SPA guidance instead.

## Example repository

Per-pack example repository: https://github.com/sky2464/agtoosa-example-official-react

## Runnable example

From the AgToosa maintainer repository (isolated project recommended):

```bash
# Stage into an isolated queue (preview + consent)
QUEUE=$(mktemp -d)
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./packs/official-react
# Expect: Pack contents preview, then queue at $QUEUE/official-react/
ls "$QUEUE/official-react/Docs/official-react-workflow.md"
```

Fixture path for CI (same install surface):

```bash
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./tests/fixtures/registry-packs/official-react
```

Evidence for DEV-095 lives in `docs/AgToosa_TestPlan-DEV-095.md` (OPE-006) — README commands alone are not install proof.

## Non-goals

- Treating this README as executed install evidence
- External registry publication (pilot status: **local candidate**)
- Replacing `official-web` for non-React stacks
