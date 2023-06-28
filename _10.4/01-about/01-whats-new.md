---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
layout: redirects
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 10.4.

## Kafka version upgraded to 2.8.0

{{site.data.reuse.short_name}} version 10.4.0 includes Kafka release 2.8.0, and supports the use of all Kafka interfaces.

## Integration with {{site.data.reuse.openshift_short}} monitoring

The Application Monitoring feature became formally available in {{site.data.reuse.openshift_short}} 4.6. In IBM Cloud Pak foundational services 3.7 and later (formerly known as Common Services), the monitoring service takes advantage of this feature. {{site.data.reuse.openshift_short}} monitoring leverages the Prometheus stack and provides customized Grafana dashboards.

{{site.data.reuse.short_name}} supports the {{site.data.reuse.openshift_short}} [monitoring stack](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2021.3?topic=administration-enabling-openshift-container-platform-monitoring){:target="_blank"}, providing metrics for monitoring the health of your cluster and Kafka operations.

## Kafka Connect Source-to-Image is deprecated

The `KafkaConnectS2I` custom resource is deprecated in {{site.data.reuse.short_name}} version 10.4.0 and later. When installing new Kafka Connect instances, use the `KafkaConnect` custom resource and provide a pre-built image. The `KafkaConnectS2I` custom resource will be removed in future versions of {{site.data.reuse.short_name}}. Ensure your existing Kafka Connect clusters are migrated to use the `KafkaConnect` custom resource.

For more information, see [Setting up and running connectors](../../connecting/setting-up-connectors/).

## Kafka Connector topic status

{{site.data.reuse.short_name}} version 10.4.0 includes the `KafkaConnector` custom resource update to display topics being used by the connector in the status of the `KafkaConnector` custom resource.

## Kafka Connect JMX configuration option

{{site.data.reuse.short_name}} version 10.4.0 includes the `KafkaConnect` custom resource update to add the JMX configuration option.

## v1beta2 version of custom resources

{{site.data.reuse.short_name}} version 10.4.0 includes `v1beta2` versions of Strimzi custom resources.
