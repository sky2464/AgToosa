# Examples — Official Infrastructure / Security Pack

## Prerequisites

- Host project with AgToosa installed
- AgToosa version in range `>=5.0.0 <6.0.0`
- Human review before production policy changes
- Cursor and/or Claude Code (Windsurf/Gemini untested for this pilot)

## Intended use

Adopt infrastructure/security workflow guidance while preserving registry trust-boundary controls (allowlist, denylist, preview, consent).

## Runnable example

```bash
QUEUE=$(mktemp -d)
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./packs/official-infra
# Preview must list pack contents; denylisted destinations must not appear in this safe pack
ls "$QUEUE/official-infra/Docs/official-infra-workflow.md"
```

Fixture path:

```bash
echo Y | AGTOOSA_PACK_QUEUE_DIR="$QUEUE" bash agtoosa.sh --registry install ./tests/fixtures/registry-packs/official-infra
```

Negative boundary (disallowed file type) uses `tests/fixtures/registry-packs/unsafe-disallowed` — see OPP-008.

Recorded proof: `docs/AgToosa_TestPlan-DEV-080.md` (OPP-007, OPP-008).

## Non-goals

- Weakening generator-enforced registry safety
- Writing pack content into `.github/workflows/` or `.claude/settings.json`
- Treating local candidate status as external publication
