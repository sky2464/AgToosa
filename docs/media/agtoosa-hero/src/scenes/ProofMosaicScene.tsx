import React from "react";
import {AbsoluteFill, useCurrentFrame} from "remotion";
import {FilmBackground} from "../FilmBackground";
import {WorkflowRail} from "../WorkflowRail";
import {colors, fadeScene, FONT_MONO, FONT_SANS, progress} from "../theme";
import timeline from "../timeline.json";

export const ProofMosaicScene: React.FC = () => {
  const frame = useCurrentFrame();
  const cueFrame =
    timeline.cues.find((cue) => cue.id === "phase-handoff")?.frame ?? 585;
  const cueLocal = cueFrame - timeline.scenes.proof.from;
  const opacity = fadeScene(frame, 525, 18, 26);
  const titleIn = progress(frame, 12, 26);
  const handoff = progress(frame, cueLocal, 28);
  const closeIn = progress(frame, 410, 30);

  return (
    <AbsoluteFill style={{opacity}}>
      <FilmBackground frame={frame + 310} coolShift={2} />
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          top: 52,
          opacity: titleIn,
          textAlign: "center",
        }}
      >
        <div
          style={{
            color: colors.cyan,
            fontFamily: FONT_MONO,
            fontSize: 13,
            letterSpacing: "0.18em",
          }}
        >
          INIT ONCE · THEN REPEAT
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 48,
            fontWeight: 710,
            letterSpacing: "-0.048em",
            marginTop: 8,
          }}
        >
          One phase. One clear handoff.
        </div>
      </div>
      <WorkflowRail frame={frame} start={28} />
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 76,
          color: colors.muted,
          fontFamily: FONT_SANS,
          fontSize: 26,
          fontWeight: 560,
          opacity: closeIn,
          textAlign: "center",
          transform: `translateY(${(1 - closeIn) * 15}px)`,
        }}
      >
        The handoff point lands{" "}
        <span style={{color: colors.cyan, opacity: 0.7 + handoff * 0.3}}>
          on the next gate.
        </span>
      </div>
    </AbsoluteFill>
  );
};

