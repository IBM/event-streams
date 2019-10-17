---
title: "Performance and capacity planning"
excerpt: "Consider the following when planning for the performance and capacity requirements of your installation."
categories: installing
slug: capacity-planning
toc: true
---

When preparing for your {{site.data.reuse.long_name}} installation, consider the performance and capacity requirements for your system.

<!--, including the disk space required for persistent volumes, and the memory and CPU resource limits for your Kafka brokers and geo-replicator containers-->

<!--It's important to understand your requirements so that you set up your deployment to handle the intended workload. In addition,  [licensing](../planning/#licensing) is based on the number of virtual cores available to all Kafka and Geo-replicator containers deployed.-->

## Guidance for production environments

The [prerequisites](../prerequisites/#helm-resource-requirements) for {{site.data.reuse.short_name}} provide information about the minimum resources requirements for a test environment. For a baseline production deployment of {{site.data.reuse.short_name}}, increase the following values.

- Set the CPU request and limit values for Kafka brokers to `4000m`.\\
   You can use the `kafka.resources.requests.cpu` and `kafka.resources.limits.cpu` options if you are using the command line, or enter the values in the **CPU request for Kafka brokers** and **CPU limit for Kafka brokers** fields of the **Configure** page if using the UI.
- Set the memory request and limit values for Kafka brokers to at least `6Gi`.\\
   You can use the `kafka.resources.requests.memory` and `kafka.resources.limits.memory` options if you are using the command line, or enter the values in the **Memory request for Kafka brokers** and **Memory limit for Kafka brokers** fields of the **Configure** page if using the UI.

You can set higher values when [configuring](../configuring) your installation, or set them [later](../../administering/scaling/).

**Note:** This guidance sets the requests and limits to the same values. You might need to set the limits to higher values depending on your intended workload. Remember to add the increases to the minimum [resource requirement values](../prerequisites/#helm-resource-requirements), and ensure the increased settings can be served by your system.

**Important:** For high throughput environments, also ensure you [prepare](#performance-considerations-for-ibm-cloud-private) your {{site.data.reuse.icp}} installation beforehand.

Depending on your workload, you can further scale {{site.data.reuse.short_name}} and fine tune Kafka performance to accommodate the increased requirements.

### Scaling {{site.data.reuse.short_name}}

If required by your planned workload, you can further increase the number of Kafka brokers, and the amount of CPU and memory available to them. For changing other values, see the guidance about [scaling](../../administering/scaling/) {{site.data.reuse.short_name}}.

A [performance report](../../../pdfs/Performance Report 2019.2.1 v1.0.pdf){:target="_blank"} based on example case studies is available to provide guidance for setting these values.

### Tuning {{site.data.reuse.short_name}} Kafka performance

You can further fine-tune the performance settings of your {{site.data.reuse.short_name}} Kafka brokers to suit your requirements. Kafka provides a range of parameters to set, but consider the following ones when reviewing performance requirements. You can set these parameters when installing {{site.data.reuse.short_name}}, or you can modify them later.

- The `num.replica.fetchers` parameter sets the number of threads available on each broker to replicate messages from topic leaders. Increasing this setting increases
I/O parallelism in the follower broker, and can help reduce bottlenecks and message latency. You can start by setting this value to match the number of brokers deployed in the system.\\
   **Note:** Increasing this value results in brokers using more CPU resources and network bandwidth.
- The `num.io.threads` parameter sets the number of threads available to a broker for processing requests. As the load on each broker increases, handling requests can become a bottleneck. Increasing this parameter value can help mitigate this issue. The value to set depends on the overall system load and the processing power of the worker nodes, which varies for each deployment. There is a correlation between this setting and the `num.network.threads` setting.
- The `num.network.threads` parameter sets the number of threads available to the broker for receiving and sending requests and responses to the network. The value to set depends on the overall network load, which varies for each deployment. There is a correlation between this setting and the `num.io.threads` setting.
- The `replica.fetch.min.bytes`, `replica.fetch.max.bytes`, and `replica.fetch.response.max.bytes` parameters control the minimum and maximum sizes for message payloads when
performing inter-broker replication. Set these values to be greater than the `message.max.bytes` parameter to ensure that all messages sent by a producer can be replicated
between brokers. The value to set depends on message throughput and average size, which varies for each deployment.

To set these parameter values, you can use a ConfigMap that specifies Kafka configuration settings for your {{site.data.reuse.short_name}} installation.

#### Setting before installation

If you are creating the ConfigMap and setting the parameters when installing {{site.data.reuse.short_name}}, you can add these parameters to the properties file with the required values.

1. Add the parameters and their values to the Kafka `server.properties` file, for example:\\
   ```
   num.io.threads=24
   num.network.threads=9
   num.replica.fetchers=3
   replica.fetch.max.bytes=5242880
   replica.fetch.min.bytes=1048576
   replica.fetch.response.max.bytes=20971520
   ```
2. Create the ConfigMap as described in the [planning for installation](../planning/#configmap-for-kafka-static-configuration) section, for example:\\
   `kubectl -n <namespace_name> create configmap <configmap_name> --from-env-file=<full_path/server.properties>`
3. When installing {{site.data.reuse.short_name}}, ensure you [provide](../configuring/#specifying-a-configmap-for-kafka-configuration) the ConfigMap to the installation.

#### Modifying an existing installation

If you are updating an existing {{site.data.reuse.short_name}} installation, you can use the ConfigMap you already have for the Kafka configuration settings, and include the parameters and their values in the ConfigMap. You can then apply the new settings by updating the ConfigMap as described [modifying Kafka broker configurations](../../administering/modifying-configs/#modifying-broker-and-cluster-settings), for example:

`helm upgrade --reuse-values --set kafka.configMapName=<configmap_name> <release_name> <charts.tgz>`

Alternatively, you can modify broker configuration settings dynamically by using the {{site.data.reuse.short_name}} CLI as described in [modifying Kafka broker configurations](../../administering/modifying-configs/#modifying-broker-and-cluster-settings), for example:

`cloudctl es cluster-config --config num.replica.fetchers=4`

**Important:** Using the {{site.data.reuse.short_name}} CLI overrides the values specified in the ConfigMap. In addition, the CLI enforces constraints to avoid certain parameters to be misconfigured. For example, you cannot set `num.replica.fetches` to a value greater than double its current value. This means that you might have to make incremental updates to the value, for example:

```
cloudctl es cluster-config --config num.replica.fetchers=2
cloudctl es cluster-config --config num.replica.fetchers=4
cloudctl es cluster-config --config num.replica.fetchers=8
cloudctl es cluster-config --config num.replica.fetchers=9
```

## Performance considerations for {{site.data.reuse.icp}}

For high throughput environments, consider the following configuration options when setting up your {{site.data.reuse.icp}} environment.
- Set up an external load balancer for your {{site.data.reuse.icp}} cluster to provide a dedicated external access point for the cluster that provides intelligent routing algorithms.
- Set up a dedicated internal network for inter-broker traffic to avoid contention between internal processes and external traffic.

**Important:** You must consider and set these {{site.data.reuse.icp}} configuration options before installing {{site.data.reuse.short_name}}.

### Setting up a load balancer

In high throughput environments, [configure an external load balancer](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/set_loadbalancer.html){:target="_blank"} for your {{site.data.reuse.icp}} cluster.

Without a load balancer, a typical {{site.data.reuse.short_name}} installation includes a master node for allowing external traffic into the cluster. There are also worker nodes that host Kafka brokers. Each broker has an advertised listener that consists of the master node's IP address and a unique node port within the cluster. This means the worker nodes can be identified without being exposed externally.

When a producer connects to the {{site.data.reuse.short_name}} master node through the bootstrap port, they are sent metadata that identifies partition leaders for the topics hosted by the brokers. So, access to the cluster is based on the address `<master_node:bootstrap_port>`, and identification is based on the advertised listener addresses within the cluster, which has a node port to uniquely identify the specific broker.

For example, the connection is made to the `<master_node:bootstrap_port>` address, for example: `192.0.2.24:30724`

The advertised listener is then made up of the `<master_node:unique_port>` address, for example: `192.0.2.24:88945`

The producer then sends messages to the advertised listener for a partition leader of a topic. These requests go through the master node and are passed to the right worker node in {{site.data.reuse.short_name}} based on the internal IP address for that specific advertised listener that identifies the broker.

This means all traffic is routed through the master node before being distributed across the cluster. If the master node is overloaded by service requests, network traffic, or system operations, it becomes a bottleneck for incoming requests.

![Schemas: Setup without a load balancer diagram.](../../../images/No_Load_Balancer.svg "Diagram representing flow of message data through the master node where there is no load balancer.")

A load balancer replaces the master node as the entry point into the cluster, providing a dedicated service that typically runs on a separate node. In this case the bootstrap address points to the load balancer instead of the master node. The load balancer passes incoming requests to any of the available worker nodes. The worker node then forwards the request onto the correct broker within the cluster based on its advertised listener address.

Setting up a load balancer provides more control over how requests are forwarded into the cluster (for example, round-robin, least congested, and so on), and frees up the master node for system operations.

![Schemas: Setup with a load balancer diagram.](../../../images/Load_Balancer.svg "Diagram representing flow of message data when a load balancer is set up.")

For more information about configuring an external load balancer for your cluster, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/set_loadbalancer.html){:target="_blank"}.

**Important:** When using a load balancer for {{site.data.reuse.icp}}, ensure you set the address for your endpoint in the [External hostname/IP address field](../configuring/#configuring-external-access) field when installing your {{site.data.reuse.short_name}} instance.

### Setting up an internal network

Communication between brokers can generate significant network traffic in high usage scenarios. Topic configuration such as replication factor settings can also impact traffic volume. For high performance setups, enable an internal network to handle workload traffic within the cluster.

To configure an internal network for inter-broker workload traffic, enable a second network interface on each node, and configure the `config.yaml` before installing {{site.data.reuse.icp}}. For example, use the `calico_ip_autodetection_method` setting to configure the master node IP address on the second network as follows:

`calico_ip_autodetection_method: can-reach=<internal_ip_address_for_master_node>`

For more information about setting up a second network, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/config_yaml.html){:target="_blank"}.



## Disk space for persistent volumes

You need to ensure you have sufficient disk space in the persistent storage for the Kafka brokers to meet your expected throughput and retention requirements. In Kafka, unlike other messaging systems, the messages on a topic are not immediately removed after they are consumed. Instead, the configuration of each topic determines how much space the topic is permitted and how it is managed.

Each partition of a topic consists of a sequence of files called log segments. The size of the log segments is determined by the cluster configuration `log.segment.bytes` (default is 1 GB). This can be overridden by using the topic-level configuration `segment.bytes`.

For each log segment, there are two index files called the time index and the offset index. The size of the index is determined by the cluster configuration `log.index.size.max.bytes` (default is 10 MB). This can be overridden by using the topic-level configuration `segment.index.bytes`.

Log segments can be deleted or compacted, or both, to manage their size. The topic-level configuration `cleanup.policy` determines the way the log segments for the topic are managed.

For more information about the broker configurations and topic-level configurations, see [the Kafka documentation](https://kafka.apache.org/documentation/#configuration){:target="_blank"}.

You can specify the cluster and topic-level configurations by using [the {{site.data.reuse.long_name}} CLI](../../administering/modifying-configs/#modifying-broker-and-cluster-settings). You can also set topic-level configuration when setting up the topic in the {{site.data.reuse.long_name}} UI (click the **Topics** tab, then click **Create topic**, and click **Advanced**).

### Log cleanup by deletion

If the topic-level configuration `cleanup.policy` is set to `delete` (the default value), old log segments are discarded when the retention time or size limit is reached, as set by the following properties:

- Retention time is set by `retention.ms`, and is the maximum time in milliseconds that a log segment is retained before being discarded to free up space.
- Size limit is set by `retention.bytes`, and is the maximum size that a partition can grow to before old log segments are discarded.

By default, there is no size limit, only a time limit. The default time limit is 7 days (604,800,000 ms).

You also need to have sufficient disk space for the log segment deletion mechanism to operate. The broker configuration `log.retention.check.interval.ms` (default is 5 minutes) controls how often the broker checks to see whether log segments should be deleted. The broker configuration `log.segment.delete.delay.ms` (default is 1 minute) controls how long the broker waits before deleting the log segments. This means that by default you also need to ensure you have enough disk space to store log segments for an additional 6 minutes for each partition.

#### Worked example 1

Consider a cluster that has 3 brokers, and 1 topic with 1 partition with a replication factor of 3. The expected throughput is 3,000 bytes per second. The retention time period is 7 days (604,800 seconds).

Each broker hosts 1 replica of the topic's single partition.

The log capacity required for the 7 days retention period can be determined as follows: 3,000 * (604,800 + 6 * 60) = 1,815,480,000 bytes.

So, each broker requires approximately 2GB of disk space allocated in its persistent volume, plus approximately 20 MB of space for index files. In addition, allow at least 1 log segment of extra space to make room for the actual cleanup process. Altogether, you need a total of just over 3 GB disk space for persistent volumes.

#### Worked example 2

Consider a cluster that has 3 brokers, and 1 topic with 1 partition with a replication factor of 3. The expected throughput is 3,000 bytes per second.  The retention size configuration is set to 2.5 GB.

Each broker hosts 1 replica of the topic's single partition.

The number of log segments for 2.5 GB is 3, but you should also allow 1 extra log segment after cleanup.

So, each broker needs approximately 4 GB of disk space allocated in its persistent volume, plus approximately 40 MB of space for index files.

The retention period achieved at this rate is approximately 2,684,354,560 / 3,000 = 894,784 seconds, or 10.36 days.

### Log cleanup by compaction

If the topic-level configuration `cleanup.policy` is set to `compact`, the log for the topic is compacted periodically in the background by the log cleaner. In a compacted topic, each message has a key. The log only needs to contain the most recent message for each key, while earlier messages can be discarded. The log cleaner calculates the offset of the most recent message for each key, and then copies the log from start to finish, discarding keys which have later messages in the log. As each copied segment is created, they are swapped into the log right away to keep the amount of additional space required to a minimum.

Estimating the amount of space that a compacted topic will require is complex, and depends on factors such as the number of unique keys in the messages, the frequency with which each key appears in the uncompacted log, and the size of the messages.

### Log cleanup by using both

You can specify both `delete` and `compact` values for the `cleanup.policy` configuration at the same time. In this case, the log is compacted, but the cleanup process also follows the retention time or size limit settings.

When both methods are enabled, capacity planning is simpler than when you only have compaction set for a topic. However, some use cases for log compaction depend on messages not being deleted by log cleanup, so consider whether using both is right for your scenario.

<!--
## Memory requirements

TBD

## CPU requirements

TBD
-->
