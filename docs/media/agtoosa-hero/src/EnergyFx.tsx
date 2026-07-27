import { AbsoluteFill, interpolate } from "remotion";
import { clamp, palette } from "./Design";

const impactFrames = [11, 112, 150, 195, 240, 285, 380, 420, 450, 480, 500, 520, 575];

export const impactAtFrame = (frame: number) =>
  Math.max(
    0,
    ...impactFrames.map((impactFrame) => {
      const distance = Math.abs(frame - impactFrame);
      return distance > 9 ? 0 : (1 - distance / 9) ** 2;
    }),
  );

export const EnergyFx = ({ frame }: { frame: number }) => {
  const impact = impactAtFrame(frame);
  const lifecycleEnergy =
    interpolate(frame, [105, 135, 370, 405], [0, 1, 1, 0], clamp) * 0.82;
  const finalEnergy = interpolate(frame, [520, 555, 630, 658], [0, 1, 0.8, 0], clamp);
  const lineEnergy = Math.max(lifecycleEnergy, finalEnergy);
  const beatFrames = (30 * 60) / 128;
  const beatPhase = frame % beatFrames;
  const beatPulse = Math.exp(-beatPhase / 2.8);
  const sweepX = ((frame * 18) % 2200) - 520;
  const sceneColor =
    frame < 380 ? palette.cyan : frame < 520 ? palette.green : palette.blue;

  return (
    <AbsoluteFill style={{ pointerEvents: "none", overflow: "hidden" }}>
      {Array.from({ length: 22 }).map((_, index) => {
        const speed = 13 + (index % 5) * 4;
        const x = ((index * 137 + frame * speed) % 1850) - 280;
        const y = 34 + ((index * 79) % 735);
        return (
          <div
            key={index}
            style={{
              position: "absolute",
              left: x,
              top: y,
              width: 105 + (index % 4) * 52,
              height: index % 3 === 0 ? 3 : 2,
              borderRadius: 99,
              opacity: lineEnergy * (0.06 + (index % 5) * 0.025),
              background: `linear-gradient(90deg, transparent, ${index % 3 === 0 ? palette.cyan : "#9bc9ff"})`,
              transform: "rotate(-11deg)",
              filter: "blur(.3px)",
            }}
          />
        );
      })}
      <div
        style={{
          position: "absolute",
          left: sweepX,
          top: -240,
          width: 320,
          height: 1300,
          opacity: lineEnergy * 0.18,
          background:
            "linear-gradient(90deg, transparent, rgba(125,225,255,.5), transparent)",
          filter: "blur(35px)",
          transform: "rotate(18deg)",
        }}
      />
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: "50%",
          width: 620 + impact * 540,
          height: 620 + impact * 540,
          borderRadius: "50%",
          border: `2px solid color-mix(in srgb, ${sceneColor} ${impact * 45}%, transparent)`,
          opacity: impact * 0.55,
          transform: "translate(-50%, -50%)",
          boxShadow: `0 0 100px color-mix(in srgb, ${sceneColor} ${impact * 28}%, transparent)`,
        }}
      />
      <AbsoluteFill
        style={{
          opacity: impact * 0.17,
          background: `radial-gradient(circle, white 0%, ${sceneColor} 18%, transparent 68%)`,
          mixBlendMode: "screen",
        }}
      />
      <AbsoluteFill
        style={{
          opacity: 0.035 + beatPulse * lineEnergy * 0.025,
          backgroundImage:
            "repeating-linear-gradient(0deg, transparent 0, transparent 3px, rgba(255,255,255,.24) 4px)",
          mixBlendMode: "screen",
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 56,
          right: 56,
          top: 34,
          height: 1,
          opacity: 0.24,
          background: "linear-gradient(90deg, transparent, #5fbfff, transparent)",
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 56,
          right: 56,
          bottom: 34,
          height: 1,
          opacity: 0.18,
          background: "linear-gradient(90deg, transparent, #5fbfff, transparent)",
        }}
      />
      <div
        style={{
          position: "absolute",
          right: 58,
          top: 48,
          color: palette.muted,
          fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
          fontSize: 11,
          letterSpacing: 2.5,
          opacity: 0.52,
        }}
      >
        AGTOOSA // PROOF ENGINE
      </div>
    </AbsoluteFill>
  );
};
