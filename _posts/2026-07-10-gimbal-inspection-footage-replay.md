---
layout: post
title: "Gimbal inspection footage as a stabilization test"
categories: [tightloop, demo, gimbal]
---

Industrial inspection footage often fails in practical ways: vibration, acceleration events, rolling platform motion, and periods where the sensor view becomes less useful even though the gimbal is working.

The TightLoop gimbal inspection replay demonstrates the product idea visually. The input disturbance is held constant. The baseline view and assisted view are compared on the same footage-like trace.

The related adaptive-assist results from industrial IMU fixtures are encouraging: nmVOR lowered RMS by about 2.06x, and nmVAL lowered RMS by about 2.91x. Those are not universal camera claims, but they show that a residual layer can improve motion traces after a baseline stabilizer.

For real inspection work, the metric should be chosen by the customer: unusable frames, target displacement, feature-track stability, or downstream measurement error.

The replay matters because it makes the evaluation concrete. A stabilization product should be judged on the same recorded disturbance, not on a nicer selected video.
