import {spawnSync} from "node:child_process";
import {existsSync} from "node:fs";
import {readdir, readFile, stat} from "node:fs/promises";
import {fileURLToPath} from "node:url";
import {dirname, extname, join, resolve} from "node:path";
import {probeJson, remotionBinary, runCommand} from "./media-tools.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const packageDir = resolve(scriptDir, "..");
const candidateDir = join(
  packageDir,
  "out",
  "candidates",
  "creative-reset-v2",
);
const requireCheckpoint = process.argv.includes("--checkpoint");
const failures = [];
const warnings = [];

const check = (condition, message) => {
  if (condition) console.log(`PASS  ${message}`);
  else {
    console.error(`FAIL  ${message}`);
    failures.push(message);
  }
};

const walk = async (root) => {
  const files = [];
  for (const entry of await readdir(root, {withFileTypes: true})) {
    const path = join(root, entry.name);
    if (entry.isDirectory()) files.push(...(await walk(path)));
    else files.push(path);
  }
  return files;
};

const sourceFiles = [
  ...(await walk(join(packageDir, "src"))),
  ...(await walk(join(packageDir, "scripts"))),
].filter((file) => [".ts", ".tsx", ".mjs"].includes(extname(file)));

for (const file of sourceFiles) {
  const lines = (await readFile(file, "utf8")).split("\n").length;
  check(lines <= 500, `${file.slice(packageDir.length + 1)} is ${lines}/500 lines`);
  if (extname(file) === ".mjs") {
    const result = spawnSync(process.execPath, ["--check", file], {
      cwd: packageDir,
      encoding: "utf8",
    });
    check(result.status === 0, `${file.slice(packageDir.length + 1)} parses`);
  }
}

runCommand("npm", ["run", "typecheck"], {
  cwd: packageDir,
  label: "TypeScript",
});
runCommand(remotionBinary(packageDir), ["versions"], {
  cwd: packageDir,
  label: "Remotion versions",
});

const timeline = JSON.parse(
  await readFile(join(packageDir, "src", "timeline.json"), "utf8"),
);
check(timeline.fps === 30, "timeline is 30fps");
check(timeline.durationInFrames === 1320, "master is exactly 1320 frames");
check(
  timeline.readmeDurationInFrames === 720,
  "README loop is exactly 720 frames",
);
check(timeline.cues?.length === 5, "timeline defines exactly five cues");
const expectedCueIds = [
  "status-scan",
  "init-lock",
  "phase-handoff",
  "next-route",
  "proof-resolve",
];
check(
  expectedCueIds.every((id) => timeline.cues.some((cue) => cue.id === id)),
  "timeline uses the five revision-specific cue roles",
);
check(
  new Set(timeline.cues.map((cue) => cue.frame)).size === 5,
  "all cue frames are unique",
);
const rootSource = await readFile(join(packageDir, "src", "Root.tsx"), "utf8");
const indexSource = await readFile(join(packageDir, "src", "index.ts"), "utf8");
check(
  indexSource.includes('@fontsource-variable/inter'),
  "Inter is bundled for the readable README typography",
);
check(rootSource.includes('id="MarketingMaster"'), "MarketingMaster is registered");
check(rootSource.includes('id="ReadmeLoop"'), "ReadmeLoop is registered");
check(rootSource.includes('id="Hero"'), "legacy Hero remains during review");
const marketingSource = await readFile(
  join(packageDir, "src", "MarketingMaster.tsx"),
  "utf8",
);
check(!marketingSource.includes("EnergyFx"), "new master has no global EnergyFx");
const readmeSource = await readFile(
  join(packageDir, "src", "ReadmeLoop.tsx"),
  "utf8",
);
check(
  readmeSource.includes("FONT_READABLE") &&
    !readmeSource.includes("fontFamily: FONT_MONO"),
  "README display typography uses Inter instead of terminal mono",
);
check(
  readmeSource.includes("<TensionScene") &&
    readmeSource.includes("<ReframeScene") &&
    readmeSource.includes("<WorkflowScene") &&
    readmeSource.includes("<RoutingScene") &&
    readmeSource.includes("<VerifyScene") &&
    readmeSource.includes("<ClosingScene"),
  "README cut composes the six cinematic story beats",
);
check(
  readmeSource.includes("REPO-AWARE PROJECT DRIVER") &&
    readmeSource.includes("/NEXT · READS SYNC · RUNS THE RIGHT PHASE"),
  "README cut presents Next as the state-aware one-phase driver",
);
check(
  readmeSource.includes("interpolate(frame, [68, 85], [1, 0]"),
  "README closing scene fades to the base frame for a clean loop",
);
check(!readmeSource.includes("<Audio"), "README composition mounts no audio");
const audioDesignSource = await readFile(
  join(packageDir, "src", "AudioDesign.tsx"),
  "utf8",
);
check(
  audioDesignSource.includes("from={cue.frame}"),
  "audio cues mount from shared manifest frames",
);
check(
  audioDesignSource.includes("render-audio/rhythm-pulse.wav"),
  "final composition retains the signature rhythm stem",
);
const terminalSource = await readFile(
  join(packageDir, "src", "VerifierTerminal.tsx"),
  "utf8",
);
check(!terminalSource.includes(">✓<"), "verifier gate headings have no invented checks");
check(
  terminalSource.includes("6 pass · 1 warn · 0 fail"),
  "verifier terminal records the verified run summary",
);
const workflowSource = await readFile(
  join(packageDir, "src", "WorkflowRail.tsx"),
  "utf8",
);
check(
  workflowSource.includes("markerEnd") &&
    workflowSource.includes("from={{x: position.x + width / 2") &&
    workflowSource.includes("to={{x: next.x - width / 2"),
  "workflow connectors terminate at directional node anchors",
);
const ctaSource = await readFile(
  join(packageDir, "src", "scenes", "CtaScene.tsx"),
  "utf8",
);
check(
  ctaSource.includes("/agtoosa-init") &&
    ctaSource.includes("/agtoosa-next") &&
    ctaSource.includes("github.com/sky2464/AgToosa"),
  "CTA retains canonical commands and the public repository",
);
const campaignReadme = await readFile(join(packageDir, "README.md"), "utf8");
check(
  campaignReadme.includes("compact display labels") &&
    !campaignReadme.includes("/agtoosa-specs"),
  "compact phase labels document the singular canonical command mapping",
);
for (const scene of [
  "TensionScene.tsx",
  "ReframeScene.tsx",
  "ProofMosaicScene.tsx",
  "SystemRevealScene.tsx",
  "VerificationScene.tsx",
]) {
  const source = await readFile(join(packageDir, "src", "scenes", scene), "utf8");
  check(source.includes("timeline.cues.find"), `${scene} uses shared cue timing`);
}

const checkpointFiles = {
  animatic: join(candidateDir, "agtoosa-marketing-v3-animatic.mp4"),
  readme: join(candidateDir, "agtoosa-readme-v6.gif"),
  poster: join(candidateDir, "agtoosa-poster-v3.png"),
  storyboard: join(
    candidateDir,
    "storyboard",
    "agtoosa-storyboard-v3.png",
  ),
};

if (requireCheckpoint) {
  Object.entries(checkpointFiles).forEach(([name, file]) =>
    check(existsSync(file), `${name} checkpoint exists`),
  );
  const fullStills = await readdir(
    join(candidateDir, "storyboard", "1440x810"),
  );
  const halfStills = await readdir(
    join(candidateDir, "storyboard", "720x405"),
  );
  check(fullStills.filter((file) => file.endsWith(".png")).length === 8, "eight 1440×810 storyboard stills exist");
  check(halfStills.filter((file) => file.endsWith(".png")).length === 8, "eight 720×405 storyboard stills exist");
  for (const cue of timeline.cues) {
    const cueFile = join(
      packageDir,
      "public",
      "render-audio",
      "cues",
      cue.file,
    );
    check(existsSync(cueFile), `${cue.id} audio cue exists`);
    if (existsSync(cueFile)) {
      const probe = probeJson(packageDir, cueFile);
      const stream = probe.streams.find((item) => item.codec_type === "audio");
      const expected = cue.duration / timeline.fps;
      check(
        Math.abs(Number(stream?.duration) - expected) <= 1 / timeline.fps,
        `${cue.id} duration matches its manifest within one frame`,
      );
    }
  }
  const rhythmFile = join(
    packageDir,
    "public",
    "render-audio",
    "rhythm-pulse.wav",
  );
  check(existsSync(rhythmFile), "signature rhythm stem exists");
  if (existsSync(rhythmFile)) {
    const probe = probeJson(packageDir, rhythmFile);
    const stream = probe.streams.find((item) => item.codec_type === "audio");
    check(
      Number(stream?.sample_rate) === 48000 &&
        stream?.channels === 2 &&
        Math.abs(Number(stream?.duration) - 44) < 0.01,
      "signature rhythm stem is 44-second stereo 48kHz audio",
    );
  }
}

if (existsSync(checkpointFiles.animatic)) {
  const probe = probeJson(packageDir, checkpointFiles.animatic);
  const video = probe.streams.find((stream) => stream.codec_type === "video");
  const audio = probe.streams.find((stream) => stream.codec_type === "audio");
  check(video?.codec_name === "h264", "animatic video is H.264");
  check(video?.width === 1440 && video?.height === 810, "animatic is 1440×810");
  check(video?.r_frame_rate === "30/1", "animatic is 30fps");
  check(Number(video?.nb_frames) === 1320, "animatic has 1320 video frames");
  check(
    Math.abs(Number(video?.duration) - 44) < 0.01,
    "animatic video duration is 44 seconds",
  );
  check(audio?.codec_name === "aac", "animatic audio is AAC");
  check(
    Number(audio?.sample_rate) === 48000 && audio?.channels === 2,
    "animatic audio is stereo 48kHz",
  );
}

if (existsSync(checkpointFiles.readme)) {
  const probe = probeJson(packageDir, checkpointFiles.readme);
  const video = probe.streams.find((stream) => stream.codec_type === "video");
  const audio = probe.streams.find((stream) => stream.codec_type === "audio");
  const fileStats = await stat(checkpointFiles.readme);
  check(video?.codec_name === "gif", "README candidate is GIF");
  check(video?.width === 800 && video?.height === 450, "README GIF is 800×450");
  check(Number(video?.nb_frames) === 720, "README GIF has all 720 frames");
  check(
    Math.abs(Number(video?.duration) - 24) < 0.05,
    "README GIF duration is 24 seconds",
  );
  check(!audio, "README GIF is silent");
  check(fileStats.size < 8_000_000, "README GIF is below 8 MB");
}

if (existsSync(checkpointFiles.poster)) {
  const probe = probeJson(packageDir, checkpointFiles.poster);
  const image = probe.streams.find((stream) => stream.codec_type === "video");
  check(image?.width === 720 && image?.height === 405, "poster is 720×405");
}

if (existsSync(checkpointFiles.storyboard)) {
  const probe = probeJson(packageDir, checkpointFiles.storyboard);
  const image = probe.streams.find((stream) => stream.codec_type === "video");
  check(image?.width === 1920 && image?.height === 540, "contact sheet is 1920×540");
}

const finalMaster = join(candidateDir, "agtoosa-marketing-v3-master.mp4");
if (existsSync(finalMaster)) {
  const result = runCommand(
    process.execPath,
    [join(scriptDir, "check-audio.mjs"), finalMaster, "--final"],
    {cwd: packageDir, capture: true, label: "Final audio check"},
  );
  console.log(result.stdout);
} else {
  warnings.push("Final licensed-score master is intentionally absent at checkpoint.");
}

for (const warning of warnings) console.warn(`WARN  ${warning}`);
if (failures.length > 0) {
  throw new Error(`${failures.length} media verification check(s) failed.`);
}
console.log(`PASS  media verification complete with ${warnings.length} warning(s)`);
