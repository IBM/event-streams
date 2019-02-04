---
title: "Monitoring Kafka cluster health"
permalink: /administering/cluster-health/
excerpt: "Understand the health of your Kafka cluster at a glance."

toc: false
---

Monitoring the health of your Kafka cluster is important to keep your operations running smoothly. {{site.data.reuse.short_name}} collects metrics from Kafka brokers that provide information about the health of your Kafka cluster.

To get an overview of the cluster health, you can view some of the metrics in the dashboard provided through the {{site.data.reuse.icp}} monitoring service.

To check the health of your clusters through the dashboard:
1. Log in to {{site.data.reuse.long_name}} as an administrator
2. Click the **Monitor** tab. A dashboard is displayed with overview charts for messages, partitions, and replicas.
3. Click a chart to drill down into more detail.
4. Click **1 hour**, **1 day**, **1 week**, or **1 month** to view data for different time periods.

{{site.data.reuse.monitor_metrics_retention}}
