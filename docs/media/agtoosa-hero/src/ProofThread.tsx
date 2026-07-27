import React from "react";
import {colors, progress} from "./theme";

export type ThreadPoint = {
  x: number;
  y: number;
  label?: string;
  color?: string;
};

type ProofThreadProps = {
  points: ThreadPoint[];
  frame: number;
  start?: number;
  duration?: number;
  width?: number;
  height?: number;
  color?: string;
  showLabels?: boolean;
};

const pathFromPoints = (points: ThreadPoint[]) =>
  points
    .map((point, index) => `${index === 0 ? "M" : "L"} ${point.x} ${point.y}`)
    .join(" ");

export const ProofThread: React.FC<ProofThreadProps> = ({
  points,
  frame,
  start = 0,
  duration = 45,
  width = 1440,
  height = 810,
  color = colors.cyan,
  showLabels = false,
}) => {
  const draw = progress(frame, start, duration);
  return (
    <svg
      viewBox={`0 0 ${width} ${height}`}
      width={width}
      height={height}
      style={{position: "absolute", inset: 0, overflow: "visible"}}
    >
      <path
        d={pathFromPoints(points)}
        fill="none"
        pathLength={1}
        stroke={colors.line}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
      />
      <path
        d={pathFromPoints(points)}
        fill="none"
        pathLength={1}
        stroke={color}
        strokeDasharray={1}
        strokeDashoffset={1 - draw}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={3}
      />
      {points.map((point, index) => {
        const pointProgress = progress(
          draw,
          index / Math.max(1, points.length - 1) - 0.06,
          0.16,
          (value) => value,
        );
        const nodeColor = point.color ?? color;
        return (
          <g key={`${point.x}-${point.y}-${index}`} opacity={pointProgress}>
            <circle
              cx={point.x}
              cy={point.y}
              fill={colors.ink}
              r={10}
              stroke={nodeColor}
              strokeWidth={2}
            />
            <circle cx={point.x} cy={point.y} fill={nodeColor} r={3.4} />
            {showLabels && point.label ? (
              <text
                x={point.x}
                y={point.y + 32}
                fill={colors.muted}
                fontFamily='"IBM Plex Mono", monospace'
                fontSize={14}
                letterSpacing={1.8}
                textAnchor="middle"
              >
                {point.label}
              </text>
            ) : null}
          </g>
        );
      })}
    </svg>
  );
};
