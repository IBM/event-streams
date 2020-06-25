---
title: "Switching clusters"
excerpt: "Using geo-replication to recover when clusters become unavailable."
categories: georeplication
slug: failover
toc: true
---

When one of your origin {{site.data.reuse.short_name}} clusters experiences problems and becomes unavailable, you can switch your client applications to use the geo-replicated topics on your destination {{site.data.reuse.short_name}} cluster.

Ensure you [plan for geo-replication](../planning/) before [setting it up](../setting-up/).

## Switching clusters

When one of your origin {{site.data.reuse.short_name}} clusters experiences problems and goes down, switch your applications over to use the geo-replicated topics on the destination cluster as follows.

1. Log in to your destination {{site.data.reuse.short_name}} cluster as an administrator.
2. Click **Connect to this cluster**.
3. Go to the **Resources** tab, and use the information on the page to change your client application settings to use the geo-replicated topic on the destination cluster. You need the following information to do this:\\
   * **Bootstrap server**: In the **Kafka listener and credentials** section, select the listener from the list.
      - Click the **External** tab for applications connecting from outside of the {{site.data.reuse.openshift_short}} cluster.
      - Click the **Internal** tab for applications connecting from inside the {{site.data.reuse.openshift_short}} cluster.
    * **Credentials**: To connect securely to {{site.data.reuse.short_name}}, your application needs credentials with permission to access the cluster and resources such as topics. In the **Kafka listener and credentials** section, click the **Generate SCRAM credentials** or **Generate TLS credentials** button next to the listener you are using, and follow the instructions to select the level of access you want to grant to your resources with the credentials.
   * **Certificates**: A certificate is required by your client applications to connect securely to the destination cluster. In the **Certificates** section, download either the PKCS12 certificate or PEM certificate. If you use the PKCS12 certificate, make a copy of the **Certificate password** to use with the certificate in your application.

After the connection is configured, your client application can continue to operate using the geo-replicated topics on the destination cluster.

**Note**: Replicated topics on the destination cluster will have a prefix added to the topic name. The prefix is the name of the {{site.data.reuse.short_name}} instance on the origin cluster, as defined in the EventStreams custom resource, for example `my_origin.<topic-name>`. You can use regular expressions to define the topics that a Kafka Consumer is subscribed to, for example `.*<topic-name>`. Using a regular expression means that the topic subscription does not need to change when switching to the destination cluster.

## Updating consumer group offsets

The topic at the origin cluster and the geo-replicated topic at the destination cluster might have different offsets for the same messages, depending on when geo-replication started. This means that a consuming application that is switched to use the destination cluster cannot use the consumer group offset from the origin cluster.

### Updating consumer group offsets by using checkpoints

Geo-replication uses the Kafka Mirror Maker 2.0 `MirrorCheckpointConnector` to automatically store consumer group offset checkpoints for all origin cluster consumer groups. Each checkpoint maps the last committed offset for each consumer group in the origin cluster to the equivalent offset in the destination cluster. The checkpoints are stored in the `<origin_cluster_name>.checkpoints.internal` topic on the destination cluster.

**Note**: Consumer offset checkpoint topics are internal topics that are not displayed in the UI and CLI. Run the following CLI command to include internal topics in the topic listing:\\
`cloudctl es topics --internal`.

When processing messages from the destination cluster, you can use the checkpoints to start consuming from an offset that is equivalent to the last committed offset at the origin cluster. If your application is written in Java, Kafka's [`RemoteClusterUtils`](https://kafka.apache.org/25/javadoc/index.html?org/apache/kafka/connect/mirror/RemoteClusterUtils.html){:target="_blank"} class provides the `translateOffsets()` utility method to retrieve the destination cluster offsets for a consumer group from the checkpoints topic. You can then use the `KafkaConsumer.seek()` method to override the offsets that the consumer will use on the next `poll`.

For example, the following Java code snippet will update the `example-group` consumer group offset from the `origin-cluster` cluster to the destination cluster equivalent:

```
// Retrieve the mapped offsets for the destination cluster topic-partitions
Map<TopicPartition, OffsetAndMetadata> destinationOffsetsMap = RemoteClusterUtils.translateOffsets(properties, "origin-cluster",
        "example-group", Duration.ofMillis(10000));

// Update the KafkaConsumer to start at the mapped offsets for every topic-partition
destinationOffsetsMap.forEach((topicPartition, offsetAndMetadata) -> kafkaConsumer.seek(topicPartition, offsetAndMetadata));

// Retrieve records at the destination cluster, starting from the mapped offsets
ConsumerRecords<byte[], byte[]> records = kafkaConsumer.poll(Duration.ofMillis(10000))
```

**Note**: To configure how often checkpoints are stored and which consumer groups are stored in the checkpoints topic, you can edit the following properties in your Kafka Mirror Maker 2 custom resource:
 - `spec.mirror.checkpointConnector.config`
 - `spec.mirror.groupsPattern`

### Updating consumer group offsets manually

If you want your client application to continue processing messages on the destination cluster from the point they reached on the topic on the origin cluster, or if you want your client application to start processing messages from the beginning of the topic, you can use the `cloudctl es group-reset` command.

* To continue processing messages from the point they reached on the topic on the origin cluster, you can specify the offset for the consumer group that your client application is using:\\
  1. {{site.data.reuse.cp_cli_login}}
  2. Run the following command to initialize the {{site.data.reuse.short_name}} CLI on the cluster:\\
  `cloudctl es init`
  3. Run the `cloudctl es group-reset` command as follows:
  \\
  `cloudctl es group-reset --group <your-consumer-group-id> --topic <topic-name> --mode datetime --value <timestamp>`\\
  \\
  For example, the following command instructs the applications in consumer group `consumer-group-1` to start consuming messages with timestamps from after midday on 28th September 2018:\\
  \\
  `cloudctl es group-reset --group consumer-group-1 --topic GEOREPLICATED.TOPIC --mode datetime --value 2018-09-28T12:00:00+00:00 --execute`

* To start processing messages from the beginning of the topic, you can use the `--mode earliest` option, for example:\\
  `cloudctl es group-reset --group consumer-group-1 --topic GEOREPLICATED.TOPIC --mode earliest --execute`

These methods also avoid the need to make code changes to your client application.
