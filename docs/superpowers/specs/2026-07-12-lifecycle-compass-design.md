# Design: AgToosa Lifecycle Compass

**Date:** 2026-07-12  
**Story:** DEV-116  
**Status:** Approved in brainstorming — awaiting AgToosa spec sign-off  
**ADR:** `docs/adr/ADR-014-lifecycle-compass.md`

## Summary

Replace the NL Intent Map phrase table with **AgToosa Lifecycle Compass** — hybrid semantic + deterministic routing that anchors every freeform ask to Spec → Build → Review → Ship, while allowing tributary work (explore, fix, track) that serves an active phase.

## Problem

| Failure | Example |
|---------|---------|
| Under-routing | "add OAuth" → agent codes without spec |
| Over-routing | typo fix → full spec ceremony |
| Phase ambiguity | "CI is red" → unclear if build, review, or fix |

DEV-110 intake handles risk (soft/hard). DEV-112 phrase table handles a few keywords. Neither generalizes to natural language.

## Solution: Two-axis model

| Axis | Owner | Input |
|------|-------|-------|
| Intent (what user wants) | Agent semantics | Utterance + context |
| Phase (where project is) | Deterministic | `--status-line` SYNC pulse |

**Reconcile** intent × phase → ANCHOR + workflow + soft/hard gate.

## Branded lines

| Moment | Line |
|--------|------|
| Soft route | `Compass: soft → <phase> — <why>` |
| Hard gate | `**AgToosa Lifecycle Compass** — <benefit>. ANCHOR: <phase> — confirm /agtoosa-<phase>.` |
| Tributary | `Compass: tributary (<explore\|fix\|track>) → serving <phase> · <story>` |
| Return | `When done: return to /agtoosa-<phase> — <SYNC rationale>` |

## Semantic classes → ANCHOR

| Meaning | ANCHOR | Workflow |
|---------|--------|----------|
| New capability / architecture | `spec` | `/agtoosa-spec` |
| Implement approved work | `build` | `/agtoosa-build` |
| Quality check / audit | `review` | `/agtoosa-review` |
| Release / deploy | `ship` | `/agtoosa-ship` |
| Small bug in active story | `build` (tributary: fix) | expedite + return |
| Read-only question | active phase (tributary: explore) | answer + return |
| Backlog capture | `spec` (tributary: track) | `/agtoosa-task` + return |

## State reconciliation

If user intent conflicts with SYNC `next`, explain mismatch and anchor to the correct lifecycle phase — do not silently code.

## Optional CLI

`bash agtoosa.sh --status-line [path] --route-hint --format json`:

```json
{
  "sync": "SYNC: DEV-042 · In Progress · tasks 3/7 · clarity ready · next /agtoosa-build",
  "anchor": "build",
  "story_id": "DEV-042",
  "tasks_done": 3,
  "tasks_total": 7
}
```

## Non-goals

- Runtime workflow engine
- `/agtoosa-compass` slash command
- Auto-chaining phases
- Shell-based utterance NLP

## Implementation reference

Full EARS spec: `docs/archived/spec-DEV-116.md`  
Test plan: `docs/AgToosa_TestPlan-DEV-116.md`
