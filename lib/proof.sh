#!/usr/bin/env bash
# lib/proof.sh — shared helpers for Evidence Provenance v2 (DEV-120)

proof_sha256_file() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
  else
    echo "Error: no sha256 tool (shasum or sha256sum)" >&2
    return 2
  fi
}

proof_repo_head() {
  local root="$1"
  git -C "$root" rev-parse HEAD 2>/dev/null
}

proof_resolve_path() {
  local root="$1"
  local rel="$2"
  # Reject absolute paths and traversal
  [[ "$rel" == /* ]] && return 1
  [[ "$rel" == *".."* ]] && return 1
  local full="$root/$rel"
  [[ -f "$full" ]] && printf '%s\n' "$full"
}

proof_validate_graph_json() {
  local graph_file="$1"
  python3 - "$graph_file" <<'PY'
import json, sys

path = sys.argv[1]
NODE_TYPES = {"story", "ac", "artifact", "command-run", "content-hash", "repo-snapshot"}
EDGE_TYPES = {"references", "verified-by", "content-of"}
required_top = {"version", "story_id", "provider", "nodes", "edges"}

try:
    with open(path, encoding="utf-8") as f:
        g = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: invalid graph: {e}", file=sys.stderr)
    sys.exit(1)

missing = required_top - set(g.keys())
if missing:
    print(f"Error: missing fields: {sorted(missing)}", file=sys.stderr)
    sys.exit(1)
if g.get("version") != 1 or g.get("provider") != "local-hash":
    print("Error: unsupported version or provider", file=sys.stderr)
    sys.exit(1)
if not g.get("nodes"):
    print("Error: graph has no nodes", file=sys.stderr)
    sys.exit(1)

nodes = {n.get("id"): n for n in g["nodes"]}
for nid, n in nodes.items():
    if not nid:
        print("Error: node missing id", file=sys.stderr)
        sys.exit(1)
    if n.get("type") not in NODE_TYPES:
        print(f"Error: unknown node type '{n.get('type')}'", file=sys.stderr)
        sys.exit(1)

for e in g.get("edges", []):
    if e.get("type") not in EDGE_TYPES:
        print(f"Error: unknown edge type '{e.get('type')}'", file=sys.stderr)
        sys.exit(1)
    if e.get("from") not in nodes or e.get("to") not in nodes:
        print("Error: edge references unknown node", file=sys.stderr)
        sys.exit(1)
PY
}
