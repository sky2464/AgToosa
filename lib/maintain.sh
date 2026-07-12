#!/usr/bin/env bash

# ── AgToosa: verify / doctor / uninstall helpers ───────────────
# Sourced by agtoosa.sh.
# Globals read: SCRIPT_DIR, TEMPLATE_DIR, AGTOOSA_VERSION, FORCE, ASSUME_YES,
#               DOCS_FILES, OPTIONAL_TEMPLATE_FILES, CONTEXT_FILES, colors.

# Run the deterministic lifecycle verifier against a target repo.
# Prefers the target's installed copy (so downstream pins stay honest),
# falls back to the template copy shipped with the generator.
# Remaining args after target (--format, --strict, stats) are forwarded.
run_verify() {
  local target="$1"
  shift || true
  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 2
  fi
  local script=""
  for candidate in "${target}/Docs/agtoosa-verify.sh" "${target}/docs/agtoosa-verify.sh" \
                   "${TEMPLATE_DIR}/Docs/agtoosa-verify.sh"; do
    [[ -f "$candidate" ]] && script="$candidate" && break
  done
  if [[ -z "$script" ]]; then
    echo -e "${RED}❌ Error: agtoosa-verify.sh not found in target or template.${NC}" >&2
    return 2
  fi
  bash "$script" --root "$target" "$@"
}

# Emit doctor JSON (verify-result-v1 + provenance) via python.
_doctor_emit_json() {
  local exit_code="$1" findings_file="$2" provenance_json="$3"
  PASS_COUNT="$PASS_COUNT" WARN_COUNT="$WARN_COUNT" FAIL_COUNT="$FAIL_COUNT" \
  EXIT_CODE="$exit_code" FINDINGS_FILE="$findings_file" PROVENANCE_JSON="$provenance_json" \
  python3 - <<'PY'
import json, os
findings = []
path = os.environ["FINDINGS_FILE"]
if os.path.exists(path) and os.path.getsize(path) > 0:
    with open(path, encoding="utf-8") as f:
        for line in f:
            parts = line.rstrip("\n").split("\t", 6)
            if len(parts) < 6:
                continue
            sev, fid, problem, impact, fix, assurance = parts[:6]
            item = {
                "id": fid, "severity": sev, "problem": problem,
                "impact": impact, "fix": fix, "assurance": assurance,
            }
            refs = [r for r in (parts[6] if len(parts) > 6 else "").split(",") if r]
            if refs:
                item["ac_refs"] = refs
            findings.append(item)
doc = {
    "schema_version": "verify-result-v1",
    "tool": "doctor",
    "exit_code": int(os.environ["EXIT_CODE"]),
    "summary": {
        "pass": int(os.environ["PASS_COUNT"]),
        "warn": int(os.environ["WARN_COUNT"]),
        "fail": int(os.environ["FAIL_COUNT"]),
    },
    "findings": findings,
    "provenance": json.loads(os.environ["PROVENANCE_JSON"]),
}
print(json.dumps(doc, ensure_ascii=False, separators=(",", ":")))
PY
}

# Diagnose an existing AgToosa install: version skew, platform wiring,
# context health, pending pack queue, stale backups, and provenance surfaces.
# Optional: --format text|json (default text).
run_doctor() {
  local target="$1"
  shift || true
  local format="text"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --format)
        [[ $# -lt 2 ]] && { echo -e "${RED}❌ Error: --format requires text|json${NC}" >&2; return 2; }
        format="$2"; shift
        case "$format" in text|json) ;; *)
          echo -e "${RED}❌ Error: invalid --format '${format}' (expected text|json)${NC}" >&2
          return 2 ;;
        esac ;;
      *)
        echo -e "${RED}❌ Error: unknown doctor argument '${1}'${NC}" >&2
        return 2 ;;
    esac
    shift
  done

  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 2
  fi

  local PASS_COUNT=0 WARN_COUNT=0 FAIL_COUNT=0
  local findings_file
  findings_file="$(mktemp)"
  trap 'rm -f "$findings_file"' RETURN

  _doc_pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    if [[ "$format" == "text" ]]; then
      echo -e "  ${GREEN}✅${NC} $1"
    fi
  }
  _doc_finding() {
    local severity="$1" id="$2" problem="$3" impact="$4" fix="$5" assurance="${6:-guided}"
    if [[ "$severity" == "fail" ]]; then
      FAIL_COUNT=$((FAIL_COUNT + 1))
    else
      WARN_COUNT=$((WARN_COUNT + 1))
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t\n' \
      "$severity" "$id" "$problem" "$impact" "$fix" "$assurance" >> "$findings_file"
    if [[ "$format" == "text" ]]; then
      local icon label
      if [[ "$severity" == "fail" ]]; then
        icon="${RED}❌${NC}"; label="FAIL"
      else
        icon="${YELLOW}⚠️${NC}"; label="WARN"
      fi
      echo -e "  ${icon} ${label}  ${id}"
      echo "  Problem: ${problem}"
      echo "  Impact:  ${impact}"
      echo "  Fix:     ${fix}"
    fi
  }

  if [[ "$format" == "text" ]]; then
    echo -e "${BOLD}AgToosa Doctor — ${target}${NC}"
    echo ""
  fi

  # Resolve Docs/ vs docs/ for provenance paths.
  local docs_rel="Docs" docs_dir="${target}/Docs"
  if [[ ! -d "$docs_dir" && -d "${target}/docs" ]]; then
    docs_rel="docs"; docs_dir="${target}/docs"
  fi

  # Provenance surfaces (rev4-conflict-resolutions §5).
  local ver_path="${docs_rel}/.agtoosa-version"
  local lock_path="${docs_rel}/agtoosa-lock.json"
  local state_path=".agtoosa/state.json"
  local ver_present=false lock_present=false state_present=false ver_value=""
  [[ -f "${target}/${ver_path}" ]] && ver_present=true && ver_value="$(tr -d '\n' < "${target}/${ver_path}")"
  [[ -f "${target}/${lock_path}" ]] && lock_present=true
  [[ -f "${target}/${state_path}" ]] && state_present=true

  local provenance_json
  provenance_json=$(VER_PATH="$ver_path" LOCK_PATH="$lock_path" STATE_PATH="$state_path" \
    VER_PRESENT="$ver_present" LOCK_PRESENT="$lock_present" STATE_PRESENT="$state_present" \
    VER_VALUE="$ver_value" python3 - <<'PY'
import json, os
def surface(path, present, committed, authority, value=None):
    d = {"path": path, "present": present == "true", "committed": committed, "authority": authority}
    if value:
        d["value"] = value
    return d
doc = {
  "version_marker": surface(os.environ["VER_PATH"], os.environ["VER_PRESENT"], True,
    "Installed AgToosa semver marker (committed)", os.environ.get("VER_VALUE") or None),
  "lock_file": surface(os.environ["LOCK_PATH"], os.environ["LOCK_PRESENT"], True,
    "Pack pins, platforms, reproducibility contract (committed when used)"),
  "state_file": surface(os.environ["STATE_PATH"], os.environ["STATE_PRESENT"], False,
    "Operational hashes, last apply, evidence refs (gitignored; absent is OK)"),
}
# Drop null value
if "value" in doc["version_marker"] and doc["version_marker"]["value"] is None:
    del doc["version_marker"]["value"]
print(json.dumps(doc, separators=(",", ":")))
PY
)

  if [[ "$format" == "text" ]]; then
    echo "  Provenance surfaces (rev4 §5):"
    echo "    version_marker: ${ver_path} present=${ver_present} committed=true"
    echo "      authority: Installed AgToosa semver marker (committed)"
    echo "    lock_file: ${lock_path} present=${lock_present} committed=true"
    echo "      authority: Pack pins, platforms, reproducibility contract (committed when used)"
    echo "    state_file: ${state_path} present=${state_present} committed=false"
    echo "      authority: Operational hashes, last apply, evidence refs (gitignored; absent is OK)"
    echo ""
  fi

  # Install presence + version skew.
  if [[ "$ver_present" == true ]]; then
    if [[ "$ver_value" == "$AGTOOSA_VERSION" ]]; then
      _doc_pass "Installed version ${ver_value} matches generator v${AGTOOSA_VERSION}"
    else
      _doc_finding warn "DR-version-skew" \
        "Installed v${ver_value}, generator v${AGTOOSA_VERSION}" \
        "Version skew can leave workflow docs and platforms out of date." \
        "Run: bash agtoosa.sh --update '${target}'" guided
    fi
  elif [[ -d "$docs_dir" ]]; then
    _doc_finding warn "DR-no-version" \
      "${docs_rel}/ exists but no ${ver_path} marker (pre-3.x install or partial copy)" \
      "Doctor cannot confirm install version or safe update skew." \
      "Re-install or update with agtoosa.sh to write ${ver_path}." guided
  else
    _doc_finding fail "DR-not-installed" \
      "No Docs/ directory — AgToosa is not installed here." \
      "Verify/doctor cannot diagnose an uninstalled tree." \
      "Run: bash agtoosa.sh" enforced
    if [[ "$format" == "json" ]]; then
      _doctor_emit_json 1 "$findings_file" "$provenance_json"
    else
      echo ""
      echo -e "${RED}${BOLD}Doctor result: not installed.${NC}"
    fi
    return 1
  fi

  # Core workflow docs present.
  local missing=0 f
  for f in "${DOCS_FILES[@]}"; do
    [[ -f "${target}/${f}" ]] || missing=$((missing + 1))
  done
  if [[ $missing -eq 0 ]]; then
    _doc_pass "All ${#DOCS_FILES[@]} core workflow docs present"
  else
    _doc_finding warn "DR-missing-docs" \
      "${missing} core workflow doc(s) missing" \
      "Missing workflow docs break command routing and updates." \
      "Run bash agtoosa.sh --update '${target}' to restore." guided
  fi

  # Platform entry-point wiring.
  if [[ -d "${target}/.cursor" && ! -f "${target}/.cursorrules" ]]; then
    _doc_finding warn "DR-cursor-entry" \
      ".cursor/ exists but .cursorrules entry point is missing" \
      "Cursor adapters may not load AgToosa core rules." \
      "Restore .cursorrules via --update or re-install with cursor selected." guided
  fi
  if [[ -d "${target}/.windsurf" && ! -f "${target}/.windsurfrules" ]]; then
    _doc_finding warn "DR-windsurf-entry" \
      ".windsurf/ exists but .windsurfrules entry point is missing" \
      "Windsurf adapters may not load AgToosa rules." \
      "Restore .windsurfrules via --update or re-install with windsurf selected." guided
  fi
  if [[ -d "${target}/.claude" && ! -f "${target}/CLAUDE.md" ]]; then
    _doc_finding warn "DR-claude-entry" \
      ".claude/ exists but CLAUDE.md entry point is missing" \
      "Claude Code may miss AgToosa agent instructions." \
      "Restore CLAUDE.md via --update or re-install with claude selected." guided
  fi

  # Context health.
  if [[ -d "${docs_dir}/Context" ]]; then
    if grep -lE '\[name\]|\[url\]|\[e\.g\.' "${docs_dir}/Context/"*.md >/dev/null 2>&1; then
      _doc_finding warn "DR-context-placeholders" \
        "Context files still contain template placeholders" \
        "Agents may treat placeholders as real product facts." \
        "Run /agtoosa-init to populate Docs/Context/." guided
    else
      _doc_pass "Context files populated"
    fi
  fi

  # Pending pack queue in the generator checkout.
  if [[ -d "$PACK_QUEUE_DIR" ]] && find "$PACK_QUEUE_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -q .; then
    if [[ "$format" == "text" ]]; then
      echo -e "  ${CYAN}ℹ️${NC}  Queued pack(s) pending merge — run: bash agtoosa.sh (install) to merge them"
    fi
  fi

  # Stale backup files.
  local baks
  baks=$(find "$target" -maxdepth 2 -name '*.bak.*' 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$baks" -gt 0 && "$format" == "text" ]]; then
    echo -e "  ${CYAN}ℹ️${NC}  ${baks} backup file(s) (*.bak.*) present — clean up and gitignore them"
  fi

  local exit_code=0
  if [[ $FAIL_COUNT -gt 0 || $WARN_COUNT -gt 0 ]]; then
    exit_code=1
  fi

  if [[ "$format" == "json" ]]; then
    _doctor_emit_json "$exit_code" "$findings_file" "$provenance_json"
  else
    echo ""
    if [[ $exit_code -eq 0 ]]; then
      echo -e "${GREEN}${BOLD}Doctor result: healthy.${NC}"
    else
      echo -e "${YELLOW}${BOLD}Doctor result: $((WARN_COUNT + FAIL_COUNT)) issue(s) found.${NC}"
    fi
  fi
  return "$exit_code"
}

# Remove AgToosa-owned files from a project. Preserves user data:
# Master-Plan, Master-Architecture, Changelog, Context/, archived/, and any
# platform entry-point files that may contain user content (those get a notice).
run_uninstall() {
  local target="$1"
  if [[ -z "$target" ]]; then
    read -rp "Project path to uninstall AgToosa from: " target
    target="${target/#\~/$HOME}"
    target="${target%/}"
  fi
  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 1
  fi
  if [[ ! -d "${target}/Docs" ]]; then
    echo -e "${RED}❌ Error: No Docs/ directory in '${target}' — nothing to uninstall.${NC}" >&2
    return 1
  fi

  local _rp_target _rp_script
  _rp_target="$(cd "$target" && pwd)"
  _rp_script="$(cd "$SCRIPT_DIR" && pwd)"
  if [[ "$_rp_target" == "$_rp_script" ]]; then
    echo -e "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}" >&2
    return 1
  fi

  echo -e "${BOLD}Uninstall AgToosa from: ${target}${NC}"
  echo "Removes AgToosa-owned workflow docs and platform command/rule files."
  echo "Preserves: Master-Plan.md, Master-Architecture.md, AgToosa_Changelog.md,"
  echo "           Docs/Context/, Docs/archived/, and merged platform entry-point files."
  echo ""
  local reply
  if [[ "$ASSUME_YES" == true ]]; then
    reply="Y"
  else
    read -rp "Proceed? (y/N): " reply
    reply="${reply:-N}"
  fi
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  local removed=0 f
  for f in "${DOCS_FILES[@]}"; do
    case "$f" in
      Docs/Master-Plan.md|Docs/Master-Architecture.md|Docs/AgToosa_Changelog.md) continue ;;
    esac
    if [[ -f "${target}/${f}" ]]; then
      rm -f "${target}/${f}"
      removed=$((removed + 1))
    fi
  done
  for f in "${OPTIONAL_TEMPLATE_FILES[@]}"; do
    # Entry-point files may carry user content from smart merges — leave them.
    case "$f" in
      .cursorrules|.windsurfrules|CLAUDE.md|AGENTS.md|OPENCODE.md|.github/copilot-instructions.md) continue ;;
    esac
    if [[ -f "${target}/${f}" ]]; then
      rm -f "${target}/${f}"
      removed=$((removed + 1))
    fi
  done
  if [[ -f "${target}/Docs/.agtoosa-version" ]]; then
    rm -f "${target}/Docs/.agtoosa-version"
    removed=$((removed + 1))
  fi

  # Remove now-empty AgToosa-owned directories (never user dirs like Docs/).
  local d
  for d in .claude/commands .claude/skills .claude/hooks .cursor/rules .cursor/commands \
           .gemini/commands .github/prompts .github/agents .github/instructions \
           .codex/skills .codex/prompts .windsurf/rules .windsurf/workflows \
           Docs/schemas; do
    [[ -d "${target}/${d}" ]] && find "${target}/${d}" -type d -empty -delete 2>/dev/null
  done

  echo ""
  echo -e "${GREEN}✅ Removed ${removed} AgToosa-owned file(s).${NC}"
  echo -e "${CYAN}ℹ️  Merged entry-point files (.cursorrules, CLAUDE.md, AGENTS.md, …) were kept;${NC}"
  echo -e "${CYAN}   delete the AGTOOSA START/END blocks inside them manually if desired.${NC}"
  return 0
}

# Emit one executive SYNC line from Master-Plan (read-only).
# stdout: SYNC: <story-id|none> · <status> · tasks N/M · clarity <tags|—> · next </agtoosa-command>
run_status_line() {
  local target="${1:-$PWD}"
  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 2
  fi
  local mp=""
  for candidate in "${target}/docs/Master-Plan.md" "${target}/Docs/Master-Plan.md"; do
    [[ -f "$candidate" ]] && mp="$candidate" && break
  done
  if [[ -z "$mp" ]]; then
    echo -e "${RED}❌ Error: Master-Plan.md not found under docs/ or Docs/.${NC}" >&2
    return 2
  fi
  MP_PATH="$mp" python3 - <<'PY'
import os, re

path = os.environ["MP_PATH"]
text = open(path, encoding="utf-8").read()

def section(body, name):
    m = re.search(rf"^## {re.escape(name)}\s*\n(.*?)(?=^## |\Z)", body, re.M | re.S)
    return m.group(1) if m else ""

ac = section(text, "Active Cycle")
rows = []
for line in ac.splitlines():
    if not re.match(r"^\| DEV-\d+", line):
        continue
    parts = [p.strip() for p in line.split("|") if p.strip()]
    if len(parts) < 5:
        continue
    sid, st = parts[0], parts[4]
    tc = parts[5] if len(parts) > 5 else "0/0"
    rows.append((sid, st, tc))

def score(st):
    if "In Progress" in st or "🟨" in st:
        return 3
    if "In Review" in st or "🔍" in st:
        return 2
    if "Todo" in st or "🟦" in st:
        return 1
    return 0

story_id, status, tasks_col = "none", "none", "0/0"
picked = [r for r in rows if score(r[1]) > 0]
if picked:
    picked.sort(key=lambda r: -score(r[1]))
    story_id, status, tasks_col = picked[0]

tasks_done, tasks_total = 0, 0
if "/" in tasks_col:
    try:
        tasks_done, tasks_total = [int(x) for x in tasks_col.split("/", 1)]
    except ValueError:
        pass

at = section(text, "Active Tasks")
if story_id != "none":
    m = re.search(rf"^### {re.escape(story_id)}[^\n]*\n(.*?)(?=^### |\Z)", at, re.M | re.S)
    if m:
        block = m.group(1)
        sub = [ln for ln in block.splitlines() if re.match(r"^\s+- \[[ x]\]", ln)]
        if sub:
            tasks_total = len(sub)
            tasks_done = sum(1 for ln in sub if re.match(r"^\s+- \[x\]", ln))

clarity = "—"
bl = section(text, "Backlog")
if story_id != "none":
    for line in bl.splitlines():
        if line.startswith(f"| {story_id} "):
            parts = [p.strip() for p in line.split("|") if p.strip()]
            if len(parts) >= 8:
                clarity = parts[7] or "—"
            break

st_short = re.sub(r"[🟦🟨🔍✅🏁🚫🔧⬜]\s*", "", status).strip() or status

if not rows or all(score(r[1]) == 0 for r in rows):
    next_cmd = "/agtoosa-spec"
elif story_id == "none":
    next_cmd = "/agtoosa-status"
elif "In Review" in status or "🔍" in status:
    next_cmd = "/agtoosa-ship"
elif tasks_total > 0 and tasks_done < tasks_total:
    next_cmd = "/agtoosa-build"
elif tasks_total > 0 and tasks_done >= tasks_total:
    next_cmd = "/agtoosa-review"
elif "Todo" in status or "🟦" in status or "In Progress" in status or "🟨" in status:
    next_cmd = "/agtoosa-build"
else:
    next_cmd = "/agtoosa-spec"

print(f"SYNC: {story_id} · {st_short} · tasks {tasks_done}/{tasks_total} · clarity {clarity} · next {next_cmd}")
PY
}
