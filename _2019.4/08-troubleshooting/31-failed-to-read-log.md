---
title: "Failed to read 'log header' errors in Kafka logs"
excerpt: "The Kafka logs show errors about failing to read 'log header' and about replicas potentially falling out of sync."
categories: troubleshooting
slug: failed-to-read-log
layout: redirects
toc: true
---

## Symptoms

When {{site.data.reuse.short_name}} is configured to use GlusterFS as a storage volume, the Kafka logs show errors containing messages similar to the following:

```
[2020-05-12 06:40:19,249] ERROR [ReplicaManager broker=2] Error processing fetch with max size 1048576 from consumer on partition <TOPIC-NAME>-0: (fetchOffset=10380908, logStartOffset=-1, maxBytes=1048576, currentLeaderEpoch=Optional.empty) (kafka.server.ReplicaManager)
org.apache.kafka.common.KafkaException: java.io.EOFException: Failed to read `log header` from file channel `sun.nio.ch.FileChannelImpl@a5e333e6`. Expected to read 17 bytes, but reached end of file after reading 0 bytes. Started read from position 95236164.
```

These errors mean that Kafka has been unable to read files from the Gluster volume. This can cause replicas to fall out of sync.

## Cause

See [Kafka issue 7282](https://issues.apache.org/jira/browse/KAFKA-7282){:target="_blank"}

GlusterFS has performance settings that will allow requests for data to be served from replicas when they are not in sync with the leader. This causes problems for Kafka when it attempts to read a replica log segment before it has been fully written by Gluster.

## Resolving the problem

Apply the following settings to each Gluster volume that is used by an {{site.data.reuse.short_name}} Kafka broker:

```
gluster volume set <volumeName> performance.quick-read off
gluster volume set <volumeName> performance.io-cache off
gluster volume set <volumeName> performance.write-behind off
gluster volume set <volumeName> performance.stat-prefetch off
gluster volume set <volumeName> performance.read-ahead off
gluster volume set <volumeName> performance.readdir-ahead off
gluster volume set <volumeName> performance.open-behind off
gluster volume set <volumeName> performance.client-io-threads off
```

These settings can be applied while the Gluster volume is online. The Kafka broker will not need to be modified, the broker will be able to read from the volume after the change is applied.
