import type { CSSProperties, ReactNode } from "react";
import { AbsoluteFill, interpolate, spring } from "remotion";

export const palette = {
  ink: "#07111f",
  panel: "#0b1728",
  text: "#f8fbff",
  muted: "#94a9c4",
  cyan: "#38d8ff",
  blue: "#2f8cff",
  green: "#36d399",
  amber: "#ffb84d",
  red: "#ff5f6d",
};

export const phases = [
  { label: "SPEC", command: "/agtoosa-spec", proof: "INTENT LOCKED", color: palette.blue, icon: "◆" },
  { label: "BUILD", command: "/agtoosa-build", proof: "TESTS GREEN", color: palette.green, icon: "⌘" },
  { label: "REVIEW", command: "/agtoosa-review", proof: "RISKS CHECKED", color: palette.amber, icon: "◎" },
  { label: "SHIP", command: "/agtoosa-ship", proof: "PROOF READY", color: palette.red, icon: "↗" },
];

export const clamp = {
  extrapolateLeft: "clamp" as const,
  extrapolateRight: "clamp" as const,
};

export const fade = (
  frame: number,
  enter: [number, number],
  exit?: [number, number],
) => {
  const fadeIn = interpolate(frame, enter, [0, 1], clamp);
  if (!exit) return fadeIn;
  return fadeIn * interpolate(frame, exit, [1, 0], clamp);
};

export const rise = (
  frame: number,
  fps: number,
  delay: number,
  distance = 36,
) => {
  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping: 18, stiffness: 120, mass: 0.8 },
  });
  return {
    opacity: progress,
    transform: `translateY(${(1 - progress) * distance}px)`,
  };
};

export const glass: CSSProperties = {
  background: "linear-gradient(145deg, rgba(20,39,64,.92), rgba(8,20,36,.88))",
  border: "1px solid rgba(148, 188, 224, .18)",
  boxShadow: "0 24px 80px rgba(0, 0, 0, .32), inset 0 1px rgba(255,255,255,.04)",
  backdropFilter: "blur(20px)",
};

export const Mark = ({ size = 72 }: { size?: number }) => (
  <div
    style={{
      width: size,
      height: size,
      display: "grid",
      placeItems: "center",
      position: "relative",
      filter: "drop-shadow(0 0 28px rgba(56,216,255,.3))",
    }}
  >
    <svg width={size} height={size} viewBox="0 0 72 72">
      <path
        d="M36 5 62 20v32L36 67 10 52V20L36 5Z"
        fill="rgba(47,140,255,.14)"
        stroke="#38d8ff"
        strokeWidth="2.5"
      />
      <path
        d="m24 39 9 9 17-23"
        fill="none"
        stroke="#f8fbff"
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth="5"
      />
      <circle cx="36" cy="36" r="4" fill="#38d8ff" />
    </svg>
  </div>
);

export const Ambient = ({ frame }: { frame: number }) => {
  const drift = Math.sin(frame / 30) * 34;
  const driftTwo = Math.cos(frame / 38) * 38;
  return (
    <AbsoluteFill style={{ overflow: "hidden", background: palette.ink }}>
      <div
        style={{
          position: "absolute",
          inset: "-40%",
          transform: `translate(${drift}px, ${driftTwo}px) rotate(${frame / 20}deg)`,
          background:
            "conic-gradient(from 90deg at 50% 50%, rgba(47,140,255,.12), transparent 24%, rgba(54,211,153,.09), transparent 58%, rgba(255,95,109,.08), transparent 82%)",
        }}
      />
      <div
        style={{
          position: "absolute",
          inset: 0,
          opacity: 0.2,
          backgroundImage:
            "linear-gradient(rgba(122,172,217,.14) 1px, transparent 1px), linear-gradient(90deg, rgba(122,172,217,.14) 1px, transparent 1px)",
          backgroundSize: "64px 64px",
          transform: `perspective(700px) rotateX(62deg) translateY(${190 + (frame % 64)}px) scale(1.7)`,
          transformOrigin: "center bottom",
          maskImage: "linear-gradient(to top, black, transparent 72%)",
        }}
      />
      {Array.from({ length: 18 }).map((_, index) => {
        const x = (index * 83 + frame * (0.34 + (index % 3) * 0.11)) % 1500;
        const y = (index * 137 + Math.sin(frame / 19 + index) * 34) % 810;
        return (
          <div
            key={index}
            style={{
              position: "absolute",
              left: x,
              top: y,
              width: index % 4 === 0 ? 5 : 3,
              height: index % 4 === 0 ? 5 : 3,
              borderRadius: "50%",
              background: index % 3 === 0 ? palette.cyan : "#7aa8d1",
              opacity: 0.28 + (index % 4) * 0.1,
              boxShadow: `0 0 16px ${palette.cyan}`,
            }}
          />
        );
      })}
      <div
        style={{
          position: "absolute",
          inset: 0,
          boxShadow: "inset 0 0 180px rgba(0,0,0,.6)",
        }}
      />
    </AbsoluteFill>
  );
};

export const Eyebrow = ({ children }: { children: ReactNode }) => (
  <div
    style={{
      color: palette.cyan,
      fontSize: 22,
      fontWeight: 800,
      letterSpacing: 5,
      textTransform: "uppercase",
    }}
  >
    {children}
  </div>
);
