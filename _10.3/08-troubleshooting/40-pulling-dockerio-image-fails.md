---
title: "Pulling images for Event Streams 10.3.0 fails"
excerpt: "Event Streams 10.3.0 installation fails: re-direct to pull images from to icr.io"
categories: troubleshooting
slug: dockerio-image-pull-fails
toc: true
---

## Symptoms

Installing {{site.data.reuse.short_name}} 10.3.0 fails to pull images from `docker.io` with `ImagePullBack` errors.

## Cause 

These images are no longer available to pull from `docker.io` and are instead placed in the IBM Container Registry `icr.io`.

## Resolving the problem

To resolve this issue, apply the following YAML to your cluster to add a new `ImageContentSourcePolicy`:

```
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: example
spec:
  repositoryDigestMirrors:
    - mirrors:
        - icr.io/cpopen
      source: docker.io/ibmcom
```