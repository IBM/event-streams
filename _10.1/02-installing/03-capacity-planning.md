---
title: "Performance and capacity planning"
excerpt: "Consider the following when planning for the performance and capacity requirements of your installation."
categories: installing
slug: capacity-planning
toc: true
---

<!--It's important to understand your requirements so that you set up your deployment to handle the intended workload. In addition,  [licensing](../planning/#licensing) is based on the number of virtual cores available to all Kafka, Kafka Connect and Geo-replicator containers deployed.-->

## Guidance for production environments

You can use one of the sample configurations provided by {{site.data.reuse.short_name}} to set up a production deployment. For information about the provided samples, see the [sample deployments](../planning/#sample-deployments) section.

If needed, you can [modify the selected sample configuration](../configuring) when you deploy a new instance, or make changes at a [later time](../../administering/modifying-installation).

## Tuning {{site.data.reuse.short_name}} Kafka performance

When preparing for your {{site.data.reuse.short_name}} installation, review your workload requirements and consider the configuration options available for performance tuning your {{site.data.reuse.short_name}} installation.

Kafka offers a number of configuration settings that can be adjusted as necessary for an {{site.data.reuse.short_name}} deployment. These can be used to address any bottlenecks in the system as well as perform fine tuning of Kafka performance.

Kafka provides a wide range of configuration properties to set, but consider the following when reviewing performance requirements:

- The `num.replica.fetchers` property sets the number of threads available on each broker to replicate messages from topic leaders. Increasing this setting increases I/O parallelism in the follower broker, and can help reduce bottlenecks and message latency. You can start by setting this value to match the number of brokers deployed in the system.\\
  **Note:** Increasing this value results in brokers using more CPU resources and network bandwidth.
- The `num.io.threads` property sets the number of threads available to a broker for processing requests. As the load on each broker increases, handling requests can become a bottleneck. Increasing this property value can help mitigate this issue. The value to set depends on the overall system load and the processing power of the worker nodes, which varies for each deployment. There is a correlation between this setting and the `num.network.threads` setting.
- The `num.network.threads` property sets the number of threads available to the broker for receiving and sending requests and responses to the network. The value to set depends on the overall network load, which varies for each deployment. There is a correlation between this setting and the `num.io.threads` setting.
- The `replica.fetch.min.bytes`, `replica.fetch.max.bytes`, and `replica.fetch.response.max.bytes` properties control the minimum and maximum sizes for message payloads when performing inter-broker replication. Set these values to be greater than the `message.max.bytes` property to ensure that all messages sent by a producer can be replicated between brokers. The value to set depends on message throughput and average size, which varies for each deployment.

These properties are [configured](../configuring/#applying-kafka-broker-configuration-settings) in the `EventStreams` custom resource for an instance when it is first created and can be [modified](../../administering/modifying-installation/#modifying-kafka-broker-configuration-settings) at any time.

## Disk space for persistent volumes

You need to ensure you have sufficient disk space in the persistent storage for the Kafka brokers to meet your expected throughput and retention requirements. In Kafka, unlike other messaging systems, the messages on a topic are not immediately removed after they are consumed. Instead, the configuration of each topic determines how much space the topic is permitted and how it is managed.

Each partition of a topic consists of a sequence of files called log segments. The size of the log segments is determined by the cluster-level configuration property `log.segment.bytes` (default is 1 GB). This can be overridden by using the topic-level configuration `segment.bytes`.

For each log segment, there are two index files called the time index and the offset index. The size of the index is determined by the cluster-level configuration property `log.index.size.max.bytes` (default is 10 MB). This can be overridden by using the topic-level configuration property `segment.index.bytes`.

Log segments can be deleted or compacted, or both, to manage their size. The topic-level configuration property `cleanup.policy` determines the way the log segments for the topic are managed.

For more information about these settings, see [the Kafka documentation](https://kafka.apache.org/documentation/#configuration){:target="_blank"}.

The cluster-level settings are [configured](../configuring/#applying-kafka-broker-configuration-settings) in the `EventStreams` custom resource for an instance when it is first created and can be [modified](../../administering/modifying-installation/#modifying-kafka-broker-configuration-settings) at any time.

You can specify the cluster and topic-level configurations by using the [{{site.data.reuse.long_name}} CLI](../../administering/modifying-installation/#modifying-kafka-broker-configuration-settings). You can also set topic-level configuration when [setting up the topic](../../getting-started/creating-topics/) in the {{site.data.reuse.long_name}} UI (click **Create a topic**, and set **Show all available options** to **On**).

### Log cleanup by deletion

If the topic-level configuration property `cleanup.policy` is set to `delete` (the default value), old log segments are discarded when the retention time or size limit is reached, as set by the following properties:

- Retention time is set by `retention.ms`, and is the maximum time in milliseconds that a log segment is retained before being discarded to free up space.
- Size limit is set by `retention.bytes`, and is the maximum size that a partition can grow to before old log segments are discarded.

By default, there is no size limit, only a time limit. The default time limit is 7 days (604,800,000 ms).

You also need to have sufficient disk space for the log segment deletion mechanism to operate. The cluster-level configuration property `log.retention.check.interval.ms` (default is 5 minutes) controls how often the broker checks to see whether log segments should be deleted. The cluster-level configuration property `log.segment.delete.delay.ms` (default is 1 minute) controls how long the broker waits before deleting the log segments. This means that by default you also need to ensure you have enough disk space to store log segments for an additional 6 minutes for each partition.

#### Worked example 1

Consider a cluster that has 3 brokers, and 1 topic with 1 partition with a replication factor of 3. The expected throughput is 3,000 bytes per second. The retention time period is 7 days (604,800 seconds).

Each broker hosts 1 replica of the topic's single partition.

The log capacity required for the 7 days retention period can be determined as follows: 3,000 * (604,800 + 6 * 60) = 1,815,480,000 bytes.

So, each broker requires approximately 2GB of disk space allocated in its persistent volume, plus approximately 20 MB of space for index files. In addition, allow at least 1 log segment of extra space to make room for the actual cleanup process. Altogether, you need a total of just over 3 GB disk space for persistent volumes.

#### Worked example 2

Consider a cluster that has 3 brokers, and 1 topic with 1 partition with a replication factor of 3. The expected throughput is 3,000 bytes per second. The retention size configuration is set to 2.5 GB.

Each broker hosts 1 replica of the topic's single partition.

The number of log segments for 2.5 GB is 3, but you should also allow 1 extra log segment after cleanup.

So, each broker needs approximately 4 GB of disk space allocated in its persistent volume, plus approximately 40 MB of space for index files.

The retention period achieved at this rate is approximately 2,684,354,560 / 3,000 = 894,784 seconds, or 10.36 days.

### Log cleanup by compaction

If the topic-level configuration property `cleanup.policy` is set to `compact`, the log for the topic is compacted periodically in the background by the log cleaner. In a compacted topic, each message has a key. The log only needs to contain the most recent message for each key, while earlier messages can be discarded. The log cleaner calculates the offset of the most recent message for each key, and then copies the log from start to finish, discarding all but the last of each duplicate key in the log. As each copied segment is created, they are swapped into the log right away to keep the amount of additional space required to a minimum.

Estimating the amount of space that a compacted topic will require is complex, and depends on factors such as the number of unique keys in the messages, the frequency with which each key appears in the uncompacted log, and the size of the messages.

### Log cleanup by using both

You can specify both `delete` and `compact` values for the `cleanup.policy` configuration property at the same time. In this case, the log is compacted, but the cleanup process also follows the retention time or size limit settings.

When both methods are enabled, capacity planning is simpler than when you only have compaction set for a topic. However, some use cases for log compaction depend on messages not being deleted by log cleanup, so consider whether using both is right for your scenario.

<!--
## Memory requirements

TBD

## CPU requirements

TBD
-->
