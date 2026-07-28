import React, {type ReactNode} from "react";
import {
  AbsoluteFill,
  interpolate,
  Sequence,
  useCurrentFrame,
} from "remotion";
import {BrandCredit, Wordmark} from "./Brand";
import {FilmBackground} from "./FilmBackground";
import {ReframeScene} from "./scenes/ReframeScene";
import {TensionScene} from "./scenes/TensionScene";
import {WorkflowSummaryScene} from "./scenes/WorkflowSummaryScene";
import {
  colors,
  FONT_MONO,
  FONT_SANS,
  progress,
  README_FRAMES,
} from "./theme";
import {VerifierTerminal} from "./VerifierTerminal";
import {DirectionalLink, WorkflowRail} from "./WorkflowRail";

const Segment: React.FC<{
  duration: number;
  children: ReactNode;
  fade?: number;
}> = ({duration, children, fade = 6}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(
    frame,
    [0, fade, duration - fade, duration],
    [0, 1, 1, 0],
    {extrapolateLeft: "clamp", extrapolateRight: "clamp"},
  );
  return <AbsoluteFill style={{opacity}}>{children}</AbsoluteFill>;
};

const WorkflowScene: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill>
      <FilmBackground frame={420} coolShift={3} />
      <div
        style={{
          left: 0,
          opacity: progress(frame, 4, 18),
          position: "absolute",
          right: 0,
          textAlign: "center",
          top: 58,
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
          REPOSITORY-DRIVEN DELIVERY
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
          One phase. One visible handoff.
        </div>
      </div>
      <WorkflowRail frame={frame} start={10} timingScale={0.3} readable />
      <div
        style={{
          bottom: 68,
          color: colors.muted,
          fontFamily: FONT_SANS,
          fontSize: 28,
          fontWeight: 500,
          left: 0,
          opacity: progress(frame, 96, 18),
          position: "absolute",
          right: 0,
          textAlign: "center",
        }}
      >
        Every phase leaves{" "}
        <span style={{color: colors.cyan}}>reviewable proof.</span>
      </div>
    </AbsoluteFill>
  );
};

const CommandCard: React.FC<{
  x: number;
  command: string;
  label: string;
  color: string;
  reveal: number;
}> = ({x, command, label, color, reveal}) => (
  <div
    style={{
      alignItems: "center",
      background: "rgba(10,15,29,.96)",
      border: `1px solid ${color}88`,
      borderRadius: 24,
      boxShadow: `0 26px 80px rgba(0,0,0,.42), 0 0 44px ${color}18`,
      display: "flex",
      flexDirection: "column",
      height: 154,
      justifyContent: "center",
      left: x - 180,
      opacity: reveal,
      position: "absolute",
      top: 292,
      transform: `scale(${0.9 + reveal * 0.1})`,
      width: 360,
    }}
  >
    <div
      style={{
        color,
        fontFamily: FONT_MONO,
        fontSize: 18,
        fontWeight: 500,
        letterSpacing: "0.1em",
      }}
    >
      {label}
    </div>
    <div
      style={{
        color: colors.paper,
        fontFamily: FONT_MONO,
        fontSize: 56,
        fontWeight: 500,
        letterSpacing: "-0.02em",
        marginTop: 8,
      }}
    >
      {command}
    </div>
  </div>
);

const RoutingScene: React.FC = () => {
  const frame = useCurrentFrame();
  const statusIn = progress(frame, 5, 18);
  const nextIn = progress(frame, 22, 18);
  const route = progress(frame, 42, 34);
  return (
    <AbsoluteFill>
      <FilmBackground frame={860} coolShift={11} />
      <div
        style={{
          left: 0,
          opacity: progress(frame, 2, 16),
          position: "absolute",
          right: 0,
          textAlign: "center",
          top: 72,
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
          REPO-AWARE PROJECT DRIVER
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
          One command keeps the project moving.
        </div>
      </div>
      <CommandCard
        x={370}
        command="/status"
        label="READ STATE"
        color={colors.cyan}
        reveal={statusIn}
      />
      <CommandCard
        x={1070}
        command="/next"
        label="ROUTE ONE PHASE"
        color={colors.violet}
        reveal={nextIn}
      />
      <svg
        height="810"
        style={{inset: 0, position: "absolute"}}
        viewBox="0 0 1440 810"
        width="1440"
      >
        <DirectionalLink
          id="readme-status-next"
          from={{x: 550, y: 369}}
          to={{x: 890, y: 369}}
          draw={route}
          pulse={route}
          color={colors.cyan}
          bend={-24}
        />
      </svg>
      <div
        style={{
          bottom: 86,
          color: colors.muted,
          fontFamily: FONT_MONO,
          fontSize: 20,
          fontWeight: 500,
          left: 0,
          letterSpacing: "0.08em",
          opacity: progress(frame, 58, 18),
          position: "absolute",
          right: 0,
          textAlign: "center",
        }}
      >
        /NEXT · READS SYNC · RUNS THE RIGHT PHASE
      </div>
    </AbsoluteFill>
  );
};

const VerifyScene: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill>
      <FilmBackground frame={1050} coolShift={-5} />
      <div
        style={{
          left: 0,
          opacity: progress(frame, 2, 14),
          position: "absolute",
          right: 0,
          textAlign: "center",
          top: 54,
        }}
      >
        <div
          style={{
            color: colors.muted,
            fontFamily: FONT_MONO,
            fontSize: 18,
            fontWeight: 500,
            letterSpacing: "0.1em",
          }}
        >
          DETERMINISTIC VERIFICATION
        </div>
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 48,
            fontWeight: 700,
            letterSpacing: "-0.02em",
            marginTop: 7,
          }}
        >
          The repository gets the last word.
        </div>
      </div>
      <div style={{left: 160, position: "absolute", top: 188}}>
        <VerifierTerminal
          frame={frame}
          start={8}
          timingScale={0.62}
          readable
        />
      </div>
    </AbsoluteFill>
  );
};

const ClosingScene: React.FC<{durationInFrames: number}> = ({
  durationInFrames,
}) => {
  const frame = useCurrentFrame();
  const reveal = progress(frame, 2, 14);
  const details = progress(frame, 12, 16);
  const fadeOut = interpolate(
    frame,
    [durationInFrames - 18, durationInFrames],
    [1, 0],
    {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    },
  );
  return (
    <AbsoluteFill style={{opacity: reveal * fadeOut}}>
      <FilmBackground frame={1210} coolShift={14} />
      <div
        style={{
          alignItems: "center",
          display: "flex",
          flexDirection: "column",
          inset: 0,
          justifyContent: "center",
          opacity: reveal,
          position: "absolute",
          transform: `translateY(${(1 - reveal) * 18}px)`,
        }}
      >
        <Wordmark frame={frame} start={0} align="center" readable />
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 44,
            fontWeight: 650,
            letterSpacing: "-0.02em",
            marginTop: 32,
            opacity: details,
          }}
        >
          One command.{" "}
          <span style={{color: colors.cyan}}>The right phase.</span>
        </div>
        <div
          style={{
            color: colors.cyan,
            fontFamily: FONT_MONO,
            fontSize: 20,
            fontWeight: 500,
            letterSpacing: "0.1em",
            marginTop: 18,
            opacity: details,
          }}
        >
          /NEXT · READ · ROUTE · EXECUTE
        </div>
        <div style={{marginTop: 24, opacity: details}}>
          <BrandCredit readable />
        </div>
      </div>
    </AbsoluteFill>
  );
};

export const ReadmeLoop: React.FC = () => {
  const frame = useCurrentFrame();
  const baseFrame =
    Math.sin((frame / README_FRAMES) * Math.PI * 2) * 90;
  const brandOpacity = interpolate(frame, [0, 18, 694, 714], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{background: colors.ink}}>
      <FilmBackground frame={baseFrame} coolShift={4} />
      <Sequence durationInFrames={144}>
        <Segment duration={144}>
          <TensionScene timingScale={0.8} readable />
        </Segment>
      </Sequence>
      <Sequence from={138} durationInFrames={150}>
        <Segment duration={150}>
          <ReframeScene timingScale={0.75} readable />
        </Segment>
      </Sequence>
      <Sequence from={282} durationInFrames={186}>
        <Segment duration={186}>
          <WorkflowScene />
        </Segment>
      </Sequence>
      <Sequence from={462} durationInFrames={132}>
        <Segment duration={132}>
          <RoutingScene />
        </Segment>
      </Sequence>
      <Sequence from={588} durationInFrames={132}>
        <Segment duration={132}>
          <VerifyScene />
        </Segment>
      </Sequence>
      <Sequence from={714} durationInFrames={144}>
        <Segment duration={144}>
          <WorkflowSummaryScene />
        </Segment>
      </Sequence>
      <Sequence from={852} durationInFrames={108}>
        <ClosingScene durationInFrames={108} />
      </Sequence>
      <div
        style={{
          left: 38,
          opacity: brandOpacity,
          position: "absolute",
          top: 28,
          transform: "scale(.82)",
          transformOrigin: "top left",
        }}
      >
        <Wordmark frame={frame} start={0} compact readable />
      </div>
    </AbsoluteFill>
  );
};
