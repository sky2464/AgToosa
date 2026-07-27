import React from "react";
import {AbsoluteFill, useCurrentFrame} from "remotion";
import {Wordmark} from "./Brand";
import {FilmBackground} from "./FilmBackground";
import {WorkflowRail} from "./WorkflowRail";
import {colors, FONT_MONO, FONT_SANS, README_FRAMES} from "./theme";

export const ReadmeLoop: React.FC = () => {
  const frame = useCurrentFrame();
  const phase = (frame / README_FRAMES) * Math.PI * 2;
  const loopPhase = frame / README_FRAMES;
  const breathe = 1 + Math.sin(phase) * 0.008;

  return (
    <AbsoluteFill
      style={{
        background: colors.ink,
        fontFamily: FONT_SANS,
        overflow: "hidden",
      }}
    >
      <FilmBackground frame={Math.sin(phase) * 90} />
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          top: 72,
          display: "flex",
          justifyContent: "center",
          transform: `scale(${breathe})`,
        }}
      >
        <Wordmark frame={100} start={0} align="center" compact />
      </div>
      <div
        style={{
          position: "absolute",
          inset: 0,
          top: 40,
          transform: `scale(${breathe})`,
        }}
      >
        <WorkflowRail frame={120} compact loopPhase={loopPhase} />
      </div>
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 62,
          color: colors.paper,
          fontFamily: FONT_SANS,
          fontSize: 29,
          fontWeight: 610,
          letterSpacing: "-0.025em",
          textAlign: "center",
        }}
      >
        Initialize once.{" "}
        <span style={{color: colors.cyan}}>Then keep moving.</span>
      </div>
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 31,
          color: colors.muted,
          fontFamily: FONT_MONO,
          fontSize: 13,
          letterSpacing: "0.12em",
          textAlign: "center",
        }}
      >
        /AGTOOSA-NEXT · ONE PHASE AT A TIME
      </div>
    </AbsoluteFill>
  );
};
