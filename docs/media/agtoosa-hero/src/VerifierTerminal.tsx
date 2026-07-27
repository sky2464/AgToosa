import React from "react";
import {colors, FONT_MONO, FONT_SANS, progress} from "./theme";

type VerifierTerminalProps = {
  frame: number;
  start?: number;
  timingScale?: number;
  readable?: boolean;
};

const gates = [
  "Gate 1 — Context files",
  "Gate 2 — Master-Plan integrity",
  "Gate 3 — Spec approval and naming",
  "Gate 4 — Review artifacts",
  "Gate 5 — Version parity",
];

export const VerifierTerminal: React.FC<VerifierTerminalProps> = ({
  frame,
  start = 0,
  timingScale = 1,
  readable = false,
}) => {
  const terminalIn = progress(frame, start, 20 * timingScale);
  const commandIn = progress(
    frame,
    start + 12 * timingScale,
    12 * timingScale,
  );
  const resultIn = progress(
    frame,
    start + 88 * timingScale,
    12 * timingScale,
  );

  return (
    <div
      style={{
        width: readable ? 1120 : 940,
        border: `1px solid ${colors.cyan}4d`,
        borderRadius: 22,
        background:
          "linear-gradient(155deg, rgba(11,16,32,.99), rgba(4,7,14,.99))",
        boxShadow:
          resultIn > 0
            ? `0 34px 110px rgba(0,0,0,.52), 0 0 ${42 * resultIn}px rgba(52,211,153,.16)`
            : "0 34px 110px rgba(0,0,0,.52)",
        opacity: terminalIn,
        overflow: "hidden",
        transform: `translateY(${(1 - terminalIn) * 24}px)`,
      }}
    >
      <div
        style={{
          alignItems: "center",
          borderBottom: `1px solid ${colors.line}`,
          display: "flex",
          justifyContent: "space-between",
          padding: "14px 18px",
        }}
      >
        <div style={{display: "flex", gap: 8}}>
          {[colors.danger, colors.warning, colors.success].map((color) => (
            <span
              key={color}
              style={{width: 9, height: 9, borderRadius: "50%", background: color}}
            />
          ))}
        </div>
        <div
          style={{
            color: colors.muted,
            fontFamily: FONT_MONO,
            fontSize: readable ? 22 : 13,
            fontWeight: readable ? 500 : undefined,
          }}
        >
          verified repository run
        </div>
        <div style={{width: 43}} />
      </div>
      <div style={{padding: "24px 28px 26px"}}>
        <div
          style={{
            color: colors.paper,
            fontFamily: FONT_MONO,
            fontSize: readable ? 28 : 19,
            fontWeight: readable ? 500 : undefined,
            marginBottom: 18,
            opacity: commandIn,
          }}
        >
          <span style={{color: colors.cyan}}>$</span>{" "}
          bash Docs/agtoosa-verify.sh
        </div>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: "9px 26px",
          }}
        >
          {gates.map((gate, index) => {
            const gateIn = progress(
              frame,
              start + (30 + index * 8) * timingScale,
              10 * timingScale,
            );
            return (
              <div
                key={gate}
                style={{
                  alignItems: "center",
                  color: colors.muted,
                  display: "flex",
                  fontFamily: FONT_MONO,
                  fontSize: readable ? 24 : 14,
                  fontWeight: readable ? 500 : undefined,
                  gap: 10,
                  opacity: gateIn,
                }}
              >
                <span style={{color: colors.line}}>›</span>
                {gate}
              </div>
            );
          })}
        </div>
        <div
          style={{
            color: colors.muted,
            fontFamily: FONT_MONO,
            fontSize: readable ? 24 : 13,
            fontWeight: readable ? 500 : undefined,
            marginTop: 18,
            opacity: resultIn,
          }}
        >
          Verifier summary: 6 pass · 1 warn · 0 fail
        </div>
        <div
          style={{
            alignItems: "center",
            borderTop: `1px solid ${colors.line}`,
            display: "flex",
            justifyContent: "space-between",
            marginTop: 10,
            paddingTop: 15,
            opacity: resultIn,
          }}
        >
          <div
            style={{
              color: colors.success,
              fontFamily: FONT_SANS,
              fontSize: readable ? 42 : 29,
              fontWeight: 750,
              letterSpacing: "-0.02em",
            }}
          >
            Result: ✅ PASS
          </div>
          <div
            style={{
              border: `1px solid ${colors.success}60`,
              borderRadius: 999,
              color: colors.success,
              fontFamily: FONT_MONO,
              fontSize: readable ? 20 : 13,
              fontWeight: readable ? 500 : undefined,
              padding: "7px 11px",
            }}
          >
            exit code 0
          </div>
        </div>
      </div>
    </div>
  );
};
