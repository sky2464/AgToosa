# Test Plan: DEV-018 — Registry Pack Queue

| ID | Command / setup | Expected |
|----|-----------------|----------|
| PK1 | `AGTOOSA_PACK_QUEUE_DIR=$(mktemp -d) echo Y \| bash agtoosa.sh --registry install ./tests/fixtures/mock-pack` | Exit 0; `mock-pack/workflow.md` under queue dir; not required under `ship/packs/` |
| PK2 | Source `install.sh`; set `PROJECT_PATH`, `PACK_QUEUE_DIR`; call `_merge_pack_queue` | Pack file in project; `Docs/agtoosa-lock.json` has pack entry; queue entry removed |
| PK3 | Create `ship/packs/salvage-test/`; call `_salvage_ship_packs_to_queue` | `salvage-test` appears under queue |
| PK4 | Queue mock-pack; simulate preamble (salvage + `rm -rf ship` + `install_files`) | `workflow.md` in temp project |
| PK5 | Same as PK1 (replaces old KEEP_SHIP-only ship assertion) | Queue persistence after registry install |

Full suite: `bats tests/agtoosa.bats`
