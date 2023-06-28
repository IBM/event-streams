---
title: "Connecting to IBM MQ"
excerpt: "Connecting to MQ."
categories: connecting
slug: mq
layout: redirects
toc: true
---

You can set up connections between IBM MQ and Apache Kafka or {{site.data.reuse.long_name}} systems.


## Available connectors

Connectors are available for copying data in both directions.

 - [{{site.data.reuse.kafka-connect-mq-source}}](../mq/source/):\\
    You can use the {{site.data.reuse.kafka-connect-mq-source-short}} to copy data from IBM MQ into {{site.data.reuse.long_name}} or Apache Kafka. The connector copies messages from a source MQ queue to a target Kafka topic.
 - [{{site.data.reuse.kafka-connect-mq-sink}}](../mq/sink/):\\
    You can use the {{site.data.reuse.kafka-connect-mq-sink-short}} to copy data from {{site.data.reuse.long_name}} or Apache Kafka into IBM MQ. The connector copies messages from a Kafka topic into a MQ queue.

![Kafka Connect: MQ source and sink connectors](../../../images/mq_sink_and_source.png "Diagram showing a representation of how Event Streams and MQ can be connected by using the MQ source and MQ sink connectors.")

 **Important:** If you want to use IBM MQ connectors on IBM z/OS, you must [prepare your setup first](../mq/zos/).

 If you have IBM MQ running on {{site.data.reuse.icp}}, you can use the IBM MQ Connectors to connect your {{site.data.reuse.short_name}} to IBM MQ on {{site.data.reuse.icp}}. See the [instructions](../icp/) about running connectors on {{site.data.reuse.icp}}.

## When to use

Many organizations use both IBM MQ and Apache Kafka for their messaging needs. Although they're generally used to solve different kinds of messaging problems, users often want to connect them together for various reasons. For example, IBM MQ can be integrated with systems of record while Apache Kafka is commonly used for streaming events from web applications. The ability to connect the two systems together enables scenarios in which these two environments intersect.

**Note:** You can use an existing IBM MQ or Kafka installation, either locally or on the cloud. For performance reasons, it is recommended to run the Kafka Connect worker close to the queue manager to minimize the effect of network latency. For example, if you have a queue manager in your datacenter and Kafka in the cloud, it's best to run the Kafka Connect worker in your datacenter.
