---
title: "Cannot add schemas when using IBM Cloud Private 3.1.2"
excerpt: "Cannot add schemas after a successful upgrade or installation."
categories: troubleshooting
slug: cannot-add-schemas-icp312
toc: true
---

## Symptoms

If you are using {{site.data.reuse.icp}} 3.1.2, and upgrade to {{site.data.reuse.short_name}} 2019.2.1, or install 2019.2.1 on an {{site.data.reuse.icp}} 3.1.2 instance that already has or had a previous {{site.data.reuse.short_name}} installation, then the option to add schemas and schema versions are not available after a successful upgrade or installation.

The **Add schema** and **Add schema version** buttons are not available in the UI, and you cannot add schemas or schema versions by using the {{site.data.reuse.short_name}} CLI. For example, when running the `cloudctl es schema-add` command when logged in as a user with the correct permissions (Administrator or Operator roles), the following error is displayed:

```
cloudctl es schema-add /Users/jsmith/qp/schemas/ABC_schema_1.0.0.avsc
FAILED
Event Streams API request failed:
Error response from server. Status code: 403. Forbidden

Unable to add version 1.0.0 of schema ABC_schema to the registry.
```

## Causes

{{site.data.reuse.icp}} 3.1.2 authentication does not automatically pick up the new schema registry IAM roles if roles have been set up as part of a previous {{site.data.reuse.short_name}} installation on the same {{site.data.reuse.icp}} instance. This happens even when using a different namespace.

## Resolving the problem

To update the user permissions, roll the `auth-pdp` pods to pick up the new roles as follows:

1. {{site.data.reuse.icp_cli_login}}
2. List the names of the `auth-pdp` pods:\\
   `kubectl get pods -n kube-system | grep auth-pdp`
3. Delete the `auth-pdp` pods by running the following command for each `auth-pdp` pod:\\
   `kubectl delete pods -n kube-system <auth-pdp-pod-name>`
4. Wait for the new `auth-pdp` pods to be installed automatically.
5. Refresh the {{site.data.reuse.short_name}} UI. The **Add schema** and **Add schema version** buttons are now available in the UI. The command line options also work (for example, `cloudctl es schema-add`).
