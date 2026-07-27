import {interpolate} from "remotion";

export const FILM_WIDTH = 1440;
export const FILM_HEIGHT = 810;
export const FPS = 30;
export const MASTER_FRAMES = 44 * FPS;
export const README_FRAMES = 24 * FPS;

export const FONT_SANS =
  '"Manrope Variable", Manrope, ui-sans-serif, system-ui, sans-serif';
export const FONT_MONO =
  '"IBM Plex Mono", ui-monospace, SFMono-Regular, Menlo, monospace';

export const colors = {
  ink: "#05070d",
  panel: "#0b1020",
  panelRaised: "#10182b",
  paper: "#f5f7fb",
  muted: "#a6b1c4",
  faint: "#53617a",
  line: "#26324a",
  cyan: "#22d3ee",
  violet: "#8b5cf6",
  spec: "#0284c7",
  build: "#059669",
  review: "#d97706",
  ship: "#dc2626",
  danger: "#fb7185",
  success: "#34d399",
  warning: "#fbbf24",
} as const;

export const clamp = (value: number) => Math.max(0, Math.min(1, value));

export const easeOutCubic = (value: number) => 1 - Math.pow(1 - value, 3);

export const easeInOutCubic = (value: number) =>
  value < 0.5
    ? 4 * value * value * value
    : 1 - Math.pow(-2 * value + 2, 3) / 2;

export const progress = (
  frame: number,
  start: number,
  duration: number,
  easing: (value: number) => number = easeOutCubic,
) => easing(clamp((frame - start) / Math.max(1, duration)));

export const fadeScene = (
  frame: number,
  duration: number,
  fadeIn = 15,
  fadeOut = 18,
) =>
  interpolate(
    frame,
    [0, fadeIn, duration - fadeOut, duration],
    [0, 1, 1, 0],
    {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    },
  );

export const lerp = (from: number, to: number, value: number) =>
  from + (to - from) * value;

export const frameToSeconds = (frame: number) => frame / FPS;
