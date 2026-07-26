#!/usr/bin/env bash
# lib/interchange-providers/openspec.sh — OpenSpec interchange provider (DEV-124)

interchange_export_openspec() {
  local root="$1"
  local story="$2"
  local spec_path="$3"
  local proof_graph="$4"
  local out_manifest="$5"
  local out_artifact="$6"

  local parsed tmp_artifact
  parsed="$(mktemp)"
  tmp_artifact="$(mktemp)"
  trap 'rm -f "$parsed"' RETURN

  interchange_parse_spec "$spec_path" >"$parsed" || return 1

  python3 - "$parsed" "$tmp_artifact" <<'PY'
import json, sys

with open(sys.argv[1], encoding="utf-8") as f:
    parsed = json.load(f)

story_id = parsed["story_id"]
proposal_id = f"change-{story_id.lower()}"
scenarios = []
for req in parsed.get("requirements", []):
    text = req["text"]
    when, then = text, text
    if " THE SYSTEM SHALL " in text:
        when = text.split(" THE SYSTEM SHALL ")[0].replace("WHEN ", "", 1)
        then = text.split(" THE SYSTEM SHALL ", 1)[1]
    scenarios.append({"id": req["id"], "when": when, "then": then})

artifact = {
    "framework": "openspec",
    "fixture_profile": "openspec-v1",
    "story_id": story_id,
    "proposal_id": proposal_id,
    "title": f"OpenSpec export — {story_id}",
    "specs": [{"name": story_id, "scenarios": scenarios}],
    "source_ids": {"story_id": story_id, "proposal_id": proposal_id, "framework": "openspec"},
}
with open(sys.argv[2], "w", encoding="utf-8") as f:
    json.dump(artifact, f, indent=2)
    f.write("\n")
PY

  interchange_build_export_manifest "$root" "$parsed" "$spec_path" "$proof_graph" "$out_manifest" || return 1
  cp "$tmp_artifact" "$out_artifact"
}

interchange_import_openspec() {
  local root="$1"
  local fixture="$2"
  local out_manifest="$3"
  local out_loss="$4"

  python3 - "$root" "$fixture" "$out_manifest" "$out_loss" <<'PY'
import json, os, re, sys
from datetime import datetime, timezone

root, fixture_path, manifest_path, loss_path = sys.argv[1:5]
ac_pat = re.compile(r"^AC-[0-9]{3}$")

with open(fixture_path, encoding="utf-8") as f:
    data = json.load(f)

story_id = data.get("story_id", "UNKNOWN")
fixture_rel = os.path.relpath(os.path.abspath(fixture_path), root)
openspec = data.get("openspec", {})

requirements = []
for spec in data.get("specs", []):
    for scenario in spec.get("scenarios", []):
        sid = scenario.get("id", "")
        if not ac_pat.match(sid):
            continue
        text = f"WHEN {scenario.get('when', '')} THE SYSTEM SHALL {scenario.get('then', '')}".strip()
        requirements.append({
            "id": sid,
            "kind": "acceptance-criterion",
            "text": text,
            "priority": "Must",
        })
for req in openspec.get("requirements", []):
    rid = req.get("ref", req.get("id", ""))
    if ac_pat.match(rid):
        requirements.append({
            "id": rid,
            "kind": "acceptance-criterion",
            "text": req.get("statement", req.get("text", "")),
            "priority": req.get("priority", "Must"),
        })

tasks = openspec.get("work_items", [])
if not tasks:
    tasks = [{
        "id": data.get("proposal_id", f"change-{story_id.lower()}"),
        "text": data.get("title", story_id),
        "completed": False,
    }]

manifest = {
    "version": 1,
    "story_id": story_id,
    "source_framework": "openspec",
    "source_ids": data.get("source_ids", {
        "story_id": story_id,
        "proposal_id": data.get("proposal_id", f"change-{story_id.lower()}"),
    }),
    "authority": {"owner": "imported-derived", "preserved": False},
    "requirements": requirements,
    "tasks": tasks,
    "provenance": {
        "fixture_path": fixture_rel,
        "imported_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    },
}

loss = {
    "version": 1,
    "story_id": story_id,
    "source_framework": "openspec",
    "entries": [
        {
            "field": "authority.owner",
            "reason": "OpenSpec fixtures cannot assert Master-Plan SoT — manifest is imported-derived",
            "severity": "high",
        },
        {
            "field": "tasks.wave_plan",
            "reason": "OpenSpec proposal shape omits AgToosa task tree and wave plan",
            "severity": "low",
        },
        {
            "field": "requirements.priority",
            "reason": "OpenSpec scenarios lack Must/Should priority labels from AgToosa EARS table",
            "severity": "low",
        },
    ],
}

for path, payload in ((manifest_path, manifest), (loss_path, loss)):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)
        f.write("\n")
PY
}

interchange_openspec_export() {
  interchange_export_openspec "$@"
}

interchange_openspec_import() {
  interchange_import_openspec "$@"
}
