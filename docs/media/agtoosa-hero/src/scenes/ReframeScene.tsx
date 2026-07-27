import React from "react";
import {AbsoluteFill, useCurrentFrame} from "remotion";
import {ProofGlyph} from "../Brand";
import {FilmBackground} from "../FilmBackground";
import {
  colors,
  fadeScene,
  FONT_MONO,
  FONT_READABLE,
  FONT_SANS,
  progress,
} from "../theme";
import timeline from "../timeline.json";

const initSteps = ["SCAN CODEBASE", "ESTABLISH CONTEXT", "WIRE ASSISTANTS"];

export const ReframeScene: React.FC<{
  timingScale?: number;
  readable?: boolean;
}> = ({timingScale = 1, readable = false}) => {
  const frame = useCurrentFrame();
  const cueFrame =
    timeline.cues.find((cue) => cue.id === "init-lock")?.frame ?? 216;
  const cueLocal =
    (cueFrame - timeline.scenes.reframe.from) * timingScale;
  const opacity = fadeScene(frame, 210, 15, 22);
  const commandIn = progress(frame, 18 * timingScale, 27 * timingScale);
  const stepsIn = progress(frame, 66 * timingScale, 26 * timingScale);
  const lock = progress(frame, cueLocal, 18 * timingScale);

  return (
    <AbsoluteFill style={{opacity}}>
      <FilmBackground frame={readable ? 120 : frame + 120} coolShift={5} />
      <div
        style={{
          position: "absolute",
          left: 126,
          top: 160,
          opacity: commandIn,
          transform: `translateY(${(1 - commandIn) * 22}px)`,
        }}
      >
        <div
          style={{
            color: colors.cyan,
            fontFamily: readable ? FONT_READABLE : FONT_MONO,
            fontSize: readable ? 26 : 14,
            fontWeight: readable ? 700 : undefined,
            letterSpacing: readable ? "0.1em" : "0.18em",
          }}
        >
          ONE-TIME SETUP
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: readable ? FONT_READABLE : FONT_MONO,
            fontSize: readable ? 104 : 118,
            fontWeight: readable ? 800 : 500,
            letterSpacing: readable ? "-0.055em" : "-0.065em",
            marginTop: 6,
          }}
        >
          /init
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: readable ? FONT_READABLE : FONT_SANS,
            fontSize: readable ? 52 : 38,
            fontWeight: readable ? 700 : 650,
            letterSpacing: readable ? "-0.025em" : "-0.035em",
            marginTop: 12,
          }}
        >
          Initialize once.
        </div>
        <div
          style={{
            color: colors.muted,
            fontFamily: readable ? FONT_READABLE : FONT_SANS,
            fontSize: readable ? 38 : 25,
            fontWeight: readable ? 500 : undefined,
            marginTop: 9,
          }}
        >
          Then let the repository drive.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          right: 130,
          top: 182,
          width: 430,
          border: `1px solid ${colors.cyan}48`,
          borderRadius: 24,
          background: "rgba(10,15,29,.92)",
          boxShadow: `0 0 ${50 * lock}px rgba(34,211,238,.17)`,
          opacity: stepsIn,
          padding: "28px 30px",
        }}
      >
        {initSteps.map((step, index) => {
          const itemIn = progress(
            frame,
            (70 + index * 19) * timingScale,
            18 * timingScale,
          );
          return (
            <div
              key={step}
              style={{
                alignItems: "center",
                borderTop: index === 0 ? undefined : `1px solid ${colors.line}`,
                color: colors.paper,
                display: "flex",
                fontFamily: readable ? FONT_READABLE : FONT_MONO,
                fontSize: readable ? 30 : 17,
                fontWeight: readable ? 650 : 500,
                gap: 18,
                opacity: itemIn,
                padding: "18px 0",
              }}
            >
              <span
                style={{
                  alignItems: "center",
                  border: `1px solid ${colors.cyan}88`,
                  borderRadius: "50%",
                  color: colors.cyan,
                  display: "inline-flex",
                  height: 25,
                  justifyContent: "center",
                  width: 25,
                }}
              >
                {index + 1}
              </span>
              {step}
            </div>
          );
        })}
        {!readable ? (
          <div
            style={{
              position: "absolute",
              right: 24,
              bottom: 22,
              opacity: 0.15 + lock * 0.75,
            }}
          >
            <ProofGlyph frame={100} size={68} />
          </div>
        ) : null}
      </div>
    </AbsoluteFill>
  );
};
