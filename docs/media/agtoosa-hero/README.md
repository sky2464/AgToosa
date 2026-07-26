# AgToosa README Hero Assets

Hybrid motion package for the GitHub README hero.

## Files

| File | Purpose |
|------|---------|
| `lifecycle-accent.svg` | Animated SVG accent (works inline and as fallback) |
| `agtoosa-hero.gif` | Looped hero for README (`<img>`) |
| `agtoosa-hero-poster.png` | Static poster frame |
| `agtoosa-hero.webp` | Optional WebP loop export |
| `src/` | Remotion composition source |

## Regenerate (requires Node 18+)

```bash
cd docs/media/agtoosa-hero
npm install
npm run render:all
cp out/agtoosa-hero.gif out/agtoosa-hero-poster.png out/agtoosa-hero.webp .
```

Or render individually: `npm run render:gif`, `npm run render:png`.

## Design

- Palette: indigo → cyan gradient; phase pills match README mermaid colors
- 8s loop at 30fps (240 frames)
- Tagline: **Verify. Don't trust the chat.**
