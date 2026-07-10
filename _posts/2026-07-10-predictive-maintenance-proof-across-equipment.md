---
layout: post
title: "A neuromorphic warning layer tested on turbofans, bearings, and wind gearboxes"
categories: [tightloop, sentinel, predictive-maintenance]
---

Predictive maintenance is often presented as a prediction problem. Lower RMSE, better RUL curves, cleaner anomaly scores. Those numbers matter, but they are not the whole product problem. A plant team usually asks different questions: did the warning arrive early enough to schedule work, did it create nuisance alarms, and can it sit beside the monitoring system already in use?

TightLoop Sentinel is being tested as that second layer. It is not framed as a universal replacement for deep RUL models or condition monitoring. The more defensible claim is narrower: a neuromorphic `SLNN + NdFractal + HRR` layer can add precursor state, persistence, and warning policy around existing predictive-maintenance systems.

The latest preprint summarized three public benchmark families:

- NASA C-MAPSS turbofan RUL, where Sentinel was evaluated beside deep and non-deep life-prediction baselines.
- NASA IMS bearing run-to-failure vibration data, where a low-data precursor layer was tested against conservative bearing alarms.
- NREL wind gearbox vibration data, where a confirmation layer was tested under healthy/damaged gearbox distribution shift.

The important product pattern is not "one model beats everything." It is that the same architectural family can play different operational roles. On a turbofan task, the layer can recover earlier warning lead time. On bearing runs, it can act as a precursor signal where there is little failure data. On wind gearbox data, it can guard against false positives from a strong vibration baseline or one-class autoencoder under healthy distribution shift.

That is a more useful deployment shape than a clean leaderboard claim. Real plants rarely rip out their alarm stack. They add something only if it can be validated against their incident history and if it can run in a mode such as:

- early OR: warn if either the existing system or Sentinel sees a credible precursor;
- confirmed: require both systems before escalating;
- guarded lead recovery: let Sentinel recover earlier warnings while controlling false positives;
- shadow mode: run beside the existing tool until operators trust it.

This also clarifies what the result does not claim. It is not a proof of universal predictive-maintenance superiority. It is not a state-of-the-art RUL paper. It does not expose proprietary implementation constants. It shows a commercially useful possibility: a compact warning layer can be evaluated as an operational policy component, not only as a prediction model.

That distinction matters. Maintenance value is created by lead time, fewer missed faults, and fewer disruptive false alarms. If a model improves only a numerical score but cannot be mapped to maintenance windows, it is hard to sell. If a layer can be replayed against a customer's past failures and show earlier warnings under a clear false-alarm budget, it becomes a pilotable product.

Related material: cording.ai TightLoop Sentinel, Zenodo predictive-maintenance preprint, NASA C-MAPSS, NASA IMS, and NREL gearbox benchmark notes.
