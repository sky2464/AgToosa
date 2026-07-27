import React from "react";
import {colors, FONT_MONO, FONT_SANS, progress} from "./theme";

export type FlowPoint = {x: number; y: number};

type DirectionalLinkProps = {
  from: FlowPoint;
  to: FlowPoint;
  draw: number;
  color?: string;
  id: string;
  bend?: number;
  pulse?: number;
};

const cubicPoint = (
  from: FlowPoint,
  to: FlowPoint,
  bend: number,
  value: number,
) => {
  const oneMinus = 1 - value;
  const controlA = {x: from.x + (to.x - from.x) * 0.36, y: from.y + bend};
  const controlB = {x: from.x + (to.x - from.x) * 0.64, y: to.y - bend};
  return {
    x:
      oneMinus ** 3 * from.x +
      3 * oneMinus ** 2 * value * controlA.x +
      3 * oneMinus * value ** 2 * controlB.x +
      value ** 3 * to.x,
    y:
      oneMinus ** 3 * from.y +
      3 * oneMinus ** 2 * value * controlA.y +
      3 * oneMinus * value ** 2 * controlB.y +
      value ** 3 * to.y,
  };
};

export const DirectionalLink: React.FC<DirectionalLinkProps> = ({
  from,
  to,
  draw,
  color = colors.cyan,
  id,
  bend = 0,
  pulse,
}) => {
  const safeDraw = Math.max(0, Math.min(1, draw));
  const pulseValue = Math.max(0, Math.min(1, pulse ?? safeDraw));
  const controlA = {
    x: from.x + (to.x - from.x) * 0.36,
    y: from.y + bend,
  };
  const controlB = {
    x: from.x + (to.x - from.x) * 0.64,
    y: to.y - bend,
  };
  const point = cubicPoint(from, to, bend, pulseValue);
  return (
    <>
      <defs>
        <marker
          id={id}
          markerWidth="8"
          markerHeight="8"
          refX="7"
          refY="4"
          orient="auto"
          markerUnits="strokeWidth"
        >
          <path d="M 0 0 L 8 4 L 0 8 z" fill={color} />
        </marker>
      </defs>
      <path
        d={`M ${from.x} ${from.y} C ${controlA.x} ${controlA.y}, ${controlB.x} ${controlB.y}, ${to.x} ${to.y}`}
        fill="none"
        pathLength={1}
        stroke={color}
        strokeDasharray={1}
        strokeDashoffset={1 - safeDraw}
        strokeLinecap="round"
        strokeWidth={2.2}
        markerEnd={safeDraw > 0.9 ? `url(#${id})` : undefined}
        opacity={0.28 + safeDraw * 0.72}
      />
      {safeDraw > 0.04 && safeDraw < 0.99 ? (
        <circle
          cx={point.x}
          cy={point.y}
          r={6}
          fill={colors.paper}
          stroke={color}
          strokeWidth={3}
        />
      ) : null}
      {safeDraw > 0.04 ? (
        <circle cx={from.x} cy={from.y} r={3.5} fill={color} />
      ) : null}
      {safeDraw > 0.9 ? (
        <circle cx={to.x} cy={to.y} r={4.5} fill={color} />
      ) : null}
    </>
  );
};

const phases = [
  {phase: "INIT", command: "/init", note: "ONCE", color: colors.cyan},
  {phase: "SPEC", command: "/spec", note: "DEFINE", color: colors.spec},
  {phase: "BUILD", command: "/build", note: "IMPLEMENT", color: colors.build},
  {phase: "REVIEW", command: "/review", note: "INSPECT", color: colors.review},
  {phase: "SHIP", command: "/ship", note: "RELEASE", color: colors.ship},
];

const positions = [
  {x: 150, y: 430},
  {x: 435, y: 350},
  {x: 720, y: 445},
  {x: 1005, y: 350},
  {x: 1290, y: 430},
];

type WorkflowRailProps = {
  frame: number;
  start?: number;
  compact?: boolean;
  loopPhase?: number;
  timingScale?: number;
};

export const WorkflowRail: React.FC<WorkflowRailProps> = ({
  frame,
  start = 0,
  compact = false,
  loopPhase,
  timingScale = 1,
}) => {
  const width = compact ? 158 : 194;
  const height = compact ? 78 : 112;
  const connectorStarts = [58, 138, 222, 306];
  const loopPosition =
    loopPhase === undefined
      ? undefined
      : Math.max(0, Math.min(0.9999, loopPhase)) * 4;
  const activeLoopConnector =
    loopPosition === undefined ? -1 : Math.floor(loopPosition);
  const activeLoopProgress =
    loopPosition === undefined ? 0 : loopPosition - activeLoopConnector;

  return (
    <div style={{position: "absolute", inset: 0}}>
      <svg
        width="1440"
        height="810"
        viewBox="0 0 1440 810"
        style={{position: "absolute", inset: 0, overflow: "visible"}}
      >
        {positions.slice(0, -1).map((position, index) => {
          const next = positions[index + 1];
          const draw =
            loopPhase === undefined
              ? progress(
                  frame,
                  start + connectorStarts[index] * timingScale,
                  42 * timingScale,
                )
              : 1;
          const pulse =
            loopPhase === undefined
              ? draw
              : activeLoopConnector === index
                ? activeLoopProgress
                : 1;
          return (
            <DirectionalLink
              key={phases[index].phase}
              id={`phase-arrow-${index}`}
              from={{x: position.x + width / 2, y: position.y}}
              to={{x: next.x - width / 2, y: next.y}}
              bend={index % 2 === 0 ? -12 : 12}
              color={phases[index + 1].color}
              draw={draw}
              pulse={pulse}
            />
          );
        })}
      </svg>
      {phases.map((item, index) => {
        const reveal =
          loopPhase === undefined
            ? progress(
                frame,
                start +
                  (index === 0
                    ? 12 * timingScale
                    : (connectorStarts[index - 1] + 30) * timingScale),
                20 * timingScale,
              )
            : 1;
        const isLoopActive =
          loopPhase !== undefined &&
          (activeLoopConnector === index || activeLoopConnector + 1 === index);
        return (
          <div
            key={item.phase}
            style={{
              position: "absolute",
              left: positions[index].x - width / 2,
              top: positions[index].y - height / 2,
              width,
              height,
              alignItems: "center",
              background: `linear-gradient(145deg, ${colors.panelRaised}f5, ${colors.panel}f5)`,
              border: `1px solid ${item.color}${isLoopActive ? "cc" : "72"}`,
              borderRadius: compact ? 16 : 20,
              boxShadow: isLoopActive
                ? `0 0 38px ${item.color}35`
                : "0 24px 70px rgba(0,0,0,.34)",
              boxSizing: "border-box",
              display: "flex",
              flexDirection: "column",
              justifyContent: "center",
              opacity: reveal,
              transform: `scale(${0.9 + reveal * 0.1 + (isLoopActive ? 0.025 : 0)})`,
            }}
          >
            <div
              style={{
                color: item.color,
                fontFamily: FONT_MONO,
                fontSize: compact ? 10 : 12,
                letterSpacing: "0.16em",
              }}
            >
              {item.phase} · {item.note}
            </div>
            <div
              style={{
                color: colors.paper,
                fontFamily: FONT_SANS,
                fontSize: compact ? 27 : 34,
                fontWeight: 700,
                letterSpacing: "-0.035em",
                marginTop: compact ? 5 : 8,
              }}
            >
              {item.command}
            </div>
          </div>
        );
      })}
    </div>
  );
};
