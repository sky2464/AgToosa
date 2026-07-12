#!/usr/bin/env bash
# DEV-096 — Deterministic official-pack validation (manifest, SHA, fixture parity).
# Offline/private by default: local files only; no registry network fetch.
set -euo pipefail

ROOT_DIR="${AGTOOSA_PACK_VALIDATE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MODE="${AGTOOSA_PACK_VALIDATE_MODE:-private}"

usage() {
  cat <<'EOF'
Usage:
  scripts/validate-official-packs.sh [--mode private|offline] [--root DIR]

Validates each packs/official-* pilot:
  1. bash agtoosa.sh --catalog validate <manifest>
  2. provenance.sha256 vs SHA-256 of pack Docs/ content
  3. fixture Docs/ tree parity vs pack Docs/ (allowlisted installable paths)

Modes:
  private|offline  Local-only checks; no network (default).

Environment:
  AGTOOSA_PACK_VALIDATE_ROOT   Override repository root (isolated fixtures)
  AGTOOSA_PACK_VALIDATE_MODE   private|offline
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      [[ $# -lt 2 ]] && { echo "Error: --mode requires private or offline" >&2; exit 2; }
      MODE="$2"
      shift 2
      ;;
    --root)
      [[ $# -lt 2 ]] && { echo "Error: --root requires a directory" >&2; exit 2; }
      ROOT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$MODE" in
  private|offline) ;;
  *)
    echo "Error: unsupported mode '$MODE' (expected private or offline)" >&2
    exit 2
    ;;
esac

ROOT_DIR="$(cd "$ROOT_DIR" && pwd)"
AGTOOSA_SH="$ROOT_DIR/agtoosa.sh"
PACKS_DIR="$ROOT_DIR/packs"
FIXTURES_DIR="$ROOT_DIR/tests/fixtures/registry-packs"

[[ -f "$AGTOOSA_SH" ]] || { echo "Error: agtoosa.sh not found under $ROOT_DIR" >&2; exit 2; }
[[ -d "$PACKS_DIR" ]] || { echo "Error: packs/ not found under $ROOT_DIR" >&2; exit 2; }

compute_sha256() {
  local file="$1"
  if command -v sha256sum &>/dev/null; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v shasum &>/dev/null; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    echo "Error: Neither sha256sum nor shasum found on this system." >&2
    return 1
  fi
}

FAILURES=0

record_fail() {
  # Actionable diagnostic: pack, file, observed, expected
  local pack="$1" file="$2" observed="$3" expected="$4"
  printf 'FAIL pack=%s file=%s observed=%s expected=%s\n' "$pack" "$file" "$observed" "$expected" >&2
  FAILURES=$((FAILURES + 1))
}

pass() {
  printf 'ok - %s\n' "$1"
}

# Allowlisted installable paths: Docs/** under each official pack (mirrors OPP fixtures).
list_docs_relpaths() {
  local base="$1"
  local docs="$base/Docs"
  [[ -d "$docs" ]] || return 0
  (
    cd "$docs" && find . -type f | sed 's|^\./||' | sort
  )
}

validate_pack() {
  local pack_name="$1"
  local pack_dir="$PACKS_DIR/$pack_name"
  local fixture_dir="$FIXTURES_DIR/$pack_name"
  local manifest="$pack_dir/manifest.json"
  local before_failures=$FAILURES

  [[ -d "$pack_dir" ]] || {
    record_fail "$pack_name" "packs/$pack_name" "missing" "directory present"
    return
  }
  [[ -f "$manifest" ]] || {
    record_fail "$pack_name" "manifest.json" "missing" "file present"
    return
  }
  [[ -d "$fixture_dir" ]] || {
    record_fail "$pack_name" "tests/fixtures/registry-packs/$pack_name" "missing" "fixture directory present"
    return
  }

  # AC-002: catalog manifest validation
  local catalog_out catalog_status=0
  catalog_out="$(bash "$AGTOOSA_SH" --catalog validate "$manifest" 2>&1)" || catalog_status=$?
  if [[ "$catalog_status" -ne 0 ]]; then
    record_fail "$pack_name" "manifest.json" "catalog validate exit $catalog_status" "Catalog valid (exit 0)"
    printf '%s\n' "$catalog_out" >&2
  else
    printf '%s\n' "$catalog_out"
  fi

  # AC-003: provenance.sha256 vs canonical pack Docs content
  local recorded
  recorded="$(python3 - "$manifest" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
entries = d.get("entries") or []
if not entries:
    print("")
    raise SystemExit(0)
print(entries[0].get("provenance", {}).get("sha256") or "")
PY
)"
  if [[ -z "$recorded" ]]; then
    record_fail "$pack_name" "manifest.json/provenance.sha256" "missing" "64-char hex digest"
  fi

  local docs_count=0
  local primary_rel="" primary_path="" computed=""
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    docs_count=$((docs_count + 1))
    if [[ -z "$primary_rel" ]]; then
      primary_rel="$rel"
      primary_path="$pack_dir/Docs/$rel"
    fi
  done < <(list_docs_relpaths "$pack_dir")

  if [[ "$docs_count" -eq 0 ]]; then
    record_fail "$pack_name" "Docs/" "missing" "at least one Docs/ file"
  elif [[ "$docs_count" -eq 1 ]]; then
    computed="$(compute_sha256 "$primary_path")"
    if [[ -n "$recorded" && "$computed" != "$recorded" ]]; then
      record_fail "$pack_name" "Docs/$primary_rel" "$computed" "$recorded"
    fi
  else
    # Multi-file Docs/: deterministic content digest of sorted path+hash lines
    local digest_input=""
    while IFS= read -r rel; do
      [[ -z "$rel" ]] && continue
      local h
      h="$(compute_sha256 "$pack_dir/Docs/$rel")"
      digest_input+="${rel} ${h}"$'\n'
    done < <(list_docs_relpaths "$pack_dir")
    computed="$(printf '%s' "$digest_input" | if command -v sha256sum &>/dev/null; then sha256sum | awk '{print $1}'; else shasum -a 256 | awk '{print $1}'; fi)"
    if [[ -n "$recorded" && "$computed" != "$recorded" ]]; then
      record_fail "$pack_name" "Docs/(tree-digest)" "$computed" "$recorded"
    fi
  fi

  # AC-004: fixture Docs/ tree parity with pack Docs/
  local pack_paths fixture_paths
  pack_paths="$(list_docs_relpaths "$pack_dir")"
  fixture_paths="$(list_docs_relpaths "$fixture_dir")"

  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    local pack_file="$pack_dir/Docs/$rel"
    local fix_file="$fixture_dir/Docs/$rel"
    if [[ ! -f "$fix_file" ]]; then
      record_fail "$pack_name" "Docs/$rel" "missing in fixture" "present (parity with packs/$pack_name/Docs/$rel)"
      continue
    fi
    local pack_hash fix_hash
    pack_hash="$(compute_sha256 "$pack_file")"
    fix_hash="$(compute_sha256 "$fix_file")"
    if [[ "$pack_hash" != "$fix_hash" ]]; then
      record_fail "$pack_name" "Docs/$rel" "$fix_hash" "$pack_hash"
    fi
  done <<< "$pack_paths"

  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    local pack_file="$pack_dir/Docs/$rel"
    if [[ ! -f "$pack_file" ]]; then
      record_fail "$pack_name" "Docs/$rel" "extra in fixture" "absent (not in packs/$pack_name/Docs/)"
    fi
  done <<< "$fixture_paths"

  # Always emit pack name for inventory greps; overall exit tracks FAILURES.
  if [[ "$FAILURES" -eq "$before_failures" ]]; then
    pass "$pack_name manifest+sha+parity"
  else
    printf 'not ok - %s (%d finding(s))\n' "$pack_name" "$((FAILURES - before_failures))" >&2
  fi
}

shopt -s nullglob
pack_dirs=("$PACKS_DIR"/official-*)
shopt -u nullglob

if [[ "${#pack_dirs[@]}" -eq 0 ]]; then
  echo "Error: no packs/official-* directories under $PACKS_DIR" >&2
  exit 1
fi

echo "Pack validation root: $ROOT_DIR (mode=$MODE)"
echo "Offline/private mode: no registry network fetch"

for pack_path in "${pack_dirs[@]}"; do
  [[ -d "$pack_path" ]] || continue
  validate_pack "$(basename "$pack_path")"
done

if [[ "$FAILURES" -gt 0 ]]; then
  echo "Pack validation failed: $FAILURES finding(s)" >&2
  exit 1
fi

echo "Pack validation passed for ${#pack_dirs[@]} official pack(s)"
exit 0
