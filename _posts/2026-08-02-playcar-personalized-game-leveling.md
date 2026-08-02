---
layout: post
title: "playcar.cording.ai: Personalized Game Leveling with Nd, SLNN, and HRR"
date: 2026-08-02 12:00:00 +0900
excerpt: "playcar.cording.ai is a short-form mobile driving-game research prototype that tests bounded, safety-gated personalization of future game content."
categories: [games, research, personalization, nd, slnn, hrr]
---

`playcar.cording.ai` is both a short-form mobile driving game and a research prototype for personalized game leveling with Nd + SLNN + HRR. The car genre is only the test environment. The central research question is:

> Can short behavioral traces distinguish overload, underload, and recovery, then adjust the difficulty and dramatic rhythm of future content without undermining fairness or player agency?

This game is not a medical device or psychological diagnostic tool. Internal values named `flow`, overload, and underload are behavioral control signals, not measurements of immersion, emotion, or mental state.

## Runtime environment

- Mobile portrait mode only
- Android and iOS mobile browsers
- No installation, login, or server backend
- Static HTML/CSS/JavaScript/Rust WASM
- WebGPU first, with WebGL/Canvas 2D fallback
- Desktop devices show a mobile-only notice and do not start the game

## How to play

1. Open [playcar.cording.ai](https://playcar.cording.ai) in a mobile browser.
2. Keep the phone in portrait orientation and tap `TAP TO DRIVE`.
3. Hold `LEFT` or `RIGHT` to turn.
4. Releasing the button stops yaw input and preserves the current travel heading.
5. Follow every bend and choose the lane manually. There is no automatic lane keeping.
6. Collect green GAS and avoid orange obstacles and the road edge.
7. The run ends when GAS or HP reaches zero.
8. Compare the current distance with the locally stored BEST distance and try again.

## Core rules

- Starting GAS: 50%
- GAS spacing: approximately 135 m
- GAS pickup: +16%
- HP decreases after collisions and off-road driving
- HP recovers at 0.45 points per second while safely driving
- Base target speed: 18 m/s; maximum: 32 m/s
- Minimum GAS preview at maximum speed: approximately 1.56 seconds
- No time limit and no score
- A run continues while GAS and HP remain
- BEST distance is stored in the browser

Collecting every GAS pickup does not guarantee survival. Clean, fast driving can sustain resources, while missed GAS and excessive steering create meaningful pressure.

## Nd, SLNN, and HRR

### Nd — temporal context

The game observes lateral and heading error, steering reversals, speed changes, collisions, near misses, GAS, and recovery. Nd aggregates these signals across timescales from roughly 16 ms to 20 seconds, separating isolated mistakes from sustained overload.

### SLNN — online personalization

A 128-neuron LIF reservoir with learnable readouts proposes bounded residuals for future content intensity, lateral GAS risk, and steering agility while the player is pressing a button. Each SLNN residual is bounded to ±12%. The model never drives the car for the player.

### HRR — safety gate

HRR classifies sectors such as stable control, control failure, recovery drift, saturation, raw/Nd disagreement, regime shift, and resource pressure.

- It blocks difficulty increases during failure.
- It blocks increases in GAS risk during resource pressure.
- It freezes SLNN proposals and learning during raw/Nd disagreement.
- It falls back to deterministic recovery when uncertain.

## What adaptation can change

Only future content that has not yet appeared on screen can change.

- Road half-width: `3.25–5.78 m`
- Obstacle spawn probability
- Obstacle radius: `0.27–0.50 m`
- Center-lane obstacle probability and side-lane offset
- Probability that GAS appears in the center or on a side lane
- GAS lateral offset: `0.90–1.90 m`
- Steering agility while a button is held

Maximum fast relief under overload:

- intensity `−0.24`;
- obstacle probability approximately `−15 percentage points`;
- GAS risk `−0.68`;
- manual steering agility `+25%`.

Maximum challenge boost during underload in Build/Peak:

- intensity `+0.18`;
- obstacle probability approximately `+12 percentage points`;
- GAS risk `+0.18`.

## Tension and recovery rhythm

Difficulty does not increase forever in one direction.

```text
Calibration → Build → Peak → Fade → Relax → Build ...
```

- Calibration: 2.5 seconds of initial observation
- Build: up to 6 seconds of escalation
- Peak: up to 4 seconds of high intensity
- Fade: 2.2 seconds of declining threat
- Relax: at least 4 seconds of recovery

Overload can trigger immediate relief without waiting for a phase transition. Sustained underload raises difficulty quickly during Build and Peak, but it cannot cancel Fade or Relax. The goal is an alternating dramatic rhythm rather than constant maximum difficulty.

## What adaptation cannot change

- Roads, obstacles, or GAS already visible on screen
- Hitboxes immediately before a collision
- GAS burn and pickup amounts
- HP and collision damage
- Vehicle direction without player input
- Past results and BEST distance

The system therefore cannot move an obstacle or secretly guarantee success at the moment of failure.

## Data stored on the device

There is no server account or backend. The following values are stored in that browser's `localStorage`:

- BEST distance
- Up to 60 seconds of accumulated level progression
- Pacing phase and phase time
- 384 SLNN readout weights
- The latest replay v8

GAS, HP, vehicle physics, short-term Nd memory, and HRR hysteresis reset for every new run. Clearing the site's browser data also clears progression and BEST distance.

## What the prototype is intended to test

Experimental conditions:

- Fixed difficulty
- Rules-based pacing
- Rules + Nd
- Rules + Nd + online SLNN
- Rules + Nd + SLNN + HRR + bidirectional relief/boost

Evaluation targets include ease of control and agency; mastery and perceived fairness; collisions, over-correction, and recovery time; tension/recovery rhythm; fun, immersion, and willingness to retry; and p95/p99 frame time on lower-end mobile hardware.

Automated tests currently verify determinism, bounded adaptation, GAS reaction time, obstacle/GAS/road scaling, protected recovery phases, and replay integrity. They do not prove an improvement in immersion. That claim requires controlled playtests on real devices, including the Galaxy S24.

## Recommended playtest procedure

1. Use the same device in portrait orientation.
2. Treat the first run as control familiarization.
3. Play three to five seeds per experimental condition.
4. Counterbalance the order of conditions across participants.
5. After every run, record ease of control, mastery, fairness, immersion, and willingness to retry.
6. Analyze recovery after failure, difficulty oscillation, and subjective reports—not session duration alone.

## Research references

- Valve, [*Replayable Cooperative Game Design: Left 4 Dead*](https://steamcdn-a.akamaihd.net/apps/valve/2009/GDC2009_ReplayableCooperativeGameDesign_Left4Dead.pdf)
- Yannakakis & Togelius, [*Experience-Driven Procedural Content Generation*](https://yannakakis.net/wp-content/uploads/2019/02/EDPCG.pdf)
- Denisova & Cairns, [*Adaptation in Digital Games*](https://doi.org/10.1145/2793107.2793141)
- Zook & Riedl, [*A Temporal Data-Driven Player Model for Dynamic Difficulty Adjustment*](https://doi.org/10.1609/aiide.v8i1.12504)
