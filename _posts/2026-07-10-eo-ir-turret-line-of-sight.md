---
layout: post
title: "Longer line-of-sight hold under platform motion"
categories: [tightloop, product, turret]
---

EO/IR turrets, pan-tilt heads, and long-range inspection systems often start with serious control stacks: filtering, feed-forward, friction and shock compensation, gain scheduling, and disturbance rejection. The remaining value is in the line-of-sight error those stacks still leave under platform motion.

TightLoop's turret work is a good example of why adaptive assist is more credible than direct replacement. In the latest nmTurret comparison, the baseline was already strong. Direct SLNN variants were not competitive. A fixed assist was even harmful in the standard fixture. But adaptive assist reduced RMS by 1.94x in the standard test and 1.97x in the stress test against the strengthened baseline.

That is the product lesson. The neuromorphic layer should not apply correction constantly. It should behave like a residual specialist: stay quiet when the baseline is doing well, then add bounded correction when residual motion becomes structured.

The customer-facing metric is easy to understand: clearer sightline, less visible drift, and longer target hold. The engineering metric is also straightforward: replay the same platform motion and target trace, then compare remaining line-of-sight error, p95/p99 error, peak error, and command effort.

The useful claim is not that TightLoop replaces a turret controller. It is that it may reduce what remains after the controller has already done most of the work.
