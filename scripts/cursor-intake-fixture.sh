#!/usr/bin/env bash
# Create a disposable downstream project with Cursor AgToosa wiring for manual intake verification.
# Usage: bash scripts/cursor-intake-fixture.sh [path]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURE="${1:-$(mktemp -d /tmp/agtoosa-cursor-fixture-XXXXXX)}"
FIXTURE="$(cd "$FIXTURE" 2>/dev/null && pwd || echo "$FIXTURE")"

_rp_fixture="$(cd "$FIXTURE" 2>/dev/null && pwd || true)"
_rp_root="$(cd "$ROOT" && pwd)"

if [[ -z "${_rp_fixture:-}" ]]; then
  echo "❌ Error: Could not resolve fixture path '${FIXTURE}'." >&2
  exit 1
fi

if [[ "$_rp_fixture" == "$_rp_root" ]]; then
  echo "❌ Error: Target path cannot be the AgToosa source directory itself." >&2
  echo "   Use a separate directory (or omit the path for a temp fixture)." >&2
  exit 1
fi

mkdir -p "$FIXTURE"

echo "Installing AgToosa (Cursor only) into: $FIXTURE"
bash "$ROOT/agtoosa.sh" --path "$FIXTURE" --platforms cursor --yes || exit 1

fail=0
assert_file() {
  if [[ ! -f "$1" ]]; then
    echo "❌ Missing: $1" >&2
    fail=1
  fi
}

assert_file "$FIXTURE/.cursor/rules/agtoosa-core.mdc"
assert_file "$FIXTURE/.cursor/commands/agtoosa-spec.md"
assert_file "$FIXTURE/.cursor/commands/agtoosa-build.md"
assert_file "$FIXTURE/Docs/AgToosa_Agent.md"

if ! grep -q 'alwaysApply: true' "$FIXTURE/.cursor/rules/agtoosa-core.mdc"; then
  echo "❌ agtoosa-core.mdc missing alwaysApply: true" >&2
  fail=1
fi

if ! grep -q 'Project Intake' "$FIXTURE/.cursor/rules/agtoosa-core.mdc"; then
  echo "❌ agtoosa-core.mdc missing Project Intake" >&2
  fail=1
fi

if ! grep -q 'Natural language intent map' "$FIXTURE/.cursor/rules/agtoosa-core.mdc"; then
  echo "❌ agtoosa-core.mdc missing Natural language intent map" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo ""
echo "✅ Cursor intake fixture ready: $FIXTURE"
echo ""
echo "Manual verification checklist (open this path in Cursor):"
echo "  1. Command picker: /agtoosa-spec — runs Docs/AgToosa_Spec.md workflow"
echo "  2. Freeform: \"plan and code <feature>\" — Project Intake hard-gate (no silent coding)"
echo "  3. Freeform: \"build it\" with no approved spec — routes to spec first"
echo "  4. Command picker: /agtoosa-build — runs Docs/AgToosa_Build.md after spec approval"
echo ""
echo "Remove when done: rm -rf \"$FIXTURE\""
