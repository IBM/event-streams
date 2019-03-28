---
title: "Key concepts"
excerpt: "Read about the key concepts of the Apache Kafka technology."
categories: about
slug: key-concepts
toc: true
---

Apache Kafka® forms the reliable messaging core of {{site.data.reuse.long_name}}. It is a publish-subscribe messaging system designed to be fault-tolerant, providing a high-throughput and low-latency platform for handling real-time data feeds.

![Kafka architecture diagram.](../../../images/kafka_overview.png "Diagram that shows a Kafka architecture. A producer is feeding into a Kafka topic over 3 partitions and the messages are then being subscribed to by consumers.")

The following are some key Kafka concepts.

## Cluster
Kafka runs as a cluster of one or more servers. The load is balanced across the cluster by distributing it amongst the servers.

## Topic
A stream of messages is stored in categories called topics.

## Partition
Each topic comprises one or more partitions. Each partition is an ordered list of messages. The messages on a partition are each given a monotonically increasing number called the offset.

If a topic has more than one partition, it allows data to be fed through in parallel to increase throughput by distributing the partitions across the cluster. The number of partitions also influences the balancing of workload among consumers.

## Message
The unit of data in Kafka. Each message is represented as a record, which comprises two parts: key and value. The key is commonly used for data about the message and the value is the body of the message. Kafka uses the terms record and message interchangeably.

Many other messaging systems also have a way of carrying other information along with the messages. Kafka 0.11 introduced record headers for this purpose.

Because many tools in the Kafka ecosystem (such as connectors to other systems) use only the value and ignore the key, it’s best to put all of the message data in the value and just use the key for partitioning or log compaction. You should not rely on everything that reads from Kafka to make use of the key.

## Producer
A process that publishes streams of messages to Kafka topics. A producer can publish to one or more topics and can optionally choose the partition that stores the data.

## Consumer
A process that consumes messages from Kafka topics and processes the feed of messages. A consumer can consume from one or more topics or partitions.

## Consumer group
A named group of one or more consumers that together consume the messages from a set of topics. Each consumer in the group reads messages from specific partitions that it is assigned to. Each partition is assigned to one consumer in the group only.

* If there are more partitions than consumers in a group, some consumers have multiple partitions.
* If there are more consumers than partitions, some consumers have no partitions.

To learn more, see the following information:
* [Producing messages](../producing-messages)
* [Consuming messages](../consuming-messages)
* [Partition leadership](../partition-leadership/)
* [Apache Kafka documentation](http://kafka.apache.org/documentation.html)
