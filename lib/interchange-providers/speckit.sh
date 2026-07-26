#!/usr/bin/env bash
# lib/interchange-providers/speckit.sh — Spec Kit interchange provider (DEV-124)

interchange_export_speckit() {
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

  python3 - "$parsed" "$story" "$tmp_artifact" <<'PY'
import json, sys

with open(sys.argv[1], encoding="utf-8") as f:
    parsed = json.load(f)

story_id = parsed["story_id"]
title = f"Spec Kit export — {story_id}"
artifact = {
    "framework": "speckit",
    "fixture_profile": "speckit-v1",
    "story_id": story_id,
    "title": title,
    "spec_id": f"spec-{story_id}",
    "user_stories": [{
        "id": f"US-{story_id}",
        "title": title,
        "acceptance_criteria": [r["id"] for r in parsed.get("requirements", [])],
    }],
    "functional_requirements": [
        {"id": r["id"], "description": r["text"], "priority": r.get("priority", "Must")}
        for r in parsed.get("requirements", [])
    ],
    "source_ids": {"story_id": story_id, "spec_id": f"spec-{story_id}", "framework": "speckit"},
}
with open(sys.argv[3], "w", encoding="utf-8") as f:
    json.dump(artifact, f, indent=2)
    f.write("\n")
PY

  interchange_build_export_manifest "$root" "$parsed" "$spec_path" "$proof_graph" "$out_manifest" || return 1
  cp "$tmp_artifact" "$out_artifact"
}

interchange_import_speckit() {
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

requirements = []
for fr in data.get("functional_requirements", []):
    rid = fr.get("id", "")
    if ac_pat.match(rid):
        requirements.append({
            "id": rid,
            "kind": "acceptance-criterion",
            "text": fr.get("description", ""),
            "priority": fr.get("priority", "Must"),
        })
for ac in data.get("acceptance_criteria", []):
    rid = ac.get("id", "")
    if ac_pat.match(rid):
        requirements.append({
            "id": rid,
            "kind": "acceptance-criterion",
            "text": ac.get("description", ac.get("text", "")),
            "priority": ac.get("priority", "Must"),
        })

tasks = []
for us in data.get("user_stories", []):
    tasks.append({
        "id": us.get("id", f"US-{story_id}"),
        "text": us.get("title", ""),
        "completed": False,
    })
for task in data.get("tasks", []):
    tasks.append(task)

manifest = {
    "version": 1,
    "story_id": story_id,
    "source_framework": "speckit",
    "source_ids": data.get("source_ids", {"story_id": story_id, "spec_id": data.get("spec_id", f"spec-{story_id}")}),
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
    "source_framework": "speckit",
    "entries": [
        {
            "field": "authority.owner",
            "reason": "Spec Kit fixtures cannot assert Master-Plan SoT — manifest is imported-derived",
            "severity": "high",
        },
        {
            "field": "requirements.threat_model",
            "reason": "Spec Kit functional_requirements omit AgToosa STRIDE threat model section",
            "severity": "low",
        },
        {
            "field": "provenance.interview_findings",
            "reason": "Plan-Mode Spec Interview block not represented in Spec Kit export shape",
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

interchange_speckit_export() {
  interchange_export_speckit "$@"
}

interchange_speckit_import() {
  interchange_import_speckit "$@"
}
