#!/usr/bin/env bash
# lib/interchange-providers/kiro.sh — Kiro-style (SPEC-FORMAT) interchange provider (DEV-124)

interchange_export_kiro() {
  local root="$1"
  local story="$2"
  local spec_path="$3"
  local proof_graph="$4"
  local out_manifest="$5"
  local out_artifact="$6"
  interchange_kiro_export "$root" "$spec_path" "$out_manifest" "$out_artifact"
}

interchange_import_kiro() {
  local root="$1"
  local fixture="$2"
  local out_manifest="$3"
  local out_loss="$4"
  interchange_kiro_import "$root" "$fixture" "$out_manifest" "$out_loss"
}

interchange_kiro_export() {
  local root="$1"
  local spec_path="$2"
  local manifest_out="$3"
  local artifact_out="$4"

  python3 - "$root" "$spec_path" "$manifest_out" "$artifact_out" <<'PY'
import json, os, re, sys
from datetime import datetime, timezone

root, spec_path, manifest_out, artifact_out = sys.argv[1:5]
safe_pat = re.compile(r"^(?!/)(?!.*\.\.).+$")
ac_pat = re.compile(r"^AC-[0-9]{3}$")

def now_iso():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def rel_spec_path(path):
    if path.startswith(root + os.sep):
        return path[len(root) + 1:]
    return path

with open(spec_path, encoding="utf-8") as f:
    spec_text = f.read()

story_id = "UNKNOWN"
m = re.search(r"^#\s+Spec:\s+([A-Za-z0-9._-]+)\s+—", spec_text, re.MULTILINE)
if m:
    story_id = m.group(1)
else:
    m = re.search(r">\s*\*\*Story ID:\*\*\s*([A-Za-z0-9._-]+)", spec_text)
    if m:
        story_id = m.group(1)

title_m = re.search(r"^#\s+Spec:\s+[A-Za-z0-9._-]+\s+—\s+(.*)$", spec_text, re.MULTILINE)
title = title_m.group(1).strip() if title_m else story_id

requirements = []
in_ac_table = False
for line in spec_text.splitlines():
    if re.match(r"^###\s+1\.2\s+Acceptance Criteria", line):
        in_ac_table = True
        continue
    if in_ac_table and re.match(r"^###\s+", line):
        break
    if not in_ac_table or not line.strip().startswith("|"):
        continue
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) < 3 or not ac_pat.match(cells[0]):
        continue
    pri = cells[2] if cells[2] in ("Must", "Should", "Could", "Won't") else "Must"
    requirements.append({
        "id": cells[0],
        "kind": "acceptance-criterion",
        "text": cells[1],
        "priority": pri,
    })

tasks = []
in_tasks = False
for line in spec_text.splitlines():
    if re.match(r"^###\s+3\.1\s+Task tree", line):
        in_tasks = True
        continue
    if in_tasks and re.match(r"^###\s+Wave Plan", line):
        break
    if not in_tasks:
        continue
    m = re.match(r"^-\s+\[[ xX]\]\s+\*\*(\d+(?:\.\d+)?)\.\*\*\s+(.*)$", line)
    if m:
        tasks.append({"id": m.group(1), "text": m.group(2).strip(), "completed": "[x]" in line.lower()[:6]})
        continue
    m = re.match(r"^\s+-\s+\[[ xX]\]\s+(\d+(?:\.\d+)?)\s+(.*)$", line)
    if m:
        tasks.append({"id": m.group(1), "text": m.group(2).strip(), "completed": "[x]" in line.lower()[:12]})

spec_rel = rel_spec_path(os.path.abspath(spec_path))
if not safe_pat.match(spec_rel):
    print(f"Error: unsafe spec path '{spec_rel}'", file=sys.stderr)
    sys.exit(1)

sections = {}
current = None
for line in spec_text.splitlines():
    hm = re.match(r"^##\s+(\d+)\.\s+(.*)$", line)
    if hm:
        current = f"section_{hm.group(1)}"
        sections[current] = {"title": hm.group(2).strip(), "lines": []}
        continue
    if current and line.strip():
        sections[current]["lines"].append(line)

manifest = {
    "version": 1,
    "story_id": story_id,
    "source_framework": "agtoosa",
    "source_ids": {
        "story_id": story_id,
        "spec_path": spec_rel,
        "framework_export": "kiro",
    },
    "authority": {"owner": "master-plan", "preserved": True},
    "requirements": requirements,
    "tasks": tasks,
    "provenance": {
        "spec_path": spec_rel,
        "exported_at": now_iso(),
    },
}

artifact = {
    "framework": "kiro",
    "fixture_profile": "kiro-spec-format-v1",
    "story_id": story_id,
    "title": title,
    "spec_path": spec_rel,
    "format": "SPEC-FORMAT.md",
    "sections": sections,
    "acceptance_criteria": requirements,
    "task_tree": tasks,
    "source_ids": manifest["source_ids"],
}

for path, payload in ((manifest_out, manifest), (artifact_out, artifact)):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)
        f.write("\n")
PY
}

interchange_kiro_import() {
  local root="$1"
  local fixture_path="$2"
  local manifest_out="$3"
  local loss_out="$4"

  python3 - "$root" "$fixture_path" "$manifest_out" "$loss_out" <<'PY'
import json, os, sys
from datetime import datetime, timezone

root, fixture_path, manifest_out, loss_out = sys.argv[1:5]

with open(fixture_path, encoding="utf-8") as f:
    fixture = json.load(f)

story_id = fixture.get("story_id", "UNKNOWN")
requirements = fixture.get("acceptance_criteria", [])
tasks = fixture.get("task_tree", [])

fixture_rel = fixture_path
if fixture_path.startswith(root + os.sep):
    fixture_rel = fixture_path[len(root) + 1:]

manifest = {
    "version": 1,
    "story_id": story_id,
    "source_framework": "kiro",
    "source_ids": {
        "story_id": story_id,
        "spec_path": fixture.get("spec_path", f"docs/archived/spec-{story_id}.md"),
        "framework": "kiro",
    },
    "authority": {"owner": "imported-derived", "preserved": False},
    "requirements": requirements,
    "tasks": tasks,
    "provenance": {
        "fixture_path": fixture_rel,
        "imported_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    },
}

loss = {
    "version": 1,
    "story_id": story_id,
    "source_framework": "kiro",
    "entries": [
        {
            "field": "authority.owner",
            "reason": "Kiro-style fixtures cannot assert Master-Plan SoT — manifest is imported-derived",
            "severity": "high",
        },
        {
            "field": "sections.interview_findings",
            "reason": "Frozen fixture may omit live Plan-Mode Spec Interview markdown block",
            "severity": "low",
        },
    ],
}

for path, payload in ((manifest_out, manifest), (loss_out, loss)):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)
        f.write("\n")
PY
}
