---
layout: post
title: "Turning Chronos-Bolt forecasts into bounded actions on a Jetson Orin"
categories: [tightloop, sentinel, forecasting, edge-ai]
---

Time-series foundation models are useful because they can produce probabilistic forecasts without training a new model for every site. But operations teams usually do not buy a forecast distribution. They need to decide whether to allocate reserve, escalate an alert, adjust a buffer, or stage capacity.

That gap is the forecast-to-action problem.

In the latest Jetson Orin replay study, Chronos-Bolt Base was used as the forecasting model and TightLoop Sentinel was added as a bounded action layer. Chronos-Bolt estimated future value distributions. Sentinel consumed those distributions plus recent replay feedback and emitted causal center and reserve adjustments.

The experiment used four GIFT-Eval-derived tasks on a Jetson Orin CUDA environment:

- BizITObs application telemetry: 1,800 rows.
- Electricity demand: 3,000 rows.
- Jena weather: 20,160 rows.
- Bitbrains fast storage traces: 46,404 finite rows after filtering non-finite horizons.

The strongest result was on BizITObs. The combined Chronos-Bolt Base plus TightLoop Sentinel condition improved interval coverage by 32.89 percentage points and reduced mean operational cost by 56.45% under the default actuator setting. Electricity and Jena Weather also showed improved coverage and lower mean cost, while Bitbrains improved coverage but remained difficult because near-zero interval widths dominated the mean normalized cost.

The study is intentionally not a claim that Sentinel makes Chronos-Bolt a better forecaster. That would be the wrong interpretation. The cleaner role separation is:

```text
Chronos-Bolt: forecast distribution
TightLoop Sentinel: bounded causal operational adjustment
```

The operational cost used in the replay combined undercoverage shortfall, reserve width, and action churn. That cost is not universal. A data center, HVAC system, logistics queue, and storage cluster would all define business cost differently. But the replay is useful because it evaluates the layer where forecasts become decisions.

The edge angle is also important. The run used Jetson Orin, CUDA Chronos inference, and a compact Rust Sentinel component. That suggests a deployment path where the plant or edge box keeps forecasting local and converts uncertainty into practical control signals without needing a large cloud service in the loop.

The most interesting limitation was Bitbrains. The initial trace had non-finite labels; the fix required filtering non-finite forecast/actual rows during trace generation and adding finite-input guards in the Rust loader. That kind of failure is not glamorous, but it is exactly the sort of thing an operational replay should expose before a product goes near a live system.

The broader conclusion is simple: probabilistic forecasts are not the endpoint. If a forecast is going to affect real operations, there must be a layer that decides how much action is justified, how fast it should change, and how to trade off missed peaks against wasted reserve. TightLoop Sentinel is one attempt at that layer.

Related material: Chronos-Bolt, GIFT-Eval, Jetson Orin CUDA replay, and the cording.ai TightLoop Sentinel Zenodo preprint.
