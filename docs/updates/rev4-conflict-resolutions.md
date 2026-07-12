# Rev4 Conflict Resolutions

> **Status:** Resolved at spec promotion (2026-07-12).
> **Authority:** Binding for DEV-086–DEV-106 spec authoring. See enrolled stories in `docs/Master-Plan.md`.

## 1. DEV-080 three-pack cap vs five-pack maximum

**Conflict:** `docs/official-pack-pilot-checklist.md` line 16 forbids a fourth pack under DEV-080.

**Resolution:** DEV-095 **supersedes** DEV-080 inventory AC. Official pilot maximum is **five** packs (`official-api`, `official-web`, `official-infra`, `official-react`, `official-security`). DEV-080 three-pack delivery remains shipped; expansion is DEV-095 scope only after DEV-096 pack CI is green on existing pilots.

## 2. `official-web` vs `official-react`

**Conflict:** Rev4 lists React frontend; repo has `packs/official-web/`.

**Resolution:** **Split domains:**
- `official-web` — generic web/SPA workflow (retain; no rename).
- `official-react` — React-specific ACs, tooling hooks, and example repo (new in DEV-095).
- No overlap: web pack stays stack-agnostic; react pack references React/Next/Vite conventions explicitly.

## 3. Terminal Evidence vs Delivery Evidence naming

**Conflict:** DEV-010 ships **Terminal Evidence Contract** in `AgToosa_Agent.md`; Rev4 proposes **Evidence Contract**.

**Resolution:** New doc title is **`AgToosa_Delivery_Evidence_Contract.md`** (DEV-087). Cross-link from `AgToosa_Agent.md` Terminal Evidence section and `AgToosa_Evidence.md` ledger doc. Search terms: "delivery evidence" vs "terminal evidence."

## 4. `.agtoosa/policy.yaml` vs `.agtoosa/evidence.yml`

**Conflict:** Two optional YAML configs in `.agtoosa/` (DEV-059 policy + DEV-087 evidence profiles).

**Resolution:** Ship **`template/.agtoosa/README.md`** config index (DEV-087) documenting:
- `policy.yaml` — agent boundary / governance (DEV-059)
- `evidence.yml` — delivery evidence profiles (DEV-087)
- Verifier gate order: policy (Gate 6) → evidence profile (Gate 7, DEV-089) → lifecycle gates

## 5. Provenance surface authority

**Conflict:** `Docs/agtoosa-lock.json`, `.agtoosa/state.json`, `Docs/.agtoosa-version` overlap.

**Resolution (DEV-093):**

| Surface | Authority | Committed to git |
|---------|-----------|------------------|
| `Docs/.agtoosa-version` | Installed AgToosa semver marker | Yes |
| `Docs/agtoosa-lock.json` | Pack pins, platforms, reproducibility contract | Yes (when used) |
| `.agtoosa/state.json` | Operational hashes, last apply, evidence refs | No (gitignored) |

Doctor summarizes all three with explicit labels (DEV-088).

## 6. Lock file path in update docs

**Conflict:** `AgToosa_Update.md` cites `.agtoosa-lock.json`; code writes `Docs/agtoosa-lock.json`.

**Resolution:** DEV-090 AC requires correcting all references to **`Docs/agtoosa-lock.json`**. ADR-004 drift (`platforms[]`, pack SHA revalidation on update) addressed in DEV-093.
