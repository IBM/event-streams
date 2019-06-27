---
title: "Cannot add schemas after installing earlier Event Streams version"
excerpt: "Installing earlier Event Streams version in the same IBM Cloud Private causes authentication failures when attempting to use schemas."
categories: troubleshooting
slug: cannot-add-schemas-earlier-install
toc: true
---

## Symptoms

If you install an earlier version of Event Streams on an {{site.data.reuse.icp}} instance that already has an installation of {{site.data.reuse.short_name}} 2019.2.1, then the option to add schemas and schema versions becomes unavailable on the {{site.data.reuse.short_name}} 2019.2.1 installation.

The **Add schema** and **Add schema version** buttons are not available in the UI, and you cannot add schemas or schema versions by using the {{site.data.reuse.short_name}} CLI. For example, when running the `cloudctl es schema-add` command when logged in as a user with the correct permissions (Administrator or Operator roles), the following error is displayed:

```
cloudctl es schema-add /Users/jsmith/qp/schemas/ABC_schema_1.0.0.avsc
FAILED
Event Streams API request failed:
Error response from server. Status code: 403. Forbidden

Unable to add version 1.0.0 of schema ABC_schema to the registry.
```

## Causes

The IAM roles for schema registry authentication that are set up as part of the {{site.data.reuse.short_name}} 2019.2.1 installation are overwritten by the installation of an earlier version of {{site.data.reuse.short_name}} on the same {{site.data.reuse.icp}} instance. This happens even when using a different namespace.

## Resolving the problem

Restore the IAM roles for the schema registry authentication:

1. {{site.data.reuse.icp_cli_login}}
2. List the ConfigMaps in the {{site.data.reuse.short_name}} 2019.2.1 installation:\\
   `kubectl get configmaps -n <namespace>`
2. Find the role mappings ConfigMap from the list of ConfigMaps in the 2019.2.1 installation by looking for the ConfigMap with suffix `role-mappings-cm`.
3. Download and save the configuration for the job stored in the ConfigMap:\\
   `kubectl get configmap <RELEASE_NAME>-ibm-es-role-mappings-cm -o jsonpath='{.data.job}' > role-mappings-job.yml`
4. Run the following command to restore the security role mappings:\\
   `kubectl create -f ./role-mappings-job.yml`
