#!/usr/bin/env bash
set -uo pipefail

# ──────────────────────────────────────────────────────────────
# AgToosa Verifier — deterministic, read-only lifecycle gate.
#
# No AI, no network. Validates that the repo's AgToosa state is
# internally consistent: context files, Master-Plan integrity,
# spec approval, EARS acceptance criteria, AC-to-test mapping,
# threat model, task tree + wave plan, and TDD evidence blocks.
#
# Usage:
#   bash Docs/agtoosa-verify.sh [--root <repo-root>] [--strict] [stats]
#
# Exit codes: 0 = pass, 1 = findings (FAIL), 2 = usage/setup error.
# --strict promotes WARN findings to failures.
# `stats` prints cycle analytics from the Master-Plan Update Log
# and phase-event log instead of running gate checks.
# ──────────────────────────────────────────────────────────────

ROOT="$PWD"
STRICT=false
MODE="verify"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      [[ $# -lt 2 ]] && { echo "Error: --root requires a directory" >&2; exit 2; }
      ROOT="$2"; shift ;;
    --strict) STRICT=true ;;
    stats)    MODE="stats" ;;
    -h|--help)
      sed -n '4,20p' "$0"; exit 0 ;;
    *)
      echo "Error: unknown argument '$1'" >&2; exit 2 ;;
  esac
  shift
done

[[ -d "$ROOT" ]] || { echo "Error: root '$ROOT' is not a directory" >&2; exit 2; }

# Detect docs dir: Docs/ (generated projects) or docs/ (AgToosa maintainer repo).
DOCS=""
if [[ -f "$ROOT/Docs/Master-Plan.md" ]]; then
  DOCS="$ROOT/Docs"
elif [[ -f "$ROOT/docs/Master-Plan.md" ]]; then
  DOCS="$ROOT/docs"
else
  echo "Error: no Docs/Master-Plan.md or docs/Master-Plan.md under '$ROOT'." >&2
  echo "Run /agtoosa-init (or agtoosa.sh) first." >&2
  exit 2
fi
MP="$DOCS/Master-Plan.md"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

pass() { PASS_COUNT=$((PASS_COUNT + 1)); echo "  ✅ PASS  $1"; }
warn() { WARN_COUNT=$((WARN_COUNT + 1)); echo "  ⚠️  WARN  $1"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); echo "  ❌ FAIL  $1"; }

# ── stats mode ────────────────────────────────────────────────
run_stats() {
  echo "AgToosa stats — $ROOT"
  echo ""
  local total_rows ships specs builds reviews
  total_rows=$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}' "$MP" 2>/dev/null || echo 0)
  ships=$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}.*(Ship complete|Ship 🚀 Deployed)' "$MP" 2>/dev/null || echo 0)
  specs=$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}.*(/agtoosa-spec|Spec approved|Spec Approved)' "$MP" 2>/dev/null || echo 0)
  builds=$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}.*(Build complete|Build started)' "$MP" 2>/dev/null || echo 0)
  reviews=$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}.*Review' "$MP" 2>/dev/null || echo 0)
  echo "Update Log rows:       $total_rows"
  echo "Spec events:           $specs"
  echo "Build events:          $builds"
  echo "Review events:         $reviews"
  echo "Ship completions:      $ships"

  local archived_specs archived_reviews
  archived_specs=$(find "$DOCS/archived" -name 'spec-*.md' 2>/dev/null | wc -l | tr -d ' ')
  archived_reviews=$(find "$DOCS/archived" -name 'review-*.md' 2>/dev/null | wc -l | tr -d ' ')
  echo "Archived specs:        $archived_specs"
  echo "Archived reviews:      $archived_reviews"

  local events="$DOCS/agtoosa-events.jsonl"
  if [[ -f "$events" ]]; then
    echo "Phase events recorded: $(wc -l < "$events" | tr -d ' ')"
    if command -v jq &>/dev/null; then
      echo ""
      echo "Events by phase:"
      jq -r '.phase' "$events" 2>/dev/null | sort | uniq -c | sed 's/^/  /'
    fi
  else
    echo "Phase events recorded: 0 (no $events yet)"
  fi

  if [[ $total_rows -gt 150 ]]; then
    echo ""
    echo "⚠️  Update Log has $total_rows rows — rotate older rows to ${DOCS}/archived/updatelog-<year>.md (see AgToosa_Ship.md)."
  fi
  exit 0
}

[[ "$MODE" == "stats" ]] && run_stats

echo "AgToosa Verifier — $ROOT"
echo "Docs root: $DOCS"
echo ""

# ── Gate 1: context files populated ───────────────────────────
echo "Gate 1 — Context files"
ctx_missing=0
for f in product.md tech-stack.md workflow.md; do
  if [[ ! -f "$DOCS/Context/$f" ]]; then
    fail "missing $DOCS/Context/$f (run /agtoosa-init)"
    ctx_missing=1
  fi
done
if [[ $ctx_missing -eq 0 ]]; then
  if grep -lE '\[name\]|\[url\]|\[e\.g\.|\[N\]|\[YYYY-MM-DD\]' \
       "$DOCS/Context/product.md" "$DOCS/Context/tech-stack.md" "$DOCS/Context/workflow.md" >/dev/null 2>&1; then
    warn "context files contain template placeholders (run /agtoosa-init)"
  else
    pass "context files exist with no template placeholders"
  fi
fi

# ── Gate 2: Master-Plan integrity ──────────────────────────────
echo "Gate 2 — Master-Plan integrity"
if grep -qE '^\| DEV-[0-9]+ .*\| Epic' "$MP" || grep -qE '^\| DEV-[0-9]{3} \| Epic' "$MP" \
   || grep -A5 '^## Epics' "$MP" | grep -qE '\| DEV-[0-9]+'; then
  pass "Epics section has at least one real epic row"
else
  fail "no real Epic rows in Master-Plan ## Epics (run /agtoosa-init)"
fi

dup_ids=$(grep -oE 'DEV-[0-9]{3}' "$MP" | sort | uniq -c | awk '$1 > 50 {print $2}')
if [[ -n "$dup_ids" ]]; then
  warn "story IDs appear unusually often (possible Update Log bloat): $(echo "$dup_ids" | tr '\n' ' ')"
fi

log_rows=$(grep -cE '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}' "$MP" 2>/dev/null || echo 0)
if [[ $log_rows -gt 150 ]]; then
  warn "Update Log has $log_rows rows; rotate older rows to archived/updatelog-<year>.md"
else
  pass "Update Log within rotation budget ($log_rows rows)"
fi

# ── Gate 3: active stories have approved specs ────────────────
echo "Gate 3 — Spec approval and naming"
active_ids=$(awk '/^## Active Cycle/,/^## [^A]/' "$MP" | grep -oE '^\| DEV-[0-9]{3}' | grep -oE 'DEV-[0-9]{3}' | sort -u)
if [[ -z "$active_ids" ]]; then
  if awk '/^## Active Cycle/,/^## [^A]/' "$MP" | grep -qiE 'cycle parked|_\(none'; then
    pass "Active Cycle idle (parked — spec checks skipped)"
  else
    warn "no stories found in ## Active Cycle (idle is fine; verify skipped spec checks)"
  fi
else
  for id in $active_ids; do
    spec=""
    for candidate in "$DOCS/archived/spec-${id}.md" "$DOCS/specs/spec-${id}.md"; do
      [[ -f "$candidate" ]] && spec="$candidate" && break
    done
    if [[ -z "$spec" ]]; then
      fail "$id: no spec file (expected $DOCS/archived/spec-${id}.md)"
      continue
    fi
    if grep -qE '^## ✅ Spec Approved|^## Spec Approved' "$spec"; then
      pass "$id: spec exists and is approved ($(basename "$spec"))"
    else
      fail "$id: spec found but missing '## ✅ Spec Approved' marker"
    fi

    # EARS acceptance criteria structural lint.
    ac_rows=$(grep -cE '^\| *AC-[0-9]{3}' "$spec" 2>/dev/null || echo 0)
    if [[ $ac_rows -eq 0 ]]; then
      fail "$id: no AC-NNN rows found in spec acceptance criteria"
    else
      bad_ears=0
      while IFS= read -r row; do
        if ! echo "$row" | grep -qiE '(WHEN|WHILE|WHERE|IF|THE SYSTEM SHALL|SHALL)'; then
          bad_ears=$((bad_ears + 1))
        fi
      done < <(grep -E '^\| *AC-[0-9]{3}' "$spec")
      if [[ $bad_ears -gt 0 ]]; then
        warn "$id: $bad_ears of $ac_rows AC rows lack EARS keywords (WHEN/WHILE/WHERE/IF/SHALL)"
      else
        pass "$id: all $ac_rows AC rows use EARS patterns"
      fi
    fi

    # Threat model presence.
    if grep -qiE 'threat model|STRIDE' "$spec"; then
      pass "$id: threat model section present"
    else
      fail "$id: no threat model / STRIDE section in spec"
    fi

    # Spec revision integrity: amended specs must log revisions.
    if grep -qE '^## Spec Revision Log' "$spec"; then
      pass "$id: spec has a revision log"
    fi

    # AC-to-test mapping in the story test plan.
    tp=""
    for candidate in "$DOCS/AgToosa_TestPlan-${id}.md" "$DOCS"/AgToosa_TestPlan-*"${id}"*.md; do
      [[ -f "$candidate" ]] && tp="$candidate" && break
    done
    if [[ -z "$tp" ]]; then
      fail "$id: no test plan (expected $DOCS/AgToosa_TestPlan-${id}.md)"
    else
      unmapped=""
      while IFS= read -r ac; do
        grep -q "$ac" "$tp" || unmapped+="$ac "
      done < <(grep -oE 'AC-[0-9]{3}' "$spec" | sort -u)
      if [[ -n "$unmapped" ]]; then
        warn "$id: ACs not referenced in test plan: $unmapped"
      else
        pass "$id: every AC in the spec is referenced in the test plan"
      fi

      # TDD evidence: RED (failing) before GREEN (passing) capture.
      if grep -qiE 'RED evidence|RED run|exit[ _-]?code: *[1-9]' "$tp"; then
        pass "$id: test plan records RED (failing-run) evidence"
      else
        warn "$id: no RED failing-run evidence block in test plan (TDD gate)"
      fi
    fi

    # Task tree + wave plan.
    if awk '/^## Active Tasks/,/^## [^A]/' "$MP" | grep -q "$id"; then
      pass "$id: task tree present in Master-Plan ## Active Tasks"
    else
      warn "$id: no task tree under ## Active Tasks for this story"
    fi
    if grep -qE '^### Wave Plan' "$spec"; then
      pass "$id: spec contains a Wave Plan"
    else
      warn "$id: spec has no ### Wave Plan section"
    fi
  done
fi

# ── Gate 4: review artifacts for Done stories ─────────────────
echo "Gate 4 — Review artifacts"
done_ids=$(awk '/^## Active Cycle/,/^## [^A]/' "$MP" | grep -E '✅ Done|🏁 Shipped' | grep -oE 'DEV-[0-9]{3}' | sort -u)
for id in $done_ids; do
  if ls "$DOCS/archived/review-${id}"*.md >/dev/null 2>&1 || ls "$DOCS/archived/review-"*"${id}"*.md >/dev/null 2>&1; then
    pass "$id: review artifact archived"
  else
    warn "$id: marked Done but no archived review-${id}.md yet (run /agtoosa-review)"
  fi
done

# ── Gate 5: generator version parity (maintainer repos only) ──
echo "Gate 5 — Version parity"
if [[ -f "$ROOT/agtoosa.sh" && -f "$ROOT/agtoosa.ps1" ]]; then
  bv=$(grep -m1 'AGTOOSA_VERSION=' "$ROOT/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
  pv=$(grep -m1 'AGTOOSA_VERSION' "$ROOT/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
  if [[ -n "$bv" && "$bv" == "$pv" ]]; then
    pass "generator version parity (bash=$bv, ps1=$pv)"
  else
    fail "generator version mismatch (bash=$bv, ps1=$pv)"
  fi
elif [[ -f "$DOCS/.agtoosa-version" ]]; then
  pass "installed AgToosa version: $(cat "$DOCS/.agtoosa-version")"
else
  warn "no $DOCS/.agtoosa-version marker (install with agtoosa.sh to enable update checks)"
fi

# ── Gate 6: optional governance policy (DEV-059) ───────────────
# Missing policy is NOT a finding. Invalid present policy → WARN.
echo "Gate 6 — Optional governance policy"
POLICY_CHECK=""
VERIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
for candidate in \
  "$DOCS/agtoosa-policy-check.sh" \
  "$VERIFY_DIR/agtoosa-policy-check.sh" \
  "$ROOT/docs/agtoosa-policy-check.sh" \
  "$ROOT/Docs/agtoosa-policy-check.sh" \
  "$ROOT/template/Docs/agtoosa-policy-check.sh"
do
  if [[ -f "$candidate" ]]; then
    POLICY_CHECK="$candidate"
    break
  fi
done
if [[ -z "$POLICY_CHECK" ]]; then
  pass "no policy checker installed (optional)"
else
  policy_rc=0
  policy_out=$(bash "$POLICY_CHECK" --root "$ROOT" 2>&1) || policy_rc=$?
  if echo "$policy_out" | grep -q 'policy_path=none'; then
    pass "no extra policy configured"
  elif [[ $policy_rc -eq 0 ]]; then
    pass "optional policy valid ($(echo "$policy_out" | grep -m1 'policy_path=' || true))"
  else
    warn "invalid optional policy (see agtoosa-policy-check.sh); missing policy is never a finding"
  fi
fi

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────────"
echo "Verifier summary: $PASS_COUNT pass · $WARN_COUNT warn · $FAIL_COUNT fail"
if [[ $FAIL_COUNT -gt 0 ]]; then
  echo "Result: ❌ FAIL"
  exit 1
fi
if [[ "$STRICT" == true && $WARN_COUNT -gt 0 ]]; then
  echo "Result: ❌ FAIL (strict mode: warnings are failures)"
  exit 1
fi
echo "Result: ✅ PASS"
exit 0
