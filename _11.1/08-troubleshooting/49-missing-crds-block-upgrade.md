---
title: "Upgrade to 11.1.5 stuck in pending state"
excerpt: "Longstanding Event Streams instances might be blocked from upgrading to 11.1.5 due to missing CRDs"
categories: troubleshooting
slug: missing-crds-block-upgrade
toc: true
---

## Symptoms

Upgrade to {{site.data.reuse.short_name}} 11.1.5 is blocked in `pending` state with a message similar to the following:

```
InstallComponentFailed risk of data loss updating "kafkamirrormaker2s.eventstreams.ibm.com": new CRD removes version v1alpha1 that is listed as a stored version on the existing CRD
```

## Causes

Some API versions in Custom Resource Definitions (CRDs) are missing in {{site.data.reuse.short_name}} 11.1.5. The Operator Lifecycle Manager (OLM) checks whether all the previously stored API Versions in the CRDs are present before starting the upgrade process. Because the prerequisite is not met, the upgrade process is stuck in a `pending` state.

## Resolving the problem

As the prerequisite is not met, upgrading to {{site.data.reuse.short_name}} 11.1.5 is interrupted. However, the instance being upgraded (both the {{site.data.reuse.short_name}} operator and the instance) will continue running uninterrupted.
