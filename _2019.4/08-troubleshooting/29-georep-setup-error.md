---
title: "Error when geo-replicating to an earlier version of Event Streams"
excerpt: "Creating a destination topic fails when setting up geo-replication from a later version of Event Streams to an earlier version of Event Streams."
categories: troubleshooting
slug: georeplication-version-error
layout: redirects
toc: true
---

## Symptoms

When setting up geo-replication on a destination cluster that is running an earlier version of {{site.data.reuse.short_name}} than the origin cluster, the topic creation fails with the following error message:

```
ERROR_CREATING_TOPIC

org.apache.kafka.common.errors.InvalidConfigurationException: Invalid value 2.3-IV1 for configuration message.format.version: Version `2.3-IV1` is not a valid version
```

The error message always includes the strings `ERROR_CREATING_TOPIC` and `org.apache.kafka.common.errors.InvalidConfigurationException`

However, the type of the `InvalidConfigurationException` message can vary depending on the configuration options used for the origin topic.


## Causes

When setting up a geo-replication job, a replica of the topic is created on the destination cluster that uses the same configuration settings as the topic on the origin cluster.

If the origin and destination {{site.data.reuse.short_name}} clusters have different Kafka versions, then the destination cluster might not support the same topic configuration options as the origin cluster.

Creating the replica of the topic on the destination cluster can fail in such cases.

## Resolving the problem

Manually create a topic with the same name on the destination cluster before setting up geo-replication. Ensure you set the same number of partitions for the topic as you have set for the topic on the origin cluster you will be geo-replicating from.

If a topic with a matching name already exists on the destination cluster, geo-replication will reuse the topic instead of creating one.

You can create a topic by using the {{site.data.reuse.short_name}} UI or CLI.
