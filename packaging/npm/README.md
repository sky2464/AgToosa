# agtoosa (npm wrapper)

Thin npm distribution wrapper for the [AgToosa](https://github.com/sky2464/AgToosa) spec-driven agentic AI framework generator.

```bash
# Interactive install into a project
npx agtoosa

# Non-interactive
npx agtoosa --path . --platforms cursor,claude --yes

# Verify a repo's AgToosa lifecycle state (deterministic, no AI)
npx agtoosa --verify .
```

The wrapper downloads the release tarball **pinned to this package's version**, screens the archive member list for unsafe paths, and runs `agtoosa.sh` with your arguments. macOS and Linux (incl. WSL2) only; native Windows users should clone the repo and run `agtoosa.ps1`.

Registry packs queue to `~/.cache/agtoosa/pack-queue` (not the temp extract) so a later `npx agtoosa --path <project> --yes` can merge them.

## Publishing (maintainers)

`npm/package.json` version must equal `AGTOOSA_VERSION` in `agtoosa.sh` — bump both on release, then:

```bash
cd npm && npm publish
```
