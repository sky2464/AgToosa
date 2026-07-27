import React from "react";
import {ArtifactCard, StatusPill} from "./ArtifactCard";
import {ProofGlyph} from "./Brand";
import {ProofThread, ThreadPoint} from "./ProofThread";
import {colors, FONT_MONO, FONT_SANS, progress} from "./theme";

type RepositoryGraphProps = {
  frame: number;
  start?: number;
};

const proofNodes: ThreadPoint[] = [
  {x: 160, y: 240, label: "APPROVED SPEC", color: colors.spec},
  {x: 390, y: 108, label: "AC → TEST", color: colors.build},
  {x: 650, y: 240, label: "RED / GREEN", color: colors.build},
  {x: 510, y: 455, label: "REVIEW", color: colors.review},
  {x: 230, y: 458, label: "VERIFY", color: colors.ship},
  {x: 160, y: 240, color: colors.spec},
];

export const RepositoryGraph: React.FC<RepositoryGraphProps> = ({
  frame,
  start = 0,
}) => {
  const reveal = progress(frame, start, 36);
  const labels = progress(frame, start + 30, 28);
  return (
    <div
      style={{
        position: "relative",
        width: 810,
        height: 560,
        opacity: reveal,
        transform: `scale(${0.9 + reveal * 0.1})`,
      }}
    >
      <ProofThread
        frame={frame}
        start={start + 2}
        duration={62}
        width={810}
        height={560}
        points={proofNodes}
        showLabels
      />
      <div
        style={{
          position: "absolute",
          left: 328,
          top: 212,
          width: 160,
          height: 136,
          borderRadius: 24,
          border: `1px solid ${colors.cyan}72`,
          background:
            "radial-gradient(circle at 50% 35%, rgba(34,211,238,.16), rgba(11,16,32,.97) 68%)",
          boxShadow: "0 24px 80px rgba(0,0,0,.46)",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <ProofGlyph frame={frame} start={start + 8} size={72} muted />
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 18,
            fontWeight: 720,
            marginTop: -5,
          }}
        >
          repository
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 235,
          bottom: 2,
          display: "flex",
          gap: 9,
          opacity: labels,
        }}
      >
        <StatusPill color={colors.cyan}>repo-native</StatusPill>
        <StatusPill color={colors.success}>inspectable evidence</StatusPill>
      </div>
    </div>
  );
};

const adapters = [
  "Cursor",
  "Claude Code",
  "Copilot",
  "Windsurf",
  "Codex",
  "Gemini CLI",
];

export const AdapterPanel: React.FC<{frame: number; start?: number}> = ({
  frame,
  start = 0,
}) => (
  <ArtifactCard
    frame={frame}
    start={start}
    width={430}
    eyebrow="PLATFORM ADAPTERS"
    title="Assistant-neutral workflow"
    accent={colors.violet}
  >
    <div
      style={{
        display: "grid",
        gridTemplateColumns: "1fr 1fr",
        gap: 9,
      }}
    >
      {adapters.map((adapter, index) => {
        const visible = progress(frame, start + 14 + index * 3, 12);
        return (
          <div
            key={adapter}
            style={{
              border: `1px solid ${colors.line}`,
              borderRadius: 9,
              color: colors.paper,
              fontFamily: FONT_MONO,
              fontSize: 13,
              padding: "10px 11px",
              opacity: visible,
              transform: `translateX(${(1 - visible) * 10}px)`,
            }}
          >
            <span style={{color: colors.violet, marginRight: 7}}>◆</span>
            {adapter}
          </div>
        );
      })}
    </div>
    <div
      style={{
        borderTop: `1px solid ${colors.line}`,
        color: colors.muted,
        fontFamily: FONT_MONO,
        fontSize: 13,
        lineHeight: 1.45,
        marginTop: 16,
        paddingTop: 14,
      }}
    >
      No target-app runtime. No SDK to link.
    </div>
  </ArtifactCard>
);
