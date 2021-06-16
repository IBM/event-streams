---
title: "Event Streams metrics unavailable"
excerpt: "Event Streams metrics are unavailable after upgrading to foundational services 3.8"
categories: troubleshooting
slug: metrics-not-available
toc: true
---

## Symptoms

After upgrading to {{site.data.reuse.icpfs}} version 3.8, the {{site.data.reuse.short_name}} UI monitoring page no longer displays the {{site.data.reuse.short_name}} metrics and the {{site.data.reuse.short_name}} custom dashboards no longer display data.

## Causes

{{site.data.reuse.short_name}} uses the Prometheus provided with {{site.data.reuse.fs}} to scrape and store metrics.  The {{site.data.reuse.short_name}} UI and the {{site.data.reuse.short_name}} custom dashboards are configured to use the data stored in this instance of Prometheus.

{{site.data.reuse.icpfs}} 3.8 and later does not include Prometheus.

## Resolving the problem

To scrape and store metrics, use the Prometheus provided with the {{site.data.reuse.openshift}}.

Reconfigure {{site.data.reuse.short_name}} to utilize the {{site.data.reuse.openshift_short}} Prometheus instance.

1. Enable [OpenShift monitoring for user-defined projects](https://docs.openshift.com/container-platform/4.6/monitoring/enabling-monitoring-for-user-defined-projects.html){:target="_blank"}.
2. Create the following `podmonitor` custom resources:

```
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: <release>-kafka
  namespace: <namespace>
spec:
  podMetricsEndpoints:
  - port: tcp-prometheus
    scheme: http
  selector:
    matchLabels:
      eventstreams.ibm.com/cluster: <release>
      eventstreams.ibm.com/kind: Kafka
      eventstreams.ibm.com/name: <release>-kafka

```


```

apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: <release>-metrics
  namespace: <namespace>
spec:
  podMetricsEndpoints:
  - port: metrics
    scheme: http
  selector:
    matchLabels:
      eventstreams.ibm.com/name: <release>-ibm-es-metrics

```

After a period of time (testing showed 20 minutes), the {{site.data.reuse.short_name}} custom Kafka dashboard displays metrics.

For information about accessing the Kafka dashboard, see [monitoring cluster health using Grafana](../../administering/cluster-health/#grafana).

You can use the metrics displayed in this dashboard for monitoring the {{site.data.reuse.short_name}} cluster. The dashboard provides the equivalent information that would be displayed in the {{site.data.reuse.short_name}} UI.
