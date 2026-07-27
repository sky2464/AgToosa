import { AbsoluteFill, interpolate, spring } from "remotion";
import { clamp, Eyebrow, fade, glass, Mark, palette, rise } from "./Design";

export const IntroScene = ({ frame, fps }: { frame: number; fps: number }) => {
  const opacity = fade(frame, [0, 18], [112, 140]);
  const mark = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 92, mass: 0.8 },
  });
  const bubbleOne = rise(frame, fps, 30, 28);
  const bubbleTwo = rise(frame, fps, 52, 28);
  const introGlow = interpolate(frame, [0, 18, 62, 112], [0, 1, 0.55, 0.2], clamp);

  return (
    <AbsoluteFill style={{ opacity }}>
      <div
        style={{
          position: "absolute",
          left: 60,
          bottom: 30,
          color: palette.text,
          fontSize: 170,
          fontWeight: 950,
          letterSpacing: -10,
          opacity: 0.025,
        }}
      >
        AGTOOSA
      </div>
      <div
        style={{
          position: "absolute",
          left: 120,
          top: 152,
          transform: `scale(${mark}) rotate(${(1 - mark) * -12}deg)`,
          filter: `drop-shadow(0 0 ${25 + introGlow * 55}px rgba(56,216,255,.45))`,
        }}
      >
        <div
          style={{
            position: "absolute",
            inset: -34,
            borderRadius: "50%",
            border: "1px solid rgba(56,216,255,.25)",
            transform: `rotate(${frame * 1.4}deg) scale(${0.86 + introGlow * 0.14})`,
          }}
        />
        <Mark size={116} />
      </div>
      <div style={{ position: "absolute", left: 276, top: 146 }}>
        <div style={{ ...rise(frame, fps, 12), display: "flex", gap: 18 }}>
          <Eyebrow>Repo-native control plane</Eyebrow>
          <span
            style={{
              color: palette.green,
              fontSize: 18,
              fontWeight: 800,
              padding: "5px 12px",
              borderRadius: 99,
              background: "rgba(54,211,153,.12)",
              border: "1px solid rgba(54,211,153,.35)",
            }}
          >
            v5.3.35
          </span>
        </div>
        <div
          style={{
            ...rise(frame, fps, 18),
            marginTop: 22,
            color: palette.text,
            fontSize: 88,
            lineHeight: 0.95,
            fontWeight: 900,
            letterSpacing: -5,
            textShadow: `0 0 ${introGlow * 34}px rgba(56,216,255,.3)`,
          }}
        >
          AI development.
          <br />
          <span
            style={{
              background: "linear-gradient(90deg, #fff, #8fe9ff)",
              WebkitBackgroundClip: "text",
              color: "transparent",
            }}
          >
            With receipts.
          </span>
        </div>
        <div
          style={{
            ...rise(frame, fps, 32),
            color: palette.muted,
            fontSize: 27,
            lineHeight: 1.45,
            marginTop: 30,
          }}
        >
          Turn your coding assistant into a disciplined,
          <br />
          security-aware development team.
        </div>
      </div>
      <div
        style={{
          ...bubbleOne,
          ...glass,
          position: "absolute",
          right: 105,
          top: 106,
          borderRadius: 18,
          padding: "16px 22px",
          color: palette.muted,
          fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
          fontSize: 18,
        }}
      >
        “Looks done.”
      </div>
      <div
        style={{
          ...bubbleTwo,
          ...glass,
          position: "absolute",
          right: 105,
          bottom: 130,
          borderRadius: 18,
          padding: "18px 24px",
          color: palette.green,
          fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
          fontWeight: 700,
          fontSize: 19,
        }}
      >
        ✓ Evidence says done.
      </div>
      <div
        style={{
          ...rise(frame, fps, 72),
          ...glass,
          position: "absolute",
          left: 276,
          bottom: 68,
          padding: "11px 18px",
          borderRadius: 9,
          color: palette.text,
          fontSize: 15,
          fontWeight: 850,
          letterSpacing: 2.4,
        }}
      >
        CONTROL THE CHAOS <span style={{ color: palette.cyan }}>//</span> PROVE THE WORK
      </div>
      <div
        style={{
          position: "absolute",
          right: 106,
          bottom: 68,
          color: palette.muted,
          fontSize: 14,
          letterSpacing: 1.8,
          opacity: 0.62,
        }}
      >
        A SOLUTION BY <span style={{ color: palette.text, fontWeight: 800 }}>ATOOSA DEV</span>
      </div>
    </AbsoluteFill>
  );
};

export const FinalScene = ({ frame, fps }: { frame: number; fps: number }) => {
  const opacity = fade(frame, [520, 548], [640, 659]);
  const mark = spring({
    frame: frame - 535,
    fps,
    config: { damping: 14, stiffness: 105 },
  });
  const pulse = 1 + Math.sin((frame - 540) / 11) * 0.025;
  const ctaPulse =
    1 +
    Math.sin(Math.max(0, frame - 575) / 7) *
      interpolate(frame, [575, 590, 640], [0, 0.035, 0.018], clamp);
  return (
    <AbsoluteFill
      style={{
        opacity,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
      }}
    >
      <div
        style={{
          position: "absolute",
          color: palette.text,
          fontSize: 260,
          fontWeight: 950,
          letterSpacing: 22,
          opacity: 0.025,
          transform: `translateY(${Math.sin(frame / 16) * 8}px)`,
        }}
      >
        PROOF
      </div>
      {[0, 1, 2].map((ring) => (
        <div
          key={ring}
          style={{
            position: "absolute",
            left: "50%",
            top: 194,
            width: 120 + ring * 65,
            height: 120 + ring * 65,
            borderRadius: "50%",
            border: "1px solid rgba(56,216,255,.16)",
            opacity: mark * (0.55 - ring * 0.13),
            transform: `translate(-50%, -50%) rotate(${frame * (ring % 2 === 0 ? 0.8 : -0.6)}deg)`,
          }}
        />
      ))}
      <div style={{ transform: `scale(${mark * pulse})` }}>
        <Mark size={104} />
      </div>
      <div
        style={{
          ...rise(frame, fps, 545),
          color: palette.text,
          fontSize: 82,
          fontWeight: 950,
          letterSpacing: -4,
          marginTop: 18,
        }}
      >
        AgToosa
      </div>
      <div
        style={{
          ...rise(frame, fps, 555),
          color: palette.muted,
          fontSize: 29,
          marginTop: 8,
        }}
      >
        Spec-driven AI development that proves its work.
      </div>
      <div
        style={{
          ...rise(frame, fps, 575),
          display: "flex",
          alignItems: "center",
          gap: 18,
          marginTop: 44,
          padding: "17px 26px",
          borderRadius: 16,
          color: palette.text,
          fontSize: 21,
          fontWeight: 800,
          background: "linear-gradient(100deg, #2478ff, #00a9cf)",
          boxShadow: "0 18px 70px rgba(47,140,255,.48), inset 0 1px rgba(255,255,255,.35)",
          transform: `${rise(frame, fps, 575).transform} scale(${ctaPulse})`,
        }}
      >
        Start the 15-minute proof
        <span style={{ fontSize: 28 }}>→</span>
      </div>
      <div
        style={{
          ...rise(frame, fps, 590),
          color: palette.cyan,
          fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
          fontSize: 18,
          marginTop: 28,
        }}
      >
        github.com/sky2464/AgToosa
      </div>
      <div
        style={{
          ...rise(frame, fps, 602),
          color: palette.muted,
          fontSize: 13,
          letterSpacing: 2,
          marginTop: 14,
        }}
      >
        A SOLUTION BY <span style={{ color: palette.text, fontWeight: 800 }}>ATOOSA DEV</span>
      </div>
    </AbsoluteFill>
  );
};
