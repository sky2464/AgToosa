import {spawnSync} from "node:child_process";
import {existsSync} from "node:fs";
import {join} from "node:path";

export const remotionBinary = (packageDir) => {
  const binary = join(
    packageDir,
    "node_modules",
    ".bin",
    process.platform === "win32" ? "remotion.cmd" : "remotion",
  );
  if (!existsSync(binary)) {
    throw new Error(`Remotion CLI not found at ${binary}; run npm ci first.`);
  }
  return binary;
};

export const runCommand = (
  command,
  args,
  {cwd, capture = false, label = command} = {},
) => {
  const result = spawnSync(command, args, {
    cwd,
    encoding: capture ? "utf8" : undefined,
    stdio: capture ? "pipe" : "inherit",
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    const details = capture
      ? `\n${result.stdout ?? ""}\n${result.stderr ?? ""}`
      : "";
    throw new Error(`${label} failed with exit ${result.status}.${details}`);
  }
  return result;
};

export const ffmpeg = (packageDir, args, options = {}) =>
  runCommand(remotionBinary(packageDir), ["ffmpeg", ...args], {
    cwd: packageDir,
    label: "Remotion FFmpeg",
    ...options,
  });

export const ffprobe = (packageDir, args, options = {}) =>
  runCommand(remotionBinary(packageDir), ["ffprobe", ...args], {
    cwd: packageDir,
    label: "Remotion FFprobe",
    ...options,
  });

export const parseLoudnorm = (text) => {
  const matches = [...text.matchAll(/\{[\s\S]*?\}/g)];
  for (const match of matches.reverse()) {
    try {
      const parsed = JSON.parse(match[0]);
      if ("input_i" in parsed || "output_i" in parsed) return parsed;
    } catch {
      // Keep scanning earlier JSON blocks.
    }
  }
  throw new Error("FFmpeg loudnorm JSON was not found.");
};

export const probeJson = (packageDir, filePath) => {
  const result = ffprobe(
    packageDir,
    [
      "-v",
      "error",
      "-show_entries",
      "format=filename,format_name,duration,size,bit_rate:stream=index,codec_name,codec_type,width,height,r_frame_rate,avg_frame_rate,sample_rate,channels,channel_layout,duration,nb_frames",
      "-of",
      "json",
      filePath,
    ],
    {capture: true},
  );
  return JSON.parse(result.stdout);
};
