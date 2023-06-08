---
title: "Identity and Access Management (IAM): 403 error when signing in to Event Streams UI"
excerpt: "When signing into the Event Streams UI, the 403 Not Authorized page is displayed."
categories: troubleshooting
slug: ui-403-error
toc: true
---

## Symptoms

Signing into the {{site.data.reuse.short_name}} UI as an IAM user fails with the message `403 Not authorized`, indicating that the user does not have permission to access the {{site.data.reuse.short_name}} instance.

{{site.data.reuse.iam_note}}

## Causes

To access the {{site.data.reuse.short_name}} UI, the user must either have the `Cluster Administrator` role or the `Administrator` role and be in a team with a namespace resource added for the namespace containing the {{site.data.reuse.short_name}} instance. If neither of these applies, the error will be displayed.

## Resolving the problem

[Assign access to users](../../security/managing-access/#assigning-access-to-users) with an `Administrator` role by ensuring they are in a team with access to the correct namespace.
