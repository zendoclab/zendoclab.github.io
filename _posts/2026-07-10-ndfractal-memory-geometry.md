---
layout: post
title: "NdFractal as memory geometry for residual regimes"
categories: [tightloop, research, ndfractal]
---

NdFractal is a memory-geometry concept. Instead of treating history as only a longer buffer, it compresses past inputs into a state-function landscape intended to separate similar residual regimes from genuinely different ones.

The product motivation is practical. Many residual errors are not independent samples. A slight wobble, a contact transition, a cooling drift, or a vibration precursor can look weak at one time scale and obvious at another.

NdFractal is meant to add that multi-scale context before the SLNN/HRR path acts.

The nmGrip v33 tests are a useful example. Adding NdFractal did not simply dominate v32. Some variants improved RMS while worsening overgrip; another improved overgrip while slightly worsening RMS. That is still informative because it shows the memory frontend changes the operating tradeoff rather than acting as a free improvement.

The right question for NdFractal is therefore not "does memory help everywhere?" It is "which residual regimes become separable enough to improve a policy under the customer's chosen cost function?"
