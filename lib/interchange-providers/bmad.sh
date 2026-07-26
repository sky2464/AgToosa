#!/usr/bin/env bash
# lib/interchange-providers/bmad.sh — BMAD interchange provider (DEV-124)

interchange_export_bmad() {
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

  python3 - "$parsed" "$spec_path" "$tmp_artifact" <<'PY'
import json, re, sys

with open(sys.argv[1], encoding="utf-8") as f:
    parsed = json.load(f)

with open(sys.argv[2], encoding="utf-8") as f:
    spec_text = f.read()

story_id = parsed["story_id"]
epic_m = re.search(r">\s*\*\*Epic:\*\*\s*(.+)$", spec_text, re.MULTILINE)
epic = epic_m.group(1).strip() if epic_m else f"epic-{story_id.lower()}"

artifact = {
    "framework": "bmad",
    "fixture_profile": "bmad-v1",
    "story_id": story_id,
    "epic_id": epic,
    "title": f"BMAD export — {story_id}",
    "stories": [{
        "id": story_id,
        "title": f"BMAD export — {story_id}",
        "acceptance_criteria": [r["id"] for r in parsed.get("requirements", [])],
        "tasks": [{"id": t["id"], "description": t["text"]} for t in parsed.get("tasks", [])],
    }],
    "source_ids": {"story_id": story_id, "epic_id": epic, "framework": "bmad"},
}
with open(sys.argv[3], "w", encoding="utf-8") as f:
    json.dump(artifact, f, indent=2)
    f.write("\n")
PY

  interchange_build_export_manifest "$root" "$parsed" "$spec_path" "$proof_graph" "$out_manifest" || return 1
  cp "$tmp_artifact" "$out_artifact"
}

interchange_import_bmad() {
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
bmad = data.get("bmad", {})

requirements = []
tasks = []

for story in data.get("stories", []):
    for ac_id in story.get("acceptance_criteria", []):
        if ac_pat.match(ac_id):
            requirements.append({
                "id": ac_id,
                "kind": "acceptance-criterion",
                "text": f"Imported BMAD acceptance criterion {ac_id}",
                "priority": "Must",
            })
    for task in story.get("tasks", []):
        tasks.append({
            "id": task.get("id", ""),
            "text": task.get("description", task.get("text", "")),
            "completed": False,
        })

for ac in bmad.get("acceptance_tests", []):
    rid = ac.get("ac_id", ac.get("id", ""))
    if ac_pat.match(rid):
        requirements.append({
            "id": rid,
            "kind": "acceptance-criterion",
            "text": ac.get("ears", ac.get("text", "")),
            "priority": ac.get("priority", "Must"),
        })
for task in bmad.get("implementation_tasks", []):
    tasks.append(task)

manifest = {
    "version": 1,
    "story_id": story_id,
    "source_framework": "bmad",
    "source_ids": data.get("source_ids", {
        "story_id": story_id,
        "epic_id": data.get("epic_id", bmad.get("epic_ref", f"epic-{story_id.lower()}")),
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
    "source_framework": "bmad",
    "entries": [
        {
            "field": "authority.owner",
            "reason": "BMAD fixtures cannot assert Master-Plan SoT — manifest is imported-derived",
            "severity": "high",
        },
        {
            "field": "requirements.ears_text",
            "reason": "BMAD acceptance_criteria IDs omit full EARS requirement text",
            "severity": "low",
        },
        {
            "field": "requirements.priority",
            "reason": "BMAD persona stories lack Must/Should priority labels",
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

interchange_bmad_export() {
  interchange_export_bmad "$@"
}

interchange_bmad_import() {
  interchange_import_bmad "$@"
}
