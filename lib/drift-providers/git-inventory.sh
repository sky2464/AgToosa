#!/usr/bin/env bash
# lib/drift-providers/git-inventory.sh — allowlisted path inventory drift provider (DEV-122)

drift_git_inventory_assess() {
  local root="$1"
  local baseline="$2"
  local strict="${3:-false}"
  local measurement="${4:-}"
  local repo_root="${5:-}"

  python3 - "$root" "$baseline" "$strict" "$measurement" "$repo_root" <<'PY'
import json, hashlib, os, sys
from datetime import datetime, timezone

root, baseline_path, strict_flag, measurement_path, repo_root_arg = sys.argv[1:6]
strict = strict_flag.lower() == "true"
repo_root = repo_root_arg or os.path.abspath(os.path.join(os.path.dirname(baseline_path), "..", "..", ".."))

def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()

def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)

def impact_rank(level):
    order = {"none": 0, "low": 1, "medium": 2, "high": 3}
    return order.get(level, 0)

def suggested_rigor(impact):
    if impact in ("none", "low"):
        return "light"
    if impact == "medium":
        return "standard"
    return "elevated"

def compute_measurement(labels_path):
    if not labels_path or not os.path.isfile(labels_path):
        return None
    labels = load_json(labels_path)
    cases = labels.get("cases", [])
    if not cases:
        return None
    tp = tn = fp = fn = 0
    for case in cases:
        fixture = case.get("fixture", "")
        expected = bool(case.get("expected_drift", False))
        fixture_root = os.path.join(repo_root, "tests/fixtures/drift-assess", fixture)
        observed = False
        for entry in baseline.get("paths", []):
            rel = entry["path"]
            if ".." in rel or rel.startswith("/"):
                continue
            full = os.path.join(fixture_root, rel)
            if not os.path.isfile(full):
                observed = True
                break
            if sha256_file(full) != entry["sha256"]:
                observed = True
                break
        if expected and observed:
            tp += 1
        elif not expected and not observed:
            tn += 1
        elif not expected and observed:
            fp += 1
        else:
            fn += 1
    denom_pos = tp + fn
    denom_neg = tn + fp
    return {
        "source": "fixture-labeled",
        "cases_file": labels_path,
        "true_positives": tp,
        "true_negatives": tn,
        "false_positives": fp,
        "false_negatives": fn,
        "false_positive_rate": (fp / denom_neg) if denom_neg else 0.0,
        "false_negative_rate": (fn / denom_pos) if denom_pos else 0.0,
    }

try:
    baseline = load_json(baseline_path)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read baseline: {e}", file=sys.stderr)
    sys.exit(2)

if baseline.get("version") != 1:
    print("Error: unsupported baseline version", file=sys.stderr)
    sys.exit(2)

added = []
removed = []
modified = []
unchanged = []
max_impact = "none"

for entry in baseline.get("paths", []):
    rel = entry.get("path", "")
    expected = entry.get("sha256", "")
    impact = entry.get("impact_level", "low")
    if not rel or rel.startswith("/") or ".." in rel:
        print(f"Error: unsafe baseline path '{rel}'", file=sys.stderr)
        sys.exit(2)
    full = os.path.join(root, rel)
    if not os.path.isfile(full):
        removed.append(rel)
        if impact_rank(impact) > impact_rank(max_impact):
            max_impact = impact
        continue
    actual = sha256_file(full)
    if actual == expected:
        unchanged.append(rel)
    else:
        modified.append({
            "path": rel,
            "expected_sha256": expected,
            "actual_sha256": actual,
            "impact_level": impact,
        })
        if impact_rank(impact) > impact_rank(max_impact):
            max_impact = impact

if not removed and not modified:
    max_impact = "none"

report = {
    "version": 1,
    "provider": "git-inventory",
    "baseline_id": baseline.get("baseline_id", "unknown"),
    "assessed_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    "summary": {
        "added": len(added),
        "removed": len(removed),
        "modified": len(modified),
        "unchanged": len(unchanged),
    },
    "overall_impact_level": max_impact,
    "suggested_rigor": suggested_rigor(max_impact),
    "changes": {
        "added": added,
        "removed": removed,
        "modified": modified,
        "unchanged": unchanged,
    },
}

measurement = compute_measurement(measurement_path)
if measurement:
    report["measurement"] = measurement

print(json.dumps(report, indent=2))

exit_code = 0
if strict and max_impact == "high":
    exit_code = 1
sys.exit(exit_code)
PY
}
