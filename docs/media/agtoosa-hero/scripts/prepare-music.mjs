import {createHash} from "node:crypto";
import {readFile, writeFile, mkdir} from "node:fs/promises";
import {existsSync} from "node:fs";
import {fileURLToPath} from "node:url";
import {basename, dirname, join, resolve} from "node:path";
import {ffmpeg, parseLoudnorm, probeJson} from "./media-tools.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const packageDir = resolve(scriptDir, "..");

const primary = {
  title: "Close Up",
  author: "Michael Ramir C.",
  sourceUrl: "https://mixkit.co/free-stock-music/corporate-music/",
  licenseUrl: "https://mixkit.co/license/",
};
const fallback = {
  title: "Motivating Mornings",
  author: "Ahjay Stelino",
  sourceUrl: "https://mixkit.co/free-stock-music/corporate-music/",
  licenseUrl: "https://mixkit.co/license/",
};

const args = process.argv.slice(2);
const inputArg = args.find((arg) => !arg.startsWith("--"));
const useFallback = args.includes("--fallback");
const outputOption = args.find((arg) => arg.startsWith("--output-dir="));
const outputDir = outputOption
  ? resolve(process.cwd(), outputOption.slice("--output-dir=".length))
  : join(packageDir, "public", "render-audio");
const outputFile = join(outputDir, "marketing-music.wav");
const metadataFile = join(outputDir, "music-metadata.json");
if (!inputArg) {
  console.error(
    "Usage: npm run prepare:music -- /path/to/download.mp3 [--fallback]",
  );
  process.exit(2);
}

const inputFile = resolve(process.cwd(), inputArg);
if (!existsSync(inputFile)) {
  throw new Error(`Licensed source file not found: ${inputFile}`);
}

const source = useFallback ? fallback : primary;
const probe = probeJson(packageDir, inputFile);
const duration = Number(probe.format?.duration ?? 0);
if (!Number.isFinite(duration) || duration < 44) {
  throw new Error(`Source must be at least 44 seconds; found ${duration}s.`);
}

const originalBytes = await readFile(inputFile);
const sha256 = createHash("sha256").update(originalBytes).digest("hex");
const piecewiseExpression = [
  "if(lt(t\\,5)\\,0.126",
  "if(lt(t\\,6.5)\\,0.126+(t-5)*0.5827",
  "if(lt(t\\,35)\\,1",
  "if(lt(t\\,35.6)\\,1-(t-35)*1.25",
  "if(lt(t\\,39.2)\\,0.25",
  "if(lt(t\\,40)\\,0.25+(t-39.2)*0.9375",
  "if(lt(t\\,42.5)\\,1\\,max(0\\,(44-t)/1.5))))))))",
].join("\\,");
const shapeExpression = `if(isnan(t)\\,0.126\\,${piecewiseExpression})`;
const prefilters = [
  "atrim=0:44",
  "asetpts=PTS-STARTPTS",
  "aresample=48000",
  `volume='${shapeExpression}':eval=frame`,
].join(",");
const target = "I=-18:TP=-2:LRA=11";

const analysis = ffmpeg(
  packageDir,
  [
    "-hide_banner",
    "-nostats",
    "-i",
    inputFile,
    "-vn",
    "-af",
    `${prefilters},loudnorm=${target}:print_format=json`,
    "-f",
    "null",
    "-",
  ],
  {capture: true},
);
const measured = parseLoudnorm(`${analysis.stdout}\n${analysis.stderr}`);
const normalize = [
  `loudnorm=${target}`,
  `measured_I=${measured.input_i}`,
  `measured_LRA=${measured.input_lra}`,
  `measured_TP=${measured.input_tp}`,
  `measured_thresh=${measured.input_thresh}`,
  `offset=${measured.target_offset}`,
  "linear=true",
  "print_format=summary",
].join(":");

await mkdir(outputDir, {recursive: true});
ffmpeg(packageDir, [
  "-y",
  "-hide_banner",
  "-i",
  inputFile,
  "-vn",
  "-af",
  `${prefilters},${normalize}`,
  "-ar",
  "48000",
  "-ac",
  "2",
  "-c:a",
  "pcm_s24le",
  outputFile,
]);

const metadata = {
  title: source.title,
  author: source.author,
  source_url: source.sourceUrl,
  license_url: source.licenseUrl,
  downloaded_on: new Date().toISOString().slice(0, 10),
  original_filename: basename(inputFile),
  original_sha256: sha256,
  source_duration_seconds: duration,
  derivative: "public/render-audio/marketing-music.wav",
  edits: {
    trim_seconds: 44,
    sample_rate_hz: 48000,
    channels: 2,
    bit_depth: 24,
    cold_open_gain_db: -18,
    verifier_drop_seconds: [35, 40],
    fade_out_seconds: [42.5, 44],
    loudness_target_lufs: -18,
    true_peak_target_dbtp: -2,
  },
};
await writeFile(metadataFile, `${JSON.stringify(metadata, null, 2)}\n`, "utf8");

console.log(`Prepared ${source.title} by ${source.author}`);
console.log(`Wrote ${outputFile}`);
console.log(`Wrote ${metadataFile}`);
