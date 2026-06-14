#!/usr/bin/env node
/*
 * npx agtoosa — thin distribution wrapper for the AgToosa generator.
 *
 * Downloads the release tarball PINNED to this package's version (never a
 * moving branch), verifies the archive member list, extracts to a temp dir,
 * and executes agtoosa.sh with any forwarded arguments.
 *
 * Requires: bash, tar (present by default on macOS/Linux).
 * Windows users: use WSL2 or Git Bash (see README) — native PowerShell users
 * should run agtoosa.ps1 from a git clone instead.
 */

"use strict";

const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const VERSION = require("../package.json").version;
const REPO = "sky2464/AgToosa";
const TARBALL_URL = `https://github.com/${REPO}/archive/refs/tags/v${VERSION}.tar.gz`;

function fail(msg) {
  console.error(`agtoosa: ${msg}`);
  process.exit(1);
}

function have(cmd) {
  const probe = spawnSync(cmd, ["--version"], { stdio: "ignore" });
  return probe.status === 0 || probe.status === 1;
}

async function main() {
  if (process.platform === "win32") {
    fail(
      "native Windows is not supported by the npm wrapper.\n" +
        "Use WSL2 (npx agtoosa inside WSL) or clone the repo and run .\\agtoosa.ps1"
    );
  }
  if (!have("bash")) fail("bash is required but was not found on PATH.");
  if (!have("tar")) fail("tar is required but was not found on PATH.");

  const workdir = fs.mkdtempSync(path.join(os.tmpdir(), "agtoosa-npm-"));
  const archivePath = path.join(workdir, "agtoosa.tar.gz");

  console.log(`Downloading AgToosa v${VERSION} (pinned release)...`);
  const res = await fetch(TARBALL_URL, { redirect: "follow" });
  if (!res.ok) {
    fail(`download failed (${res.status}) for ${TARBALL_URL}`);
  }
  fs.writeFileSync(archivePath, Buffer.from(await res.arrayBuffer()));

  // Reject archives with absolute-path or '..' members before extraction.
  const list = spawnSync("tar", ["-tzf", archivePath], { encoding: "utf8" });
  if (list.status !== 0) fail("unable to read archive member list.");
  for (const member of list.stdout.split("\n")) {
    if (!member) continue;
    if (member.startsWith("/") || `/${member}/`.includes("/../")) {
      fail(`archive contains unsafe member path: ${member}`);
    }
  }

  const extract = spawnSync("tar", ["-xzf", archivePath, "-C", workdir], {
    stdio: "inherit",
  });
  if (extract.status !== 0) fail("extraction failed.");

  const srcDir = fs
    .readdirSync(workdir)
    .map((name) => path.join(workdir, name))
    .find((p) => fs.statSync(p).isDirectory());
  if (!srcDir || !fs.existsSync(path.join(srcDir, "agtoosa.sh"))) {
    fail("extracted archive does not contain agtoosa.sh");
  }

  const args = process.argv.slice(2);
  // Run from the user's cwd so relative --path values (e.g. "." or "myapp")
  // resolve against their project, not the ephemeral extract dir we delete below.
  const run = spawnSync("bash", [path.join(srcDir, "agtoosa.sh"), ...args], {
    stdio: "inherit",
    cwd: process.cwd(),
  });

  fs.rmSync(workdir, { recursive: true, force: true });
  process.exit(run.status ?? 1);
}

main().catch((err) => fail(err.message));
