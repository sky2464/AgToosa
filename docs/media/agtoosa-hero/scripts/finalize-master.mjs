import {existsSync} from "node:fs";
import {fileURLToPath} from "node:url";
import {dirname, resolve} from "node:path";
import {ffmpeg, parseLoudnorm} from "./media-tools.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const packageDir = resolve(scriptDir, "..");
const [inputArg, outputArg] = process.argv.slice(2);
if (!inputArg || !outputArg) {
  console.error("Usage: node scripts/finalize-master.mjs input.mp4 output.mp4");
  process.exit(2);
}

const inputFile = resolve(packageDir, inputArg);
const outputFile = resolve(packageDir, outputArg);
if (!existsSync(inputFile)) throw new Error(`Input not found: ${inputFile}`);

const target = "I=-16:TP=-1.5:LRA=11";
const analysis = ffmpeg(
  packageDir,
  [
    "-hide_banner",
    "-nostats",
    "-i",
    inputFile,
    "-vn",
    "-af",
    `loudnorm=${target}:print_format=json`,
    "-f",
    "null",
    "-",
  ],
  {capture: true},
);
const measured = parseLoudnorm(`${analysis.stdout}\n${analysis.stderr}`);
const filter = [
  `loudnorm=${target}`,
  `measured_I=${measured.input_i}`,
  `measured_LRA=${measured.input_lra}`,
  `measured_TP=${measured.input_tp}`,
  `measured_thresh=${measured.input_thresh}`,
  `offset=${measured.target_offset}`,
  "linear=true",
  "print_format=summary",
].join(":");

ffmpeg(packageDir, [
  "-y",
  "-hide_banner",
  "-i",
  inputFile,
  "-c:v",
  "copy",
  "-af",
  filter,
  "-c:a",
  "libfdk_aac",
  "-b:a",
  "320k",
  "-ar",
  "48000",
  "-ac",
  "2",
  outputFile,
]);

console.log(`Finalized master mix: ${outputFile}`);
