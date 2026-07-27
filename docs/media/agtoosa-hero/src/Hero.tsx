import {
  AbsoluteFill,
  Audio,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Ambient } from "./Design";
import { EnergyFx, impactAtFrame } from "./EnergyFx";
import { FinalScene, IntroScene } from "./IntroFinal";
import { LifecycleScene, VerifyScene } from "./LifecycleVerify";

export const Hero: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const impact = impactAtFrame(frame);
  const shakeX = Math.sin(frame * 2.7) * impact * 5;
  const shakeY = Math.cos(frame * 3.2) * impact * 3;
  return (
    <AbsoluteFill
      style={{
        fontFamily: "Inter, ui-sans-serif, system-ui, -apple-system, sans-serif",
      }}
    >
      <AbsoluteFill
        style={{
          transform: `translate(${shakeX}px, ${shakeY}px) scale(${1 + impact * 0.018})`,
        }}
      >
        <Ambient frame={frame} />
        <IntroScene frame={frame} fps={fps} />
        <LifecycleScene frame={frame} fps={fps} />
        <VerifyScene frame={frame} fps={fps} />
        <FinalScene frame={frame} fps={fps} />
      </AbsoluteFill>
      <EnergyFx frame={frame} />
      <Audio src={staticFile("audio/agtoosa-score.wav")} volume={0.62} />
      <Audio src={staticFile("audio/agtoosa-sfx.wav")} volume={0.7} />
    </AbsoluteFill>
  );
};
