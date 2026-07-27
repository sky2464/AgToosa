import React from "react";
import {AbsoluteFill, Sequence} from "remotion";
import {AudioDesign, AudioMode} from "./AudioDesign";
import {CtaScene} from "./scenes/CtaScene";
import {ProofMosaicScene} from "./scenes/ProofMosaicScene";
import {ReframeScene} from "./scenes/ReframeScene";
import {SystemRevealScene} from "./scenes/SystemRevealScene";
import {TensionScene} from "./scenes/TensionScene";
import {VerificationScene} from "./scenes/VerificationScene";
import timeline from "./timeline.json";
import {colors, FONT_SANS} from "./theme";

export const MarketingVisual: React.FC = () => {
  const scenes = timeline.scenes;
  return (
    <AbsoluteFill
      style={{
        background: colors.ink,
        fontFamily: FONT_SANS,
        overflow: "hidden",
      }}
    >
      <Sequence
        from={scenes.tension.from}
        durationInFrames={scenes.tension.duration}
        premountFor={30}
      >
        <TensionScene />
      </Sequence>
      <Sequence
        from={scenes.reframe.from}
        durationInFrames={scenes.reframe.duration}
        premountFor={30}
      >
        <ReframeScene />
      </Sequence>
      <Sequence
        from={scenes.proof.from}
        durationInFrames={scenes.proof.duration}
        premountFor={30}
      >
        <ProofMosaicScene />
      </Sequence>
      <Sequence
        from={scenes.system.from}
        durationInFrames={scenes.system.duration}
        premountFor={30}
      >
        <SystemRevealScene />
      </Sequence>
      <Sequence
        from={scenes.verify.from}
        durationInFrames={scenes.verify.duration}
        premountFor={30}
      >
        <VerificationScene />
      </Sequence>
      <Sequence
        from={scenes.cta.from}
        durationInFrames={scenes.cta.duration}
        premountFor={30}
      >
        <CtaScene />
      </Sequence>
    </AbsoluteFill>
  );
};

export const MarketingMaster: React.FC<{audioMode?: AudioMode}> = ({
  audioMode = "final",
}) => (
  <AbsoluteFill>
    <MarketingVisual />
    <AudioDesign mode={audioMode} />
  </AbsoluteFill>
);

export const MarketingAnimatic: React.FC = () => (
  <MarketingMaster audioMode="animatic" />
);
