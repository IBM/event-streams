---
title: "Setting up alert notifications to Slack"
description: "Receive notifications about the health of your cluster based on monitored metrics."
permalink: /tutorials/monitoring-alerts/
toc: true
section: "Tutorials for IBM Event Streams"
cardType: "large"
---

Receiving notifications based on monitored metrics is an important way of keeping an eye on the health of your cluster. You can set up notifications to be sent to applications like Slack based on pre-defined triggers.

The following tutorial shows an example of how to set up alert notifications to be sent to Slack based on metrics from {{site.data.reuse.short_name}}.

## Prerequisites

- Ensure you have an {{site.data.reuse.short_name}} installation available. This tutorial is based on {{site.data.reuse.short_name}} version 11.0.2 installed on {{site.data.reuse.openshift}} 4.8.43.
- Ensure you have [Slack](https://slack.com/){:target="_blank"} installed and ready to use. This tutorial is based on Slack version 4.28.171.
- You need to be a Workplace Administrator to add apps to a Slack channel.

## Preparing Slack

To send notifications from {{site.data.reuse.short_name}} to your Slack channel, configure an incoming webhook URL within your Slack service. The webhook URL provided by Slack is required for the integration steps later in this section. To create the webhook URL:

1. Open Slack and go to your Slack channel where you want the notifications to be sent.
2. From your Slack channel click the icon for **Channel Settings**, and select **Add apps** or **Add an app** depending on the Slack plan you are using.
3. Search for "Incoming Webhooks".
4. Click **Add configuration**.
5. Select the channel that you want to post to.
6. Click **Add Incoming Webhooks integration**.
7. Copy the URL in the **Webhook URL** field.

For more information about incoming webhooks in Slack, see the [Slack documentation](https://api.slack.com/incoming-webhooks){:target="_blank"}.

## Installing the Prometheus server

In this tutorial, we will use the Prometheus Operator to launch the Prometheus server and install Prometheus Alertmanager. The Prometheus Operator will initially be implemented in the same namespace as {{site.data.reuse.short_name}}. The following resources are required to launch a Prometheus server after installing the Prometheus Operator.

- ClusterRole
- ServiceAccount
- ClusterRoleBinding
- Prometheus

The YAML file for installing these resources is available on [GitHub](https://github.com/strimzi/strimzi-kafka-operator/blob/main/examples/metrics/prometheus-install/prometheus.yaml){:target="_blank"}.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus-server
  labels:
    app: strimzi
rules:
  - apiGroups: [""]
    resources:
      - nodes
      - nodes/proxy
      - services
      - endpoints
      - pods
    verbs: ["get", "list", "watch"]
  - apiGroups:
      - extensions
    resources:
      - ingresses
    verbs: ["get", "list", "watch"]
  - nonResourceURLs: ["/metrics"]
    verbs: ["get"]

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus-server
  labels:
    app: strimzi

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus-server
  labels:
    app: strimzi
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-server
subjects:
  - kind: ServiceAccount
    name: prometheus-server
    namespace: <namespace>

---
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  labels:
    app: strimzi
spec:
  replicas: 1
  serviceAccountName: prometheus-server
  podMonitorSelector:
    matchLabels:
      app: strimzi
  serviceMonitorSelector: {}
  resources:
    requests:
      memory: 400Mi
  enableAdminAPI: false
  ruleSelector:
    matchLabels:
      role: alert-rules
      app: strimzi
  alerting:
    alertmanagers:
    - namespace: <namespace>
      name: alertmanager
      port: alertmanager
```

Replace `<namespace>` with the namespace where your {{site.data.reuse.short_name}} instance is installed. After applying this YAML, it will bring up a Prometheus server. You can access the Prometheus server by applying a route that points to the `prometheus-operated` service.

The following is an example route to access the Prometheus server.

```yaml
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: prometheus
  namespace: <namespace>
spec:
  path: /
  to:
    kind: Service
    name: prometheus-operated
    weight: 100
  port:
    targetPort: web
```

## Installing Alertmanager

Alertmanager handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integration, for example, email, PagerDuty, or Slack. It also takes care of silencing and inhibiting alerts. For more information about Prometheus Alertmanager, see the [Prometheus documentation](https://prometheus.io/docs/alerting/latest/configuration/){:target="_blank"}.

We will deploy an Alertmanager service in order to create a route to the Alertmanager user interface. The following example deploys an Alertmanager with port 9093 configured for the service.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  name: alertmanager
  labels:
    app: strimzi
spec:
  replicas: 1
---
apiVersion: v1
kind: Service
metadata:
  name: alertmanager
  labels:
    app: strimzi
spec:
  ports:
    - name: alertmanager
      port: 9093
      targetPort: 9093
      protocol: TCP
  selector:
    alertmanager: alertmanager
  type: ClusterIP
```

The following route provides access to the Alertmanager user interface.

```yaml
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: alertmanager
  namespace: <namespace>
spec:
  path: /
  to:
    kind: Service
    name: alertmanager-operated
    weight: 100
  port:
    targetPort: web
  wildcardPolicy: None
```

## Slack Integration

Define the Slack channel as the receiver using the incoming webhook you copied earlier, and also set up the notification details such as the channel to post to, the content format, and criteria for the events to send to Slack. Settings to configure include the following:

- `slack_api_url`: The incoming webhook generated in Slack earlier.
- `send_resolved`: Set to `true` to send notifications about resolved alerts.
- `channel`: The Slack channel to send the notifications to.
- `username`: The username that posts the alert notifications to the channel.

For more information about the configuration settings to enter for Slack notifications, see the [Prometheus documentation](https://prometheus.io/docs/alerting/configuration/#slack_config){:target="_blank"}.

The content for the posts can be customized, see the following [blog](https://medium.com/quiq-blog/better-slack-alerts-from-prometheus-49125c8c672b){:target="_blank"} for Slack alert examples from Prometheus.

For example, to set up Slack notifications for your alert rule created earlier:

```yaml
{% raw %}
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-alertmanager
type: Opaque
stringData:
  alertmanager.yaml: |
    global:
      slack_api_url: <slack_api_url>
    route:
      receiver: slack
    receivers:
    - name: slack
      slack_configs:
      - channel: "<channel>"
        # The username to post alerts as
        username: "<username>"

        # An icon for posts in Slack
        icon_url: https://ibm.github.io/event-streams/images/es_icon_light.png

        #
        # The content for posts to Slack when alert conditions are fired
        # Improves on the formatting from the default, with support for handling
        #  alerts containing multiple events.
        # (Modified from the examples in
        #   https://medium.com/quiq-blog/better-slack-alerts-from-prometheus-49125c8c672b)
        title: |-{% raw %}
          [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ if or (and (eq (len .Alerts.Firing) 1) (eq (len .Alerts.Resolved) 0)) (and (eq (len .Alerts.Firing) 0) (eq (len .Alerts.Resolved) 1)) }}{{ range .Alerts.Firing }} @ {{ .Annotations.identifier }}{{ end }}{{ range .Alerts.Resolved }} @ {{ .Annotations.identifier }}{{ end }}{{ end }}
        text: |-
          {{ if or (and (eq (len .Alerts.Firing) 1) (eq (len .Alerts.Resolved) 0)) (and (eq (len .Alerts.Firing) 0) (eq (len .Alerts.Resolved) 1)) }}
          {{ range .Alerts.Firing }}{{ .Annotations.description }}{{ end }}{{ range .Alerts.Resolved }}{{ .Annotations.description }}{{ end }}
          {{ else }}
          {{ if gt (len .Alerts.Firing) 0 }}
          *Alerts Firing:*
          {{ range .Alerts.Firing }}- {{ .Annotations.identifier }}: {{ .Annotations.description }}
          {{ end }}{{ end }}
          {{ if gt (len .Alerts.Resolved) 0 }}
          *Alerts Resolved:*
          {{ range .Alerts.Resolved }}- {{ .Annotations.identifier }}: {{ .Annotations.description }}
          {{ end }}{{ end }}
          {{ end }}
        send_resolved: true
        {% endraw %}
```

## Selecting the metrics to monitor

In the `EventStreams` custom resource, you can configure a ConfigMap path as the `metricsConfig`. In the configuration map, you can specify the metrics you want to monitor.

The following is an example of configuring the `metricsConfig` in the `EventStreams` custom resource:

```yaml
metricsConfig:
  type: jmxPrometheusExporter
  valueFrom:
    configMapKeyRef:
      key: kafka-metrics-config.yaml
      name: metrics-config
```

The metrics are exported by means of the JMX Prometheus Exporter. For more information about the exporter, see the following [Github page](https://github.com/prometheus/jmx_exporter){:target="_blank"}.

The following is an example of various metrics that can be collected from both ZooKeeper and Kafka.

```yaml
{% raw %}
kind: ConfigMap
apiVersion: v1
metadata:
  name: kafka-metrics
  labels:
    app: strimzi
data:
  kafka-metrics-config.yaml: |
    lowercaseOutputName: true
    rules:
    # Special cases and very specific rules
    - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value
      name: kafka_server_$1_$2
      type: GAUGE
      labels:
       clientId: "$3"
       topic: "$4"
       partition: "$5"
    - pattern: kafka.server<type=(.+), partition=(.+)><>Value
      name: kafka_server_$1_partitioncount
      type: GAUGE
      labels:
       partition: "$1"
    - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value
      name: kafka_server_$1_$2
      type: GAUGE
      labels:
       clientId: "$3"
       broker: "$4:$5"
    - pattern: kafka.server<type=(.+), cipher=(.+), protocol=(.+), listener=(.+), networkProcessor=(.+)><>connections
      name: kafka_server_$1_connections_tls_info
      type: GAUGE
      labels:
        cipher: "$2"
        protocol: "$3"
        listener: "$4"
        networkProcessor: "$5"
    - pattern: kafka.server<type=(.+), clientSoftwareName=(.+), clientSoftwareVersion=(.+), listener=(.+), networkProcessor=(.+)><>connections
      name: kafka_server_$1_connections_software
      type: GAUGE
      labels:
        clientSoftwareName: "$2"
        clientSoftwareVersion: "$3"
        listener: "$4"
        networkProcessor: "$5"
    - pattern: "kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+):"
      name: kafka_server_$1_$4
      type: GAUGE
      labels:
       listener: "$2"
       networkProcessor: "$3"
    - pattern: kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+)
      name: kafka_server_$1_$4
      type: GAUGE
      labels:
       listener: "$2"
       networkProcessor: "$3"
    # Some percent metrics use MeanRate attribute
    # Ex) kafka.server<type=(KafkaRequestHandlerPool), name=(RequestHandlerAvgIdlePercent)><>MeanRate
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>MeanRate
      name: kafka_$1_$2_$3_percent
      type: GAUGE
    # Generic gauges for percents
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>Value
      name: kafka_$1_$2_$3_percent
      type: GAUGE
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*, (.+)=(.+)><>Value
      name: kafka_$1_$2_$3_percent
      type: GAUGE
      labels:
        "$4": "$5"
    # Generic per-second counters with 0-2 key/value pairs
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
    # Generic gauges with 0-2 key/value pairs
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
    # Emulate Prometheus 'Summary' metrics for the exported 'Histogram's.
    # Note that these are missing the '_sum' metric!
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*), (.+)=(.+)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        "$6": "$7"
        quantile: "0.$8"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        quantile: "0.$6"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        quantile: "0.$4"
  zookeeper-metrics-config.yaml: |
    lowercaseOutputName: true
    rules:
    # replicated Zookeeper
    - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+)><>(\\w+)"
      name: "zookeeper_$2"
      type: GAUGE
    - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+)><>(\\w+)"
      name: "zookeeper_$3"
      type: GAUGE
      labels:
        replicaId: "$2"
    - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+)><>(Packets\\w+)"
      name: "zookeeper_$4"
      type: COUNTER
      labels:
        replicaId: "$2"
        memberType: "$3"
    - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+)><>(\\w+)"
      name: "zookeeper_$4"
      type: GAUGE
      labels:
        replicaId: "$2"
        memberType: "$3"
    - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+), name3=(\\w+)><>(\\w+)"
      name: "zookeeper_$4_$5"
      type: GAUGE
      labels:
        replicaId: "$2"
        memberType: "$3"{% endraw %}
```

For example, to test the triggering of alerts, you can monitor the total number of partitions for all topics by using the `kafka_server_replicamanager_partitioncount_value` metric. When topics are created, this metric can trigger notifications.

For production environments, a good metric to monitor is the number of under-replicated partitions as it tells you about potential problems with your Kafka cluster, such as load or network problems where the cluster becomes overloaded and followers are not able to catch up on leaders. Under-replicated partitions might be a temporary problem, but if it continues for longer, it probably requires urgent attention. An example is to set up a notification trigger to your Slack channel if the number of under-replicated partitions is greater than 0 for more than a minute. You can do this with the `kafka_server_replicamanager_underreplicatedpartitions_value` metric.

The examples in this tutorial show you how to set up monitoring for a number of metrics, with the purpose of testing notification triggers, and also to have a production environment example.

**Note:** Not all of the metrics that Kafka uses are published to Prometheus by default. The metrics that are published are controlled by a ConfigMap. You can publish metrics by adding them to the ConfigMap.

For information about the different metrics, see [Monitoring Kafka](https://kafka.apache.org/documentation/#monitoring){:target="_blank"}.

## Setting the alert rule

To set up the alert rule and define the trigger criteria, use the `PrometheusRule` custom resource.

The following YAML configuration will configure Prometheus rules to deliver various alerts to Slack; for example: `The zookeeper is running out of free storage space` or `The consumer group lag is too great`.

```yaml
{% raw %}
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: alert-rules
    app: strimzi
  name: prometheus-k8s-rules
spec:
  groups:
  - name: kafka
    rules:
    - alert: KafkaRunningOutOfSpace
      expr: kubelet_volume_stats_available_bytes{persistentvolumeclaim=~"data(-[0-9]+)?-(.+)-kafka-[0-9]+"} * 100 / kubelet_volume_stats_capacity_bytes{persistentvolumeclaim=~"data(-[0-9]+)?-(.+)-kafka-[0-9]+"} < 15
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka is running out of free disk space'
        description: 'There are only {{ $value }} percent available at {{ $labels.persistentvolumeclaim }} PVC'
    - alert: UnderReplicatedPartitions
      expr: kafka_server_replicamanager_underreplicatedpartitions > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka under replicated partitions'
        description: 'There are {{ $value }} under replicated partitions on {{ $labels.kubernetes_pod_name }}'
    - alert: AbnormalControllerState
      expr: sum(kafka_controller_kafkacontroller_activecontrollercount) by (strimzi_io_name) != 1
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka abnormal controller state'
        description: 'There are {{ $value }} active controllers in the cluster'
    - alert: OfflinePartitions
      expr: sum(kafka_controller_kafkacontroller_offlinepartitionscount) > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka offline partitions'
        description: 'One or more partitions have no leader'
    - alert: UnderMinIsrPartitionCount
      expr: kafka_server_replicamanager_underminisrpartitioncount > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka under min ISR partitions'
        description: 'There are {{ $value }} partitions under the min ISR on {{ $labels.kubernetes_pod_name }}'
    - alert: OfflineLogDirectoryCount
      expr: kafka_log_logmanager_offlinelogdirectorycount > 0
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Kafka offline log directories'
        description: 'There are {{ $value }} offline log directories on {{ $labels.kubernetes_pod_name }}'
    - alert: ScrapeProblem
      expr: up{kubernetes_namespace!~"openshift-.+",kubernetes_pod_name=~".+-kafka-[0-9]+"} == 0
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'Prometheus unable to scrape metrics from {{ $labels.kubernetes_pod_name }}/{{ $labels.instance }}'
        description: 'Prometheus was unable to scrape metrics from {{ $labels.kubernetes_pod_name }}/{{ $labels.instance }} for more than 3 minutes'
    - alert: ClusterOperatorContainerDown
      expr: count((container_last_seen{container="strimzi-cluster-operator"} > (time() - 90))) < 1 or absent(container_last_seen{container="strimzi-cluster-operator"})
      for: 1m
      labels:
        severity: major
      annotations:
        summary: 'Cluster Operator down'
        description: 'The Cluster Operator has been down for longer than 90 seconds'
    - alert: KafkaBrokerContainersDown
      expr: absent(container_last_seen{container="kafka",pod=~".+-kafka-[0-9]+"})
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'All `kafka` containers down or in CrashLookBackOff status'
        description: 'All `kafka` containers have been down or in CrashLookBackOff status for 3 minutes'
    - alert: KafkaContainerRestartedInTheLast5Minutes
      expr: count(count_over_time(container_last_seen{container="kafka"}[5m])) > 2 * count(container_last_seen{container="kafka",pod=~".+-kafka-[0-9]+"})
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: 'One or more Kafka containers restarted too often'
        description: 'One or more Kafka containers were restarted too often within the last 5 minutes'
    - alert: KafkaUnderreplicatedPartitions
      expr: sum(kafka_server_replicamanager_underreplicatedpartitions_value) by (job) > 0
      labels:
        severity: warning
      annotations:
        summary: Kafka cluster {{$labels.job}} has underreplicated partitions
        description: The Kafka cluster {{$labels.job}} has {{$value}} underreplicated partitions
    - alert: KafkaOfflinePartitions
      expr: sum(kafka_server_replicamanager_underreplicatedpartitions_value) by (job) > 0
      labels:
        severity: critical
      annotations:
        summary: Kafka cluster {{$labels.job}} has offline partitions
        description: The Kafka cluster {{$labels.job}} has {{$value}} offline partitions
  - name: zookeeper
    rules:
    - alert: AvgRequestLatency
      expr: zookeeper_avgrequestlatency > 10
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Zookeeper average request latency'
        description: 'The average request latency is {{ $value }} on {{ $labels.kubernetes_pod_name }}'
    - alert: OutstandingRequests
      expr: zookeeper_outstandingrequests > 10
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Zookeeper outstanding requests'
        description: 'There are {{ $value }} outstanding requests on {{ $labels.kubernetes_pod_name }}'
    - alert: ZookeeperRunningOutOfSpace
      expr: kubelet_volume_stats_available_bytes{persistentvolumeclaim=~"data-(.+)-zookeeper-[0-9]+"} < 5368709120
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: 'Zookeeper is running out of free disk space'
        description: 'There are only {{ $value }} bytes available at {{ $labels.persistentvolumeclaim }} PVC'
    - alert: ZookeeperContainerRestartedInTheLast5Minutes
      expr: count(count_over_time(container_last_seen{container="zookeeper"}[5m])) > 2 * count(container_last_seen{container="zookeeper",pod=~".+-zookeeper-[0-9]+"})
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: 'One or more Zookeeper containers were restarted too often'
        description: 'One or more Zookeeper containers were restarted too often within the last 5 minutes. This alert can be ignored when the Zookeeper cluster is scaling up'
    - alert: ZookeeperContainersDown
      expr: absent(container_last_seen{container="zookeeper",pod=~".+-zookeeper-[0-9]+"})
      for: 3m
      labels:
        severity: major
      annotations:
        summary: 'All `zookeeper` containers in the Zookeeper pods down or in CrashLookBackOff status'
        description: 'All `zookeeper` containers in the Zookeeper pods have been down or in CrashLookBackOff status for 3 minutes'{% endraw %}
```


### Example test setup

As mentioned earlier, to test the triggering of alerts, you can monitor the total number of partitions for all topics by using the `kafka_server_replicamanager_partitioncount_value` metric.

Define an alert rule that creates a notification if the number of partitions increases. To achieve this, add a new rule for `kafka_server_replicamanager_partitioncount_value`, and set the trigger conditions in the `expr` section, for example:

**Note:** In this example, we are setting a threshold value of 50 as the built-in consumer-offsets topic has 50 partitions by default already, and this topic is automatically created the first time a consumer application connects to the cluster. We will create a topic later with 10 partitions to [test](#testing) the firing of the alert and the subsequent notification to the Slack channel.

```yaml
{% raw %}
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: alert-rules
    app: strimzi
  name: partition-count
  namespace: <namespace>
spec:
  groups:
  - name: kafka
    rules:
      # Posts an alert if the number of partitions increases
      - alert: PartitionCount
        expr: kafka_server_replicamanager_partitioncount_value > 50
        for: 10s
        labels:
          # Labels should match the alert manager so that it is received by the Slack hook
          severity: critical
        # The contents of the Slack messages that are posted are defined here
        annotations:
          identifier: "Partition count"
          description: "There are {{ $value }} partition(s) reported by broker {{ $labels.kafka }}"
{% endraw %}
```

**Important:** As noted in the prerequisites, this tutorial is based on {{site.data.reuse.openshift}} 4.8.43.

To review your alert rules set up this way, use the `oc get PrometheusRules` command, for example:

```bash
$ oc get PrometheusRules
NAME                   AGE
prometheus-k8s-rules   1h
partition-count        1h
```

### Example production setup

As mentioned earlier, a good metric to monitor in production environments is the metric `kafka_server_replicamanager_underreplicatedpartitions_value`, for which we want to define an alert rule that creates a notification if the number of under-replicated partitions is greater than 0 for more than a minute. To achieve this, add a new rule for `kafka_server_replicamanager_underreplicatedpartitions_value`, and set the trigger conditions in the `data` section, for example:

```yaml
{% raw %}
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: alert-rules
    app: strimzi
  name: monitoring-prometheus-alertrules
  namespace: <namespace>
spec:
  groups:
  - name: alert.rules
    rules:
      # Posts an alert if there are any under-replicated partitions
      #  for longer than a minute
      - alert: under_replicated_partitions
        expr: kafka_server_replicamanager_underreplicatedpartitions_value > 0
        for: 1m
        labels:
          # Labels should match the alert manager so that it is received by the Slack hook
          severity: critical
        # The contents of the Slack messages that are posted are defined here
        annotations:
          identifier: "Under-replicated partitions"
          description: "There are {% raw %}{{ $value }}{% endraw %} under-replicated partition(s) reported by broker {% raw %}{{ $labels.kafka }}{% endraw %}"
```

**Important:** As noted in the prerequisites, this tutorial is based on {{site.data.reuse.openshift}} 4.8.43.

To review your alert rules set up this way, use the `oc get PrometheusRules` command, for example:

```bash
$ oc get PrometheusRules
NAME                          AGE
Under-replicated partitions   1h
```

You can also see the list of alerts in both the Prometheus UI and the Alertmanager UI.

The following are examples from both UIs.

- Prometheus Alert Page:

![Prometheus Alert Page](../../images/prometheus_alert_page.png "Prometheus alert page with list of alerts.")

- Alertmanager Home Page:

![Alertmanager Home Page](../../images/alertmanager_home_page.png "Alertmanager home page with list of alerts.")

Prometheus Sample Alert Rule:

![Prometheus alert rules](../../images/alert_rules.png "Screen capture showing the alert rule for the under_replicated_partitions alert in the Prometheus UI.")

Prometheus Sample Alert:

![Prometheus alert rules](../../images/alerts.png "Screen capture showing the details for the under_replicated_partitions alert in the Prometheus UI.")

## Testing

### Example test setup

To create a notification for the test setup, create a topic with 10 partitions as follows:

1. Log in to your IBM Event Streams UI.
2. Click the **Topics** tab.
3. Click **Create topic**.
4. Follow the instructions to create the topic, and set the **Partitions** value to 10.

The following notification is sent to the Slack channel when the topic is created:

![Alert firing message posted to Slack channel in test example](../../images/slack_alert_firing_test.png "Screen capture showing the firing message posted to the Slack channel by the PartitionCount alert.")

To create a resolution alert, delete the topic you created previously:

1. Log in to your IBM Event Streams UI.
2. Click the **Topics** tab.
3. Go to the topic you created and click ![More options icon](../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Delete this topic**.

When the topic is deleted, the following resolution alert is posted:

![Alert resolved message posted to Slack channel in test example](../../images/slack_alert_resolved_test.png "Screen capture showing the resolved message posted to the Slack channel by the PartitionCount alert.")

### Example production setup

For the production environment example, the following notification is posted to the Slack channel if the number of under-replicated partitions remains above 0 for a minute:

![Alert firing message posted to Slack channel in production example](../../images/slack_alert_firing.png "Screen capture showing the firing message posted to the Slack channel by the under_replicated_partitions alert.")

When the cluster recovers, a new resolution alert is posted when the number of under-replicated partitions returns to 0. This is based on the `send_resolved` setting (was set to `true`).

![Alert resolved message posted to Slack channel in production example](../../images/slack_alert_resolved.png "Screen capture showing the resolved message posted to the Slack channel by the under_replicated_partitions alert.")

## Setting up other notifications

You can use this example to set up alert notifications to other applications, including [HipChat](https://prometheus.io/docs/alerting/configuration/#hipchat_config){:target="_blank"}, [PagerDuty](https://prometheus.io/docs/alerting/configuration/#pagerduty_config){:target="_blank"}, [emails](https://prometheus.io/docs/alerting/configuration/#email_config){:target="_blank"}, and so on. You can also use this technique to generate HTTP calls, which lets you customize alerts when defining a flow in tools like [Node-RED](https://nodered.org/){:target="_blank"} or [IBM App Connect](https://developer.ibm.com/integration/docs/){:target="_blank"}.


### Troubleshooting

To obtain more log data, you can increase the logging level for the Alertmanager by modifying the `loglevel` custom resource as follows:

```yaml
spec:
  logLevel: debug
```
