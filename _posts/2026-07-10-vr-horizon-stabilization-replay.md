---
layout: post
title: "VR horizon stabilization as a replay problem"
categories: [tightloop, demo, vr]
---

VR horizon drift is one of the easiest residual errors to see. The baseline camera may track the target, but the horizon still wobbles enough to create discomfort or make the operator view feel unstable.

The TightLoop VR horizon replay compares a strengthened view-control baseline with the same trace after adaptive assist. The internal result reported a 3.53x lower horizon error signal and a 1.88x lower operator-view error.

The reason this is interesting is the evaluation format. A camera system can be judged on the same recorded motion, target, and output. That makes the before/after claim less subjective than a hand-tuned demo.

For product use, the important artifact is the motion-record exporter. A customer should be able to send a trace where the camera still feels wrong, then receive a replay showing whether TightLoop reduces the measured residual.

The claim is intentionally small: not better art direction, not better game feel by default, but less remaining horizon error on traces where the current controller leaves structured motion.
