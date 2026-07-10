---
layout: post
title: "An EUV precision-stage digital twin for process-window residuals"
categories: [tightloop, demo, optics]
---

EUV and precision-stage systems are useful examples because residual error has an obvious business meaning: process-window violations, alignment loss, and measurement instability.

The digital twin shows a baseline precision-stage controller under stress and then the same trace with TightLoop assist. The goal is not to simulate a full production tool. It is to make the residual-control question inspectable.

The latest nmOptic results support this framing. Adaptive assist improved standard RMS by about 1.96x and stress RMS by about 1.80x against a strong optical baseline. Direct SLNN was not competitive, which reinforces the product boundary: assist, not replacement.

For a real precision-stage customer, the validation should be replay-based and domain-specific. The customer defines the process window. TightLoop is evaluated on whether it reduces the number or severity of violations without increasing unacceptable actuator behavior.

The digital twin is valuable if it leads to that kind of trace-level test.
