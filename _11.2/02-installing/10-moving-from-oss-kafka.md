---
title: "Migrating from open-source Apache Kafka to Event Streams"
excerpt: "Learn about the steps required to move from an open-source Kafka implementation to using Event Streams."
categories: installing
slug: moving-from-oss-kafka
toc: true
---

If you are using open-source Apache Kafka as your event-streaming platform, you can move to {{site.data.reuse.long_name}} and [benefit](../../about/overview/) from its features and enterprise-level support.

## Prerequisites


Ensure you have an {{site.data.reuse.short_name}} deployment available. See the instructions for [installing]({{ 'installpagedivert' | relative_url }}) on your platform. 

For many of the tasks, you can use the [Kafka console tools](https://kafka.apache.org/quickstart){:target="_blank"}. Many of the console tools work with {{site.data.reuse.short_name}}, as described in the [using console tools](../../getting-started/using-kafka-console-tools/) topic.

## Create the required topics in {{site.data.reuse.short_name}}

In {{site.data.reuse.short_name}}, create the same set of topics that have been deployed in the open-source Kafka cluster.

To list these topics, run the following Kafka console tool:

`./kafka-topics.sh --bootstrap-server <host>:<port> --describe`

For each existing topic, [create a new topic](../../getting-started/creating-topics) in {{site.data.reuse.short_name}} with the same name. Ensure you use the same partition and replica settings, as well as any other non-default settings that were applied to the existing topic in your open-source Kafka instance.

## Change producer configuration

Change the configuration for applications that produce messages to your open-source Kafka cluster to connect to {{site.data.reuse.short_name}} instead as described in [connecting clients](../../getting-started/connecting).

If you are using the Kafka console tools, see the instructions for the example console producer in [using the console tools](../../getting-started/using-kafka-console-tools/#using-the-console-tools-with-ibm-event-streams) to change where the messages are produced to.

## Change consumer configuration

Change the configuration for applications that consume messages from your open-source Kafka cluster to connect to {{site.data.reuse.short_name}} instead as described in [connecting clients](../../getting-started/connecting).

If you are using the Kafka console tools, see the instructions for the example console consumer in [using the console tools](../../getting-started/using-kafka-console-tools/#using-the-console-tools-with-ibm-event-streams) to change where messages are consumed from.
