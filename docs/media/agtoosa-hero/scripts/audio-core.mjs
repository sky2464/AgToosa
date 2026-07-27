import {mkdir, writeFile} from "node:fs/promises";
import {dirname} from "node:path";

export const SAMPLE_RATE = 48000;

export const createStereo = (seconds) => {
  const length = Math.ceil(seconds * SAMPLE_RATE);
  return {
    left: new Float64Array(length),
    right: new Float64Array(length),
    length,
  };
};

const panGains = (pan) => {
  const angle = ((Math.max(-1, Math.min(1, pan)) + 1) * Math.PI) / 4;
  return [Math.cos(angle), Math.sin(angle)];
};

const envelope = (time, duration, attack, release) => {
  if (time < 0 || time >= duration) return 0;
  const attackGain = attack <= 0 ? 1 : Math.min(1, time / attack);
  const releaseGain =
    release <= 0 ? 1 : Math.min(1, (duration - time) / release);
  return Math.sin(Math.min(attackGain, releaseGain) * Math.PI * 0.5);
};

const oscillator = (phase, wave) => {
  if (wave === "triangle") {
    return (2 / Math.PI) * Math.asin(Math.sin(phase));
  }
  if (wave === "soft-square") {
    return Math.tanh(Math.sin(phase) * 2.2) * 0.72;
  }
  return Math.sin(phase);
};

export const addTone = (
  stereo,
  {
    start,
    duration,
    frequency,
    frequencyEnd = frequency,
    amplitude,
    pan = 0,
    attack = 0.06,
    release = 0.24,
    wave = "sine",
    vibrato = 0,
  },
) => {
  const first = Math.max(0, Math.floor(start * SAMPLE_RATE));
  const last = Math.min(stereo.length, Math.ceil((start + duration) * SAMPLE_RATE));
  const [leftGain, rightGain] = panGains(pan);
  let phase = 0;

  for (let index = first; index < last; index += 1) {
    const localTime = index / SAMPLE_RATE - start;
    const ratio = localTime / Math.max(duration, 0.001);
    const frequencyAtTime =
      frequency * Math.pow(frequencyEnd / frequency, ratio);
    const vibratoGain =
      vibrato > 0 ? 1 + Math.sin(localTime * Math.PI * 5.2) * vibrato : 1;
    phase += (Math.PI * 2 * frequencyAtTime * vibratoGain) / SAMPLE_RATE;
    const gain =
      oscillator(phase, wave) *
      amplitude *
      envelope(localTime, duration, attack, release);
    stereo.left[index] += gain * leftGain;
    stereo.right[index] += gain * rightGain;
  }
};

let randomState = 0x6d2b79f5;
const seededNoise = () => {
  randomState = (randomState * 1664525 + 1013904223) >>> 0;
  return (randomState / 0xffffffff) * 2 - 1;
};

export const addNoise = (
  stereo,
  {
    start,
    duration,
    amplitude,
    pan = 0,
    attack = 0.03,
    release = 0.2,
    smoothing = 0.88,
    stutterHz = 0,
  },
) => {
  const first = Math.max(0, Math.floor(start * SAMPLE_RATE));
  const last = Math.min(stereo.length, Math.ceil((start + duration) * SAMPLE_RATE));
  const [leftGain, rightGain] = panGains(pan);
  let filtered = 0;
  for (let index = first; index < last; index += 1) {
    const localTime = index / SAMPLE_RATE - start;
    filtered = filtered * smoothing + seededNoise() * (1 - smoothing);
    const stutter =
      stutterHz > 0
        ? Math.max(0, Math.sin(localTime * Math.PI * 2 * stutterHz))
        : 1;
    const gain =
      filtered *
      amplitude *
      stutter *
      envelope(localTime, duration, attack, release);
    stereo.left[index] += gain * leftGain;
    stereo.right[index] += gain * rightGain;
  }
};

export const normalizePeak = (stereo, target = 0.62) => {
  let peak = 0;
  for (let index = 0; index < stereo.length; index += 1) {
    peak = Math.max(
      peak,
      Math.abs(stereo.left[index]),
      Math.abs(stereo.right[index]),
    );
  }
  const gain = peak > 0 ? target / peak : 1;
  for (let index = 0; index < stereo.length; index += 1) {
    stereo.left[index] *= gain;
    stereo.right[index] *= gain;
  }
  return {peak, gain};
};

const writeInt24LE = (buffer, value, offset) => {
  const normalized = Math.max(-1, Math.min(1, value));
  let sample = Math.round(normalized * 0x7fffff);
  if (sample < 0) sample += 0x1000000;
  buffer[offset] = sample & 0xff;
  buffer[offset + 1] = (sample >> 8) & 0xff;
  buffer[offset + 2] = (sample >> 16) & 0xff;
};

export const writeWave24 = async (filePath, stereo) => {
  const channels = 2;
  const bitsPerSample = 24;
  const blockAlign = (channels * bitsPerSample) / 8;
  const dataSize = stereo.length * blockAlign;
  const buffer = Buffer.alloc(44 + dataSize);

  buffer.write("RIFF", 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write("WAVE", 8);
  buffer.write("fmt ", 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20);
  buffer.writeUInt16LE(channels, 22);
  buffer.writeUInt32LE(SAMPLE_RATE, 24);
  buffer.writeUInt32LE(SAMPLE_RATE * blockAlign, 28);
  buffer.writeUInt16LE(blockAlign, 32);
  buffer.writeUInt16LE(bitsPerSample, 34);
  buffer.write("data", 36);
  buffer.writeUInt32LE(dataSize, 40);

  for (let index = 0; index < stereo.length; index += 1) {
    const offset = 44 + index * blockAlign;
    writeInt24LE(buffer, stereo.left[index], offset);
    writeInt24LE(buffer, stereo.right[index], offset + 3);
  }

  await mkdir(dirname(filePath), {recursive: true});
  await writeFile(filePath, buffer);
};
