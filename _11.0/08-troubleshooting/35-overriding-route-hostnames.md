---
title: "Unable to override external listener route host"
excerpt: "When using a CR instance to override external listener route host the change is not applied"
categories: troubleshooting
slug: overriding-route-hostnames
layout: redirects
toc: true
---

## Symptoms
When deploying an instance of {{site.data.reuse.short_name}} with an external listener and overriding the host by using `overrides.bootstrap/broker`, the host fields do not persist in the custom resource and the changes do not take effect.

```
spec:
  strimziOverrides:
    kafka:
      listeners:
        - name: external
          port: 9092
          tls:true
          type: route
            overrides:
              bootstrap:
                host: bootstrap.myhost.com
              brokers:
                - broker: 0
                  host: broker-0.myhost.com
```

## Causes
There are two `CustomResourceDefinitions` that are missing the `host` fields, and as such the {{site.data.reuse.openshift}} API server removes the fields when an instance of {{site.data.reuse.short_name}} is deployed containing those fields.

## Resolving the problem

1. Modify the two `CustomResourceDefinitions` that have been deployed when the {{site.data.reuse.short_name}} operator was installed:

   **bootstrap `host` property:**

   ```
   host:
     type: string
     description: Host for the bootstrap route. This
       field will be used in the `spec.host` field
       of the OpenShift Route.
   ```

   **broker host property:**

   ```
   host:
     type: string
     description: Host for the broker route. This
       field will be used in the `spec.host` field
       of the OpenShift Route.
   ```

2. Add the properties to the `strimziOverrides.kafka.listeners.external.overrides.(bootstrap|brokers)` schemas in the `eventstreams.eventstreams.ibm.com` `CustomResourceDefinition` as follows:

   `oc edit crd eventstreams.eventstreams.ibm.com`

   If the `apiVersion` is `apiextensions.k8s.io/v1`, edit as follows:

   ```
   apiVersion: apiextensions.k8s.io/v1
   ...
   spec:
     versions:
     - name: v1beta1
       schema:
         openAPIV3Schema:
           properties:
             spec:
               properties:
                 strimziOverrides:
                   properties:
                     kafka:
                       properties:
                         listeners:
                           properties:
                             external:
                               properties:
                                 overrides:
                                   properties:
                                     bootstrap:
                                       # ADD BOOTSTRAP HOST PROPERTY HERE
                                     ...
                                     brokers:
                                       items:
                                         properties:
                                           # ADD BROKER HOST PROPERTY HERE
                                     ...
   ```

   If the `apiVersion` is `apiextensions.k8s.io/v1beta1`, edit as follows:

   ```
   spec:
     validation:
       openAPIV3Schema:
         properties:
           spec:
             properties:
               strimziOverrides:
                 properties:
                   kafka:
                     properties:
                       listeners:
                         properties:
                           external:
                             properties:
                               overrides:
                                 properties:
                                   bootstrap:
                                     # ADD BOOTSTRAP HOST PROPERTY HERE
                                   ...
                                   brokers:
                                     items:
                                       properties:
                                         # ADD BROKER HOST PROPERTY HERE
                                   ...
   ```

3. Add the properties to the `kafka.listeners.external.overrides.(bootstrap|brokers)` schemas in the `kafkas.eventstreams.ibm.com` `CustomResourceDefinition` as follows:

   `oc edit crd kafkas.eventstreams.ibm.com`

   If the `apiVersion` is `apiextensions.k8s.io/v1`, edit as follows:

   ```
   apiVersion: apiextensions.k8s.io/v1
   ...
   spec:
     versions:
     - name: v1beta1
       schema:
         openAPIV3Schema:
           properties:
             spec:
               properties:
                 kafka:
                   properties:
                     listeners:
                       properties:
                         external:
                           properties:
                             overrides:
                               properties:
                                 bootstrap:
                                   # ADD BOOTSTRAP HOST PROPERTY HERE
                                 ...
                                 brokers:
                                   items:
                                     properties:
                                       # ADD BROKER HOST PROPERTY HERE
                                 ...
   ```

   If the `apiVersion` is `apiextensions.k8s.io/v1beta1`, edit as follows:

   ```
   spec:
     validation:
       openAPIV3Schema:
         properties:
           spec:
             properties:
               kafka:
                 properties:
                   listeners:
                     properties:
                       external:
                         properties:
                           overrides:
                             properties:
                               bootstrap:
                                 # ADD BOOTSTRAP HOST PROPERTY HERE
                               ...
                               brokers:
                                 items:
                                   properties:
                                     # ADD BROKER HOST PROPERTY HERE
                               ...
   ```

**Note:** If you uninstall or change the operator version, the `CustomResourceDefinitions` will be overridden. You will need to patch the values again.

<!--
When the issue is resolved, update this section to include:
"Resolved in Event Streams x.y.z"
-->
