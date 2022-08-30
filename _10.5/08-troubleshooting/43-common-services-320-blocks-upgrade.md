---
title: "IBM Cloud Pak foundational services 3.20 blocks upgrade to Event Streams 11.0.x"
excerpt: "An Event Streams 10.5.0 instance cannot be upgraded to 11.0.x when IBM Cloud Pak foundational services has been upgraded to 3.20."
categories: troubleshooting
slug: foundational-services-320-upgrade-block
toc: true
---

## Symptoms

An upgrade of an {{site.data.reuse.short_name}} instance from 10.5.0 to 11.0.1 or later is blocked because the dependency requirements cannot be met: {{site.data.reuse.icpfs}} 3.19.x is not available.

## Causes

{{site.data.reuse.short_name}} 11.0.0 allows {{site.data.reuse.icpfs}} to upgrade its Continuous Delivery (CD) stream from 3.19 to 3.20.x. This blocks upgrades to {{site.data.reuse.short_name}} 11.0.1 or later as these versions are fixed on the {{site.data.reuse.icpfs}} Extended Update Support (EUS) release which is 3.19.x.

## Resolving the problem

To resolve this issue, uninstall the {{site.data.reuse.icpfs}} CD installation, and reinstall {{site.data.reuse.icpfs}} 3.19.x, which is fixed on the EUS stream, then proceed with the {{site.data.reuse.short_name}} upgrade.
