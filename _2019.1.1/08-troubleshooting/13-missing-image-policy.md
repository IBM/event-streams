---
title: "Chart deployment fails with 'no matching repositories in the ImagePolicies' error"
excerpt: "Chart deployment fails because one or more required repositories are missing from the deployed image policies."
categories: troubleshooting
slug: image-policy-missing-repository
toc: true
---

## Symptoms

When the {{site.data.reuse.long_name}} chart is deployed, an `Internal service error` occurs stating that there are `no matching repositories in the ImagePolicies`.

## Causes

Image policies are used to control access to Docker repositories and it is necessary to ensure that there is a suitable policy in place before the chart is installed.

This situation occurs when there are image policies defined for the namespace into which the chart is being deployed, but none of them include the required repositories. To confirm this, list the image policies defined as follows:

```
kubectl get imagepolicy
```

For each image policy, you can check which repositories it includes as follows:

```
kubectl describe imagepolicy <imagePolicyName>
```

If you are using {{site.data.reuse.long_name}} (not the {{site.data.reuse.ce_short}}), you will need access to the following image repositories:

* docker.io
* mycluster.icp:8500

If you are using {{site.data.reuse.ce_short}}, you need access to the following image repositories:

* docker.io

## Resolving the problem

To apply an image policy, create a new yaml file with the following content, replacing the namespace with the namespace into which the chart will be deployed and the name with a name of your choice. The following is an example where we are adding both repositories:

```
apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
kind: ImagePolicy
metadata:
  name: <imagePolicyName>
  namespace: <namespace>
spec:
  repositories:
  - name: docker.io/*
    policy: null
  - name: mycluster.icp:8500/*
    policy: null
```

Then run the following command to create the image policy:

```
kubectl apply -f <yamlFile>
```

Finally, repeat the installation steps to deploy the chart.
