import React from "react";
import {AbsoluteFill} from "remotion";
import {colors} from "./theme";

type FilmBackgroundProps = {
  frame: number;
  coolShift?: number;
};

export const FilmBackground: React.FC<FilmBackgroundProps> = ({
  frame,
  coolShift = 0,
}) => {
  const driftX = Math.sin(frame / 180) * 28;
  const driftY = Math.cos(frame / 240) * 18;
  return (
    <AbsoluteFill
      style={{
        background: colors.ink,
        overflow: "hidden",
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: "-14%",
          transform: `translate(${driftX}px, ${driftY}px)`,
          background: [
            `radial-gradient(circle at ${24 + coolShift}% 22%, rgba(2,132,199,0.15), transparent 34%)`,
            "radial-gradient(circle at 78% 72%, rgba(139,92,246,0.12), transparent 38%)",
            "radial-gradient(circle at 48% 48%, rgba(34,211,238,0.045), transparent 44%)",
          ].join(","),
        }}
      />
      <div
        style={{
          position: "absolute",
          inset: 0,
          opacity: 0.22,
          backgroundImage:
            "linear-gradient(rgba(141,154,178,0.08) 1px, transparent 1px), linear-gradient(90deg, rgba(141,154,178,0.06) 1px, transparent 1px)",
          backgroundSize: "72px 72px",
          maskImage:
            "radial-gradient(circle at center, black 0%, rgba(0,0,0,.48) 46%, transparent 82%)",
        }}
      />
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "linear-gradient(180deg, rgba(5,7,13,0.06), rgba(5,7,13,0.28) 64%, rgba(5,7,13,0.72))",
        }}
      />
      <div
        style={{
          position: "absolute",
          inset: 0,
          boxShadow: "inset 0 0 190px rgba(0,0,0,0.72)",
        }}
      />
    </AbsoluteFill>
  );
};
