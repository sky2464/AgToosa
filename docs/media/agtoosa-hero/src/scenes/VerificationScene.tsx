import React from "react";
import {AbsoluteFill, useCurrentFrame} from "remotion";
import {FilmBackground} from "../FilmBackground";
import {VerifierTerminal} from "../VerifierTerminal";
import {
  colors,
  fadeScene,
  FONT_MONO,
  FONT_SANS,
  progress,
} from "../theme";
import timeline from "../timeline.json";

export const VerificationScene: React.FC = () => {
  const frame = useCurrentFrame();
  const cueFrame =
    timeline.cues.find((cue) => cue.id === "proof-resolve")?.frame ??
    1155;
  const cueLocal = cueFrame - timeline.scenes.verify.from;
  const opacity = fadeScene(frame, 180, 14, 18);
  const labelIn = progress(frame, 8, 22);
  const confirmation = progress(frame, cueLocal, 12);

  return (
    <AbsoluteFill style={{opacity}}>
      <FilmBackground frame={frame + 1040} coolShift={-6} />
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          top: 58,
          opacity: labelIn,
          textAlign: "center",
        }}
      >
        <div
          style={{
            color: colors.muted,
            fontFamily: FONT_MONO,
            fontSize: 13,
            letterSpacing: "0.16em",
          }}
        >
          DETERMINISTIC VERIFICATION
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 39,
            fontWeight: 690,
            letterSpacing: "-0.035em",
            marginTop: 7,
          }}
        >
          The repository gets the last word.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 250,
          top: 194,
          transform: `scale(${1 + confirmation * 0.012})`,
        }}
      >
        <VerifierTerminal frame={frame} start={16} />
      </div>
    </AbsoluteFill>
  );
};
