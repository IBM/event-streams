---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
toc: true
---

Find out what is new in {{site.data.reuse.long_name}}.

## Release 2018.3.1

### Support for IBM Cloud Private on Linux on IBM Z

In addition to Linux® 64-bit (x86_64) systems, {{site.data.reuse.short_name}} 2018.3.1 and later is also [supported](../../installing/prerequisites/#ibm-cloud-private-environment) on Linux on IBM® Z systems.

### Support for IBM Cloud Private version 3.1.1

In addition to {{site.data.reuse.icp}} 3.1.0, {{site.data.reuse.short_name}} 2018.3.1 and later is also [supported](../../installing/prerequisites/#ibm-cloud-private-environment) on {{site.data.reuse.icp}} 3.1.1.

### Kafka version upgraded to 2.0.1

{{site.data.reuse.short_name}} 2018.3.1 uses the Kafka 2.0.1 release.

### Kafka Connect sink connector for IBM MQ

In addition to the {{site.data.reuse.kafka-connect-mq-source}}, the [{{site.data.reuse.kafka-connect-mq-sink}}](../../connecting/mq/sink/) is also availble to use with {{site.data.reuse.long_name}} 2018.3.1 and later.

### Support for Kafka quotas to allow clients to be throttled

You can [set Kafka quotas](../../administering/quotas/) to control the broker resources used by clients.

### New design for sample application

The UI for the [starter application](../../getting-started/generating-starter-app/) has been redesigned to have both the producer and the consumer on a single page.

### New Cluster Connection view with API Key generation and updated geo-replication flow

A new UI component helps obtain connection details (including certificates and API keys), access sample code snippets, and set up geo-replication (geo-replication is not available in {{site.data.reuse.ce_short}}). Log in to your {{site.data.reuse.short_name}} UI, and click **Connect to this cluster** on the right to access the new UI.

### Default resource requirements have changed

See the updated tables for the {{site.data.reuse.short_name}} [resource requirements](../../installing/prerequisites/#helm-resource-requirements).

### Documentation: Highlighting differences between versions

Any difference in features or behaviour between {{site.data.reuse.short_name}} releases is highlighted in the documentation using the following graphics:

- ![Event Streams 2018.3.1 icon](../../../images/2018.3.1.svg "In Event Streams 2018.3.1.") Applicable to {{site.data.reuse.long_name}} 2018.3.1.
- ![Event Streams 2018.3.0 icon](../../../images/2018.3.0.svg "In Event Streams 2018.3.0.") Applicable to {{site.data.reuse.long_name}} 2018.3.0.

## Release 2018.3.0

First GA release.
