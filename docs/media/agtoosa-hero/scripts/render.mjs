import {existsSync} from "node:fs";
import {copyFile, mkdir} from "node:fs/promises";
import {fileURLToPath} from "node:url";
import {dirname, join, resolve} from "node:path";
import {runCommand, remotionBinary} from "./media-tools.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const packageDir = resolve(scriptDir, "..");
const outputDir = join(
  packageDir,
  "out",
  "candidates",
  "creative-reset-v2",
);
const entry = "src/index.ts";
const remotion = remotionBinary(packageDir);

const runRemotion = (args) =>
  runCommand(remotion, args, {cwd: packageDir, label: "Remotion render"});
const runNode = (script, args = []) =>
  runCommand(process.execPath, [join(scriptDir, script), ...args], {
    cwd: packageDir,
    label: script,
  });

const storyboardFrames = [
  {frame: 90, slug: "01-status"},
  {frame: 270, slug: "02-init"},
  {frame: 450, slug: "03-spec"},
  {frame: 585, slug: "04-build"},
  {frame: 705, slug: "05-review-ship"},
  {frame: 975, slug: "06-status-next"},
  {frame: 1155, slug: "07-verify"},
  {frame: 1260, slug: "08-cta"},
];

const renderContactSheet = async () => {
  const halfDir = join(outputDir, "storyboard", "720x405");
  const publicStoryboardDir = join(packageDir, "public", "storyboard-temp");
  await mkdir(publicStoryboardDir, {recursive: true});
  for (const [index, shot] of storyboardFrames.entries()) {
    const source = join(halfDir, `${shot.slug}.png`);
    if (!existsSync(source)) {
      throw new Error(`Storyboard still is missing: ${source}`);
    }
    await copyFile(
      source,
      join(publicStoryboardDir, `${String(index + 1).padStart(2, "0")}.png`),
    );
  }
  runRemotion([
    "still",
    entry,
    "StoryboardContactSheet",
    join(outputDir, "storyboard", "agtoosa-storyboard-v3.png"),
    "--frame=0",
    "--image-format=png",
  ]);
};

const renderStoryboard = async () => {
  const fullDir = join(outputDir, "storyboard", "1440x810");
  const halfDir = join(outputDir, "storyboard", "720x405");
  await mkdir(fullDir, {recursive: true});
  await mkdir(halfDir, {recursive: true});
  for (const shot of storyboardFrames) {
    runRemotion([
      "still",
      entry,
      "MarketingStoryboard",
      join(fullDir, `${shot.slug}.png`),
      `--frame=${shot.frame}`,
      "--image-format=png",
    ]);
    runRemotion([
      "still",
      entry,
      "MarketingStoryboard",
      join(halfDir, `${shot.slug}.png`),
      `--frame=${shot.frame}`,
      "--scale=0.5",
      "--image-format=png",
    ]);
  }
  await renderContactSheet();
};

const renderAnimatic = async () => {
  await mkdir(outputDir, {recursive: true});
  runNode("generate-review-audio.mjs");
  runRemotion([
    "render",
    entry,
    "MarketingAnimatic",
    join(outputDir, "agtoosa-marketing-v3-animatic.mp4"),
    "--codec=h264",
    "--crf=20",
    "--x264-preset=medium",
    "--pixel-format=yuv420p",
    "--color-space=bt709",
    "--image-format=png",
    "--audio-codec=aac",
    "--audio-bitrate=256k",
    "--sample-rate=48000",
  ]);
};

const renderReadme = async () => {
  await mkdir(outputDir, {recursive: true});
  runRemotion([
    "render",
    entry,
    "ReadmeLoop",
    join(outputDir, "agtoosa-readme-v4.gif"),
    "--codec=gif",
    "--scale=0.5",
    "--muted",
    "--color-space=bt709",
    "--image-format=png",
  ]);
};

const renderPoster = async () => {
  await mkdir(outputDir, {recursive: true});
  runRemotion([
    "still",
    entry,
    "MarketingStoryboard",
    join(outputDir, "agtoosa-poster-v3.png"),
    "--frame=1260",
    "--scale=0.5",
    "--image-format=png",
  ]);
};

const renderMaster = async () => {
  const music = join(
    packageDir,
    "public",
    "render-audio",
    "marketing-music.wav",
  );
  if (!existsSync(music)) {
    throw new Error(
      "Prepared licensed music is missing. Run npm run prepare:music -- /path/to/download.mp3",
    );
  }
  runNode("generate-review-audio.mjs");
  await mkdir(outputDir, {recursive: true});
  const raw = join(outputDir, "agtoosa-marketing-v3-master-raw.mp4");
  const final = join(outputDir, "agtoosa-marketing-v3-master.mp4");
  runRemotion([
    "render",
    entry,
    "MarketingMaster",
    raw,
    "--codec=h264",
    "--crf=18",
    "--x264-preset=slow",
    "--pixel-format=yuv420p",
    "--color-space=bt709",
    "--image-format=png",
    "--audio-codec=aac",
    "--audio-bitrate=320k",
    "--sample-rate=48000",
  ]);
  runNode("finalize-master.mjs", [
    "out/candidates/creative-reset-v2/agtoosa-marketing-v3-master-raw.mp4",
    "out/candidates/creative-reset-v2/agtoosa-marketing-v3-master.mp4",
  ]);
  console.log(`Final master: ${final}`);
};

const mode = process.argv[2];
if (!mode) {
  console.error(
    "Usage: node scripts/render.mjs storyboard|contact|animatic|readme|poster|master|checkpoint",
  );
  process.exit(2);
}

if (mode === "storyboard") await renderStoryboard();
else if (mode === "contact") await renderContactSheet();
else if (mode === "animatic") await renderAnimatic();
else if (mode === "readme") await renderReadme();
else if (mode === "poster") await renderPoster();
else if (mode === "master") await renderMaster();
else if (mode === "checkpoint") {
  await renderStoryboard();
  await renderAnimatic();
  await renderReadme();
  await renderPoster();
} else {
  throw new Error(`Unknown render mode: ${mode}`);
}

console.log(`Candidate output: ${outputDir}`);
