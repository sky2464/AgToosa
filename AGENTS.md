# AgToosa Maintainer

You are acting as the AgToosa maintainer for this repository.

Before making changes, read and follow `docs/agtoosa-maintainer.md` (**Maintainer Dogfood Mode**).

Use this mode when changing generator behavior, template workflow files, platform wiring, version wiring, or bats coverage in this repository.

## Cursor Cloud specific instructions

AgToosa is a pure Bash/PowerShell framework generator (no build step, no server). The "application" is `agtoosa.sh`; run it directly with `bash agtoosa.sh ...`. Node is pre-installed and only used for the thin `npm/` wrapper and `npx markdownlint-cli2`.

Dev toolchain (installed by the startup update script): `shellcheck` and `bats` via apt. `markdownlint-cli2` is fetched on demand via `npx --yes` (no install). Note apt provides `bats` 1.10.0, while CI pins 1.13.0 from source — the suite runs fine on 1.10.0.

Commands (see `CONTRIBUTING.md` and `.github/workflows/ci.yml` for the canonical set):
- Lint: `shellcheck -x -S warning --exclude=SC2002,SC2046,SC2086,SC1091,SC2034 agtoosa.sh bootstrap.sh lib/*.sh` and `npx --yes markdownlint-cli2 "*.md" "docs/**/*.md" ".github/**/*.md"` (CI runs markdownlint with `|| true`, so it never gates).
- Test: `bats tests/agtoosa.bats` (~700 tests, takes a few minutes).
- Run/verify the generator: `bash agtoosa.sh --version`, `--help`, `bash agtoosa.sh --verify .`.
- Smoke-install into a throwaway project: `bash agtoosa.sh --path /tmp/proj --platforms cursor,claude --yes` then `bash agtoosa.sh --doctor /tmp/proj` (doctor only recognizes `Docs/` installs, not the maintainer `docs/` tree).

Gotchas discovered during setup: `main` CI is currently red at the ShellCheck step (pre-existing `SC2178`/`SC2128` in `lib/catalog.sh`), which means the bats step never runs in CI. Locally, `bats tests/agtoosa.bats` has ~20 pre-existing content-drift failures (e.g. `WP2` expects exactly 18 `agtoosa-*` command adapters but the template ships 19). These are repository-state assertions, not environment problems — do not treat them as setup breakage. Use `--yes` for all non-interactive generator runs; without it the installer prompts for a TTY.