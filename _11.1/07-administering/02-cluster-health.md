---
title: "Monitoring Kafka cluster health"
excerpt: "Understand the health of your Kafka cluster at a glance."
categories: administering
slug: cluster-health
toc: true
---

Monitoring the health of your Kafka cluster helps to verify that your operations are running smoothly. The {{site.data.reuse.short_name}} UI includes a [preconfigured dashboard](#viewing-the-preconfigured-dashboard) that monitors Kafka data.

{{site.data.reuse.short_name}} also provides a number of ways to export metrics from your Kafka brokers to external monitoring and logging applications. These metrics are useful indicators of the health of the cluster, and can provide warnings of potential problems. The following sections provide an overview of the available options.

For information about the health of your topics, check the [producer activity](../topic-health/) dashboard.

## JMX Exporter

You can use {{site.data.reuse.short_name}} to collect JMX metrics from Kafka brokers, ZooKeeper nodes, and Kafka Connect nodes, and export them to Prometheus.

For an example of how to configure the JMX exporter, see [configuring the JMX Exporter](../../installing/configuring#configuring-the-jmx-exporter)

## Kafka Exporter

You can use {{site.data.reuse.short_name}} to export metrics to Prometheus. These metrics are otherwise only accessible through the Kafka command-line tools. This allows topic metrics such as consumer group lag to be collected.

For an example of how to configure a Kafka Exporter, see [configuring the Kafka Exporter](../../installing/configuring#configuring-the-kafka-exporter).

## JmxTrans (deprecated)

JmxTrans can be used to push JMX metrics from Kafka brokers to external applications or databases. For more information, see [configuring JmxTrans](../../security/secure-jmx-connections#configuring-a-jmxtrans-deployment).

{{site.data.reuse.jmx_deprecated}}

## Grafana

You can use dashboards in the Grafana service to monitor your {{site.data.reuse.short_name}} instance for health and performance of your Kafka clusters.

### Viewing installed Grafana dashboards

To view the {{site.data.reuse.short_name}} Grafana dashboards, follow these steps:

1. {{site.data.reuse.icpfs_ui_login}}
2. Navigate to the {{site.data.reuse.icpfs}} console homepage.
3. Click the hamburger icon in the top left.
4. Expand **Monitor Health**.
5. Click the **Monitoring** in the expanded menu to open the Grafana homepage.
6. Click the user icon in the bottom left corner to open the user profile page.
7. In the **Organizations** table, find the namespace where you installed the {{site.data.reuse.short_name}} `monitoringdashboard` custom resource, and switch the user profile to that namespace.
8. Hover over the **Dashboards** on the left and click **Manage**.
9. Click on the dashboard you want to view in the **Dashboard** table.

Ensure you select your namespace, cluster name, and other filters at the top of the dashboard to view the required information.

## Kibana

Create dashboards in the Kibana service that is provided by the {{site.data.reuse.openshift_short}} [cluster logging](https://docs.openshift.com/container-platform/4.12/logging/cluster-logging.html){:target="_blank"}, and use the dashboards to monitor for specific errors in the logs and set up alerts for when a number of errors occur over a period of time in your {{site.data.reuse.short_name}} instance.

To install the {{site.data.reuse.short_name}} Kibana dashboards, follow these steps:

1. Ensure you have [cluster logging](https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-deploying.html){:target="_blank"} installed.
2. Download the JSON file that includes the example Kibana dashboards for {{site.data.reuse.short_name}} from [GitHub](https://github.com/ibm-messaging/event-streams-operator-resources/tree/master/kibana-dashboards){:target="_blank"}.

2. Navigate to the Kibana homepage on your cluster.

   **For {{site.data.reuse.icpfs}}**: {{site.reuse.data.icpcs_ui_login}} Click the hamburger icon in the top left and then expand **Monitor Health**. Then click **Logging** to open the Kibana homepage.

   **For {{site.data.reuse.openshift_short}} cluster logging stack**: {{site.data.reuse.openshift_ui_login}} Then follow the instructions to navigate to [cluster logging's Kibana homepage](https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-visualizer.html#cluster-logging-visualizer-kibana_cluster-logging-visualizer){:target="_blank"}.
3. Click **Management** in the navigation on the left.
4. Click **Index patterns**.
5. Click **Creat index pattern**.
6. Enter `app*` in the **Index pattern** field, and click **Next step**.
7. Select `@timestamp` from the **Time Filter field name** list, and click **Create index pattern**.
8. Click **Saved Objects**.
9. Click the **Import** icon and navigate to the JSON file you downloaded earlier that includes the example Kibana dashboards for {{site.data.reuse.short_name}}.
10. If an `Index Pattern Conflicts` warning is displayed, select the `app*` index pattern from the **New index pattern** list for each conflict, then click **Confirm all changes**.
11. Click **Dashboard** in the navigation on the left to view the downloaded dashboards.

## IBM Instana

Instana is an observability tool that can be used to monitor your {{site.data.reuse.short_name}} deployment.

Instana also offers [Kafka-centric monitoring](https://www.instana.com/supported-technologies/apache-kafka-observability/){:target="_blank"} that can provide useful insights into the performance and the health of your Kafka cluster.

For information about installing and configuring an Instana host agent on the {{site.data.reuse.openshift}}, see the [Instana documentation](https://www.ibm.com/docs/en/instana-observability/current?topic=requirements-installing-host-agent-openshift){:target="_blank"}.

After installing, Instana can monitor all aspects of an {{site.data.reuse.short_name}} instance with no extra configuration required.

**Note**: You might receive the following error message in the Instana dashboards when you check monitoring metrics for the {{site.data.reuse.short_name}} UI container:

```
Monitoring issue: nodejs_collector_not_installed

The @instana/collector package is not installed in this Node.js application, or the @instana/collector package cannot announce itself to the host agent, for example due to networking issues.
```

If you require monitoring of the {{site.data.reuse.short_name}} UI, you can enable Instana to monitor the UI by setting the following in the `EventStreams` custom resource:

```yaml
  apiVersion: eventstreams.ibm.com/v1beta2
  kind: EventStreams
  # ...
  spec:
  # ...
  adminUI:
      env:
      -  name: INSTANA_AGENT_HOST
         valueFrom:
               fieldRef:
                  fieldPath: status.hostIP
```
## Other Monitoring Tools

You can also use [external monitoring tools](../external-monitoring/) to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster.

## Viewing the preconfigured dashboard

To get an overview of the cluster health, you can view a selection of metrics on the {{site.data.reuse.short_name}} **Monitoring** dashboard.

1. {{site.data.reuse.es_ui_login}}
2. Click **Monitoring** in the primary navigation. A dashboard is displayed with overview charts for messages, partitions, and replicas.
3. Select **1 hour**, **1 day**, **1 week**, or **1 month** to view data for different time periods.
