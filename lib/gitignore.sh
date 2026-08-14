#!/usr/bin/env bash

# ── AgToosa: operational .gitignore merge (DEV-144) ─────────────
# Sourced by agtoosa.sh. Marker-managed block for downstream projects.

AGTOOSA_GITIGNORE_BEGIN='# BEGIN AgToosa operational (managed — do not edit)'
AGTOOSA_GITIGNORE_END='# END AgToosa operational'

gitignore_operational_patterns() {
  printf '%s\n' '.agtoosa/' '*.bak.*' '.worktrees/'
}

gitignore_render_operational_block() {
  local line
  echo "$AGTOOSA_GITIGNORE_BEGIN"
  while IFS= read -r line; do
    [[ -n "$line" ]] && echo "$line"
  done < <(gitignore_operational_patterns)
  echo "$AGTOOSA_GITIGNORE_END"
}

gitignore_has_operational_marker() {
  local project_path="$1"
  local gi="${project_path}/.gitignore"
  [[ -f "$gi" ]] && grep -qF "$AGTOOSA_GITIGNORE_BEGIN" "$gi"
}

# Merge or refresh the operational marker block in project .gitignore.
gitignore_merge_operational() {
  local project_path="$1"
  local gi="${project_path}/.gitignore"
  local block_file tmp

  [[ -n "$project_path" && -d "$project_path" ]] || {
    echo "gitignore: invalid project path" >&2
    return 1
  }

  block_file="$(mktemp)"
  gitignore_render_operational_block > "$block_file"

  if [[ ! -f "$gi" ]]; then
    cp "$block_file" "$gi"
    rm -f "$block_file"
    return 0
  fi

  if grep -qF "$AGTOOSA_GITIGNORE_BEGIN" "$gi"; then
    tmp="$(mktemp)"
  GI="$gi" BEGIN="$AGTOOSA_GITIGNORE_BEGIN" END="$AGTOOSA_GITIGNORE_END" BLOCK_FILE="$block_file" OUT="$tmp" \
    python3 <<'PY'
import os
import sys

gi = os.environ["GI"]
begin = os.environ["BEGIN"]
end = os.environ["END"]
out_path = os.environ["OUT"]
with open(os.environ["BLOCK_FILE"], encoding="utf-8") as bf:
    block = bf.read().rstrip("\n") + "\n"

with open(gi, encoding="utf-8") as f:
    lines = f.readlines()

out = []
inblock = False
replaced = False
for line in lines:
    stripped = line.rstrip("\n")
    if stripped == begin:
        inblock = True
        replaced = True
        out.append(block)
        continue
    if stripped == end:
        inblock = False
        continue
    if not inblock:
        out.append(line)

if replaced and inblock:
    print(
        "gitignore: malformed AgToosa marker block (BEGIN without END); leaving .gitignore unchanged",
        file=sys.stderr,
    )
    sys.exit(2)

if not replaced:
    if out and out[-1].strip():
        out.append("\n")
    out.append(block)

with open(out_path, "w", encoding="utf-8") as f:
    f.writelines(out)
PY
    py_rc=$?
    if [[ $py_rc -eq 2 ]]; then
      rm -f "$tmp"
      return 0
    fi
    if [[ $py_rc -ne 0 ]]; then
      rm -f "$tmp"
      return 1
    fi
    mv "$tmp" "$gi"
  else
    {
      echo ""
      cat "$block_file"
    } >> "$gi"
  fi

  rm -f "$block_file"
  return 0
}

# List tracked operational paths (empty when not a git repo).
gitignore_tracked_operational_paths() {
  local project_path="$1"
  local git_dir="${project_path}/.git"
  [[ -d "$git_dir" ]] || return 0

  git -C "$project_path" ls-files 2>/dev/null \
    | grep -E '^\.agtoosa/|\.bak\.[0-9]' || true
}

# Doctor: warn when marker missing or operational paths are tracked.
gitignore_doctor_check() {
  local target="$1"
  local doc_pass="${2:-}"
  local doc_finding="${3:-}"

  [[ -n "$doc_pass" && -n "$doc_finding" ]] || return 0

  if ! gitignore_has_operational_marker "$target"; then
    "$doc_finding" warn "GIG-003" \
      "Operational .gitignore marker block is missing" \
      "Operational artifacts (.agtoosa/, backups, worktrees) may be committed to git." \
      "Re-run: bash agtoosa.sh --update '${target}' or add the block from template/.gitignore" guided
    return 0
  fi

  "$doc_pass" "Operational .gitignore marker block present"

  local tracked line fix_hint sample_count=0
  tracked="$(gitignore_tracked_operational_paths "$target")"
  [[ -n "$tracked" ]] || return 0

  fix_hint="git rm -r --cached .agtoosa/"
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    if [[ "$line" == .agtoosa/* ]]; then
      continue
    fi
    fix_hint="${fix_hint}; git rm --cached '${line}'"
    sample_count=$((sample_count + 1))
    [[ $sample_count -ge 3 ]] && break
  done <<< "$tracked"

  "$doc_finding" warn "GIG-004" \
    "Operational paths are tracked in git (.agtoosa/ and/or *.bak.*)" \
    "Tracked operational files leak local state and merge backups into version control." \
    "${fix_hint} (manual — run from project root after reviewing)" guided
}
