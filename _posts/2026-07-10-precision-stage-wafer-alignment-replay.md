---
layout: post
title: "A precision-stage replay for wafer-alignment-style residuals"
categories: [tightloop, demo, optics]
---

Precision-stage errors are small, but they are not abstract. They can become alignment loss, measurement noise, or process-window violations.

The wafer-alignment-style replay visualizes that problem. The baseline controller handles most of the motion. TightLoop is added as a residual assist layer to see whether the remaining error can be reduced.

The related nmOptic tests used a strong baseline and showed why humility matters. Direct SLNN was not competitive. Adaptive assist was: standard RMS improved from 0.000014 to 0.000007, and stress RMS improved from 0.000035 to 0.000020.

For a precision customer, the only credible next step is a replay against their own traces. The data do not need to be exotic: time, target, command, measured position or optical residual, and process window indicators.

The demo is a pointer to that evaluation path. If the residual error is structured, an assist layer may reduce it. If it is not, the replay should show that too.
