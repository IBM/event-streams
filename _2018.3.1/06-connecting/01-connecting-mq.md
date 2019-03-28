---
title: "Connecting to IBM MQ"
excerpt: "Connecting to MQ."
categories: connecting
slug: mq
toc: true
---

You can set up connections between IBM MQ and Apache Kafka or {{site.data.reuse.long_name}} systems.

Connectors are available for copying data in both directions.

## Available connectors

 - [{{site.data.reuse.kafka-connect-mq-source}}](../mq/source/):\\
    You can use the {{site.data.reuse.kafka-connect-mq-source-short}} to copy data from IBM MQ into {{site.data.reuse.long_name}} or Apache Kafka. The connector copies messages from a source MQ queue to a target Kafka topic.
 - [{{site.data.reuse.kafka-connect-mq-sink}}](../mq/sink/):\\
    You can use the {{site.data.reuse.kafka-connect-mq-sink-short}} to copy data from {{site.data.reuse.long_name}} or Apache Kafka into IBM MQ. The connector copies messages from a Kafka topic into a MQ queue.

 **Important:** If you want to use IBM MQ connectors on IBM z/OS, you must [prepare your setup first](../mq/zos/).

## When to use

Many organizations use both IBM MQ and Apache Kafka for their messaging needs. Although they're generally used to solve different kinds of messaging problems, users often want to connect them together for various reasons. For example, IBM MQ can be integrated with systems of record while Apache Kafka is commonly used for streaming events from web applications. The ability to connect the two systems together enables scenarios in which these two environments intersect.

## About Kafka Connect

When connecting Apache Kafka and other systems, the technology of choice is the [Kafka Connect framework](https://kafka.apache.org/documentation/#connect).

Kafka Connect connectors run inside a Java process called a worker. Kafka Connect can run in either standalone or distributed mode. Standalone mode is intended for testing and temporary connections between systems. Distributed mode is more appropriate for production use.

When you run Kafka Connect with a standalone worker, there are two configuration files:
* The worker configuration file contains the properties needed to connect to Kafka. This is where you provide the details for connecting to Kafka.
* The connector configuration file contains the properties needed for the connector. This is where you provide the details for connecting to IBM MQ.

When you run Kafka Connect with the distributed worker, you still use a worker configuration file but the connector configuration is supplied using a REST API. Refer to the Kafka Connect documentation for more details about the distributed worker.

For getting started and problem diagnosis, the simplest setup is to run only one connector in each standalone worker. Kafka Connect workers print a lot of information and it's easier to understand if the messages from multiple connectors are not interleaved.

**Note:** You can use an existing IBM MQ or Kafka installation, either locally or on the cloud. For performance reasons, it is recommended to run the Kafka Connect worker close to the queue manager to minimise the effect of network latency. For example, if you have a queue manager in your datacenter and Kafka in the cloud, it's best to run the Kafka Connect worker in your datacenter.
