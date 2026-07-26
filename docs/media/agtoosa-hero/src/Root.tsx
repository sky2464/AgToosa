import { Composition } from "remotion";
import { Hero } from "./Hero";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="Hero"
        component={Hero}
        durationInFrames={240}
        fps={30}
        width={720}
        height={405}
      />
    </>
  );
};
