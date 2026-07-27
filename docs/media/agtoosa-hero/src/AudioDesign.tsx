import React from "react";
import {Audio, Sequence, staticFile} from "remotion";
import timeline from "./timeline.json";
import {clamp} from "./theme";

export type AudioMode = "final" | "animatic" | "none";

const dbToGain = (db: number) => Math.pow(10, db / 20);
const duckGain = dbToGain(-2.5);

const smoothStep = (value: number) => {
  const t = clamp(value);
  return t * t * (3 - 2 * t);
};

const cueDuck = (frame: number, cueFrame: number, duration: number) => {
  const attack = 5;
  const release = 10;
  const from = cueFrame - attack;
  const holdUntil = cueFrame + duration;
  const to = holdUntil + release;

  if (frame < from || frame > to) return 1;
  if (frame < cueFrame) {
    return 1 - (1 - duckGain) * smoothStep((frame - from) / attack);
  }
  if (frame <= holdUntil) return duckGain;
  return duckGain + (1 - duckGain) * smoothStep((frame - holdUntil) / release);
};

const musicVolume = (frame: number) =>
  timeline.cues.reduce(
    (gain, cue) => Math.min(gain, cueDuck(frame, cue.frame, cue.duration)),
    1,
  );

const musicFiles: Record<Exclude<AudioMode, "none">, string> = {
  final: "render-audio/marketing-music.wav",
  animatic: "render-audio/animatic-score.wav",
};

export const AudioDesign: React.FC<{mode: AudioMode}> = ({mode}) => {
  if (mode === "none") return null;
  return (
    <>
      <Audio
        src={staticFile(musicFiles[mode])}
        volume={(frame) => musicVolume(frame) * (mode === "animatic" ? 1 : 0.9)}
      />
      {mode === "final" ? (
        <Audio
          src={staticFile("render-audio/rhythm-pulse.wav")}
          volume={(frame) => musicVolume(frame) * 0.28}
        />
      ) : null}
      {timeline.cues.map((cue) => (
        <Sequence
          key={cue.id}
          from={cue.frame}
          durationInFrames={cue.duration}
          layout="none"
          name={cue.id}
        >
          <Audio
            src={staticFile(`render-audio/cues/${cue.file}`)}
            volume={mode === "animatic" ? 0.58 : 0.7}
          />
        </Sequence>
      ))}
    </>
  );
};
