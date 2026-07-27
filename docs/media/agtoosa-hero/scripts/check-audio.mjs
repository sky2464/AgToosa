import {existsSync} from "node:fs";
import {fileURLToPath} from "node:url";
import {dirname, resolve} from "node:path";
import {ffmpeg, parseLoudnorm, probeJson} from "./media-tools.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const packageDir = resolve(scriptDir, "..");
const args = process.argv.slice(2);
const fileArg = args.find((arg) => !arg.startsWith("--"));
const isFinal = args.includes("--final");
if (!fileArg) {
  console.error("Usage: node scripts/check-audio.mjs <media-file> [--final]");
  process.exit(2);
}

const filePath = resolve(process.cwd(), fileArg);
if (!existsSync(filePath)) throw new Error(`Media file not found: ${filePath}`);

const probe = probeJson(packageDir, filePath);
const audio = probe.streams?.find((stream) => stream.codec_type === "audio");
if (!audio) throw new Error("No audio stream found.");

const analyze = (inputArgs = []) => {
  const result = ffmpeg(
    packageDir,
    [
      "-hide_banner",
      "-nostats",
      ...inputArgs,
      "-i",
      filePath,
      "-vn",
      "-af",
      "loudnorm=I=-16:TP=-1:LRA=11:print_format=json",
      "-f",
      "null",
      "-",
    ],
    {capture: true},
  );
  return parseLoudnorm(`${result.stdout}\n${result.stderr}`);
};

const loudness = analyze();
const segmentLoudness = Object.fromEntries(
  Object.entries({
    cold_open: [0, 5],
    proof_body: [11, 16],
    system_reveal: [31.5, 3],
    verifier_bed: [35.6, 2.4],
    cta: [40, 4],
  }).map(([name, [start, duration]]) => {
    const measurement = analyze([
      "-ss",
      String(start),
      "-t",
      String(duration),
    ]);
    return [name, Number(measurement.input_i)];
  }),
);
const verifierDropDb =
  segmentLoudness.verifier_bed - segmentLoudness.system_reveal;
const roundedVerifierDropDb = Number(verifierDropDb.toFixed(2));

const integrated = Number(loudness.input_i);
const truePeak = Number(loudness.input_tp);
const lra = Number(loudness.input_lra);

console.log(
  JSON.stringify(
    {
      file: filePath,
      codec: audio.codec_name,
      sample_rate: Number(audio.sample_rate),
      channels: audio.channels,
      integrated_lufs: integrated,
      true_peak_dbtp: truePeak,
      lra,
      segment_lufs: segmentLoudness,
      verifier_drop_db: roundedVerifierDropDb,
    },
    null,
    2,
  ),
);

if (audio.channels !== 2 || Number(audio.sample_rate) !== 48000) {
  throw new Error("Audio must be stereo at 48kHz.");
}
if (!Number.isFinite(integrated) || !Number.isFinite(truePeak)) {
  throw new Error("Invalid loudness measurement.");
}
if (truePeak > -1) throw new Error(`True peak ${truePeak} dBTP exceeds -1 dBTP.`);
if (verifierDropDb > -6) {
  throw new Error(
    `Verifier bed drops only ${verifierDropDb.toFixed(2)} dB; expected at least 6 dB.`,
  );
}
if (isFinal && Math.abs(integrated - -16) > 0.6) {
  throw new Error(`Final loudness ${integrated} LUFS is outside -16 ±0.6.`);
}
