---
layout: post
title: "A browser demo for adaptive camera stabilization"
categories: [tightloop, demo, vr]
---

The VR adaptive camera demo exists to make the residual-error idea visible. A camera controller can be good and still leave enough motion to bother the operator. The demo shows the type of trace where TightLoop is meant to sit after the normal controller and reduce what remains.

The useful part of a web demo is not photorealism. It is replayability. If the same target and motion record can be run through a baseline and then through an assist layer, viewers can inspect whether the final view actually settles faster or hides less useful information.

This is the same evaluation logic used in the internal VR horizon replay. The headline result was a 3.53x reduction in horizon error and a 1.88x reduction in operator-view error. The browser demo should be read as an interface to that question: can residual motion be captured, replayed, and reduced without rebuilding the entire camera system?

The next useful step is to make every public camera demo export a trace: target position, camera command, camera pose, measured view error, and frame timing. That turns a visual demo into a test artifact.
