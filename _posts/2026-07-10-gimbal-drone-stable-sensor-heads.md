---
layout: post
title: "Stable sensor heads in motion"
categories: [tightloop, product, gimbal]
---

Drones, payload gimbals, mobile inspection rigs, OIS modules, and robot sensor heads all share the same visible failure: the view still moves after the stabilizer has done its job.

The TightLoop gimbal/drone product line is an adaptive assist layer for that remaining motion. It is not a full flight controller. It is not a replacement for a payload gimbal stack. It is a residual-error layer that can be replayed against recorded IMU, command, and image displacement traces.

The broader adaptive-assist results support this product shape. In industrial IMU fixtures, nmVOR adaptive assist reduced RMS from 0.003754 to 0.001824, about 2.06x lower. nmVAL adaptive assist reduced RMS from 0.004149 to 0.001427, about 2.91x lower, with better p95, p99, max residual, and trade score than the baseline.

Those numbers suggest a practical evaluation path: ask for a short flight, inspection, or mobile-platform record. Measure unusable frames, sightline displacement, horizon drift, or target hold. Then replay with the assist layer.

The most credible product claim is not "perfect stabilization." It is fewer unusable frames and less remaining sensor-head motion under the same disturbance record.
