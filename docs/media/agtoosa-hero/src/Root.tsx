import { Composition } from "remotion";
import { Hero } from "./Hero";
import {
  MarketingAnimatic,
  MarketingMaster,
  MarketingVisual,
} from "./MarketingMaster";
import { ReadmeLoop } from "./ReadmeLoop";
import { StoryboardContactSheet } from "./StoryboardContactSheet";
import timeline from "./timeline.json";
import { FILM_HEIGHT, FILM_WIDTH, FPS } from "./theme";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="MarketingMaster"
        component={MarketingMaster}
        durationInFrames={timeline.durationInFrames}
        fps={FPS}
        width={FILM_WIDTH}
        height={FILM_HEIGHT}
      />
      <Composition
        id="MarketingAnimatic"
        component={MarketingAnimatic}
        durationInFrames={timeline.durationInFrames}
        fps={FPS}
        width={FILM_WIDTH}
        height={FILM_HEIGHT}
      />
      <Composition
        id="MarketingStoryboard"
        component={MarketingVisual}
        durationInFrames={timeline.durationInFrames}
        fps={FPS}
        width={FILM_WIDTH}
        height={FILM_HEIGHT}
      />
      <Composition
        id="ReadmeLoop"
        component={ReadmeLoop}
        durationInFrames={timeline.readmeDurationInFrames}
        fps={FPS}
        width={FILM_WIDTH}
        height={FILM_HEIGHT}
      />
      <Composition
        id="StoryboardContactSheet"
        component={StoryboardContactSheet}
        durationInFrames={1}
        fps={FPS}
        width={1920}
        height={540}
      />
      <Composition
        id="Hero"
        component={Hero}
        durationInFrames={660}
        fps={30}
        width={1440}
        height={810}
      />
    </>
  );
};
