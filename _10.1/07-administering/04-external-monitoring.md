---
title: "Monitoring with external tools"
excerpt: "You can use third-party monitoring tools to monitor your Event Streams Kafka cluster."
categories: administering
slug: external-monitoring
toc: true
---

You can use third-party monitoring tools to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster by connecting to the JMX port on the Kafka brokers and reading Kafka metrics.

You must [configure](../../installing/configuring/#configuring-external-monitoring-through-jmx) your installation to set up access for external monitoring tools.

For examples about setting up monitoring with external tools such as Datadog, Prometheus, and Splunk, see the [tutorials]({{ 'tutorials' | relative_url }}) page.

If you have a tool or service you want to use to monitor your clusters, you can [contact support]({{ 'support' | relative_url }}).
