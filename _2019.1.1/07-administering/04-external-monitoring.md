---
title: "Monitoring with external tools"
excerpt: "You can use third party monitoring tools to monitor your Event Streams Kafka cluster."
categories: administering
slug: external-monitoring
toc: true
---

You can use third party monitoring tools to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster by connecting to the JMX port on the Kafka brokers and reading Kafka metrics.

You must [configure](../../installing/configuring/#configuring-external-monitoring-tools) your installation to set up access for external monitoring tools.

For setup examples, see the information about setting up external tools such as [Datadog](../../tutorials/monitor-with-datadog/) or an external [Prometheus](../../tutorials/monitor-with-prometheus/) instance.

If you have a tool or service you want to use to monitor your clusters, you can [raise a request](../../support/#suggest-a-feature).
