import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const sampleRate = 48_000;
const duration = 22;
const sampleCount = sampleRate * duration;
const beat = 60 / 128;
const bar = beat * 4;
const outputDirectory = join(
  dirname(fileURLToPath(import.meta.url)),
  "..",
  "public",
  "audio",
);

const makeBus = () => ({
  left: new Float32Array(sampleCount),
  right: new Float32Array(sampleCount),
});

const score = makeBus();
const effects = makeBus();
let noiseState = 0x5a17c9e3;

const random = () => {
  noiseState = (Math.imul(noiseState, 1_664_525) + 1_013_904_223) >>> 0;
  return (noiseState / 0xffffffff) * 2 - 1;
};

const midiToFrequency = (note) => 440 * 2 ** ((note - 69) / 12);

const addSample = (bus, index, value, pan = 0) => {
  if (index < 0 || index >= sampleCount) return;
  const angle = ((pan + 1) * Math.PI) / 4;
  bus.left[index] += value * Math.cos(angle);
  bus.right[index] += value * Math.sin(angle);
};

const envelope = (time, length, attack = 0.02, release = 0.2) => {
  const fadeIn = Math.min(1, time / Math.max(attack, 0.001));
  const fadeOut = Math.min(1, (length - time) / Math.max(release, 0.001));
  return Math.max(0, Math.min(fadeIn, fadeOut));
};

const addTone = (
  bus,
  start,
  length,
  frequency,
  amplitude,
  {
    pan = 0,
    attack = 0.02,
    release = 0.25,
    decay = 0,
    harmonics = [1],
    vibrato = 0,
  } = {},
) => {
  const firstSample = Math.floor(start * sampleRate);
  const count = Math.floor(length * sampleRate);
  for (let offset = 0; offset < count; offset += 1) {
    const time = offset / sampleRate;
    const amp =
      amplitude *
      envelope(time, length, attack, release) *
      (decay ? Math.exp(-time * decay) : 1);
    const wobble = vibrato ? Math.sin(time * Math.PI * 2 * 4.2) * vibrato : 0;
    let value = 0;
    for (let h = 0; h < harmonics.length; h += 1) {
      value +=
        (Math.sin(time * Math.PI * 2 * frequency * (h + 1 + wobble)) *
          harmonics[h]) /
        harmonics.length;
    }
    addSample(bus, firstSample + offset, value * amp, pan);
  }
};

const addPad = (start, length, notes, amplitude) => {
  notes.forEach((note, index) => {
    const frequency = midiToFrequency(note);
    const pan = -0.65 + (index / Math.max(notes.length - 1, 1)) * 1.3;
    addTone(score, start, length, frequency, amplitude, {
      pan,
      attack: 0.6,
      release: 0.75,
      harmonics: [1, 0.28, 0.1],
      vibrato: index % 2 === 0 ? 0.0012 : -0.0012,
    });
    addTone(score, start, length, frequency * 1.004, amplitude * 0.38, {
      pan: -pan,
      attack: 0.8,
      release: 0.65,
      harmonics: [1, 0.18],
    });
  });
};

const addPluck = (start, note, amplitude, pan) => {
  addTone(score, start, 0.72, midiToFrequency(note), amplitude, {
    pan,
    attack: 0.004,
    release: 0.25,
    decay: 4.2,
    harmonics: [1, 0.6, 0.28, 0.12],
  });
};

const addKick = (bus, start, amplitude) => {
  const firstSample = Math.floor(start * sampleRate);
  const count = Math.floor(sampleRate * 0.5);
  let phase = 0;
  for (let offset = 0; offset < count; offset += 1) {
    const time = offset / sampleRate;
    const frequency = 44 + 105 * Math.exp(-time * 20);
    phase += (Math.PI * 2 * frequency) / sampleRate;
    const value = Math.sin(phase) * Math.exp(-time * 8.5) * amplitude;
    addSample(bus, firstSample + offset, value, 0);
  }
};

const addHat = (start, amplitude, pan) => {
  const firstSample = Math.floor(start * sampleRate);
  const count = Math.floor(sampleRate * 0.095);
  let previous = 0;
  for (let offset = 0; offset < count; offset += 1) {
    const time = offset / sampleRate;
    const noise = random();
    const highPassed = noise - previous * 0.96;
    previous = noise;
    addSample(
      score,
      firstSample + offset,
      highPassed * Math.exp(-time * 45) * amplitude,
      pan,
    );
  }
};

const addClap = (start, amplitude) => {
  [0, 0.013, 0.027].forEach((offset, layer) => {
    const firstSample = Math.floor((start + offset) * sampleRate);
    const count = Math.floor(sampleRate * 0.19);
    let previous = 0;
    for (let sample = 0; sample < count; sample += 1) {
      const time = sample / sampleRate;
      const noise = random();
      const highPassed = noise - previous * 0.92;
      previous = noise;
      const value =
        highPassed *
        Math.exp(-time * (19 + layer * 4)) *
        amplitude *
        (1 - layer * 0.18);
      addSample(score, firstSample + sample, value, layer === 1 ? -0.22 : 0.22);
    }
  });
  addTone(score, start, 0.28, 190, amplitude * 0.18, {
    attack: 0.002,
    release: 0.16,
    decay: 10,
    harmonics: [1, 0.45],
  });
};

const addRiser = (start, length, amplitude, pan = 0) => {
  const firstSample = Math.floor(start * sampleRate);
  const count = Math.floor(length * sampleRate);
  let lowPassed = 0;
  let phase = 0;
  for (let offset = 0; offset < count; offset += 1) {
    const time = offset / sampleRate;
    const progress = time / length;
    const shape = progress ** 1.7;
    lowPassed += (random() - lowPassed) * (0.015 + progress * 0.24);
    phase += (Math.PI * 2 * (110 + progress ** 2 * 1_450)) / sampleRate;
    const value =
      (lowPassed * 1.9 + Math.sin(phase) * 0.18) *
      shape *
      envelope(time, length, 0.08, 0.04) *
      amplitude;
    addSample(effects, firstSample + offset, value, pan + Math.sin(progress * Math.PI) * 0.24);
  }
};

const addSubDrop = (start, amplitude) => {
  const firstSample = Math.floor(start * sampleRate);
  const count = Math.floor(sampleRate * 1.25);
  let phase = 0;
  for (let offset = 0; offset < count; offset += 1) {
    const time = offset / sampleRate;
    const frequency = 78 - Math.min(45, time * 38);
    phase += (Math.PI * 2 * frequency) / sampleRate;
    addSample(
      effects,
      firstSample + offset,
      Math.sin(phase) * Math.exp(-time * 2.6) * amplitude,
      0,
    );
  }
};

const addWhoosh = (start, length, amplitude, pan = 0) => {
  const firstSample = Math.floor(start * sampleRate);
  const count = Math.floor(length * sampleRate);
  let filtered = 0;
  let phase = 0;
  for (let offset = 0; offset < count; offset += 1) {
    const time = offset / sampleRate;
    const progress = time / length;
    const shape = Math.sin(Math.PI * progress) ** 1.5;
    const cutoff = 0.012 + progress * 0.18;
    filtered += (random() - filtered) * cutoff;
    phase += (Math.PI * 2 * (180 + progress * 780)) / sampleRate;
    const value = (filtered * 1.8 + Math.sin(phase) * 0.12) * shape * amplitude;
    addSample(effects, firstSample + offset, value, pan + (progress - 0.5) * 0.5);
  }
};

const addImpact = (start, amplitude, color = 1) => {
  addKick(effects, start, amplitude * 0.8);
  addTone(effects, start, 1.15, 75 * color, amplitude * 0.5, {
    attack: 0.002,
    release: 0.75,
    decay: 3.5,
    harmonics: [1, 0.48, 0.2],
  });
  const firstSample = Math.floor(start * sampleRate);
  const count = Math.floor(sampleRate * 0.55);
  for (let offset = 0; offset < count; offset += 1) {
    const time = offset / sampleRate;
    const value = random() * Math.exp(-time * 10) * amplitude * 0.22;
    addSample(effects, firstSample + offset, value, 0);
  }
};

const addTick = (start, note, pan) => {
  addTone(effects, start, 0.32, midiToFrequency(note), 0.28, {
    pan,
    attack: 0.002,
    release: 0.12,
    decay: 8,
    harmonics: [1, 0.55, 0.22],
  });
};

const progression = [
  [48, 55, 60, 63],
  [44, 51, 56, 60],
  [51, 58, 63, 67],
  [46, 53, 58, 62],
];
const bassRoots = [36, 32, 39, 34];

for (let barIndex = 0; barIndex < Math.ceil(duration / bar); barIndex += 1) {
  const chord = progression[barIndex % progression.length];
  const start = barIndex * bar;
  const sectionGain =
    start < 2 ? 0.68 : start < 12.2 ? 1 : start < 16.6 ? 0.78 : 1.16;
  addPad(start, Math.min(bar + 0.35, duration - start), chord, 0.09 * sectionGain);
  for (let beatIndex = 0; beatIndex < 4; beatIndex += 1) {
    const beatStart = start + beatIndex * beat;
    if (beatStart > duration - 0.3) continue;
    addTone(
      score,
      beatStart,
      0.48,
      midiToFrequency(bassRoots[barIndex % 4]),
      0.2 * sectionGain,
      {
        attack: 0.006,
        release: 0.16,
        decay: 3.5,
        harmonics: [1, 0.5, 0.18],
      },
    );
    if (start >= bar) {
      addKick(score, beatStart, (beatIndex % 2 === 0 ? 0.36 : 0.27) * sectionGain);
      addHat(beatStart + beat / 2, 0.082 * sectionGain, beatIndex % 2 === 0 ? -0.48 : 0.48);
      addHat(beatStart + beat * 0.75, 0.04 * sectionGain, beatIndex % 2 === 0 ? 0.35 : -0.35);
      if (beatIndex % 2 === 1) addClap(beatStart, 0.12 * sectionGain);
    }
    const arpNote = chord[(beatIndex + barIndex) % chord.length] + 12;
    addPluck(beatStart + beat * 0.08, arpNote, 0.13 * sectionGain, -0.55 + beatIndex * 0.36);
    addPluck(
      beatStart + beat * 0.56,
      chord[(beatIndex + barIndex + 1) % chord.length] + 12,
      0.085 * sectionGain,
      0.55 - beatIndex * 0.3,
    );
    if ((barIndex >= 2 && barIndex <= 5) || (barIndex >= 9 && barIndex <= 10)) {
      addTone(score, beatStart + beat * 0.18, beat * 0.7, midiToFrequency(arpNote + 12), 0.055, {
        pan: beatIndex % 2 === 0 ? -0.25 : 0.25,
        attack: 0.008,
        release: 0.18,
        decay: 2.8,
        harmonics: [1, 0.72, 0.46, 0.24, 0.12],
      });
    }
  }
}

addRiser(0, 0.38, 0.38, 0);
addImpact(0.38, 0.82, 1.2);
addSubDrop(0.4, 0.34);
addRiser(3.02, 0.76, 0.58, -0.18);
addWhoosh(3.38, 0.72, 0.62, -0.2);
addImpact(3.74, 0.5, 1.08);
[5, 6.5, 8, 9.5].forEach((time, index) => {
  addImpact(time, 0.5, 1 + index * 0.12);
  addTick(time + 0.04, 79 + index * 2, -0.55 + index * 0.36);
});
addRiser(11.75, 0.92, 0.62, 0.18);
addWhoosh(12.25, 0.85, 0.68, 0.2);
addImpact(12.66, 0.56, 0.9);
[14, 15, 16].forEach((time, index) => addTick(time, 84 + index * 3, -0.4 + index * 0.4));
addRiser(15.9, 0.8, 0.68, 0);
addImpact(16.68, 0.92, 0.82);
addSubDrop(16.7, 0.46);
addRiser(16.75, 0.6, 0.54, -0.15);
addWhoosh(17.02, 0.8, 0.7, -0.1);
addImpact(17.34, 0.58, 1.18);
addTick(19.18, 91, -0.3);
addTick(19.27, 98, 0.35);
addRiser(20.25, 0.9, 0.5, 0.12);
addWhoosh(20.82, 0.85, 0.52, 0.15);

const applyMasterFade = (bus, fadeInSeconds, fadeOutStart) => {
  for (let index = 0; index < sampleCount; index += 1) {
    const time = index / sampleRate;
    const fadeIn = Math.min(1, time / fadeInSeconds);
    const fadeOut = time < fadeOutStart ? 1 : Math.max(0, (duration - time) / (duration - fadeOutStart));
    bus.left[index] *= fadeIn * fadeOut;
    bus.right[index] *= fadeIn * fadeOut;
  }
};

const saturate = (bus, drive) => {
  const ceiling = Math.tanh(drive);
  for (let index = 0; index < sampleCount; index += 1) {
    bus.left[index] = Math.tanh(bus.left[index] * drive) / ceiling;
    bus.right[index] = Math.tanh(bus.right[index] * drive) / ceiling;
  }
};

const normalize = (bus, targetPeak) => {
  let peak = 0;
  let squared = 0;
  for (let index = 0; index < sampleCount; index += 1) {
    peak = Math.max(peak, Math.abs(bus.left[index]), Math.abs(bus.right[index]));
    squared += bus.left[index] ** 2 + bus.right[index] ** 2;
  }
  const gain = peak > 0 ? targetPeak / peak : 1;
  for (let index = 0; index < sampleCount; index += 1) {
    bus.left[index] *= gain;
    bus.right[index] *= gain;
  }
  return {
    peak: targetPeak,
    rms: Math.sqrt(squared / (sampleCount * 2)) * gain,
  };
};

const writeWave = (path, bus) => {
  const bytesPerSample = 2;
  const dataSize = sampleCount * 2 * bytesPerSample;
  const buffer = Buffer.alloc(44 + dataSize);
  buffer.write("RIFF", 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write("WAVE", 8);
  buffer.write("fmt ", 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20);
  buffer.writeUInt16LE(2, 22);
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(sampleRate * 2 * bytesPerSample, 28);
  buffer.writeUInt16LE(2 * bytesPerSample, 32);
  buffer.writeUInt16LE(16, 34);
  buffer.write("data", 36);
  buffer.writeUInt32LE(dataSize, 40);
  for (let index = 0; index < sampleCount; index += 1) {
    const offset = 44 + index * 4;
    buffer.writeInt16LE(Math.round(Math.max(-1, Math.min(1, bus.left[index])) * 32767), offset);
    buffer.writeInt16LE(Math.round(Math.max(-1, Math.min(1, bus.right[index])) * 32767), offset + 2);
  }
  writeFileSync(path, buffer);
};

applyMasterFade(score, 0.9, 20.8);
applyMasterFade(effects, 0.08, 21.55);
saturate(score, 2.1);
saturate(effects, 1.45);
const scoreStats = normalize(score, 0.82);
const effectStats = normalize(effects, 0.76);
let mixPeak = 0;
let mixSquared = 0;
let clippedSamples = 0;
for (let index = 0; index < sampleCount; index += 1) {
  const left = score.left[index] * 0.62 + effects.left[index] * 0.7;
  const right = score.right[index] * 0.62 + effects.right[index] * 0.7;
  mixPeak = Math.max(mixPeak, Math.abs(left), Math.abs(right));
  mixSquared += left ** 2 + right ** 2;
  if (Math.abs(left) >= 1 || Math.abs(right) >= 1) clippedSamples += 1;
}
const mixRms = Math.sqrt(mixSquared / (sampleCount * 2));

mkdirSync(outputDirectory, { recursive: true });
writeWave(join(outputDirectory, "agtoosa-score.wav"), score);
writeWave(join(outputDirectory, "agtoosa-sfx.wav"), effects);

console.log(
  `Generated 22s stereo audio at 48kHz: score peak=${scoreStats.peak.toFixed(2)} rms=${scoreStats.rms.toFixed(3)}, sfx peak=${effectStats.peak.toFixed(2)} rms=${effectStats.rms.toFixed(3)}`,
);
console.log(
  `Remotion mix: peak=${mixPeak.toFixed(3)} rms=${mixRms.toFixed(3)} clipped_samples=${clippedSamples}`,
);
if (clippedSamples > 0) {
  throw new Error("Audio mix clips; lower the Remotion track volumes.");
}
