---
layout: post
title: "SLNN foundation: online residual learning"
categories: [tightloop, research, slnn]
---

SLNN is the early control idea behind much of the TightLoop work: a spiking-liquid-style neuromorphic system built around timing, online adaptation, and residual error.

The important product lesson from later experiments is that direct SLNN control is not always the right deployment mode. In several strong-baseline fixtures, direct neural control was worse than the existing controller. The useful pattern became adaptive assist: preserve the customer controller and let SLNN contribute bounded residual correction only where it helps.

That makes SLNN less like a universal controller and more like a residual dynamics engine. It can react while the signal is changing, represent heterogeneous time constants, and update from reward or error feedback.

The final product claim should therefore be modest. SLNN is not valuable because it sounds biologically inspired. It is valuable if it reduces measured residual error under replay, HIL, bench, or field validation without breaking the baseline safety envelope.

That framing is what turned the research idea into TightLoop.
