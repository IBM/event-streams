---
title: "Metrics do not display in operator Grafana dashboard"
excerpt: "The Event Streams Operators Grafana dashboard does not display any information."
categories: troubleshooting
slug: no-metrics-ui
toc: true
---

## Symptoms

One of the dashboards in the [Grafana service](../../administering/cluster-health/#grafana), the {{site.data.reuse.long_name}} Operators dashboard, does not display metrics.

## Causes

The {{site.data.reuse.short_name}} metrics are not provided to Prometheus.

## Resolving the problem

Add the following `PodMonitor` to your namespace where {{site.data.reuse.short_name}} is installed.

1. in the {{site.data.reuse.openshift_short}} web console, go to **Search** in the navigation on the left.
2. Search for `PosMonitor` in **Resources**.
3. Click **Create PodMonitor**.
4. Add the following snippet, and replace `<namespace>` with the namespace where your {{site.data.reuse.short_name}} is installed:

   ```
   apiVersion: monitoring.coreos.com/v1
   kind: PodMonitor
   metadata:
     name: operator-metrics
     namespace: <namespace>
   spec:
     podMetricsEndpoints:
       - port: metrics
         scheme: http
     selector:
       matchLabels:
         app.kubernetes.io/name: eventstreams-operator
         eventstreams.ibm.com/kind: cluster-operator
   ```

5. Click **Create**. The {{site.data.reuse.short_name}} Operators dashboard will display metrics after a few minutes.
