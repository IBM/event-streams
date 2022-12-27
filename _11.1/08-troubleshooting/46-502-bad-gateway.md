---
title: "502 Bad Gateway error when logging in to Event Streams UI"
excerpt: "Logging in to the Event Streams 11.1.2 UI as an IAM user fails with a '502 Bad Gateway' error message."
categories: troubleshooting
slug: 502-bad-gateway
toc: true
---

## Symptoms

If you installed {{site.data.reuse.short_name}} version 11.1.2 as part of {{site.data.reuse.cp4i}}, signing in to the UI as an {{site.data.reuse.icpfs}} Identity and Access Management (IAM) user fails with a `502 Bad Gateway` error message.

## Causes

The {{site.data.reuse.short_name}} operator has misconfigured the authorization permissions for the Identity and Access Management (IAM) user.

## Resolving the problem

[Upgrade](../../installing/upgrading/) your {{site.data.reuse.short_name}} instance to version 11.1.3 to resolve the issue.
