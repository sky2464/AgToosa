import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

const phases = [
  { label: "Spec", color: "#0284c7" },
  { label: "Build", color: "#059669" },
  { label: "Review", color: "#d97706" },
  { label: "Ship", color: "#dc2626" },
];

export const Hero: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleOpacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        background: "linear-gradient(135deg, #312e81 0%, #1e3a5f 50%, #0e7490 100%)",
        fontFamily: "ui-sans-serif, system-ui, sans-serif",
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "radial-gradient(circle at 50% 30%, rgba(34,211,238,0.15), transparent 60%)",
        }}
      />
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          height: "100%",
          opacity: titleOpacity,
        }}
      >
        <div style={{ fontSize: 42, fontWeight: 800, color: "#e0e7ff" }}>
          AgToosa
        </div>
        <div style={{ fontSize: 16, color: "#94a3b8", marginTop: 8 }}>
          Spec → Build → Review → Ship
        </div>
        <div
          style={{
            display: "flex",
            gap: 24,
            marginTop: 48,
          }}
        >
          {phases.map((phase, i) => {
            const delay = i * 12;
            const scale = spring({
              frame: frame - delay,
              fps,
              config: { damping: 14, stiffness: 120 },
            });
            const glow = interpolate(
              frame,
              [delay, delay + 30, delay + 60],
              [0.5, 1, 0.7],
              { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
            );
            return (
              <div
                key={phase.label}
                style={{
                  width: 120,
                  height: 56,
                  borderRadius: 12,
                  background: phase.color,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  color: "#fff",
                  fontWeight: 700,
                  fontSize: 16,
                  transform: `scale(${scale})`,
                  opacity: glow,
                  boxShadow: `0 0 24px ${phase.color}55`,
                }}
              >
                {phase.label}
              </div>
            );
          })}
        </div>
        <div
          style={{
            marginTop: 56,
            padding: "10px 20px",
            background: "rgba(15,23,42,0.85)",
            borderRadius: 8,
            fontFamily: "ui-monospace, monospace",
            fontSize: 15,
            color: "#22d3ee",
          }}
        >
          /agtoosa-spec → spec.md ✓
        </div>
        <div
          style={{
            marginTop: 32,
            fontSize: 17,
            fontWeight: 600,
            color: "#cbd5e1",
            opacity: interpolate(frame, [120, 150], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
          }}
        >
          Verify. Don't trust the chat.
        </div>
      </div>
    </AbsoluteFill>
  );
};
