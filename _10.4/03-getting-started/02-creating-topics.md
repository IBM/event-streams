---
title: "Creating a Kafka topic"
excerpt: "Create a Kafka topic to learn more about using Event Streams"
categories: getting-started
slug: creating-topics
toc: true
---

To use Kafka topics to store events in {{site.data.reuse.long_name}}, create and configure a Kafka topic.

## Using the UI

1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click **Home** in the primary navigation.
3. Click the **Create a topic** tile.
4. Enter a topic name in the **Topic name** field, for example, `my-topic`.
   This is the name of the topic that an application will be producing to or consuming from.

   Click **Next**.
5. Enter the number of **Partitions**, for example, `1`.
   Partitions are used for scaling and distributing topic data across the Apache Kafka brokers.
   For the purposes of a basic starter application, using only 1 partition is sufficient.

   Click **Next**.
6. Select a **Message retention**,  for example,  **A day**.
   This is how long messages are retained before they are deleted.

   Click **Next**.
7. Select a replication factor in **Replicas**,  for example, **Replication factor: 1**.
   This is how many copies of a topic will be made for high availability. For production environments, select **Replication factor: 3** as a minimum.

8. Click **Create topic**. The topic is created and can be viewed from the **Topics** tab located in the primary navigation.

**Note:** To view all configuration options you can set for topics, set **Show all available options** to **On**.

**Note:** Kafka supports additional [topic configuration](https://kafka.apache.org/28/documentation/#topicconfigs) settings. Enable **Show all available options** to access more detailed configuration settings if required.

## Using the CLI

1. {{site.data.reuse.cp_cli_login}}

   Find out how to [retrieve the login URL](../logging-in) for your {{site.data.reuse.short_name}} CLI.

2. Run the following command to initialize the {{site.data.reuse.long_name}} CLI on the cluster:\\
   `cloudctl es init`

3. Run the following command to create a topic:

   `cloudctl es topic-create --name <topic-name> --partitions <number-of-partitions> --replication-factor <replication-factor>`

   For example, to create a topic called `my-topic` that has 1 partition, a replication factor of 1, and 1 day set for message retention time (provided in milliseconds):

   `cloudctl es topic-create --name my-topic --partitions 1 --replication-factor 1 --config retention.ms=86400000`

   **Important:** Do not set `<replication-factor>` to a greater value than the number of available brokers.


**Note:** To view all configuration options you can set for topics, use the help option as follows: `cloudctl es topic-create --help`

Kafka supports additional [topic configuration](https://kafka.apache.org/28/documentation/#topicconfigs) settings. Extend the topic creation command with one or more `--config <property>=<value>` properties to apply additional configuration settings. The following additinal properties are currently supported:

* cleanup.policy
* compression.type
* delete.retention.ms
* file.delete.delay.ms
* flush.messages
* flush.ms
* follower.replication.throttled.replicas
* index.interval.bytes
* leader.replication.throttled.replicas
* max.message.bytes
* message.format.version
* message.timestamp.difference.max.ms
* message.timestamp.type
* min.cleanable.dirty.ratio
* min.compaction.lag.ms
* min.insync.replicas
* preallocate
* retention.bytes
* retention.ms
* segment.bytes
* segment.index.bytes
* segment.jitter.ms
* segment.ms
* unclean.leader.election.enable
