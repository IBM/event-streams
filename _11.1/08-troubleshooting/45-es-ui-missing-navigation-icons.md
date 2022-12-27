---
title: "Missing navigation icons in the Event Streams UI"
excerpt: "When accessing the Event Streams 11.1.2 UI as an IAM user, some navigation icons are missing."
categories: troubleshooting
slug: es-ui-missing-navigation-icons
toc: true
---

## Symptoms

When accessing {{site.data.reuse.short_name}} version 11.1.2 as an {{site.data.reuse.icpfs}} Identity and Access Management (IAM) user, some of the navigation icons are missing from the navigation pane of the UI.

## Causes

The {{site.data.reuse.short_name}} operator has misconfigured the authorization permissions for the Identity and Access Management (IAM) user.

## Resolving the problem

[Upgrade](../../installing/upgrading/) your {{site.data.reuse.short_name}} instance to version 11.1.3 to resolve the issue.