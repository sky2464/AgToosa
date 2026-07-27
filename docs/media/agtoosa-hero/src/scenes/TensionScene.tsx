import React from "react";
import {AbsoluteFill, useCurrentFrame} from "remotion";
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

const StatusRow: React.FC<{
  frame: number;
  start: number;
  label: string;
  value: string;
  readable?: boolean;
}> = ({frame, start, label, value, readable = false}) => {
  const reveal = progress(frame, start, 18);
  return (
    <div
      style={{
        alignItems: "center",
        borderTop: `1px solid ${colors.line}`,
        display: "flex",
        justifyContent: "space-between",
        opacity: reveal,
        padding: "16px 0",
        transform: `translateX(${(1 - reveal) * 14}px)`,
      }}
    >
      <span
        style={{
          color: colors.muted,
          fontFamily: readable ? FONT_READABLE : FONT_MONO,
          fontSize: readable ? 30 : 15,
          fontWeight: readable ? 650 : 500,
        }}
      >
        {label}
      </span>
      <span
        style={{
          color: colors.paper,
          fontFamily: readable ? FONT_READABLE : FONT_MONO,
          fontSize: readable ? 31 : 16,
          fontWeight: readable ? 700 : 500,
        }}
      >
        {value}
      </span>
    </div>
  );
};

export const TensionScene: React.FC<{
  timingScale?: number;
  readable?: boolean;
}> = ({timingScale = 1, readable = false}) => {
  const frame = useCurrentFrame();
  const cueFrame =
    timeline.cues.find((cue) => cue.id === "status-scan")?.frame ?? 54;
  const cueLocal =
    (cueFrame - timeline.scenes.tension.from) * timingScale;
  const opacity = fadeScene(frame, 165, 10, 18);
  const commandIn = progress(frame, 16 * timingScale, 25 * timingScale);
  const panelIn = progress(frame, 45 * timingScale, 30 * timingScale);
  const scan = progress(frame, cueLocal, 24 * timingScale);
  const closeIn = progress(frame, 112 * timingScale, 22 * timingScale);

  return (
    <AbsoluteFill style={{opacity}}>
      <FilmBackground frame={readable ? 0 : frame} coolShift={-5} />
      <div
        style={{
          position: "absolute",
          left: 92,
          top: 130,
          opacity: commandIn,
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
          AGTOOSA COMMAND
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: readable ? FONT_READABLE : FONT_MONO,
            fontSize: readable ? 104 : 112,
            fontWeight: readable ? 800 : 500,
            letterSpacing: readable ? "-0.055em" : "-0.06em",
            marginTop: 8,
          }}
        >
          /status
        </div>
        <div
          style={{
            color: colors.muted,
            fontFamily: readable ? FONT_READABLE : FONT_SANS,
            fontSize: readable ? 44 : 31,
            fontWeight: readable ? 600 : 560,
            marginTop: 9,
          }}
        >
          Know where the work is.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          right: 72,
          top: 156,
          width: 520,
          background: "rgba(10,15,29,.94)",
          border: `1px solid ${colors.cyan}55`,
          borderRadius: 22,
          boxShadow: "0 30px 90px rgba(0,0,0,.48)",
          opacity: panelIn,
          overflow: "hidden",
          padding: "24px 28px 18px",
          transform: `translateY(${(1 - panelIn) * 24}px)`,
        }}
      >
        <div
          style={{
            color: colors.cyan,
            fontFamily: readable ? FONT_READABLE : FONT_MONO,
            fontSize: readable ? 26 : 13,
            fontWeight: readable ? 700 : 500,
            letterSpacing: readable ? "0.08em" : "0.15em",
            marginBottom: 14,
          }}
        >
          READ-ONLY PROJECT PULSE
        </div>
        <StatusRow
          frame={frame}
          start={58 * timingScale}
          label="PLAN"
          value="where we are"
          readable={readable}
        />
        <StatusRow
          frame={frame}
          start={73 * timingScale}
          label="TASKS"
          value="what remains"
          readable={readable}
        />
        <StatusRow
          frame={frame}
          start={88 * timingScale}
          label="NEXT"
          value="one action"
          readable={readable}
        />
        <div
          style={{
            position: "absolute",
            left: 0,
            right: 0,
            top: `${18 + scan * 70}%`,
            height: 2,
            background:
              "linear-gradient(90deg, transparent, rgba(34,211,238,.85), transparent)",
            opacity: Math.sin(scan * Math.PI),
          }}
        />
      </div>
      <div
        style={{
          position: "absolute",
          left: 95,
          bottom: 82,
          color: colors.paper,
          fontFamily: readable ? FONT_READABLE : FONT_SANS,
          fontSize: readable ? 44 : 28,
          fontWeight: readable ? 650 : 620,
          opacity: closeIn,
        }}
      >
        Read state. <span style={{color: colors.cyan}}>Move with intent.</span>
      </div>
    </AbsoluteFill>
  );
};
