# Examples — Official Security Pack

## Prerequisites

- Host project with AgToosa installed
- AgToosa version in range `>=5.0.0 <6.0.0`
- Cursor and/or Claude Code (Windsurf/Gemini untested for this pilot)
- Human review available for trust-boundary and policy changes

## Intended use

Adopt security-sensitive workflow guidance: STRIDE threat modeling, evidence expectations, and honest claim boundaries. Does not replace `official-web` or `official-api` for product-domain scaffolds.

## Example repository

Per-pack example repository: https://github.com/sky2464/agtoosa-example-official-security

## Runnable example

```bash
QUEUE=$(mktemp -d)
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./packs/official-security
ls "$QUEUE/official-security/Docs/official-security-workflow.md"
```

Fixture path:

```bash
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./tests/fixtures/registry-packs/official-security
```

Recorded install/merge proof: `docs/AgToosa_TestPlan-DEV-095.md` (OPE-007).

## Non-goals

- README-only “proof” of install
- Claiming the pack is externally published
- Implying AgToosa itself runs scanners or fails CI on SAST findings without recorded command evidence
- Duplicating web UI or API service scaffolds
