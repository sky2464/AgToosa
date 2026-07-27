import React from "react";
import {AbsoluteFill, Img, staticFile} from "remotion";
import timeline from "./timeline.json";
import {colors, FONT_MONO} from "./theme";

const labels = [
  "01 · STATUS",
  "02 · INIT",
  "03 · SPEC",
  "04 · BUILD",
  "05 · REVIEW → SHIP",
  "06 · STATUS → NEXT",
  "07 · VERIFY",
  "08 · CTA",
];

export const StoryboardContactSheet: React.FC = () => (
  <AbsoluteFill
    style={{
      display: "grid",
      gridTemplateColumns: "repeat(4, 480px)",
      gridTemplateRows: "repeat(2, 270px)",
      background: colors.ink,
    }}
  >
    {timeline.storyboardFrames.map((frame, index) => (
      <div
        key={frame}
        style={{
          position: "relative",
          width: 480,
          height: 270,
          overflow: "hidden",
          border: `1px solid ${colors.line}`,
          boxSizing: "border-box",
        }}
      >
        <Img
          src={staticFile(
            `storyboard-temp/${String(index + 1).padStart(2, "0")}.png`,
          )}
          style={{
            position: "absolute",
            left: 25,
            top: 28,
            width: 430,
            height: 242,
            objectFit: "contain",
          }}
        />
        <div
          style={{
            position: "absolute",
            left: 13,
            top: 7,
            color: colors.paper,
            fontFamily: FONT_MONO,
            fontSize: 10,
            letterSpacing: "0.08em",
          }}
        >
          {labels[index]} · {(frame / 30).toFixed(1)}s
        </div>
      </div>
    ))}
  </AbsoluteFill>
);
