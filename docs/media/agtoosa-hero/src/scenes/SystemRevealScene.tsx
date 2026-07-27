import React from "react";
import {AbsoluteFill, useCurrentFrame} from "remotion";
import {FilmBackground} from "../FilmBackground";
import {DirectionalLink} from "../WorkflowRail";
import {colors, fadeScene, FONT_MONO, FONT_SANS, progress} from "../theme";
import timeline from "../timeline.json";

const CommandCard: React.FC<{
  x: number;
  command: string;
  label: string;
  color: string;
  reveal: number;
}> = ({x, command, label, color, reveal}) => (
  <div
    style={{
      position: "absolute",
      left: x - 180,
      top: 228,
      width: 360,
      height: 154,
      alignItems: "center",
      background: "rgba(10,15,29,.95)",
      border: `1px solid ${color}70`,
      borderRadius: 24,
      boxShadow: "0 26px 80px rgba(0,0,0,.38)",
      display: "flex",
      flexDirection: "column",
      justifyContent: "center",
      opacity: reveal,
      transform: `scale(${0.92 + reveal * 0.08})`,
    }}
  >
    <div
      style={{
        color,
        fontFamily: FONT_MONO,
        fontSize: 13,
        letterSpacing: "0.16em",
      }}
    >
      {label}
    </div>
    <div
      style={{
        color: colors.paper,
        fontFamily: FONT_SANS,
        fontSize: 54,
        fontWeight: 710,
        letterSpacing: "-0.05em",
        marginTop: 8,
      }}
    >
      {command}
    </div>
  </div>
);

const miniPhases = [
  {x: 480, label: "SPEC", color: colors.spec},
  {x: 665, label: "BUILD", color: colors.build},
  {x: 850, label: "REVIEW", color: colors.review},
  {x: 1035, label: "SHIP", color: colors.ship},
];

export const SystemRevealScene: React.FC = () => {
  const frame = useCurrentFrame();
  const cueFrame =
    timeline.cues.find((cue) => cue.id === "next-route")?.frame ?? 915;
  const cueLocal = cueFrame - timeline.scenes.system.from;
  const opacity = fadeScene(frame, 270, 15, 20);
  const titleIn = progress(frame, 14, 24);
  const statusIn = progress(frame, 36, 24);
  const nextIn = progress(frame, 58, 24);
  const route = progress(frame, cueLocal, 44);
  const phaseIn = progress(frame, 106, 24);

  return (
    <AbsoluteFill style={{opacity}}>
      <FilmBackground frame={frame + 800} coolShift={10} />
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          top: 50,
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
          REPO-AWARE PROJECT DRIVER
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 45,
            fontWeight: 700,
            letterSpacing: "-0.045em",
            marginTop: 8,
          }}
        >
          One command keeps the project moving.
        </div>
      </div>
      <CommandCard
        x={350}
        command="/status"
        label="READ PROJECT STATE"
        color={colors.cyan}
        reveal={statusIn}
      />
      <CommandCard
        x={1090}
        command="/next"
        label="ROUTE · EXECUTE ONE PHASE"
        color={colors.violet}
        reveal={nextIn}
      />
      <svg
        width="1440"
        height="810"
        viewBox="0 0 1440 810"
        style={{position: "absolute", inset: 0}}
      >
        <DirectionalLink
          id="status-next-arrow"
          from={{x: 530, y: 305}}
          to={{x: 910, y: 305}}
          draw={route}
          pulse={route}
          color={colors.cyan}
          bend={-22}
        />
        <DirectionalLink
          id="next-phase-arrow"
          from={{x: 1090, y: 382}}
          to={{x: 813, y: 542}}
          draw={progress(frame, cueLocal + 24, 42)}
          pulse={progress(frame, cueLocal + 24, 42)}
          color={colors.review}
          bend={26}
        />
      </svg>
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          top: 542,
          display: "flex",
          gap: 25,
          justifyContent: "center",
          opacity: phaseIn,
        }}
      >
        {miniPhases.map((phase) => (
          <div
            key={phase.label}
            style={{
              width: 160,
              height: 64,
              alignItems: "center",
              background: "rgba(10,15,29,.94)",
              border: `1px solid ${phase.color}${phase.label === "REVIEW" ? "bb" : "55"}`,
              borderRadius: 16,
              color: phase.color,
              display: "flex",
              fontFamily: FONT_MONO,
              fontSize: 14,
              justifyContent: "center",
              letterSpacing: "0.12em",
              boxShadow:
                phase.label === "REVIEW"
                  ? `0 0 ${route * 40}px ${phase.color}30`
                  : undefined,
            }}
          >
            {phase.label}
          </div>
        ))}
      </div>
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 66,
          color: colors.muted,
          fontFamily: FONT_SANS,
          fontSize: 24,
          opacity: progress(frame, 155, 25),
          textAlign: "center",
        }}
      >
        Repeat <span style={{color: colors.paper}}>/agtoosa-next</span> — it
        reads SYNC and runs the right phase.
      </div>
    </AbsoluteFill>
  );
};
