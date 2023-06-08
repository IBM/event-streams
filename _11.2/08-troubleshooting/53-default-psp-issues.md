---
title: "Event Streams not installing due to Pod Security Policies (PSP) issues"
excerpt: "When the default Pod Security Policies (PSP) is updated by user or another operator, Event Streams does not install"
categories: troubleshooting
slug: default-psp-issues
toc: true
---

## Symptoms

For Kubernetes versions earlier than 1.24, {{site.data.reuse.short_name}} components report that an action is forbidden, stating that it is `unable to validate against any pod security policy`.

This might result in symptoms such as:

- Installation of the operator is pending and eventually times out.

  - Navigating to the **Conditions** section for the specific operator deployment under **Workloads > Deployment** displays a message similar to the following example:

    ```shell
    pods "eventstreams-cluster-operator-55d6f4cdf7-" is forbidden: unable to validate against any pod security policy: [spec.volumes[0]: Invalid value: "secret": secret volumes are not allowed to be used spec.volumes[1]: Invalid value: "secret": secret volumes are not allowed to be used]
    ```

- The installation of {{site.data.reuse.short_name}} instance is unsuccessful and the instance reports a `Failed` [status](../../installing/post-installation/).

  - The `conditions` field under status contains the following error message:

    ```shell
    Exceeded timeout of 300000ms while waiting for Pods resource
    light-insecure-zookeeper-0 in namespace es-1 to be ready
    ```

  - The status of the `<name-of-the-es-instance>-zookeeper` StrimziPodSet resource contains the following error message under the `conditions` field:

    ```shell
    pods "light-insecure-zookeeper-0" is forbidden: unable to validate against any pod security policy: [provider "anyuid": 
    Forbidden: not usable by user or serviceaccount, spec.volumes[3]: Invalid value: "secret": secret volumes are not allowed to be used,
    ```

- On a running instance of {{site.data.reuse.short_name}}, a pod that has bounced never comes back up.

  - Navigating to the **Conditions** section for the specific instance deployment under **Workloads > Deployment** displays a message similar to the following example:

  ```shell
  is forbidden: unable to validate against any pod security policy: [spec.initContainers[0].securityContext.readOnlyRootFilesystem: Invalid value: false: ReadOnlyRootFilesystem must be set to true spec.containers[0].securityContext.readOnlyRootFilesystem: Invalid value: false: ReadOnlyRootFilesystem must be set to true]
  ```

## Causes

{{site.data.reuse.short_name}} has been tested with the default `ibm-restricted-psp` Pod Security Policy (PSP) provided by IBM Cloud Pak.

If a user or any other operator applies a custom PSP that removes permissions that are required by {{site.data.reuse.short_name}}, then it will cause issues.

## Resolving the problem

Apply the custom Pod Security Policy (PSP) provided by [IBM Cloud Pak](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/ibm-restricted-psp.yaml){:target="_blank"} to enable permissions required by the product.

For information about applying the PSP, see the [Kubernetes documentation](https://v1-24.docs.kubernetes.io/docs/concepts/security/pod-security-policy){:target="_blank"}.

**Note:** Pod Security Policies (PSP) is removed from Kubernetes versions 1.25 and later.
