# AgToosa Remotion Campaign

Cinematic, proof-led marketing motion for AgToosa. This package contains two
purpose-built deliverables plus review-only compositions:

| Composition | Duration | Purpose | Audio |
| --- | ---: | --- | --- |
| `MarketingMaster` | 44s | Licensed-score marketing film | Music + five cues |
| `ReadmeLoop` | 18s | Condensed cinematic README motion | Silent |
| `MarketingAnimatic` | 44s | Creative checkpoint | Low-fi guide score + five cues |
| `MarketingStoryboard` | 44s | Still-frame review | None |
| `StoryboardContactSheet` | 1 frame | Eight-shot overview | None |
| `Hero` | 22s | Legacy publication fallback | Legacy score + SFX |

The legacy `Hero` composition and the published `agtoosa-hero.*` assets remain
available until the creative-reset checkpoint is approved. New commands write
only to the versioned, gitignored path:

```text
out/candidates/creative-reset-v2/
```

## Creative system

- AgToosa is the primary brand at every stage.
- Directional workflow connectors start and end on visible node anchors. A
  traveling handoff point shows exactly where work moves next.
- Manrope and IBM Plex Mono are bundled through local Fontsource packages.
- Canonical lifecycle colors retain their README meaning:
  `#0284c7` Spec, `#059669` Build, `#d97706` Review, `#dc2626` Ship.
- Global speed lines, rings, flashes, repeated impacts, and camera shake are
  retired.
- Phase nodes use compact display labels (`/init`, `/spec`, `/build`, `/review`,
  `/ship`). The CTA retains the canonical `/agtoosa-init` and
  `/agtoosa-next` commands.
- The silent README loop condenses the film into status, init, workflow,
  routing, verification, and closing-brand scenes. It exports all 540 frames
  at 30fps for smooth inline playback without a separate media link.
- The guide score is built around a low-frequency
  `doom · doom · doom · tek · rest` pulse with a deliberate verifier drop.
- Each foreground cue has one job: status scan, init lock, phase handoff,
  next-route, or proof resolve.
- `A solution by Atoosa Dev` appears only in the closing credit.

## Story

| Time | Beat |
| ---: | --- |
| 0–5s | Compact `/status` reads plan, tasks, and the next action. |
| 5–11s | `/init` establishes the one-time project foundation. |
| 11–27s | Directional handoffs move through `/spec` → `/build` → `/review` → `/ship`. |
| 27–35s | `/status` routes into `/next`, which selects exactly one phase. |
| 35–40s | A verified repository run executes `bash Docs/agtoosa-verify.sh`. |
| 40–44s | The canonical `/agtoosa-init` and `/agtoosa-next` close the film. |

The terminal uses the verifier's authentic success wording and the currently
verified summary: `6 pass · 1 warn · 0 fail`, `Result: ✅ PASS`, and
`exit code 0`. Gate headings are shown without invented per-gate checkmarks.
The film does not invent `ALL GATES PASS` or imply the verifier proves semantic
correctness or security. The CTA points to the public AgToosa repository and its
in-repo walkthrough, not the currently private standalone proof repository.

## Install and inspect

```bash
cd docs/media/agtoosa-hero
npm ci
npm run typecheck
npm start
```

## Review checkpoint

Render the complete checkpoint:

```bash
npm run render:checkpoint
```

Or render the pieces separately:

```bash
npm run render:storyboard
npm run render:animatic
npm run render:readme
npm run render:poster
```

The storyboard command renders eight stills at both 1440×810 and 720×405, plus
one contact sheet. The animatic uses an original rhythmic guide score with a
three-doom-and-tek phrase. It proves timing, hierarchy, directional handoffs,
cue placement, and the verifier drop; it is not the licensed final mix.

Do not copy candidates over `agtoosa-hero.gif`, `agtoosa-hero.mp4`, or
`agtoosa-hero-poster.png` until the checkpoint is approved.

## Licensed music

Primary:

- **Close Up** — Michael Ramir C.
- Source: <https://mixkit.co/free-stock-music/corporate-music/>
- License: <https://mixkit.co/license/> (`Stock Music · Free License`)

Fallback:

- **Motivating Mornings** — Ahjay Stelino
- Source and license: the same Mixkit collection and Stock Music Free License.

Download the chosen track manually, keep it outside Git, and prepare it with:

```bash
npm run prepare:music -- /absolute/path/to/downloaded-track.mp3
```

Use `--fallback` after the path when preparing the fallback track. The command:

1. verifies the input is at least 44 seconds;
2. records the original SHA-256 and source duration;
3. trims to 44 seconds at stereo 48kHz;
4. shapes the sparse 0–5s opening, 35–40s verifier drop, and 42.5–44s exit;
5. performs two-pass normalization near −18 LUFS / −2 dBTP for mix headroom;
6. writes a 24-bit WAV and full metadata to gitignored
   `public/render-audio/`.

See [LICENSED-AUDIO.md](LICENSED-AUDIO.md) for the license record and final-mix
boundary.

After preparation:

```bash
npm run render:master
npm run check:audio -- \
  out/candidates/creative-reset-v2/agtoosa-marketing-v3-master.mp4 \
  --final
```

The final master layers a quiet generated `rhythm-pulse.wav` under the licensed
score so the requested pulse survives the music replacement. The finalizer
targets approximately −16 LUFS integrated and no more than −1 dBTP. It uses a
−1.5 dBTP normalization target to leave AAC headroom.

## Verification

```bash
npm run verify:checkpoint
git diff --check -- docs/media/agtoosa-hero
bash docs/agtoosa-verify.sh
```

`verify:checkpoint` checks source parsing, TypeScript, the 500-line limit,
timeline/cue contracts, H.264/AAC metadata, GIF dimensions/silence/size, and
candidate presence. Headphone, laptop-speaker, and phone-speaker listening
remain manual review steps.
