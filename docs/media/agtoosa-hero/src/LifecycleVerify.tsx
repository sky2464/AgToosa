import type { ReactNode } from "react";
import { AbsoluteFill, Easing, interpolate, spring } from "remotion";
import {
  clamp,
  Eyebrow,
  fade,
  glass,
  palette,
  phases,
  rise,
} from "./Design";

const PhaseCard = ({
  phase,
  index,
  frame,
  fps,
}: {
  phase: (typeof phases)[number];
  index: number;
  frame: number;
  fps: number;
}) => {
  const delay = 150 + index * 45;
  const entrance = spring({
    frame: frame - delay,
    fps,
    config: { damping: 16, stiffness: 110, mass: 0.7 },
  });
  const active = interpolate(
    frame,
    [delay + 7, delay + 18, delay + 38, delay + 58],
    [0, 1, 0.18, 0],
    clamp,
  );
  const complete = interpolate(frame, [delay + 14, delay + 28], [0, 1], clamp);
  return (
    <div
      style={{
        ...glass,
        width: 268,
        height: 210,
        borderRadius: 24,
        padding: "28px 26px",
        boxSizing: "border-box",
        position: "relative",
        overflow: "hidden",
        opacity: entrance,
        transform: `translateY(${(1 - entrance) * 48 - active * 7}px) scale(${0.9 + entrance * 0.1 + active * 0.045}) rotateX(${(1 - entrance) * 10}deg)`,
        borderColor: `color-mix(in srgb, ${phase.color} ${24 + active * 45}%, transparent)`,
        boxShadow: `0 25px 70px rgba(0,0,0,.3), 0 0 ${18 + active * 34}px color-mix(in srgb, ${phase.color} ${active * 32}%, transparent)`,
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: `radial-gradient(circle at 18% 10%, color-mix(in srgb, ${phase.color} ${10 + active * 20}%, transparent), transparent 55%)`,
        }}
      />
      <div
        style={{
          width: 54,
          height: 54,
          display: "grid",
          placeItems: "center",
          borderRadius: 16,
          color: phase.color,
          background: `color-mix(in srgb, ${phase.color} 14%, transparent)`,
          border: `1px solid color-mix(in srgb, ${phase.color} 36%, transparent)`,
          fontSize: 27,
          fontWeight: 900,
          position: "relative",
        }}
      >
        {phase.icon}
      </div>
      <div
        style={{
          position: "absolute",
          right: 20,
          top: 20,
          width: 28,
          height: 28,
          display: "grid",
          placeItems: "center",
          borderRadius: "50%",
          color: palette.ink,
          background: phase.color,
          fontWeight: 950,
          fontSize: 15,
          opacity: complete * 0.72 + active * 0.28,
          transform: `scale(${0.55 + complete * 0.35 + active * 0.1})`,
          boxShadow: `0 0 24px ${phase.color}`,
        }}
      >
        ✓
      </div>
      <div
        style={{
          position: "relative",
          color: palette.text,
          fontSize: 30,
          fontWeight: 900,
          letterSpacing: 1.5,
          marginTop: 24,
        }}
      >
        {phase.label}
      </div>
      <div
        style={{
          position: "relative",
          color: palette.muted,
          fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
          fontSize: 16,
          marginTop: 8,
        }}
      >
        {phase.command}
      </div>
      <div
        style={{
          position: "absolute",
          right: 20,
          bottom: 16,
          color: phase.color,
          fontSize: 11,
          fontWeight: 900,
          letterSpacing: 1.5,
          opacity: 0.65 + complete * 0.35,
        }}
      >
        {phase.proof}
      </div>
    </div>
  );
};

export const LifecycleScene = ({
  frame,
  fps,
}: {
  frame: number;
  fps: number;
}) => {
  const opacity = fade(frame, [112, 138], [380, 405]);
  const progress = interpolate(frame, [155, 335], [0, 1], {
    ...clamp,
    easing: Easing.inOut(Easing.cubic),
  });
  const tokenBob = Math.sin(frame / 5) * 5;

  return (
    <AbsoluteFill style={{ opacity, padding: "74px 92px", boxSizing: "border-box" }}>
      <div style={{ ...rise(frame, fps, 122), textAlign: "center" }}>
        <Eyebrow>One disciplined path</Eyebrow>
        <div
          style={{
            color: palette.text,
            fontSize: 54,
            fontWeight: 900,
            letterSpacing: -2,
            marginTop: 11,
          }}
        >
          From intent to shipped evidence.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 273,
          right: 273,
          top: 235,
          height: 4,
          borderRadius: 20,
          background: "rgba(122,168,209,.15)",
          overflow: "hidden",
        }}
      >
        <div
          style={{
            width: `${progress * 100}%`,
            height: "100%",
            background: "linear-gradient(90deg, #2f8cff, #36d399, #ffb84d, #ff5f6d)",
            boxShadow: `0 0 24px ${palette.cyan}`,
          }}
        />
      </div>
      <div
        style={{
          display: "flex",
          gap: 30,
          justifyContent: "center",
          marginTop: 68,
        }}
      >
        {phases.map((phase, index) => (
          <PhaseCard
            key={phase.label}
            phase={phase}
            index={index}
            frame={frame}
            fps={fps}
          />
        ))}
      </div>
      <div
        style={{
          position: "absolute",
          left: 273 + progress * 894,
          top: 212 + tokenBob,
          width: 46,
          height: 46,
          borderRadius: 14,
          background: "#f8fbff",
          color: palette.ink,
          display: "grid",
          placeItems: "center",
          fontSize: 22,
          fontWeight: 900,
          transform: "translateX(-50%) rotate(45deg)",
          boxShadow: "0 0 0 7px rgba(56,216,255,.12), 0 0 30px rgba(56,216,255,.8)",
        }}
      >
        <span style={{ transform: "rotate(-45deg)" }}>✓</span>
      </div>
      <div
        style={{
          ...glass,
          position: "absolute",
          bottom: 58,
          left: "50%",
          transform: "translateX(-50%)",
          padding: "13px 24px",
          borderRadius: 99,
          color: palette.muted,
          fontSize: 19,
        }}
      >
        <span style={{ color: palette.cyan, fontWeight: 800 }}>Any assistant.</span>
        {" "}One repo-native workflow.
      </div>
    </AbsoluteFill>
  );
};

export const VerifyScene = ({ frame, fps }: { frame: number; fps: number }) => {
  const opacity = fade(frame, [380, 405], [520, 545]);
  const card = rise(frame, fps, 395, 34);
  const lineOne = interpolate(frame, [420, 430], [0, 1], clamp);
  const lineTwo = interpolate(frame, [450, 460], [0, 1], clamp);
  const lineThree = interpolate(frame, [480, 490], [0, 1], clamp);
  const pass = spring({
    frame: frame - 500,
    fps,
    config: { damping: 13, stiffness: 125 },
  });
  const verifyProgress = interpolate(frame, [405, 500], [0, 1], clamp);

  const TerminalLine = ({
    opacity: lineOpacity,
    children,
    color = palette.muted,
  }: {
    opacity: number;
    children: ReactNode;
    color?: string;
  }) => (
    <div style={{ opacity: lineOpacity, color, marginTop: 16 }}>
      {children}
    </div>
  );

  return (
    <AbsoluteFill style={{ opacity }}>
      <div style={{ position: "absolute", left: 105, top: 130 }}>
        <div style={rise(frame, fps, 390)}>
          <Eyebrow>Trust, but verify</Eyebrow>
          <div
            style={{
              color: palette.text,
              fontSize: 60,
              lineHeight: 1.03,
              fontWeight: 900,
              letterSpacing: -3,
              marginTop: 18,
              maxWidth: 520,
            }}
          >
            Machine checks.
            <br />
            Human confidence.
          </div>
          <div
            style={{
              color: palette.muted,
              fontSize: 25,
              lineHeight: 1.5,
              marginTop: 28,
              maxWidth: 500,
            }}
          >
            Approved specs, EARS acceptance criteria,
            threat models, and TDD evidence.
          </div>
          <div style={{ display: "flex", gap: 10, marginTop: 34 }}>
            {["VERIFIED", "REPRODUCIBLE", "EXIT 0"].map((label, index) => (
              <div
                key={label}
                style={{
                  padding: "8px 10px",
                  borderRadius: 7,
                  color: index === 2 ? palette.green : palette.cyan,
                  background: "rgba(56,216,255,.07)",
                  border: "1px solid rgba(56,216,255,.2)",
                  fontSize: 11,
                  fontWeight: 900,
                  letterSpacing: 1.2,
                  opacity: interpolate(frame, [430 + index * 22, 440 + index * 22], [0, 1], clamp),
                }}
              >
                {label}
              </div>
            ))}
          </div>
        </div>
      </div>
      <div
        style={{
          ...card,
          ...glass,
          position: "absolute",
          right: 94,
          top: 126,
          width: 680,
          height: 500,
          borderRadius: 28,
          overflow: "hidden",
        }}
      >
        <div
          style={{
            height: 58,
            display: "flex",
            alignItems: "center",
            gap: 11,
            padding: "0 23px",
            background: "rgba(4,11,20,.65)",
            borderBottom: "1px solid rgba(148,188,224,.13)",
          }}
        >
          {["#ff5f6d", "#ffb84d", "#36d399"].map((color) => (
            <div
              key={color}
              style={{ width: 13, height: 13, borderRadius: "50%", background: color }}
            />
          ))}
          <div style={{ color: palette.muted, fontSize: 15, marginLeft: 12 }}>
            deterministic-verifier
          </div>
        </div>
        <div
          style={{
            position: "absolute",
            left: 0,
            top: 57,
            width: `${verifyProgress * 100}%`,
            height: 3,
            background: "linear-gradient(90deg, #2f8cff, #38d8ff, #36d399)",
            boxShadow: `0 0 18px ${palette.cyan}`,
          }}
        />
        <div
          style={{
            padding: "32px 38px",
            fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
            fontSize: 20,
            lineHeight: 1.4,
          }}
        >
          <div style={{ color: palette.cyan }}>
            $ bash Docs/agtoosa-verify.sh
          </div>
          <TerminalLine opacity={lineOne}>
            <span style={{ color: palette.green }}>✓</span> Spec approval + EARS criteria
          </TerminalLine>
          <TerminalLine opacity={lineTwo}>
            <span style={{ color: palette.green }}>✓</span> Threat model + AC → test map
          </TerminalLine>
          <TerminalLine opacity={lineThree}>
            <span style={{ color: palette.green }}>✓</span> TDD evidence + lifecycle state
          </TerminalLine>
          <div
            style={{
              marginTop: 30,
              padding: "20px 24px",
              borderRadius: 16,
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              background: "rgba(54,211,153,.09)",
              border: "1px solid rgba(54,211,153,.28)",
              opacity: pass,
              transform: `scale(${0.92 + pass * 0.08})`,
              boxShadow: `0 0 ${pass * 42}px rgba(54,211,153,.22)`,
            }}
          >
            <span style={{ color: palette.green, fontWeight: 800 }}>
              ALL GATES PASS
            </span>
            <span style={{ color: palette.text }}>exit 0</span>
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};
