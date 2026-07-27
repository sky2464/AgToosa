# Licensed Audio Record

## Selection

| Field | Primary | Fallback |
| --- | --- | --- |
| Title | Close Up | Motivating Mornings |
| Author | Michael Ramir C. | Ahjay Stelino |
| Source URL | <https://mixkit.co/free-stock-music/corporate-music/> | <https://mixkit.co/free-stock-music/corporate-music/> |
| License URL | <https://mixkit.co/license/> | <https://mixkit.co/license/> |
| License class | Stock Music · Free License | Stock Music · Free License |

Mixkit lists `Close Up` as a rhythmic, positive, futuristic technology
underscore. The raw track must not be committed or redistributed as a standalone
repository asset.

## Checkpoint status

The creative-reset checkpoint uses the original generated
`animatic-score.wav`, not a Mixkit track. Its rhythmic identity is a
`doom · doom · doom · tek · rest` phrase. The final composition retains a quiet
generated `rhythm-pulse.wav` under the licensed score. No licensed file has been
downloaded or incorporated yet, so there is no truthful download date or
source-file hash to record at this phase.

After checkpoint approval, the operator downloads one selected track and runs:

```bash
npm run prepare:music -- /absolute/path/to/downloaded-track.mp3
```

The command writes the following auditable record to the gitignored
`public/render-audio/music-metadata.json`:

- selected title and author;
- source URL and license URL;
- download/preparation date;
- original filename and SHA-256;
- source duration;
- derivative path;
- trim, gain-shaping, verifier-drop, fade, sample format, LUFS, and true-peak
  parameters.

The record must be copied into release evidence when the final master is
approved. Keep the raw download and prepared WAV outside Git.

## Edit recipe

| Edit | Value |
| --- | --- |
| Trim | First 44 seconds |
| Format | 24-bit PCM WAV, stereo, 48kHz |
| Cold open | Approximately −18dB relative level through 5s; rise by 6.5s |
| Verifier drop | Reduced level from 35s; recovery completes by 40s |
| Ending | Fade from 42.5s to 44s |
| Score preparation | Two-pass loudnorm near −18 LUFS / −2 dBTP |
| Final complete mix | Two-pass loudnorm near −16 LUFS / −1.5 dBTP |
| Foreground cues | Exactly five; music ducks about 2.5dB around each cue |
| Signature rhythm | Generated pulse stem under final licensed score |
