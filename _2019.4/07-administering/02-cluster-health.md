---
title: "Monitoring Kafka cluster health"
excerpt: "Understand the health of your Kafka cluster at a glance."
categories: administering
slug: cluster-health
toc: true
---

Monitoring the health of your Kafka cluster ensures your operations run smoothly. {{site.data.reuse.short_name}} collects metrics from all of the Kafka brokers and exports them to a [Prometheus](https://prometheus.io/docs/introduction/overview/){:target="_blank"}-based monitoring platform. The metrics are useful indicators of the health of the cluster, and can provide warnings of potential problems.

You can use the metrics as follows:
- View a selection of metrics on a preconfigured [dashboard](#viewing-the-preconfigured-dashboard) in the {{site.data.reuse.short_name}} UI.
- Create dashboards in the Grafana service that is provided in {{site.data.reuse.icp}}, and use the dashboards to monitor your {{site.data.reuse.short_name}} instance, including Kafka health and performance details. You can create the dashboards in the {{site.data.reuse.icp}} monitoring service by selecting to **Export the {{site.data.reuse.short_name}} dashboards** when [configuring](../../installing/configuring/#ibm-cloud-private-monitoring-service) your {{site.data.reuse.short_name}} installation.

   You can also download the example Grafana dashboards for {{site.data.reuse.short_name}} from [GitHub](https://github.com/IBM/charts/tree/master/stable/ibm-eventstreams-dev/ibm_cloud_pak/pak_extensions/dashboards){:target="_blank"}, including a dashboard for monitoring geo-replication health, which is useful if you have geo-replication set up in your environment.

   Ensure you select your namespace, release name, and other filters at the top of the dashboard to view the required information.

   For more information about the monitoring capabilities provided in {{site.data.reuse.icp}}, including Grafana, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_metrics/monitoring_service.html){:target="_blank"}.

- Create alerts so that metrics that meet predefined criteria are used to send notifications to emails, Slack, PagerDuty, and so on. For an example of how to use the metrics to trigger alert notifications, see how you can set up [notifications to Slack](../../tutorials/monitoring-alerts/).

You can also use [external monitoring tools](../external-monitoring/) to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster.

For information about the health of your topics, check the [producer activity](../topic-health/) dashboard.

{{site.data.reuse.monitor_metrics_retention}}

## Viewing the preconfigured dashboard

To get an overview of the cluster health, you can view a selection of metrics on the {{site.data.reuse.short_name}} **Monitor** dashboard.

1. {{site.data.reuse.es_ui_login}}
2. Click **Monitoring** in the primary navigation. A dashboard is displayed with overview charts for messages, partitions, and replicas.
3. Select **1 hour**, **1 day**, **1 week**, or **1 month** to view data for different time periods.
