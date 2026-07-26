#!/usr/bin/env bash
# lib/proof-providers/local-hash.sh — local-hash proof provider (DEV-120)

# shellcheck source=../proof.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/proof.sh"

PROOF_NODE_TYPES="story ac artifact command-run content-hash repo-snapshot"
PROOF_EDGE_TYPES="references verified-by content-of"

proof_provider_local_hash_verify() {
  local root="$1"
  local graph_file="$2"
  local allow_stale="${3:-false}"

  python3 - "$root" "$graph_file" "$allow_stale" <<'PY'
import hashlib, json, subprocess, sys

root, graph_path, allow_stale = sys.argv[1], sys.argv[2], sys.argv[3] == "true"
NODE_TYPES = {"story", "ac", "artifact", "command-run", "content-hash", "repo-snapshot"}
EDGE_TYPES = {"references", "verified-by", "content-of"}

def fail(msg):
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(1)

try:
    with open(graph_path, encoding="utf-8") as f:
        g = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    fail(f"cannot read graph: {e}")

for key in ("version", "story_id", "provider", "nodes", "edges"):
    if key not in g:
        fail(f"missing required field '{key}'")
if g.get("provider") != "local-hash":
    fail(f"unsupported provider '{g.get('provider')}' (expected local-hash)")
if g.get("version") != 1:
    fail(f"unsupported version {g.get('version')}")

nodes = {n["id"]: n for n in g.get("nodes", [])}
if not nodes:
    fail("graph has no nodes")

for nid, n in nodes.items():
    t = n.get("type")
    if t not in NODE_TYPES:
        fail(f"unknown node type '{t}' on node '{nid}'")
    if "ref" not in n and t not in ("content-hash", "repo-snapshot"):
        fail(f"node '{nid}' missing ref")
    forbidden = ("password", "token", "secret", "api_key", "private_key")
    blob = json.dumps(n).lower()
    for f in forbidden:
        if f'"{f}"' in blob or f"{f}:" in blob:
            fail(f"forbidden field pattern '{f}' in node '{nid}'")

for e in g.get("edges", []):
    et = e.get("type")
    if et not in EDGE_TYPES:
        fail(f"unknown edge type '{et}'")
    fr, to = e.get("from"), e.get("to")
    if fr not in nodes or to not in nodes:
        fail(f"edge references unknown node: {fr} -> {to}")

def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fp:
        for chunk in iter(lambda: fp.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()

# content-of: artifact/content-hash linkage
for e in g["edges"]:
    if e["type"] != "content-of":
        continue
    src, dst = nodes[e["from"]], nodes[e["to"]]
    if src["type"] not in ("artifact", "command-run") or dst["type"] != "content-hash":
        fail(f"content-of edge {e['from']}->{e['to']} has invalid node types")
    rel = dst.get("ref") or src.get("ref")
    if not rel:
        fail(f"content-of edge {e['from']}->{e['to']} missing file ref")
    if ".." in rel or rel.startswith("/"):
        fail(f"unsafe path '{rel}'")
    full = f"{root}/{rel}"
    import os
    if not os.path.isfile(full):
        fail(f"missing artifact file '{rel}'")
    expected = dst.get("sha256")
    if not expected:
        fail(f"content-hash node '{dst['id']}' missing sha256")
    actual = sha256_file(full)
    if actual.lower() != expected.lower():
        fail(f"hash mismatch for '{rel}': expected {expected}, got {actual}")

# verified-by: command-run -> artifact
for e in g["edges"]:
    if e["type"] != "verified-by":
        continue
    src, dst = nodes[e["from"]], nodes[e["to"]]
    if src["type"] != "command-run" or dst["type"] != "artifact":
        fail(f"verified-by edge {e['from']}->{e['to']} has invalid node types")
    if not src.get("ref"):
        fail(f"command-run node '{src['id']}' missing verification string")

# repo-snapshot
snapshots = [n for n in nodes.values() if n["type"] == "repo-snapshot"]
if snapshots:
    snap = snapshots[0]
    recorded = snap.get("sha") or snap.get("ref")
    if not recorded:
        fail("repo-snapshot missing sha")
    try:
        head = subprocess.check_output(
            ["git", "-C", root, "rev-parse", "HEAD"], text=True
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        fail("cannot resolve git HEAD for repo-snapshot check")
    if head != recorded and not allow_stale:
        fail(f"repo-snapshot stale: recorded {recorded}, HEAD {head}")

print(f"provider=local-hash story_id={g['story_id']} nodes={len(nodes)} edges={len(g['edges'])} snapshot_ok=1")
PY
}
