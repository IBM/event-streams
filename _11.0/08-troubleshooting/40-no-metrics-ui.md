---
title: "Metrics do not display in operator Grafana dashboard"
excerpt: "The Event Streams Operators Grafana and UI monitoring dashboards do not display some or any metrics."
categories: troubleshooting
slug: no-metrics-ui
layout: redirects
toc: true
---

## Symptoms

One of the dashboards in the [Grafana service](../../administering/cluster-health/#grafana), the {{site.data.reuse.long_name}} Operators dashboard, does not display metrics.

## Causes

The `cluster-monitoring-config` ConfigMap is missing or the {{site.data.reuse.short_name}} metrics rules are not configured properly.

## Resolving the problem

Check if the [OpenShift monitoring for user-defined projects](https://docs.openshift.com/container-platform/4.8/monitoring/enabling-monitoring-for-user-defined-projects.html){:target="_blank"} is active . You can enable the monitoring by applying or modifying the `cluster-monitoring-config` ConfigMap.

If some of the {{site.data.reuse.short_name}} Kafka cluster metrics continue to be missing, complete the following steps:

1. [Upgrade](../../installing/upgrading/) to {{site.data.reuse.short_name}} 11.0.4, and change the name of the metrics ConfigMap in the `spec.strimziOverrides.kafka.metricsConfig.valueFrom.configMapKeyRef.name` and `spec.strimziOverrides.zookeeper.metricsConfig.valueFrom.configMapKeyRef.name` fields in the {{site.data.reuse.short_name}} custom resource . This will create a new ConfigMap with the specfied name and a set of default rules.
2. If the upgrade to {{site.data.reuse.short_name}} 11.0.4 is not possible, edit the `metrics-config` ConfigMap and add the following content specified:
  
  ```
  kind: ConfigMap
  apiVersion: v1
  metadata:
    name: metrics-config
  data:
    kafka-metrics-config.yaml: |
      lowercaseOutputName: true
      rules:
      - attrNameSnakeCase: false
        name: kafka_controller_$1_$2_$3
        pattern: kafka.controller<type=(\w+), name=(\w+)><>(Count|Value|Mean)
      - attrNameSnakeCase: false
        name: kafka_server_BrokerTopicMetrics_$1_$2
        pattern: kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec)><>(Count)
      - attrNameSnakeCase: false
        name: kafka_server_BrokerTopicMetrics_$1__alltopics_$2
        pattern: kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec)><>(OneMinuteRate)
      - attrNameSnakeCase: false
        name: kafka_server_ReplicaManager_$1_$2
        pattern: kafka.server<type=ReplicaManager, name=(\w+)><>(Value)
    zookeeper-metrics-config.yaml: |
      lowercaseOutputName: true
      rules: []
  ```

