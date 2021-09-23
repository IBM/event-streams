---
title: "Monitoring topic health"
excerpt: "Understand the health of your topics at a glance."
categories: administering
slug: topic-health
toc: false
---

To gain an insight into the overall health of topics, and highlight potential performance issues with systems producing to {{site.data.reuse.short_name}}, you can use the **Producers** dashboard provided for each topic.

The dashboard displays aggregated information about producer activity for the selected topic through metrics such as active producer count, message size, and message produce rates. The dashboard also displays information about each producer that has been producing to the topic.

You can expand an individual producer identified by its **Kafka producer ID** to gain insight into its performance through metrics such as messages produced, message size and rates, failed produce requests and any occurrences where a producer has exceeded a broker quota.

The information displayed on the dashboard can also be used to provide insight into potential causes when applications experience issues such as delays or omissions when consuming messages from the topic. For example, highlighting that a particular producer has stopped producing messages, or has a lower message production rate than expected.

**Important:** The **Producers** dashboard is intended to help highlight producers that might be experiencing issues producing to the topic. You might need to investigate the producer applications themselves to identify an underlying problem.

To access the dashboard:

1. {{site.data.reuse.es_ui_login}}
2. Click **Topics** in the primary navigation.
3. Select the topic name from the list you want to view information about.\\
   The **Producers** tab is displayed with the dashboard and details about each producer. You can refine the time period for which information is displayed. You can expand each producer to view details about their activity.

   **Note:** When a new client starts producing messages to a topic, it might take up to 5 to 10 minutes before information about the producer's activity appears in the dashboard. In the meantime, you can go to the **Messages** tab to check whether messages are being produced.

{{site.data.reuse.monitor_metrics_retention}}

For information on how to monitor consumer groups for a particular topic, see [monitoring Kafka consumer group lag](../consumer-lag).
