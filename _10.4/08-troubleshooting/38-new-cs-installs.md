---
title: "Event Streams installation reports failed status"
excerpt: "During the first installation of foundational services, the installation for the Event Streams instance reports a failed status."
categories: troubleshooting
slug: failed-status-during-cs-install
toc: true
---

## Symptoms

When installing a new instance of {{site.data.reuse.short_name}} on an {{site.data.reuse.openshift_short}} cluster that has not previously had an installation of {{site.data.reuse.icpfs}}, the status of the {{site.data.reuse.short_name}} instance is reported as `Failed`.

The following condition message is displayed in the status of the instance:

```
An unexpected exception was encountered: Common Services must be Ready.
```


## Causes

If not present at the time of installing an instance of {{site.data.reuse.short_name}}, the operator installs {{site.data.reuse.icpfs}} first. The {{site.data.reuse.short_name}} operator waits for the {{site.data.reuse.fs}} installation to complete before continuing.

The installation of {{site.data.reuse.fs}} can take several minutes, but in some cases the {{site.data.reuse.short_name}} operator does not wait long enough for the process to complete, and incorrectly reports that the installation failed when it is still in progress.

## Resolving the problem

No user action is required.

When the {{site.data.reuse.icpfs}} installation completes, the {{site.data.reuse.short_name}} operator automatically resumes the installation of the {{site.data.reuse.short_name}} instance. The status of the instance changes to `Ready` when the process is complete.

**Note:** This only applies to new installations on clusters where {{site.data.reuse.icpfs}} has not previously been installed.
