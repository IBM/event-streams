---
title: "KafkaConnectS2I build fails in an air-gapped installation"
excerpt: "KafkaConnectS2I build fails in an air-gapped installation."
categories: troubleshooting
slug: kcs2i-airgapped
toc: true
---

## Symptoms

The following error message is displayed when installing `KafkaConnectS2I` in an air-gapped environment:

```
unknown: unable to pull manifest from cp.icr.io/cp/ibm-eventstreams-kafka@sha256:a508bbc97cba7643a521c772a5ade4bd20dfa169156cafd4fda4d0614b3ad61b: Get https://cp.icr.io/v2/: dial tcp: lookup cp.icr.io on 10.166.0.10:53: no such host
```

## Causes

In an isolated system, there is no network access to the entitled image registry `cp.icr.io`.

## Resolving the problem

To resolve the error, place the correct image into the cluster's internal registry as follows.

**Note:** The `<RELEASE_SHA>` in the following instructions is the SHA output in the error message. In the example mentioned earlier, it is `a508bbc97cba7643a521c772a5ade4bd20dfa169156cafd4fda4d0614b3ad61b`

1. Log in to the entitled registry:

   `docker login cp.icr.io`

2. Pull the image:

   `docker pull cp.icr.io/cp/ibm-eventstreams-kafka@sha256:<RELEASE_SHA>`

3. Tag the image:

   `docker tag cp.icr.io/cp/ibm-eventstreams-kafka@sha256:<RELEASE_SHA> default-route-openshift-image-registry.apps.<CLUSTER_NAME>/<NAMESPACE>/ibm-eventstreams-kafka:fix`

4. If not already done, expose the {{site.data.reuse.openshift_short}} registry with the following command:

   `oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge`

5. Log in to the {{site.data.reuse.openshift_short}} registry:

   `docker login -u any_value -p $(oc whoami -t) default-route-openshift-image-registry.apps.<CLUSTER_NAME>`.

   **Note:** You might need to add your registry to your list of insecure registries in [Docker](https://docs.docker.com/registry/insecure/).

6. Push the tagged image:

   `docker push default-route-openshift-image-registry.apps.<CLUSTER_NAME>/<NAMESPACE>/ibm-eventstreams-kafka:fix`

7. Modify the `KafkaConnectS2I` custom resource to add the `image` property under the `spec`:

   ```
   spec:
       image:  image-registry.openshift-image-registry.svc:5000/<NAMESPACE>/ibm-eventstreams-kafka:fix
   ```

After following the steps, the correct image is added to the cluster's internal registry, and the error message will no longer be displayed.
