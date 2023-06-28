---
title: "Event Streams installation reports `Blocked` status"
excerpt: "Installation of Event Streams instance reports a failed status when Foundational Services is not installed."
categories: troubleshooting
slug: es-install-fails
layout: redirects
toc: true
---

## Symptoms

When installing a new instance of {{site.data.reuse.short_name}} on an {{site.data.reuse.openshift_short}} cluster, installation fails with status of the {{site.data.reuse.short_name}} instance as `Blocked`.

The following condition message is displayed in the status of the instance:

```
This instance requires Foundational Services version 3.19.0 or later 3.x fix releases. 
Install the required version of the Foundational Services operator as described in https://ibm.biz/es-cpfs-installation. 
This instance will remain in the `Blocked` status until the correct operator version is installed.
```

## Causes

This error occurs because {{site.data.reuse.icpfs}} is not installed in your cluster. {{site.data.reuse.icpfs}} is a [prerequisite](../../installing/prerequisites/#ibm-cloud-pak-foundational-services) to install an instance of {{site.data.reuse.short_name}}.

## Resolving the problem

Install {{site.data.reuse.icpfs}} before installing an instance of {{site.data.reuse.short_name}}.
