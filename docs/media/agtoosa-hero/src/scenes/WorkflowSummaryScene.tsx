import React from "react";
import {AbsoluteFill, useCurrentFrame} from "remotion";
import {FilmBackground} from "../FilmBackground";
import {colors, FONT_MONO, FONT_SANS, progress} from "../theme";
import {WorkflowRail} from "../WorkflowRail";

export const WorkflowSummaryScene: React.FC = () => {
  const frame = useCurrentFrame();
  const headingIn = progress(frame, 6, 18);
  const footerIn = progress(frame, 24, 18);

  return (
    <AbsoluteFill>
      <FilmBackground frame={1410} coolShift={7} />
      <div
        style={{
          left: 0,
          opacity: headingIn,
          position: "absolute",
          right: 0,
          textAlign: "center",
          top: 56,
          transform: `translateY(${(1 - headingIn) * 10}px)`,
        }}
      >
        <div
          style={{
            color: colors.cyan,
            fontFamily: FONT_MONO,
            fontSize: 18,
            fontWeight: 500,
            letterSpacing: "0.1em",
          }}
        >
          THE COMPLETE WORKFLOW
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 48,
            fontWeight: 700,
            letterSpacing: "-0.02em",
            marginTop: 8,
          }}
        >
          Initialize once. Then move one phase at a time.
        </div>
      </div>
      <WorkflowRail
        frame={frame}
        readable
        showCaptions
        staticView
      />
      <div
        style={{
          bottom: 58,
          color: colors.muted,
          fontFamily: FONT_SANS,
          fontSize: 28,
          fontWeight: 500,
          left: 0,
          opacity: footerIn,
          position: "absolute",
          right: 0,
          textAlign: "center",
        }}
      >
        Every handoff leaves{" "}
        <span style={{color: colors.cyan}}>reviewable proof.</span>
      </div>
    </AbsoluteFill>
  );
};
