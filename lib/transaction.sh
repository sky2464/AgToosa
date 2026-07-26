#!/usr/bin/env bash

# ── AgToosa: recoverable project transaction journal (DEV-119) ──
# Gitignored under .agtoosa/transactions/<id>/ with pre-image snapshots.

TRANSACTION_SCHEMA_VERSION=1
TRANSACTION_ACTIVE_DIR=""

transaction_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ"
}

transaction_root() {
  local project_path="$1"
  printf '%s/.agtoosa/transactions' "$project_path"
}

transaction_journal_file() {
  local txn_dir="$1"
  printf '%s/journal.json' "$txn_dir"
}

transaction_new_id() {
  local ts suffix
  ts="$(date -u +"%Y%m%dT%H%M%SZ" 2>/dev/null || date -u +"%Y%m%dT%H%M%SZ")"
  suffix="$(printf '%05d' "$((RANDOM % 100000))")"
  echo "${ts}-${suffix}"
}

# Reject path traversal in journal-relative paths.
transaction_rel_safe() {
  local rel="$1"
  [[ -n "$rel" && "$rel" != /* && "$rel" != *..* ]]
}

transaction_digest_file() {
  local f="$1"
  if declare -F apply_content_sha256 >/dev/null 2>&1; then
    apply_content_sha256 "$f"
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  else
    sha256sum "$f" | awk '{print $1}'
  fi
}

transaction_write_journal() {
  local journal_file="$1"
  python3 - "$journal_file" <<'PY'
import json, sys
path, data = sys.argv[1], json.load(sys.stdin)
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
}

transaction_read_journal() {
  local journal_file="$1"
  python3 - "$journal_file" <<'PY'
import json, sys
print(json.dumps(json.load(open(sys.argv[1], encoding="utf-8"))))
PY
}

transaction_open() {
  local project_path="$1"
  local apply_command="${2:-apply}"
  local root txn_id txn_dir journal_file started_at
  [[ -n "$project_path" ]] || return 1
  if [[ -n "$TRANSACTION_ACTIVE_DIR" ]]; then
    return 0
  fi
  root="$(transaction_root "$project_path")"
  txn_id="$(transaction_new_id)"
  txn_dir="${root}/${txn_id}"
  journal_file="$(transaction_journal_file "$txn_dir")"
  started_at="$(transaction_now_utc)"
  mkdir -p "${txn_dir}/snapshots"
  chmod 700 "${txn_dir}" 2>/dev/null || true
  TRANSACTION_ACTIVE_DIR="$txn_dir"
  python3 - "$journal_file" "$TRANSACTION_SCHEMA_VERSION" "$txn_id" "$started_at" \
    "${AGTOOSA_VERSION:-unknown}" "$apply_command" <<'PY'
import json, sys
path, schema_version, txn_id, started_at, agtoosa_version, apply_command = sys.argv[1:]
data = {
    "schema_version": int(schema_version),
    "transaction_id": txn_id,
    "status": "open",
    "started_at": started_at,
    "ended_at": None,
    "agtoosa_version": agtoosa_version,
    "apply_command": apply_command,
    "entries": [],
}
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
}

transaction_record_before() {
  local project_path="$1"
  local rel="$2"
  local target snap_rel before_marker sha_before journal_file
  [[ -n "$TRANSACTION_ACTIVE_DIR" ]] || return 1
  transaction_rel_safe "$rel" || return 1
  target="${project_path}/${rel}"
  journal_file="$(transaction_journal_file "$TRANSACTION_ACTIVE_DIR")"
  if [[ -f "$target" && ! -L "$target" ]]; then
    snap_rel="snapshots/${rel}"
    mkdir -p "$(dirname "${TRANSACTION_ACTIVE_DIR}/${snap_rel}")"
    cp "$target" "${TRANSACTION_ACTIVE_DIR}/${snap_rel}"
    sha_before="$(transaction_digest_file "$target")"
    before_marker="$snap_rel"
    python3 - "$journal_file" "$rel" "overwrite" "$before_marker" "$sha_before" <<'PY'
import json, sys
path, rel, op, before, sha = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
data = json.load(open(path, encoding="utf-8"))
data["entries"].append({"path": rel, "op": op, "before": before, "sha256_before": sha})
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
  elif [[ -f "$target" ]]; then
    echo "transaction: refusing symlink target $rel" >&2
    return 1
  else
    python3 - "$journal_file" "$rel" <<'PY'
import json, sys
path, rel = sys.argv[1], sys.argv[2]
data = json.load(open(path, encoding="utf-8"))
data["entries"].append({"path": rel, "op": "create", "before": "absent", "sha256_before": None})
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
  fi
}

transaction_set_status() {
  local status="$1"
  local journal_file ended_at
  [[ -n "$TRANSACTION_ACTIVE_DIR" ]] || return 1
  journal_file="$(transaction_journal_file "$TRANSACTION_ACTIVE_DIR")"
  ended_at="$(transaction_now_utc)"
  python3 - "$journal_file" "$status" "$ended_at" <<'PY'
import json, sys
path, status, ended_at = sys.argv[1], sys.argv[2], sys.argv[3]
data = json.load(open(path, encoding="utf-8"))
data["status"] = status
data["ended_at"] = ended_at
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
}

transaction_restore_from_dir() {
  local project_path="$1"
  local txn_dir="$2"
  local journal_file
  journal_file="$(transaction_journal_file "$txn_dir")"
  [[ -f "$journal_file" ]] || return 1
  python3 - "$project_path" "$txn_dir" "$journal_file" <<'PY'
import json, os, shutil, sys
project_path, txn_dir, journal_path = sys.argv[1], sys.argv[2], sys.argv[3]
data = json.load(open(journal_path, encoding="utf-8"))
for entry in reversed(data.get("entries", [])):
    rel = entry["path"]
    if not rel or rel.startswith("/") or ".." in rel:
        raise SystemExit(f"unsafe journal path: {rel}")
    target = os.path.join(project_path, rel)
    op = entry.get("op")
    before = entry.get("before")
    if op == "create":
        if os.path.lexists(target):
            os.remove(target)
        parent = os.path.dirname(target)
        if parent and os.path.isdir(parent) and not os.listdir(parent):
            os.rmdir(parent)
    elif op == "overwrite":
        snap = os.path.join(txn_dir, before)
        if not os.path.isfile(snap):
            raise SystemExit(f"missing snapshot for {rel}")
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copy2(snap, target)
    else:
        raise SystemExit(f"unknown op: {op}")
PY
}

transaction_rollback_active() {
  local project_path="$1"
  [[ -n "$TRANSACTION_ACTIVE_DIR" ]] || return 0
  transaction_restore_from_dir "$project_path" "$TRANSACTION_ACTIVE_DIR" || true
  transaction_set_status "aborted" || true
  TRANSACTION_ACTIVE_DIR=""
}

transaction_commit_active() {
  [[ -n "$TRANSACTION_ACTIVE_DIR" ]] || return 0
  transaction_set_status "committed"
  TRANSACTION_ACTIVE_DIR=""
}

transaction_list_incomplete_dirs() {
  local project_path="$1"
  local root txn_dir journal_file status
  root="$(transaction_root "$project_path")"
  [[ -d "$root" ]] || return 0
  for txn_dir in "$root"/*; do
    [[ -d "$txn_dir" ]] || continue
    journal_file="$(transaction_journal_file "$txn_dir")"
    [[ -f "$journal_file" ]] || continue
    status="$(python3 - "$journal_file" <<'PY'
import json, sys
print(json.load(open(sys.argv[1], encoding="utf-8")).get("status", ""))
PY
)"
    case "$status" in
      open|aborted|incomplete) printf '%s\n' "$txn_dir" ;;
    esac
  done
}

transaction_select_incomplete_dir() {
  local project_path="$1"
  local wanted_id="${2:-}"
  local root txn_dir journal_file tid started_at best_dir best_at=""
  root="$(transaction_root "$project_path")"
  [[ -d "$root" ]] || return 1
  for txn_dir in "$root"/*; do
    [[ -d "$txn_dir" ]] || continue
    journal_file="$(transaction_journal_file "$txn_dir")"
    [[ -f "$journal_file" ]] || continue
    read -r tid started_at status < <(python3 - "$journal_file" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
print(d.get("transaction_id", ""), d.get("started_at", ""), d.get("status", ""))
PY
)
    case "$status" in
      open|aborted|incomplete) ;;
      *) continue ;;
    esac
    if [[ -n "$wanted_id" ]]; then
      [[ "$tid" == "$wanted_id" ]] && { echo "$txn_dir"; return 0; }
      continue
    fi
    if [[ -z "$best_at" || "$started_at" > "$best_at" ]]; then
      best_at="$started_at"
      best_dir="$txn_dir"
    fi
  done
  if [[ -n "$wanted_id" ]]; then
    echo "transaction: no incomplete journal with id ${wanted_id}" >&2
    return 1
  fi
  [[ -n "$best_dir" ]] || return 1
  echo "$best_dir"
}

transaction_recover_project() {
  local project_path="$1"
  local wanted_id="${2:-}"
  local txn_dir journal_file
  txn_dir="$(transaction_select_incomplete_dir "$project_path" "$wanted_id")" || return 1
  journal_file="$(transaction_journal_file "$txn_dir")"
  transaction_restore_from_dir "$project_path" "$txn_dir" || return 1
  python3 - "$journal_file" "$(transaction_now_utc)" <<'PY'
import json, sys
path, ended_at = sys.argv[1], sys.argv[2]
data = json.load(open(path, encoding="utf-8"))
data["status"] = "recovered"
data["ended_at"] = ended_at
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
  echo "transaction: recovered ${txn_dir##*/}"
  return 0
}

transaction_status_project() {
  local project_path="$1"
  local root count=0 txn_dir journal_file
  root="$(transaction_root "$project_path")"
  if [[ ! -d "$root" ]]; then
    echo "transaction: no journals"
    return 0
  fi
  for txn_dir in "$root"/*; do
    [[ -d "$txn_dir" ]] || continue
    journal_file="$(transaction_journal_file "$txn_dir")"
    [[ -f "$journal_file" ]] || continue
    python3 - "$journal_file" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
print(f"{d.get('transaction_id')} status={d.get('status')} started={d.get('started_at')}")
PY
    count=$((count + 1))
  done
  [[ "$count" -gt 0 ]] || echo "transaction: no journals"
}

transaction_recover_cli() {
  local project_path="${1:-$PWD}"
  local wanted_id="${2:-}"
  project_path="$(cd "$project_path" 2>/dev/null && pwd || echo "$project_path")"
  transaction_recover_project "$project_path" "$wanted_id"
}

transaction_status_cli() {
  local project_path="${1:-$PWD}"
  project_path="$(cd "$project_path" 2>/dev/null && pwd || echo "$project_path")"
  transaction_status_project "$project_path"
}
