---
title: "Required value error when installing on OpenShift 4.5.0-4.5.5"
excerpt: "When installing Event Streams on OpenShift 4.5.0-4.5.5, a required value error stops the installation."
categories: troubleshooting
slug: required-value-error
toc: true
---

## Symptoms

When installing an {{site.data.reuse.short_name}} instance on {{site.data.reuse.openshift_short}} 4.5.0 to 4.5.5 by using the UI, the installation stops and an error about missing values is displayed after clicking **Create**. The following is an example of the error:

```
Error "Required value" for field "spec.strimziOverrides.kafka.listenrers".
```

## Causes

Due to a known issue, installing on {{site.data.reuse.openshift_short}} 4.5.0 to 4.5.5 by using the UI removes configuration details and applies an incomplete definition.

## Resolving the problem

When [installing](../../installing/installing/#installing-an-instance-by-using-the-web-console) {{site.data.reuse.short_name}} on {{site.data.reuse.openshift_short}} versions 4.5.0 to 4.5.5 by using the OpenShift UI, go to the **YAML View**, select a sample configuration on the right, and click **Try It** to load a valid sample.

Alternatively, upgrade your {{site.data.reuse.openshift_short}} version to 4.5.6.
