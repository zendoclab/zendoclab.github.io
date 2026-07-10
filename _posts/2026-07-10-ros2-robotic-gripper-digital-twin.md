---
layout: post
title: "A ROS2 robotic gripper digital twin for slip and overgrip"
categories: [tightloop, demo, grip]
---

The ROS2 gripper digital twin exists to show a tradeoff that is easy to miss in a single metric. Reducing slip is useful only if the controller does not solve it by crushing the object.

TightLoop Grip uses a predictive bio-grip HRR layer around a commercial-like impedance baseline. The digital twin shows the resulting signals: slip, overgrip, damage-risk proxy, and final behavior.

The latest nmGrip v33 NdFractal tests showed small but useful tradeoffs. The GPU1024 NdFractal variant improved RMS over v32 by 2.38% in stationary validation and 2.62% in regime shift, but overgrip was worse. Another variant improved overgrip while slightly worsening RMS.

That is the right kind of result to expose. Contact control should be configurable around the customer's object and risk model.

The demo is therefore not a victory animation. It is a way to inspect whether the controller moves the slip/damage tradeoff in the desired direction.
