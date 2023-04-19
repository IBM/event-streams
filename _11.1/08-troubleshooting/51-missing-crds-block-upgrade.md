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

To resolve the issue, ensure your catalog source is updated to the latest version, and then manually upgrade your {{site.data.reuse.short_name}} operator to 3.1.6. To manually upgrade your operator, complete the following steps:

1. Check to see that your catalog source for the {{site.data.reuse.short_name}} operator has pulled the latest version, 3.1.6. You can verify this in the Openshift web console by navigating to the **OperatorHub**, clicking the {{site.data.reuse.short_name}} operator tile, and checking the value in **Latest version**.
2. Uninstall any previous versions of the {{site.data.reuse.short_name}} operator.
3. Install the {{site.data.reuse.short_name}} operator 3.1.6.
4. Wait for the operator pod to be ready and it will upgrade your {{site.data.reuse.short_name}} instance to 11.1.6.
