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

- Ensure you have an {{site.data.reuse.short_name}} installation available. This tutorial is based on {{site.data.reuse.short_name}} version 2019.1.1.
- Ensure you have [Slack](https://slack.com/){:target="_blank"} installed and ready to use. This tutorial us based on Slack version 3.3.7.
- You need to be a Workplace Administrator to add apps to a Slack channel.

## Preparing Slack

To send notifications from {{site.data.reuse.short_name}} to your Slack channel, configure an incoming webhook URL within your Slack service. The webhook URL provided by Slack is required for the integration steps later in this section. To create the webhook URL:

1. Open Slack and go to your Slack channel where you want the notifications to be sent.
2. From your Slack channel click the icon for **Channel Settings > Add apps**.
3. Search for "incoming-webhook".
3. Click **Add configuration**.
4. Select the channel that you want to post to.
5. Click **Add Incoming Webhooks integration**.
6. Copy the URL in the **Webhook URL** field.

For more information about incoming webhooks in Slack, see the [Slack documentation](https://api.slack.com/incoming-webhooks){:target="_blank"}.

## Selecting the metric to monitor

To retrieve a list of available metrics, use an HTTP GET request on your ICP cluster URL as follows:

1. {{site.data.reuse.icp_ui_login}}
2. Use the following request: `https://<Cluster Master Host>:<Cluster Master API Port>/prometheus/api/v1/label/__name__/values`\\
   The list of available metrics is displayed. For example, you can choose to monitor the number of under-replicated partitions, and set up a trigger for notification to your Slack channel if the number is greater than 0 for more than a minute. The number of under-replicated partitions is tracked by the `kafka_server_replicamanager_underreplicatedpartitions_value` metric.

**Note:** Not all of the metrics that Kafka uses are published to Prometheus by default. The metrics that are published are controlled by a [ConfigMap](https://github.com/IBM/charts/blob/master/stable/ibm-eventstreams-dev/templates/metrics-configmap.yaml){:target="_blank"}.

For information about the different metrics, see [Monitoring Kafka](https://docs.confluent.io/current/kafka/monitoring.html){:target="_blank"}.

## Setting the alert rule

To set up the alert rule and define the trigger criteria, use the `monitoring-prometheus-alertrules` ConfigMap.

By default, the list of rules is empty. See the `data` section of the ConfigMap, for example:

```
user$ kubectl get configmap -n kube-system monitoring-prometheus-alertrules -o yaml

apiVersion: v1
data:
  alert.rules: ""
kind: ConfigMap
metadata:
  creationTimestamp: 2018-10-05T13:07:48Z
  labels:
    app: monitoring-prometheus
    chart: ibm-icpmonitoring-1.2.0
    component: prometheus
    heritage: Tiller
    release: monitoring
  name: monitoring-prometheus-alertrules
  namespace: kube-system
  resourceVersion: "4564"
  selfLink: /api/v1/namespaces/kube-system/configmaps/monitoring-prometheus-alertrules
  uid: a87b5766-c89f-11e8-9f94-00000a3304c0
```

As mentioned earlier, in this example we want to define an alert rule that creates a notification if the number of under-replicated partitions is greater than 0 for more than a minute. To achieve this, add a new rule for the metric `kafka_server_replicamanager_underreplicatedpartitions_value`, and set the trigger conditions in the `data` section, for example:

```
user$ kubectl edit -n kube-system monitoring-prometheus-alertrules

apiVersion: v1
data:
  sample.rules: |-
    groups:
    - name: alert.rules
      #
      # Each of the alerts you want to create will be listed here
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
kind: ConfigMap
metadata:
  creationTimestamp: 2018-10-05T13:07:48Z
  labels:
    app: monitoring-prometheus
    chart: ibm-icpmonitoring-1.2.0
    component: prometheus
    heritage: Tiller
    release: monitoring
  name: monitoring-prometheus-alertrules
  namespace: kube-system
  resourceVersion: "84156"
  selfLink: /api/v1/namespaces/kube-system/configmaps/monitoring-prometheus-alertrules
  uid: a87b5766-c89f-11e8-9f94-00000a3304c0
```

## Defining the alert destination

To define where to send the notifications triggered by the alert rule, specify Slack as a receiver by adding details about your Slack channel and the webhook you copied earlier to the `monitoring-prometheus-alertmanager` ConfigMap. For more information about Prometheus Alertmanager, see the [Prometheus documentation](https://prometheus.io/docs/alerting/configuration/){:target="_blank"}.

By default, the list of receivers is empty. See the `data` section of the ConfigMap, for example:

```
user$ kubectl get configmap -n kube-system monitoring-prometheus-alertmanager -o yaml

apiVersion: v1
data:
  alertmanager.yml: |-
    global:
    receivers:
      - name: default-receiver
    route:
      group_wait: 10s
      group_interval: 5m
      receiver: default-receiver
      repeat_interval: 3h
kind: ConfigMap
metadata:
  creationTimestamp: 2018-10-05T13:07:48Z
  labels:
    app: monitoring-prometheus
    chart: ibm-icpmonitoring-1.2.0
    component: alertmanager
    heritage: Tiller
    release: monitoring
  name: monitoring-prometheus-alertmanager
  namespace: kube-system
  resourceVersion: "4565"
  selfLink: /api/v1/namespaces/kube-system/configmaps/monitoring-prometheus-alertmanager
  uid: a87bdb44-c89f-11e8-9f94-00000a3304c0
```

Define the Slack channel as the receiver using the incoming webhook you copied earlier, and also set up the notification details such as the channel to post to, the content format, and criteria for the events to send to Slack. Settings to configure include the following:
- `slack_api_url`: The incoming webhook generated in Slack earlier.
- `send_resolved`: Set to `true` to send notifications about resolved alerts.
- `channel`: The Slack channel to send the notifications to.
- `username`: The username that posts the alert notifications to the channel.

For more information about the configuration settings to enter for Slack notifications, see the [Prometheus documentation](https://prometheus.io/docs/alerting/configuration/#slack_config){:target="_blank"}.

The content for the posts can be customized, see the following [blog](https://medium.com/quiq-blog/better-slack-alerts-from-prometheus-49125c8c672b){:target="_blank"} for Slack alert examples from Prometheus.

For example, to set up Slack notifications for the under-replicated partitions alert rule:

```
user$ kubectl edit configmap -n kube-system monitoring-prometheus-alertmanager
apiVersion: v1
data:
  alertmanager.yml: |-
    global:
      # This is the URL for the Incoming Webhook you created in Slack
      slack_api_url:  https://hooks.slack.com/services/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
    receivers:
      - name: default-receiver
        #
        # Adding a Slack channel integration to the default Prometheus receiver
        #  see https://prometheus.io/docs/alerting/configuration/#slack_config
        #  for details about the values to enter
        slack_configs:
        - send_resolved: true

          # The name of the Slack channel that alerts should be posted to
          channel: "#ibm-eventstreams-demo"

          # The username to post alerts as
          username: "IBM Event Streams"

          # An icon for posts in Slack
          icon_url: https://developer.ibm.com/messaging/wp-content/uploads/sites/18/2018/09/icon_dev_32_24x24.png

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
            {{ end }}{% endraw %}
    route:
      group_wait: 10s
      group_interval: 5m
      receiver: default-receiver
      repeat_interval: 3h
      #
      # The criteria for events that should go to Slack
      routes:
      - match:
          severity: critical
        receiver: default-receiver
kind: ConfigMap
metadata:
  creationTimestamp: 2018-10-05T13:07:48Z
  labels:
    app: monitoring-prometheus
    chart: ibm-icpmonitoring-1.2.0
    component: alertmanager
    heritage: Tiller
    release: monitoring
  name: monitoring-prometheus-alertmanager
  namespace: kube-system
  resourceVersion: "4565"
  selfLink: /api/v1/namespaces/kube-system/configmaps/monitoring-prometheus-alertmanager
  uid: a87bdb44-c89f-11e8-9f94-00000a3304c0
```

To check that the new alert is set up, use the Prometheus UI as follows:
1. {{site.data.reuse.icp_ui_login}}
2. Go to the Prometheus UI at `https://<Cluster Master Host>:<Cluster Master API Port>/prometheus`, and click the **Alerts** tab to see the active alerts. You can also go to **Status > Rules** to view the defined alert rules.

For example:

![Prometheus alert rules](../../images/alert_rules.png "Screen capture showing the alert rule for the under_replicated_partitions alert in the Prometheus UI.")

![Prometheus alert rules](../../images/alerts.png "Screen capture showing the details for the under_replicated_partitions alert in the Prometheus UI.")

## Testing

To see how the alert works, you can check the Prometheus UI, and then Slack.

For example, you can stop one of the Kafka brokers in your cluster. In the Prometheus **Alerts** tab the alert status shows `PENDING` before the 1 minute threshold is exceeded.

![Prometheus alert PENDING](../../images/alert_pending.png "Screen capture showing the PENDING state for the under_replicated_partitions alert in the Prometheus UI.")

If the number of under-replicated partitions remains above 0 for a minute, that status changes to `FIRING`.

![Prometheus alert FIRING](../../images/alert_firing.png "Screen capture showing the FIRING state for the under_replicated_partitions alert in the Prometheus UI.")

This means an alert is posted to the receiver defined previously – in this case, the Slack channel.

![Alert firing message posted to Slack channel](../../images/slack_alert_firing.png "Screen capture showing the firing message posted to the Slack channel by the under_replicated_partitions alert.")

When the cluster recovers, a new resolution alert is posted when the number of under-replicated partitions returns to 0. This is based on the `send_resolved` setting (was set to `true`).

![Alert resolved message posted to Slack channel](../../images/slack_alert_resolved.png "Screen capture showing the resolved message posted to the Slack channel by the under_replicated_partitions alert.")

## Setting up other notifications

You can use this example to set up alert notifications to other applications, including [HipChat](https://prometheus.io/docs/alerting/configuration/#hipchat_config){:target="_blank"}, [PagerDuty](https://prometheus.io/docs/alerting/configuration/#pagerduty_config){:target="_blank"},  [emails](https://prometheus.io/docs/alerting/configuration/#email_config){:target="_blank"}, and so on. You can also use this technique to generate HTTP calls, which lets you customize alerts when defining a flow in tools like [Node-RED](https://nodered.org/){:target="_blank"} or [IBM App Connect](https://developer.ibm.com/integration/docs/){:target="_blank"}.
