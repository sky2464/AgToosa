import React from "react";
import {AbsoluteFill, useCurrentFrame} from "remotion";
import {FilmBackground} from "../FilmBackground";
import {colors, fadeScene, FONT_MONO, FONT_SANS, progress} from "../theme";
import timeline from "../timeline.json";

const StatusRow: React.FC<{
  frame: number;
  start: number;
  label: string;
  value: string;
}> = ({frame, start, label, value}) => {
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
      <span style={{color: colors.muted, fontFamily: FONT_MONO, fontSize: 15}}>
        {label}
      </span>
      <span style={{color: colors.paper, fontFamily: FONT_MONO, fontSize: 16}}>
        {value}
      </span>
    </div>
  );
};

export const TensionScene: React.FC = () => {
  const frame = useCurrentFrame();
  const cueFrame =
    timeline.cues.find((cue) => cue.id === "status-scan")?.frame ?? 54;
  const cueLocal = cueFrame - timeline.scenes.tension.from;
  const opacity = fadeScene(frame, 165, 10, 18);
  const commandIn = progress(frame, 16, 25);
  const panelIn = progress(frame, 45, 30);
  const scan = progress(frame, cueLocal, 24);
  const closeIn = progress(frame, 112, 22);

  return (
    <AbsoluteFill style={{opacity}}>
      <FilmBackground frame={frame} coolShift={-5} />
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
            fontFamily: FONT_MONO,
            fontSize: 14,
            letterSpacing: "0.18em",
          }}
        >
          AGTOOSA COMMAND
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 112,
            fontWeight: 720,
            letterSpacing: "-0.07em",
            marginTop: 8,
          }}
        >
          /status
        </div>
        <div
          style={{
            color: colors.muted,
            fontFamily: FONT_SANS,
            fontSize: 31,
            fontWeight: 560,
            marginTop: 9,
          }}
        >
          Know where the work is.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          right: 92,
          top: 156,
          width: 470,
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
            fontFamily: FONT_MONO,
            fontSize: 13,
            letterSpacing: "0.15em",
            marginBottom: 14,
          }}
        >
          READ-ONLY PROJECT PULSE
        </div>
        <StatusRow frame={frame} start={58} label="PLAN" value="where we are" />
        <StatusRow frame={frame} start={73} label="TASKS" value="what remains" />
        <StatusRow frame={frame} start={88} label="NEXT" value="one action" />
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
          fontFamily: FONT_SANS,
          fontSize: 28,
          fontWeight: 620,
          opacity: closeIn,
        }}
      >
        Read state. <span style={{color: colors.cyan}}>Move with intent.</span>
      </div>
    </AbsoluteFill>
  );
};

