---
layout: post
title: "A wind gearbox warning is valuable if it creates a service window"
categories: [tightloop, sentinel, wind]
---

Wind gearbox failures are not only prediction problems. They are scheduling problems. A warning is useful if it creates enough time to plan service, parts, access, and downtime.

The wind gearbox Sentinel demo reported a 15.95-day maintenance window in a vibration example. The important phrase is "maintenance window." The warning must be early enough to matter, but not so noisy that operators ignore it.

The related Sentinel preprint also evaluated an NREL gearbox setting where a confirmation layer helped suppress false positives from a strong vibration baseline and a one-class deep autoencoder under healthy-condition shift.

That product role is realistic. A wind operator may already trust a vibration baseline. Sentinel does not need to replace it. It can add confirmation, early OR, or guarded warning policy around it.

The right pilot is a replay against healthy and damaged gearbox data, with clear accounting for lead time and false positives.
