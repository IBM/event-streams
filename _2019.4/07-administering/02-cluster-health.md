---
title: "Monitoring Kafka cluster health"
excerpt: "Understand the health of your Kafka cluster at a glance."
categories: administering
slug: cluster-health
layout: redirects
toc: true
---

Monitoring the health of your Kafka cluster ensures your operations run smoothly. {{site.data.reuse.short_name}} collects metrics from all of the Kafka brokers and exports them to a [Prometheus](https://prometheus.io/docs/introduction/overview/){:target="_blank"}-based monitoring platform. The metrics are useful indicators of the health of the cluster, and can provide warnings of potential problems.

You can use the metrics as follows:

- View a selection of metrics on a preconfigured [dashboard](#viewing-the-preconfigured-dashboard) in the {{site.data.reuse.short_name}} UI.
- Create dashboards in the Grafana service that is provided in {{site.data.reuse.icp}}, and use the dashboards to monitor your {{site.data.reuse.short_name}} instance, including Kafka health and performance details. You can create the dashboards in the {{site.data.reuse.icp}} monitoring service by selecting to **Export the {{site.data.reuse.short_name}} dashboards** when [configuring](../../installing/configuring/#ibm-cloud-private-monitoring-service) your {{site.data.reuse.short_name}} installation.

   For more information about the monitoring capabilities provided in {{site.data.reuse.icp}}, including Grafana, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_metrics/monitoring_service.html){:target="_blank"}.

   To install the configured Grafana dashboards, follow these steps:

   1. Download the dashboards you want to install from [GitHub](https://github.com/IBM/event-streams/tree/master/support/dashboards/grafana/2019.4){:target="_blank"}.
   2. {{site.data.reuse.icp_ui_login}}
   3. Navigate to the {{site.data.reuse.icp}} console homepage.
   4. Click the hamburger icon in the top left.
   5. Expand **Platform**.
   6. Click  **Monitoring** to navigate to the Grafana homepage.
   7. On the Grafana homepage, click the **Home** icon in the top left to view all pre-installed dashboards.
   8. Click **Import Dashboards**, and either paste the JSON of the dashboard you want to install or import the dashboard's JSON file that you downloaded in step 1.
   9. Navigate to the Grafana homepage again and click the **Home** icon, then find the dashboard you have installed to view it.

   Ensure you select your namespace, release name, and other filters at the top of the dashboard to view the required information.
- Create alerts so that metrics that meet predefined criteria are used to send notifications to emails, Slack, PagerDuty, and so on. For an example of how to use the metrics to trigger alert notifications, see how you can set up [notifications to Slack]({{ 'tutorials/monitoring-alerts/' | relative_url }}).
- Create dashboards in the Kibana service that is provided in {{site.data.reuse.icp}}. You can download example Kibana dashboards for {{site.data.reuse.short_name}} from [GitHub](https://github.com/IBM/event-streams/tree/master/support/dashboards/kibana){:target="_blank"}, and use the dashboards to monitor for specific errors in the logs and set up alerts for when a number of errors occur over a period of time in your {{site.data.reuse.short_name}} instance.

   For more information about the logging capabilities provided in {{site.data.reuse.icp}}, including Kibana, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_metrics/logging_elk.html){:target="_blank"}.

   To download the preconfigured Kibana Dashboards, follow these steps:
   1. Download `Event Streams Kibana Dashboard.json` from [GitHub](https://github.com/IBM/event-streams/tree/master/support/dashboards/kibana/2019.4){:target="_blank"}
   2. {{site.data.reuse.icp_ui_login}}
   3. Navigate to the {{site.data.reuse.icp}} console homepage.
   4. Click the hamburger icon in the top left.
   5. Expand **Platform**.
   6. Click **Logging** to navigate to the Kibana homepage.
   7. Click **Management** on the left.
   8. Click **Saved Objects**.
   9. Click the **Import** icon and navigate to the `Event Streams Kibana Dashboard.json` file that you downloaded.
   10. Click the **Dashboard** tab on the left to view the downloaded dashboards.

You can also use [external monitoring tools](../external-monitoring/) to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster.

For information about the health of your topics, check the [producer activity](../topic-health/) dashboard.

{{site.data.reuse.monitor_metrics_retention}}

## Viewing the preconfigured dashboard

To get an overview of the cluster health, you can view a selection of metrics on the {{site.data.reuse.short_name}} **Monitor** dashboard.

1. {{site.data.reuse.es_ui_login}}
2. Click **Monitoring** in the primary navigation. A dashboard is displayed with overview charts for messages, partitions, and replicas.
3. Select **1 hour**, **1 day**, **1 week**, or **1 month** to view data for different time periods.
