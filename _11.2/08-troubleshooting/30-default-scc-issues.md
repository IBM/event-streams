---
title: "Event Streams not installing due to Security Context Constraint (SCC) issues"
excerpt: "When the default Security Context Constraint (SCC) is updated by user or another operator, Event Streams does not install"
categories: troubleshooting
slug: default-scc-issues
toc: true
---

## Symptoms

{{site.data.reuse.short_name}} components report that an action is forbidden, stating that it is `unable to validate against any security context constraint`.

This could result in symptoms such as:

- Installation of the operator is pending and eventually times out.

    - Navigating to the **Conditions** section for the specific operator deployment under **Workloads > Deployment** will display a message similar to the following example:
 ```
 pods "eventstreams-cluster-operator-55d6f4cdf7-" is forbidden: unable to validate against any security context constraint: [spec.volumes[0]: Invalid value: "secret": secret volumes are not allowed to be used spec.volumes[1]: Invalid value: "secret": secret volumes are not allowed to be used]
 ```

- The installation of {{site.data.reuse.short_name}} instance is unsuccessful and the instance reports a `Failed` [status](../../installing/post-installation/).

    - The `conditions` field under status contains the following error message:
    ```
    Exceeded timeout of 300000ms while waiting for Pods resource
    light-insecure-zookeeper-0 in namespace es-1 to be ready
    ```

    - The status of the `<name-of-the-es-instance>-zookeeper` StrimziPodSet resource contains the following error message under the `conditions` field:
    ```
    pods "light-insecure-zookeeper-0" is forbidden: unable to validate against any security context constraint: [provider "anyuid": 
    Forbidden: not usable by user or serviceaccount, spec.volumes[3]: Invalid value: "secret": secret volumes are not allowed to be used,
    ```       

- On a running instance of {{site.data.reuse.short_name}}, a pod that has bounced never comes back up.

    - Navigating to the **Conditions** section for the specific instance deployment under **Workloads > Deployment** will display a message similar to the following example:
```
is forbidden: unable to validate against any security context constraint: [spec.initContainers[0].securityContext.readOnlyRootFilesystem: Invalid value: false: ReadOnlyRootFilesystem must be set to true spec.containers[0].securityContext.readOnlyRootFilesystem: Invalid value: false: ReadOnlyRootFilesystem must be set to true]
```

## Causes

{{site.data.reuse.short_name}} has been tested with the default `restricted-v2` Security Context Constraint (SCC) provided by the {{site.data.reuse.openshift_short}}.

If a user or any other operator applies a custom SCC that removes permissions required by {{site.data.reuse.short_name}}, then this will cause issues.

## Resolving the problem

Apply the custom Security Context Constraint (SCC) provided by [{{site.data.reuse.short_name}}](https://github.com/IBM/ibm-event-automation/tree/master/event-streams){:target="_blank"} to enable permissions required by the product.

To do this, edit the `eventstreams-scc.yaml` file to add your namespace and apply it using `oc` tool as follows:

1. Edit the `eventstreams-scc.yaml` and add the namespace where your {{site.data.reuse.short_name}} instance is installed.

2. {{site.data.reuse.openshift_cli_login}}

3. Run the following command to apply the SCC:

    `oc apply -f <custom_scc_file_path>`

    For example: `oc apply -f eventstreams-scc.yaml`
