#!/usr/bin/env bash
# DEV-153: summarize @smoke / @regression tags in tests/agtoosa.bats
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BATS_FILE="${ROOT}/tests/agtoosa.bats"

smoke_total=$(grep -c '@smoke' "$BATS_FILE" || true)
regression_total=$(grep -c '@regression' "$BATS_FILE" || true)
dual=$(grep -E '@test.*@regression.*@smoke|@test.*@smoke.*@regression' "$BATS_FILE" 2>/dev/null | wc -l || true)
dual=${dual// /}
sr_smoke=$(grep '@smoke' "$BATS_FILE" | grep -ciE ' SR-' || true)
sr_regression=$(grep '@regression' "$BATS_FILE" | grep -ciE ' SR-' || true)

echo "AgToosa bats tag summary ($(basename "$BATS_FILE"))"
echo "  @smoke occurrences:      $smoke_total"
echo "  @regression occurrences:  $regression_total"
echo "  dual-tagged @test lines:  $dual"
echo "  @smoke lines w/ SR-:      $sr_smoke"
echo "  @regression lines w/ SR-: $sr_regression"
echo ""
echo "Target (DEV-153): @smoke 45–75; @regression 103+ ship-wave SR tests"
echo "Run: time bats tests/agtoosa.bats -f '@smoke'"