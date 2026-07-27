import React from "react";
import {colors, FONT_READABLE, FONT_SANS, progress} from "./theme";

type ProofGlyphProps = {
  frame?: number;
  start?: number;
  size?: number;
  color?: string;
  muted?: boolean;
};

const nodes = [
  {cx: 20, cy: 63, at: 0.08},
  {cx: 42, cy: 36, at: 0.24},
  {cx: 68, cy: 55, at: 0.4},
  {cx: 94, cy: 26, at: 0.56},
];

export const ProofGlyph: React.FC<ProofGlyphProps> = ({
  frame = 90,
  start = 0,
  size = 120,
  color = colors.cyan,
  muted = false,
}) => {
  const draw = progress(frame, start, 44);
  const check = progress(frame, start + 30, 26);

  return (
    <svg
      aria-label="Four evidence nodes connected into a verified check"
      viewBox="0 0 128 112"
      width={size}
      height={(size * 112) / 128}
      style={{overflow: "visible"}}
    >
      <path
        d="M20 63 L42 36 L68 55 L94 26"
        fill="none"
        pathLength={1}
        stroke={color}
        strokeDasharray={1}
        strokeDashoffset={1 - draw}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={muted ? 3 : 4}
        opacity={muted ? 0.48 : 0.92}
      />
      {nodes.map((node, index) => {
        const nodeProgress = progress(
          draw,
          node.at,
          0.13,
          (value) => value,
        );
        return (
          <g key={`${node.cx}-${node.cy}`}>
            <circle
              cx={node.cx}
              cy={node.cy}
              r={7 + nodeProgress * 2}
              fill={colors.ink}
              stroke={color}
              strokeWidth={3}
              opacity={nodeProgress}
            />
            <circle
              cx={node.cx}
              cy={node.cy}
              r={2.4}
              fill={color}
              opacity={nodeProgress}
            />
            {!muted && (
              <circle
                cx={node.cx}
                cy={node.cy}
                r={13 + index * 0.7}
                fill="none"
                stroke={color}
                strokeWidth={1}
                opacity={nodeProgress * 0.12}
              />
            )}
          </g>
        );
      })}
      <path
        d="M68 82 L83 97 L113 60"
        fill="none"
        pathLength={1}
        stroke={colors.success}
        strokeDasharray={1}
        strokeDashoffset={1 - check}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={7}
      />
    </svg>
  );
};

type WordmarkProps = {
  frame?: number;
  start?: number;
  compact?: boolean;
  align?: "left" | "center";
  readable?: boolean;
};

export const Wordmark: React.FC<WordmarkProps> = ({
  frame = 90,
  start = 0,
  compact = false,
  align = "left",
  readable = false,
}) => {
  const reveal = progress(frame, start, 28);
  const glyphSize = compact ? 62 : 104;
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: align === "center" ? "center" : "flex-start",
        gap: compact ? 14 : 23,
        opacity: reveal,
        transform: `translateY(${(1 - reveal) * 18}px)`,
      }}
    >
      <ProofGlyph
        frame={frame}
        start={start - 8}
        size={glyphSize}
        muted={compact}
      />
      <div
        style={{
          color: colors.paper,
          fontFamily: readable ? FONT_READABLE : FONT_SANS,
          fontSize: compact ? (readable ? 48 : 40) : readable ? 92 : 78,
          fontWeight: readable ? 800 : 780,
          letterSpacing: readable ? "-0.045em" : "-0.055em",
          lineHeight: 0.9,
        }}
      >
        Ag<span style={{color: colors.cyan}}>Toosa</span>
      </div>
    </div>
  );
};

export const BrandCredit: React.FC<{readable?: boolean}> = ({
  readable = false,
}) => (
  <div
    style={{
      color: colors.muted,
      fontFamily: readable ? FONT_READABLE : FONT_SANS,
      fontSize: readable ? 20 : 17,
      fontWeight: readable ? 600 : 570,
      letterSpacing: "0.02em",
    }}
  >
    A solution by <span style={{color: colors.paper}}>Atoosa Dev</span>
  </div>
);
