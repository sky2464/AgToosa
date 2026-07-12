# Examples — Official API / Service Pack

## Prerequisites

- Host project with AgToosa installed
- AgToosa version in range `>=5.0.0 <6.0.0`
- Cursor and/or Claude Code (Windsurf/Gemini untested for this pilot)

## Intended use

Adopt API/service workflow guidance: contract-first ACs, auth boundaries, and integration-test mapping.

## Runnable example

```bash
QUEUE=$(mktemp -d)
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./packs/official-api
ls "$QUEUE/official-api/Docs/official-api-workflow.md"
```

Fixture path:

```bash
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./tests/fixtures/registry-packs/official-api
```

Recorded install/merge proof: `docs/AgToosa_TestPlan-DEV-080.md` (OPP-006).

## Non-goals

- README-only “proof” of install
- Claiming the pack is externally published
- Full-stack UI scaffolds (use `official-web`)
