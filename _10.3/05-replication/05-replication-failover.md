---
title: "Switching clusters"
excerpt: "Using geo-replication to recover when clusters become unavailable."
categories: georeplication
slug: failover
toc: true
---

When one of your origin {{site.data.reuse.short_name}} clusters experiences problems and becomes unavailable, you can switch your client applications over to use the geo-replicated topics on your destination {{site.data.reuse.short_name}} cluster.

Ensure you [plan for geo-replication](../planning/) before [setting it up](../setting-up/).

## Preparing clusters and applications for switching

To make switching of clusters require little intervention, consider the following guidance when preparing your {{site.data.reuse.short_name}} clusters and applications.

### Configure your applications for switching

Set up your applications so that reconfiguring them to switch clusters is as easy as possible. Code your applications so that security credentials, certificates, bootstrap server addresses, and other configuration settings are not hard-coded, but can be set in configuration files, or otherwise injected into your applications.

### Use the same certificates

Consider using the same certificates for both the origin and destination clusters, by [providing your own certificates at installation](../../installing/configuring/#using-your-own-certificates). This allows applications to use a single certificate to access either cluster.

**Note**: You must complete the process of providing your own certificates before installing an instance of Event Streams.

**Note**: When providing your own certificates, ensure that certificate renewal processes are followed at both the origin and destination clusters, so that both clusters continue to use the same certificates.

### Set up the same access to both clusters

Consider providing your applications the same access to both the origin and destination clusters. For example, you can duplicate the application `KafkaUser` credentials from the origin cluster to the destination cluster. This allows applications to use a single set of credentials to access either cluster. Use the following commands to retrieve the `KafkaUser` credentials and custom resource from the origin cluster, and then create a new `KafkaUser` with these credentials on the destination cluster:
1. Log in to your origin cluster. {{site.data.reuse.openshift_cli_login}}
2. Run the following command to retrieve the name of the secret for the `KafkaUser`:\\
`oc get kafkauser <name> --namespace <namespace> -o jsonpath='{"username: "}{.status.username}{"\nsecret-name: "}{.status.secret}{"\n"}'`\\
\\
The command provides the following output:
- The principal username
- The name of the Kubernetes `Secret`, which includes the namespace, containing the SCRAM password or the TLS certificates.
3. Use the `secret-name` from the previous step to run the following command. The command retrieves the credentials from the Kubernetes `Secret` and and saves them to the `kafkauser-secret.yaml` file:\\
`oc get secret <secret-name> --namespace <namespace> -o yaml > kafkauser-secret.yaml`
4. Run the following command to retrieve the `KafkaUser` custom resource YAML and save it to the `kafkauser.yaml` file:\\
`oc get kafkauser <name> --namespace <namespace> -o yaml > kafkauser.yaml`
5. Log in to your destination cluster.  {{site.data.reuse.openshift_cli_login}}
6. Edit both the `kafkauser-secret.yaml` and `kafkauser.yaml` files to set the correct namespace and {{site.data.reuse.short_name}} cluster name for the following properties:
   - `metadata.namespace`: provide the namespace of your destination cluster.
   - `metadata.labels["eventstreams.ibm.com/cluster"]`: provide the name of your destination cluster.
7. Run the following command to create the Kubernetes `Secret` containing the `KafkaUser` credentials on the destination cluster:\\
`oc apply -f kafkauser-secret.yaml`\\
**Note**: You must run this command before the creation of the `KafkaUser` to ensure the same credentials are available on both the origin and destination clusters.    
8. Run the following command to create the `KafkaUser` on the destination cluster:\\
`oc apply -f kafkauser.yaml`

**Note**: To duplicate `KafkaUser` credentials that use Mutual TLS authentication, the origin and destination cluster must be [configured with the same certificates for the client CA at installation](../../installing/configuring/#using-your-own-certificates).

**Note**: When `KafkaUser` credentials or Access Control Lists (ACLs) are modified on the origin cluster, the changes will need to be duplicated to the destination cluster to ensure that you can still switch clusters.

### Use regular expressions for consumer topic subscriptions

Geo-replicated topics on the destination cluster will have a prefix added to the topic name. The prefix is the name of the {{site.data.reuse.short_name}} instance on the origin cluster, as defined in the `EventStreams` custom resource, for example `my_origin.<topic-name>`. Consider using regular expressions to define the topics that consuming applications are subscribed to, for example `.*<topic-name>`.  Using a regular expression means that the topic subscription does not need to change when switching to the prefixed topic names on the destination cluster.

### Plan to update consumer group offsets

Consider how you will [update the consumer group offsets](#updating-consumer-group-offsets) in consuming applications when switching clusters. Geo-replication includes consumer group checkpointing to store the mapping of consumer group offsets, allowing consuming applications to continue processing messages at the appropriate offset positions.

### Produce to the same topic name

When switching clusters, produce to the same topic name on the destination cluster as was used on the origin cluster. This will ensure geo-replicated messages and directly produced messages are stored in separate topics. If consuming applications use regular expressions to subscribe to both topics, then both sets of messages will be processed.

### Consider message ordering

If message ordering is required, configure your consuming applications to process all messages from the geo-replicated topic on the destination cluster before producing applications are restarted.

## Updating existing applications to use geo-replicated topics on the destination cluster

If you are not using the same certificates and credentials on the origin and destination clusters, use the following instructions to retrieve the information required to update your applications so that they can use the geo-replicated topics from the destination cluster:

1. Log in to your destination {{site.data.reuse.short_name}} cluster as an administrator.
2. Click **Connect to this cluster**.
3. Go to the **Resources** tab, and use the information on the page to change your client application settings to use the geo-replicated topic on the destination cluster. You need the following information to do this:\\
   * **Bootstrap server**: In the **Kafka listener and credentials** section, select the listener from the list.
      - Click the **External** tab for applications connecting from outside of the {{site.data.reuse.openshift_short}} cluster.
      - Click the **Internal** tab for applications connecting from inside the {{site.data.reuse.openshift_short}} cluster.
    * **Credentials**: To connect securely to {{site.data.reuse.short_name}}, your application needs credentials with permission to access the cluster and resources such as topics. In the **Kafka listener and credentials** section, click the **Generate SCRAM credentials** or **Generate TLS credentials** button next to the listener you are using, and follow the instructions to select the level of access you want to grant to your resources with the credentials.
   * **Certificates**: A certificate is required by your client applications to connect securely to the destination cluster. In the **Certificates** section, download either the PKCS12 certificate or PEM certificate. If you use the PKCS12 certificate, make a copy of the **Certificate password** to use with the certificate in your application.

After the connection is configured, your client application can continue to operate using the geo-replicated topics on the destination cluster.

## Updating consumer group offsets

The topic on the origin cluster and the geo-replicated topic on the destination cluster might have different offsets for the same messages, depending on when geo-replication started. This means that a consuming application that is switched to use the destination cluster cannot use the consumer group offset from the origin cluster.

### Updating consumer group offsets by using checkpoints

Geo-replication uses the Kafka Mirror Maker 2.0 `MirrorCheckpointConnector` to automatically store consumer group offset checkpoints for all origin cluster consumer groups. Each checkpoint maps the last committed offset for each consumer group in the origin cluster to the equivalent offset in the destination cluster. The checkpoints are stored in the `<origin_cluster_name>.checkpoints.internal` topic on the destination cluster.

**Note**: Consumer offset checkpoint topics are internal topics that are not displayed in the UI and CLI. Run the following CLI command to include internal topics in the topic listing:\\
`cloudctl es topics --internal`.

When processing messages from the destination cluster, you can use the checkpoints to start consuming from an offset that is equivalent to the last committed offset on the origin cluster. If your application is written in Java, Kafka's [`RemoteClusterUtils`](https://kafka.apache.org/25/javadoc/index.html?org/apache/kafka/connect/mirror/RemoteClusterUtils.html){:target="_blank"} class provides the `translateOffsets()` utility method to retrieve the destination cluster offsets for a consumer group from the checkpoints topic. You can then use the `KafkaConsumer.seek()` method to override the offsets that the consumer will use on the next `poll`.

For example, the following Java code snippet will update the `example-group` consumer group offset from the `origin-cluster` cluster to the destination cluster equivalent:

```
// Retrieve the mapped offsets for the destination cluster topic-partitions
Map<TopicPartition, OffsetAndMetadata> destinationOffsetsMap = RemoteClusterUtils.translateOffsets(properties, "origin-cluster",
        "example-group", Duration.ofMillis(10000));

// Update the KafkaConsumer to start at the mapped offsets for every topic-partition
destinationOffsetsMap.forEach((topicPartition, offsetAndMetadata) -> kafkaConsumer.seek(topicPartition, offsetAndMetadata));

// Retrieve records from the destination cluster, starting from the mapped offsets
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

## Reverting message production and consumption back to the origin cluster

When the origin {{site.data.reuse.short_name}} cluster becomes available again, you can switch your client applications   back to use the topics on your origin cluster. If messages have been produced directly to the destination cluster, use the following steps to replicate those messages to the origin cluster before switching back to using it.
 - [Create an `EventStreamsGeoReplicator` custom resource](../planning) configured to connect to the origin {{site.data.reuse.short_name}} cluster, and set up geo-replication in the reverse direction to the original geo-replication flow. This means there will be a geo-replicator running on the origin cluster which copies messages from non-geo-replicated topics on the destination cluster back to geo-replicated topics on the origin cluster.
 - The geo-replicated topic named `<origin-cluster>.<topic>` on the destination cluster will not have new geo-replicated messages arriving, as the producing applications have been switched to produce messages directly to the topic without a prefix on the destination cluster. Ensure that the geo-replicated topic on the destination cluster is not geo-replicated back to the origin cluster as this will result in duplicate data on the origin cluster.
 - Switch the producing and consuming applications back to the origin cluster again by following the [previous instructions](#preparing-clusters-and-applications-for-switching). Producing applications will continue to produce messages to the original topic name on the origin cluster, and consuming applications will read from both the geo-replicated topics and the original topics on the origin cluster. Consuming applications will need their [consumer group offsets to be correctly updated](#updating-consumer-group-offsets) for the offset positions on the origin cluster.

**Note**: Due to the asynchronous nature of geo-replication, there might be messages in the original topics on the origin cluster that had not been geo-replicated over to the destination cluster when the origin cluster became unavailable. You will need to decide how to handle these messages. Consider setting consumer group offsets so that the messages are processed, or ignore the messages by setting consumer group offsets to the latest offset positions in the topic.

For example, if the origin cluster is named `my_origin`, the destination cluster is named `my_destination`, and the topic on the `my_origin` cluster is named `my_topic`, then the geo-replicated topic on the `my_destination` cluster will be named `my_origin.my_topic`.
 - When the `my_origin` cluster becomes unavailable, producing applications are switched to the `my_destination` cluster. The `my_destination` cluster now has topics named `my_topic` and `my_origin.my_topic`. Consuming applications are also switched to the `my_destination` cluster and use the regular expression `.*my_topic` to consume from both topics.
 - When the `my_origin` cluster becomes available again, reverse geo-replication is set up between the clusters. The `my_origin` cluster now has the topic named `my_topic` and a new geo-replicated topic named `my_destination.my_topic`. The topic named `my_destination.my_topic` contains the messages that were produced directly to the `my_destination` cluster.
 - Producing applications are producing to the topic named `my_topic` on the `my_destination` cluster, so the geo-replicated topic named `my_origin.my_topic` on the `my_destination` cluster does not have any new messages arriving. Existing messages in the topic named `my_origin.my_topic` are consumed from the `my_destination` cluster until there is no more processing of the messages required.\\
 **Note:** The geo-replicated topic named `my_origin.my_topic` is not included in the reverse geo-replication back to the `my_origin` cluster, as that would create a geo-replicated topic named `my_destination.my_origin.my_topic` on the `my_origin` cluster containing the same messages as in the topic named `my_topic`.
 - Producing applications are now switched back to the `my_origin` cluster, continuing to produce to the topic named `my_topic`.
 - Consuming applications are also switched back to the `my_origin` cluster, with consumer group offsets updated for the offset positions at the `my_origin` cluster. Consuming applications continue to use the regular expression `.*my_topic` to consume from both the topic named `my_topic` and the geo-replicated topic named `my_destination.my_topic`.
