---
title: "Resources not available"
excerpt: "Reasons for IBM Event Streams resources not being available."
categories: troubleshooting
slug: resources-not-available
toc: true
---

If {{site.data.reuse.long_name}} resources are not available, the following are possible symptoms and causes.


## Insufficient system resources

You can specify the memory and CPU requirements when the {{site.data.reuse.long_name}} instance is installed using the `EventStreams` custom resource. If the values set are larger than the resources available, then pods will fail to start.

Common error messages in such cases include the following:
- **`pod has unbound PersistentVolumeClaims`** - occurs when there are no Persistent Volumes available that meet the requirements provided at the time of installation.
- **`Insufficient memory`** - occurs when there are no nodes with enough available memory to support the limits provided at the time of installation.
- **`Insufficient CPU`** - occurs when there are no nodes with enough available CPU to support the limits provided at the time of installation.

To get detailed information on the cause of the error, check the events for the individual pods (not the logs at the stateful set level).

Ensure that resource requests and limits do not exceed the total memory available. For example, if a system has 16 GB of memory available per node, then the broker memory requirements must be set to be less than 16 GB. This allows resources to be available for the other {{site.data.reuse.long_name}} components which might reside on the same node.

To correct these issues, increase the amount of system resources available or re-install the {{site.data.reuse.long_name}} instance with lower resource requirements.

## Problems with secrets

Before installing the operator, configure secrets with your entitlement key for the IBM Container software library. This will enable container images to be pulled from the registry. See the [installation](../../installing/installing/#creating-an-image-pull-secret) section of the documentation for more information.

If you do not prepare the required secrets, all pods will fail to start with `ImagePullBackOff` errors. In this case, configure the required secrets and allow the pod to restart.
