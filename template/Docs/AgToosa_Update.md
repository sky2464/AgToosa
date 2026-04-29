# AgToosa /agtoosa-update

Check your installed AgToosa version and update workflow files to the latest release.

## When to Run

- You want to check if a newer AgToosa version is available
- You pulled a new release of AgToosa and want workflow improvements to reach this project
- A workflow command feels outdated compared to the AgToosa docs

## Workflow

1. **Check installed version**

   Read `Docs/.agtoosa-version` in this project. If the file does not exist, the install predates v2.5.0 (version is unknown).

2. **Tell the user their installed version** and ask them to check the AgToosa repository for the latest release tag.

3. **Run the update**

   Ask the user to `git pull` in their AgToosa clone, then run from the AgToosa directory:

   ```bash
   bash agtoosa.sh --update /path/to/this/project
   ```

   Or from this project's root (if the AgToosa clone is a sibling or known path):

   ```bash
   bash /path/to/AgToosa/agtoosa.sh --update .
   ```

4. **Confirm**

   After the user reports the command ran, re-read `Docs/.agtoosa-version` and confirm the version updated.

5. **Surface what changed**

   Read `Docs/AgToosa_Changelog.md` and show the entries between the old and new version so the user knows what new commands or workflow improvements are now available.

## What Gets Updated

| Category | Action |
|----------|--------|
| `Docs/AgToosa_*.md` workflow files | Overwritten with latest version |
| Platform entry-points (`CLAUDE.md`, `.cursorrules`, etc.) | Smart merge — only if already installed |
| Platform native dirs (`.claude/commands/`, `.cursor/rules/`, etc.) | Overwritten — only AgToosa-owned files |
| `.claude/settings.json` hooks | Deep-merged, deduplicated |

## What Is Preserved

| Category | Action |
|----------|--------|
| `Docs/Context/` | Never touched (your product/tech/workflow config) |
| `Docs/Master-Plan.md` | Never touched (your Linear mirror) |
| `Docs/AgToosa_Changelog.md` | Never touched (your project changelog) |
| `Docs/archived/` | Never touched (completed specs) |
| User files in platform dirs | Never touched (only AgToosa-owned files overwritten) |
