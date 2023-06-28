---
title: "403 error when signing in to Event Streams UI"
excerpt: "When signing into the Event Streams UI, the 403 Not Authorized page is displayed."
categories: troubleshooting
slug: ui-403-error
layout: redirects
toc: true
---

## Symptoms

Signing into the {{site.data.reuse.short_name}} UI fails with the message `403 Not authorized`, indicating that the user does not have permission to access the {{site.data.reuse.short_name}} instance.

## Causes

The most likely cause of this problem is that the user attempting to authenticate is part of an {{site.data.reuse.icp}} team that has not been associated with the  {{site.data.reuse.short_name}} instance.

## Resolving the problem

Configure the {{site.data.reuse.icp}} team that the user is part of to work with the {{site.data.reuse.short_name}} instance by running the `iam-add-release-to-team` CLI command.

Run the command as follows:

`cloudctl es iam-add-release-to-team --namespace <namespace for the {{site.data.reuse.short_name}} instance> --release <release name of the {{site.data.reuse.short_name}} instance> --team <name of the {{site.data.reuse.icp}} team that the user is imported into>`

The user can authenticate and sign in to the {{site.data.reuse.short_name}} UI after the command runs successfully.
