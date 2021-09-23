---
title: "Admin API pod does not start when using OpenShift 4.6"
excerpt: "The Admin API pod fails to start with an error stating that volume [kube-root-ca] cannot be mounted."
categories: troubleshooting
slug: admin-api-mount-failure
toc: true
---

## Symptoms

The Admin API pod fails to start when creating an {{site.data.reuse.short_name}} instance on {{site.data.reuse.openshift_short}} version 4.6, reporting a mount failure for volume `kube-root-ca`.

## Causes

The {{site.data.reuse.short_name}} Admin API pod uses the {{site.data.reuse.openshift_short}} ingress to query metrics data from Prometheus. The UI can then display the metrics in the monitoring and topics pages.

The REST client issuing the query requires access to the ingress CA certificate. The certificate exists in a ConfigMap called `kube-root-ca`. This ConfigMap is injected into all namespaces on {{site.data.reuse.openshift_short}} version 4.7 and later, but does not exist on version 4.6 and earlier.

## Resolving the problem

In the namespace where you are installing the {{site.data.reuse.short_name}} instance, create a ConfigMap called `kube-root-ca` and add the CA certificate to the ConfigMap. You can do this by copying the contents of the `default-ingress-cert` ConfigMap from the `openshift-config-managed` namespace as follows:
```
oc get cm default-ingress-cert --namespace=openshift-config-managed -o yaml | sed 's/name: default-ingress-cert/name: kube-root-ca/' | sed 's/namespace: openshift-config-managed/namespace: <target-namespace>/' | oc create -f -
```
