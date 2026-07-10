---
layout: post
title: "A turret sightline replay under shock and platform movement"
categories: [tightloop, demo, turret]
---

The turret sightline replay is a digital-twin-style visualization of a common control problem: the platform moves, the controller compensates, but the line of sight still carries residual error.

The underlying nmTurret results are important because they show why adaptive assist is the right product form. Direct SLNN control performed far worse than a strong ADRC/NTSMC-style baseline. Fixed assist could also be harmful. Adaptive assist, however, reduced RMS by 1.94x in the standard fixture and 1.97x in the stress fixture.

That is a useful engineering lesson. The residual layer should not fight the baseline. It should gate in only when there is a pattern it can help with.

The replay is therefore best understood as a test of final sightline quality, not as a claim about replacing turret control. If a customer has platform motion logs, command logs, and measured sightline offset, the same analysis can be run on their data.

The commercial metric is simple: clearer sightline and longer target hold under the same disturbance.
