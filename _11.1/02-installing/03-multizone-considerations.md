---
title: "Considerations for multizone deployments"
excerpt: "Consider the following when planning for deploying Event Streams to a cluster with multiple availability zones."
categories: installing
slug: multizone-considerations
layout: redirects
toc: true
---

As part of planning for a [resilient deployment](../planning/#planning-for-resilience), you can deploy {{site.data.reuse.short_name}} on a multizone {{site.data.reuse.openshift_short}} cluster to allow for greater resilience against external disruption. For more information and instructions, see how to [prepare for a multizone deployment](../preparing-multizone/), or see the [tutorial]({{ 'tutorials/multi-zone-tutorial/' | relative_url }}){:target="_blank"}. Before following these instructions and deploying {{site.data.reuse.short_name}} on a multizone cluster, consider the following information.

## Reasons to consider multiple availability zones

Kafka itself offers strong resilience against many failures that could occur within a compute environment. However, Kafka cannot deal with a failure that affects the entire cluster it resides on. In preparation for both planned or unplanned outages, Kafka requires an external redundancy solution or backup to avoid data loss. One solution for this is a Kafka cluster with brokers distributed across multiple availability zones.

An availability zone is an isolated set of computing infrastructure. This includes all aspects of the infrastructure from compute resources to cooling. Data centers are often made up of multiple availability zones. This allows planned outages for maintenance to be done per availability zone, and also helps contain damage from any unplanned outages due to problems within any of the availability zones.

**Note:** A multizone Kafka cluster offers resilience against failures in a single compute environment, but does not allow for the brokers to be deployed far apart due to latency issues.

## Multizone Kafka Cluster

In a multizone Kafka cluster, the brokers are deployed in one virtual compute environment that spans multiple availability zones. This requires the {{site.data.reuse.openshift_short}} environment to have nodes that are distributed across multiple availability zones. The Kafka brokers can then be set to run on specific nodes by using Kubernetes topology labels. The following diagram shows the resulting architecture:

![3 Kafka brokers on a stretch Openshift Cluster with 3 availability zones]({{ 'images/' | relative_url }}/multizone-kafka-arch.png "Diagram showing 3 Kafka brokers deployed on a stretch OpenShift cluster"){:height="100%" width="100%"}

### Trade-offs in multizone deployments

#### Latency

For Kafka to function reliably in a stretch {{site.data.reuse.openshift_short}} cluster configuration, network latency between the nodes of your Kubernetes cluster must not be greater than 20ms. Low single digit latency values are preferable. The reason is that Kafka brokers and ZooKeeper connections are considered as being deployed on the same hardware. To work around this, you can adjust the following Kafka options in the {{site.data.reuse.short_name}} custom resource:

- `zookeeper.connection.timeout.ms` sets the maximum time in milliseconds that ZooKeeper waits for a connection to establish when communicating with a Kafka broker.
- `replica.lag.time.max.ms` sets the maximum time available in milliseconds for follower replicas to catch up to the leader.

By increasing these values, Kafka can avoid timeouts. However, there is a performance cost to this. Increasing `zookeeper.connection.timeout.ms` will  result in longer wait times between operations as ZooKeeper might wait longer for a response from Kafka brokers, while increasing `replica.lag.time.max.ms` could result in longer time periods during which your replicas might be out of sync.

#### Replication

In a multizone Kafka cluster, topics, partitions, and replicas need to be carefully managed with respect to managing data redundancy. You can manage this by choosing a suitable value for `min.insync.replicas` so that in the event of an outage in one availability zone:
1. No data is lost.
2. The Kafka cluster can still operate, meaning that the number of remaining replicas is greater than or equal to the value of `min.insync.replicas`.

For example, the following table provides information about what to set as the value for `min.insync.replicas` across 3 availability zones :

| Number of Kubernetes nodes | Number of Kafka brokers |  Value for `min.insync.replicas` |
| -------------------------- | ----------------------- | ---------------------------------|
|              3             |            3            |                2                 |
|              3             |            4            |                3                 |
|              3             |            5            |                3                 |
|              3             |            6            |                4                 |
