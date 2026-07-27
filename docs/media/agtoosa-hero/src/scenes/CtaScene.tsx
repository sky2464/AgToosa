import React from "react";
import {AbsoluteFill, interpolate, useCurrentFrame} from "remotion";
import {BrandCredit, Wordmark} from "../Brand";
import {FilmBackground} from "../FilmBackground";
import {
  colors,
  FONT_MONO,
  FONT_SANS,
  progress,
} from "../theme";
export const CtaScene: React.FC = () => {
  const frame = useCurrentFrame();
  const reveal = progress(frame, 10, 30);
  const ctaIn = progress(frame, 25, 24);
  const creditIn = progress(frame, 64, 20);
  const fadeOut = interpolate(frame, [118, 135], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const bloom = progress(frame, 48, 55);

  return (
    <AbsoluteFill style={{opacity: fadeOut}}>
      <FilmBackground frame={frame + 1190} coolShift={14} />
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: "48%",
          width: 720 + bloom * 110,
          height: 420 + bloom * 90,
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(34,211,238,.13), rgba(139,92,246,.055) 42%, transparent 70%)",
          filter: "blur(22px)",
          opacity: bloom,
          transform: "translate(-50%, -50%)",
        }}
      />
      <div
        style={{
          position: "absolute",
          inset: 0,
          alignItems: "center",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          opacity: reveal,
          transform: `translateY(${(1 - reveal) * 22}px)`,
        }}
      >
        <Wordmark frame={frame} start={8} align="center" />
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_SANS,
            fontSize: 36,
            fontWeight: 620,
            letterSpacing: "-0.028em",
            marginTop: 39,
            opacity: ctaIn,
          }}
        >
          One command.{" "}
          <span style={{color: colors.cyan}}>The right phase.</span>
        </div>
        <div
          style={{
            alignItems: "center",
            display: "flex",
            gap: 14,
            marginTop: 22,
            opacity: ctaIn,
          }}
        >
          {["/agtoosa-init", "/agtoosa-next"].map((command) => (
            <span
              key={command}
              style={{
                border: `1px solid ${colors.line}`,
                borderRadius: 999,
                color: colors.paper,
                fontFamily: FONT_MONO,
                fontSize: 15,
                padding: "10px 16px",
              }}
            >
              {command}
            </span>
          ))}
        </div>
        <div
          style={{
            color: colors.cyan,
            fontFamily: FONT_MONO,
            fontSize: 12,
            letterSpacing: "0.14em",
            marginTop: 19,
            opacity: ctaIn,
          }}
        >
          START THE 15-MINUTE PROOF
        </div>
        <div
          style={{
            border: `1px solid ${colors.line}`,
            borderRadius: 999,
            color: colors.muted,
            fontFamily: FONT_MONO,
            fontSize: 16,
            marginTop: 8,
            opacity: ctaIn,
            padding: "10px 17px",
          }}
        >
          github.com/sky2464/AgToosa
        </div>
        <div style={{marginTop: 28, opacity: creditIn}}>
          <BrandCredit />
        </div>
      </div>
    </AbsoluteFill>
  );
};
