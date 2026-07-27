import {readFile} from "node:fs/promises";
import {fileURLToPath} from "node:url";
import {dirname, join, resolve} from "node:path";
import {
  addNoise,
  addTone,
  createStereo,
  normalizePeak,
  writeWave24,
} from "./audio-core.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const packageDir = resolve(scriptDir, "..");
const timeline = JSON.parse(
  await readFile(join(packageDir, "src", "timeline.json"), "utf8"),
);
const audioDir = join(packageDir, "public", "render-audio");

const addDoom = (stereo, start, amplitude = 0.34, pan = 0) => {
  addTone(stereo, {
    start,
    duration: 0.56,
    frequency: 82,
    frequencyEnd: 42,
    amplitude,
    pan,
    attack: 0.006,
    release: 0.42,
    wave: "sine",
  });
  addTone(stereo, {
    start: start + 0.004,
    duration: 0.24,
    frequency: 176,
    frequencyEnd: 74,
    amplitude: amplitude * 0.2,
    pan,
    attack: 0.003,
    release: 0.17,
    wave: "triangle",
  });
  addNoise(stereo, {
    start,
    duration: 0.035,
    amplitude: amplitude * 0.2,
    pan,
    attack: 0.001,
    release: 0.03,
    smoothing: 0.52,
  });
};

const addTek = (stereo, start, amplitude = 0.24, pan = 0.12) => {
  addNoise(stereo, {
    start,
    duration: 0.09,
    amplitude,
    pan,
    attack: 0.001,
    release: 0.075,
    smoothing: 0.2,
  });
  addTone(stereo, {
    start,
    duration: 0.14,
    frequency: 1850,
    frequencyEnd: 940,
    amplitude: amplitude * 0.28,
    pan,
    attack: 0.002,
    release: 0.11,
    wave: "triangle",
  });
};

const addPattern = (
  stereo,
  start,
  end,
  {amplitude = 0.3, phrase = 2.4, variation = 0} = {},
) => {
  let phraseIndex = 0;
  for (let phraseStart = start; phraseStart < end; phraseStart += phrase) {
    const swing = phraseIndex % 2 === 0 ? -0.04 : 0.04;
    [0, 0.48, 0.96].forEach((offset, index) => {
      if (phraseStart + offset >= end) return;
      const accent = index === 0 ? 1 : index === 2 ? 0.86 : 0.76;
      addDoom(
        stereo,
        phraseStart + offset,
        amplitude * accent,
        index === 1 ? swing : 0,
      );
    });
    const tekStart =
      phraseStart + 1.44 + (phraseIndex % 3 === 2 ? 0.06 : 0);
    if (tekStart < end) {
      addTek(
        stereo,
        tekStart,
        amplitude * (0.7 + variation * 0.15),
        phraseIndex % 2 === 0 ? 0.2 : -0.2,
      );
    }
    phraseIndex += 1;
  }
};

const addDrone = (stereo, start, duration, notes, amplitude) => {
  notes.forEach((frequency, index) =>
    addTone(stereo, {
      start: start + index * 0.03,
      duration,
      frequency,
      amplitude: amplitude / notes.length,
      pan: index === 0 ? -0.25 : 0.25,
      attack: Math.min(1.6, duration * 0.24),
      release: Math.min(1.8, duration * 0.3),
      wave: "sine",
      vibrato: 0.0015,
    }),
  );
};

const generateAnimaticScore = () => {
  const score = createStereo(44);

  addDrone(score, 0, 5.2, [55, 82.41], 0.085);
  [0.8, 2.45, 4.05].forEach((start, index) =>
    addDoom(score, start, 0.16 + index * 0.018),
  );

  addDrone(score, 5, 6, [55, 82.41, 110], 0.095);
  addPattern(score, 5.2, 11, {amplitude: 0.22, phrase: 2.4});

  addDrone(score, 11, 16, [49, 73.42, 98], 0.1);
  addPattern(score, 11.1, 27, {
    amplitude: 0.31,
    phrase: 2.4,
    variation: 0.5,
  });

  addDrone(score, 27, 8, [55, 82.41, 110], 0.11);
  addPattern(score, 27.15, 35, {
    amplitude: 0.34,
    phrase: 2.25,
    variation: 1,
  });

  addDoom(score, 35.1, 0.035);
  addDrone(score, 35, 3.5, [41.2, 61.74], 0.008);
  addNoise(score, {
    start: 35.3,
    duration: 3,
    amplitude: 0.002,
    attack: 0.8,
    release: 1,
    smoothing: 0.985,
  });

  addDrone(score, 40, 4, [55, 82.41, 110], 0.18);
  [40, 40.55, 41.1].forEach((start, index) =>
    addDoom(score, start, 0.4 * (1 - index * 0.1)),
  );
  addTek(score, 41.65, 0.31, 0.1);
  [110, 164.81, 220].forEach((frequency, index) =>
    addTone(score, {
      start: 41.72 + index * 0.035,
      duration: 2.2 - index * 0.05,
      frequency,
      amplitude: 0.085,
      pan: index * 0.28 - 0.28,
      attack: 0.08,
      release: 1.45,
      wave: "sine",
    }),
  );

  normalizePeak(score, 0.54);
  return score;
};

const generateRhythmPulse = () => {
  const pulse = createStereo(44);
  [0.8, 2.45, 4.05].forEach((start, index) =>
    addDoom(pulse, start, 0.14 + index * 0.016),
  );
  addPattern(pulse, 5.2, 11, {amplitude: 0.2, phrase: 2.4});
  addPattern(pulse, 11.1, 27, {
    amplitude: 0.29,
    phrase: 2.4,
    variation: 0.5,
  });
  addPattern(pulse, 27.15, 35, {
    amplitude: 0.32,
    phrase: 2.25,
    variation: 1,
  });
  addDoom(pulse, 35.1, 0.065);
  [40, 40.55, 41.1].forEach((start, index) =>
    addDoom(pulse, start, 0.38 * (1 - index * 0.1)),
  );
  addTek(pulse, 41.65, 0.29, 0.1);
  normalizePeak(pulse, 0.52);
  return pulse;
};

const cueFactories = {
  "status-scan": (seconds) => {
    const cue = createStereo(seconds);
    addNoise(cue, {
      start: 0,
      duration: seconds,
      amplitude: 0.19,
      pan: -0.35,
      attack: 0.03,
      release: 0.3,
      smoothing: 0.94,
      stutterHz: 7,
    });
    addTone(cue, {
      start: 0.08,
      duration: 0.72,
      frequency: 420,
      frequencyEnd: 1260,
      amplitude: 0.08,
      pan: 0.25,
      attack: 0.01,
      release: 0.48,
      wave: "triangle",
    });
    addTek(cue, 0.63, 0.14, 0.3);
    return cue;
  },
  "init-lock": (seconds) => {
    const cue = createStereo(seconds);
    addDoom(cue, 0, 0.32);
    addTone(cue, {
      start: 0.12,
      duration: seconds - 0.12,
      frequency: 310,
      frequencyEnd: 690,
      amplitude: 0.1,
      attack: 0.012,
      release: 0.55,
      wave: "triangle",
    });
    addTek(cue, 0.42, 0.18, 0.1);
    return cue;
  },
  "phase-handoff": (seconds) => {
    const cue = createStereo(seconds);
    addTone(cue, {
      start: 0,
      duration: seconds,
      frequency: 180,
      frequencyEnd: 980,
      amplitude: 0.13,
      pan: -0.5,
      attack: 0.01,
      release: 0.48,
      wave: "triangle",
    });
    addNoise(cue, {
      start: 0.04,
      duration: seconds - 0.04,
      amplitude: 0.16,
      pan: 0.42,
      attack: 0.04,
      release: 0.34,
      smoothing: 0.9,
    });
    addTek(cue, 0.76, 0.16, 0.35);
    return cue;
  },
  "next-route": (seconds) => {
    const cue = createStereo(seconds);
    [0, 0.24, 0.5].forEach((start, index) =>
      addTone(cue, {
        start,
        duration: seconds - start,
        frequency: 260 + index * 170,
        frequencyEnd: 610 + index * 220,
        amplitude: 0.1 - index * 0.014,
        pan: -0.55 + index * 0.52,
        attack: 0.008,
        release: 0.5,
        wave: "triangle",
      }),
    );
    addTek(cue, 0.92, 0.18, 0.32);
    return cue;
  },
  "proof-resolve": (seconds) => {
    const cue = createStereo(seconds);
    addTek(cue, 0, 0.24, 0);
    addDoom(cue, 0.035, 0.2);
    [392, 587.33, 783.99].forEach((frequency, index) =>
      addTone(cue, {
        start: 0.09 + index * 0.045,
        duration: seconds - 0.09 - index * 0.045,
        frequency,
        amplitude: 0.075,
        pan: index * 0.3 - 0.3,
        attack: 0.01,
        release: 0.76,
        wave: "triangle",
      }),
    );
    return cue;
  },
};

await writeWave24(join(audioDir, "animatic-score.wav"), generateAnimaticScore());
await writeWave24(join(audioDir, "rhythm-pulse.wav"), generateRhythmPulse());
for (const cue of timeline.cues) {
  const factory = cueFactories[cue.id];
  if (!factory) throw new Error(`No audio factory for ${cue.id}`);
  const stereo = factory(cue.duration / timeline.fps);
  normalizePeak(stereo, 0.5);
  await writeWave24(join(audioDir, "cues", cue.file), stereo);
}

console.log(`Generated rhythmic review audio in ${audioDir}`);
console.log(
  `Score + final rhythm stem: 44s · doom-doom-doom-tek pulse · ${timeline.cues.length} foreground cues · 48kHz stereo PCM24`,
);
