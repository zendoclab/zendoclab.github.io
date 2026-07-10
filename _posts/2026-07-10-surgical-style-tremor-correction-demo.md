---
layout: post
title: "A surgical-style tremor correction demo"
categories: [tightloop, demo, teleoperation]
---

The surgical-style demo is about a narrow problem: the tool still moves more than the operator intended. That can come from tremor, delay, overcorrection, or command jitter.

The important design choice is to show before/after behavior under the same disturbance record. Without that, a demo is just animation. With a replay, the viewer can ask whether the assist layer actually reduces the same residual motion.

The latest adaptive-assist fixture behind this line reduced mean tool-motion error from 0.001010 to 0.000407 and reduced p95 spikes by 5.05x. Those numbers should be treated as fixture results, not clinical claims.

The correct product path is research and training systems first: simulators, teleoperation testbeds, device evaluation, and data review. A regulated surgical workflow would require a separate validation path.

The demo is useful because it shows the product boundary. TightLoop is not a surgeon. It is a residual-motion assistant that can be tested on recorded command and motion streams.
