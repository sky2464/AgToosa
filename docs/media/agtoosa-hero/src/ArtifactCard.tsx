import React, {ReactNode} from "react";
import {colors, FONT_MONO, FONT_SANS, progress} from "./theme";

type ArtifactCardProps = {
  frame: number;
  start?: number;
  width: number;
  eyebrow: string;
  title: string;
  accent: string;
  children: ReactNode;
  height?: number;
  rotate?: number;
  dimmed?: boolean;
};

export const ArtifactCard: React.FC<ArtifactCardProps> = ({
  frame,
  start = 0,
  width,
  eyebrow,
  title,
  accent,
  children,
  height,
  rotate = 0,
  dimmed = false,
}) => {
  const reveal = progress(frame, start, 28);
  return (
    <div
      style={{
        width,
        minHeight: height,
        boxSizing: "border-box",
        border: `1px solid ${accent}52`,
        borderRadius: 20,
        background:
          "linear-gradient(145deg, rgba(16,24,43,0.98), rgba(7,11,22,0.96))",
        boxShadow: dimmed
          ? "0 20px 70px rgba(0,0,0,.22)"
          : `0 34px 90px rgba(0,0,0,.42), 0 0 42px ${accent}13`,
        color: colors.paper,
        opacity: reveal * (dimmed ? 0.58 : 1),
        overflow: "hidden",
        transform: `translateY(${(1 - reveal) * 26}px) rotate(${rotate}deg)`,
      }}
    >
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          borderBottom: `1px solid ${colors.line}`,
          padding: "15px 20px 13px",
        }}
      >
        <div
          style={{
            color: accent,
            fontFamily: FONT_MONO,
            fontSize: 15,
            fontWeight: 500,
            letterSpacing: "0.12em",
          }}
        >
          {eyebrow}
        </div>
        <div style={{display: "flex", gap: 7}}>
          {[0, 1, 2].map((dot) => (
            <span
              key={dot}
              style={{
                width: 6,
                height: 6,
                borderRadius: "50%",
                background: dot === 0 ? accent : colors.line,
              }}
            />
          ))}
        </div>
      </div>
      <div style={{padding: "20px 22px 23px"}}>
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 28,
            fontWeight: 690,
            letterSpacing: "-0.025em",
            lineHeight: 1.12,
            marginBottom: 17,
          }}
        >
          {title}
        </div>
        {children}
      </div>
    </div>
  );
};

export const MonoRow: React.FC<{
  label: string;
  value: string;
  color?: string;
  muted?: boolean;
}> = ({label, value, color = colors.paper, muted = false}) => (
  <div
    style={{
      display: "grid",
      gridTemplateColumns: "128px 1fr",
      gap: 18,
      alignItems: "baseline",
      borderTop: `1px solid ${colors.line}aa`,
      padding: "10px 0",
      fontFamily: FONT_MONO,
      fontSize: 18,
      lineHeight: 1.35,
      opacity: muted ? 0.54 : 1,
    }}
  >
    <span style={{color: colors.muted}}>{label}</span>
    <span style={{color}}>{value}</span>
  </div>
);

export const CodeLine: React.FC<{
  children: ReactNode;
  color?: string;
  indent?: number;
}> = ({children, color = colors.paper, indent = 0}) => (
  <div
    style={{
      color,
      fontFamily: FONT_MONO,
      fontSize: 20,
      lineHeight: 1.45,
      paddingLeft: indent,
      whiteSpace: "normal",
    }}
  >
    {children}
  </div>
);

export const StatusPill: React.FC<{
  children: ReactNode;
  color: string;
}> = ({children, color}) => (
  <span
    style={{
      display: "inline-flex",
      alignItems: "center",
      border: `1px solid ${color}70`,
      borderRadius: 999,
      background: `${color}15`,
      color,
      fontFamily: FONT_MONO,
      fontSize: 15,
      fontWeight: 500,
      padding: "6px 10px",
    }}
  >
    {children}
  </span>
);
