---
title: "Consuming messages"
excerpt: "A consumer is an application that consumes streams of messages from Kafka topics."
categories: about
slug: consuming-messages
toc: true
---

A consumer is an application that consumes streams of messages from Kafka topics. A consumer can subscribe to one or more topics or partitions. This information focuses on the Java programming interface that is part of the Apache Kafka project. The concepts apply to other languages too, but the names are sometimes a little different.

When a consumer connects to Kafka, it makes an initial bootstrap connection. This connection can be to any of the servers in the cluster. The consumer requests the partition and leadership information about the topic that it wants to consume from. Then the consumer establishes another connection to the partition leader and can begin to consume messages. These actions happen automatically internally when your consumer connects to the Kafka cluster.

A consumer is normally a long-running application. A consumer requests messages from Kafka by calling `Consumer.poll(...)` regularly. The consumer calls `poll()`, receives a batch of messages, processes them promptly, and then calls `poll()` again.

When a consumer processes a message, the message is not removed from its topic. Instead, consumers can choose from several ways of letting Kafka know which messages have been processed. This process is known as committing the offset.

In the programming interfaces, a message is actually called a record. For example, the Java class org.apache.kafka.clients.consumer.ConsumerRecord is used to represent a message for the consumer API. The terms _record_ and _message_ can be used interchangeably, but essentially a record is used to represent a message.

You might find it useful to read this information in conjunction with [producing messages](../producing-messages) in {{site.data.reuse.long_name}}.

## Configuring consumer properties

There are many configuration settings for the consumer, which control aspects of its behavior. The following table lists the most important ones:

Name  |Description   |Valid values   |Default
--|---|---|--
key.deserializer  | The class used to deserialize keys.  | Java class that implements Deserializer interface, such as org.apache.kafka.common.serialization.StringDeserializer  |  No default – you must specify a value
value.deserializer  |The class used to deserialize values.   | Java class that implements Deserializer interface, such as org.apache.kafka.common.serialization.StringDeserializer  |  No default – you must specify a value
group.id  | An identifier for the consumer group that the consumer belongs to.  | string  |	No default
auto.offset.reset  | The behavior when the consumer has no initial offset or the current offset is no longer available in the cluster.  | latest, earliest, none  |latest
enable.auto.commit  | Determines whether to commit the consumer’s offset automatically in the background.  | true, false  |true
auto.commit.interval.ms  |	The number of milliseconds between periodic commits of offsets.   | 0,…  |5000 (5 seconds)
max.poll.records  | The maximum number of records returned in a call to poll()  | 1,…  |500
session.timeout.ms  | The number of milliseconds within which a consumer heartbeat must be received to maintain a consumer’s membership of a consumer group.  | 6000-300000  |10000 (10 seconds)
max.poll.interval.ms  | The maximum time interval between polls before the consumer leaves the group.  |1,…   |300000 (5 minutes)

Many more configuration settings are available, but ensure you read the [Apache Kafka documentation](http://kafka.apache.org/26/documentation/){:target="_blank"} thoroughly before experimenting with them.

## Consumer groups

A _consumer group_ is a group of consumers cooperating to consume messages from one or more topics. The consumers in a group all use the same value for the `group.id` configuration. If you need more than one consumer to handle your workload, you can run multiple consumers in the same consumer group. Even if you only need one consumer, it\'s usual to also specify a value for `group.id`.

Each consumer group has a server in the cluster called the _coordinator_ responsible for assigning partitions to the consumers in the group. This responsibility is spread across the servers in the cluster to even the load. The assignment of partitions to consumers can change at every group rebalance.

When a consumer joins a consumer group, it discovers the coordinator for the group. The consumer then tells the coordinator that it wants to join the group and the coordinator starts a rebalance of the partitions across the group including the new member.

When one of the following changes take place in a consumer group, the group rebalances by shifting the assignment of partitions to the group members to accommodate the change:

-   a consumer joins the group
-   a consumer leaves the group
-   a consumer is considered as no longer live by the coordinator
-   new partitions are added to an existing topic

For each consumer group, Kafka remembers the committed offset for each partition being consumed.

If you have a consumer group that has rebalanced, be aware that any consumer that has left the group will have its commits rejected until it rejoins the group. In this case, the consumer needs to rejoin the group, where it might be assigned a different partition to the one it was previously consuming from.

## Consumer liveness

Kafka automatically detects failed consumers so that it can reassign partitions to working consumers. It uses two mechanisms to achieve this: polling and heartbeating.

If the batch of messages returned from `Consumer.poll(...)` is large or the processing is time-consuming, the delay before calling `poll()` again can be significant or unpredictable. In some cases, it\'s necessary to configure a long
maximum polling interval so that consumers do not get removed from their groups just because message processing is taking a while. If this were the only mechanism, it would mean that the time taken to detect a failed consumer would also be long.

To make consumer liveness easier to handle, background heartbeating was added in Kafka 0.10.1. The group coordinator expects group members to send it regular heartbeats to indicate that they remain active. A background heartbeat thread runs in the consumer sending regular heartbeats to the coordinator. If the coordinator does not receive a heartbeat from a group member within the _session timeout_, the coordinator removes the member from the group and starts a rebalance of the group. The session timeout can be much shorter than the maximum polling interval so that the time taken to detect a failed consumer can be short even if message processing takes a long time.

You can configure the maximum polling interval using the `max.poll.interval.ms` property and the session timeout using the `session.timeout.ms` property. You will typically not need to use these settings unless it takes more than 5 minutes to process a batch of messages.

### Managing offsets

For each consumer group, Kafka maintains the committed offset for each partition being consumed. When a consumer processes a message, it doesn\'t remove it from the partition. Instead, it just updates its current offset using a process called committing the offset.

By default, {{site.data.reuse.long_name}} retains committed offset information for 7 days.

### What if there is no existing committed offset?

When a consumer starts and is assigned a partition to consume, it will start at its group\'s committed offset. If there is no existing committed offset, the consumer can choose whether to start with the earliest or latest available message based on the setting of the `auto.offset.reset` property as follows:

* `latest` (the default): Your consumer receives and consumes only messages that arrive after subscribing. Your consumer has no knowledge of messages that were sent before it subscribed, therefore you should not expect that all messages will be consumed from a topic.
* `earliest`: Your consumer consumes all messages from the beginning because it is aware of all messages that have been sent.

If a consumer fails after processing a message but before committing its offset, the committed offset information will not reflect the processing of the message. This means that the message will be processed again by the next consumer in that group to be assigned the partition.

When committed offsets are saved in Kafka and the consumers are restarted, consumers resume from the point they last stopped at. When there is a committed offset, the `auto.offset.reset` property is not used.

### Committing offsets automatically

The easiest way to commit offsets is to let the Kafka consumer do it automatically. This is simple but it does give less control than committing manually. By default, a consumer automatically commits offsets every 5 seconds. This default commit happens every 5 seconds, regardless of the progress the consumer is making towards processing the messages. In addition, when the consumer calls `poll()`, this also causes the latest offset returned from the previous call to `poll()` to be committed (because it\'s probably been processed).

If the committed offset overtakes the processing of the messages and there is a consumer failure, it\'s possible that some messages might not be processed. This is because processing restarts at the committed offset, which is later than the last message to be processed before the failure. For this reason, if reliability is more important than simplicity, it\'s usually best to commit offsets manually.

### Committing offsets manually

If `enable.auto.commit` is set to `false`, the consumer commits its offsets manually. It can do this either synchronously or asynchronously. A common pattern is to commit the offset of the latest processed message based on a periodic timer. This pattern means that every message is processed at least once, but the committed offset never overtakes the progress of messages that are actively being processed. The frequency of the periodic timer controls the number of messages that can be reprocessed following a consumer failure. Messages are retrieved again from the last saved committed offset when the application restarts or when the group rebalances.

The committed offset is the offset of the messages from which processing is resumed. This is usually the offset of the most recently processed message _plus one_.

### Consumer lag

The consumer lag for a partition is the difference between the offset of the most recently published message and the consumer\'s committed offset. Although it\'s usual to have natural variations in the produce and consume rates, the consume rate should not be slower than the produce rate for an extended period.

If you observe that a consumer is processing messages successfully but occasionally appears to jump over a group of messages, it could be a sign that the consumer is not able to keep up. For topics that are not using log compaction, the amount of log space is managed by periodically deleting old log segments. If a consumer has fallen so far behind that it is consuming messages in a log segment that is deleted, it will suddenly jump forwards to the start of the next log segment. If it is important that the consumer processes all of the messages, this behavior indicates message loss from the point of view of this consumer.

You can use the `kafka-consumer-groups` tool to see the consumer lag. You can also use the consumer API and the consumer metrics for the same purpose.

## Controlling the speed of message consumption

If you have problems with message handling caused by message flooding, you can set a consumer option to control the speed of message consumption. Use `fetch.max.bytes` and `max.poll.records` to control how much data a call to `poll()` can return.

## Handling consumer rebalancing

When consumers are added to or removed from a group, a group rebalance takes place and consumers are not able to consume messages. This results in all the consumers in a consumer group being unavailable for a short period.

You could use a ConsumerRebalanceListener to manually commit offsets (if you are not using auto-commit) when notified with the \"on partitions revoked\" callback, and to pause further processing until notified of the successful rebalance using the \"on partition assigned\" callback.

## Exception handling

Any robust application that uses the Kafka client needs to handle exceptions for certain expected situations. In some cases, the exceptions are not thrown directly because some methods are asynchronous and deliver their results using a `Future` or a callback.

Here\'s a list of exceptions that you should handle in your code:

**[org.apache.kafka.common.errors.WakeupException]** Thrown by `Consumer.poll(...)` as a result of `Consumer.wakeup()` being called. This is the standard way to interrupt the consumer\'s polling loop. The polling loop should exit and `Consumer.close()` should be called to disconnect cleanly.

**[org.apache.kafka.common.errors.NotLeaderForPartitionException]** Thrown as a result of `Producer.send(...)` when the leadership for a partition changes. The client automatically refreshes its metadata to find the up-to-date leader information. Retry the operation, which should succeed with the updated metadata.

**[org.apache.kafka.common.errors.CommitFailedException]** Thrown as a result of `Consumer.commitSync(...)` when an unrecoverable error occurs. In some cases, it is not possible simply to repeat the operation because the partition assignment might have changed and the consumer might no longer be able to commit its offsets. Because `Consumer.commitSync(...)` can be partially successful when used with multiple partitions in a single call, the error recovery can be simplified by using a separate `Consumer.commitSync(...)` call for each partition.

**[org.apache.kafka.common.errors.TimeoutException]** Thrown by `Producer.send(...),  Consumer.listTopics()` if the metadata cannot be retrieved. The exception is also seen in the send callback (or the returned Future) when the requested acknowledgment does not come back within `request.timeout.ms`. The client can retry the operation, but the effect of a repeated operation depends on the specific operation. For example, if sending a message is retried, the message might be duplicated.

To learn more, see the following information:

-   [Producing messages](../producing-messages)
-   [Partition leadership](../partition-leadership/)
-   [Apache Kafka documentation](http://kafka.apache.org/documentation.html){:target="_blank"}
