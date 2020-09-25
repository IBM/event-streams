---
title: "Optimizing Kafka cluster with Cruise Control"
excerpt: "Use Cruise Control to manage your brokers and topic partitions."
categories: administering
slug: cruise-control
toc: true
---

## Overview

Cruise Control is an open-source system for optimizing your Kafka cluster by monitoring cluster workload, rebalancing a cluster based on predefined constraints, and detecting and fixing anomalies.

You can set up {{site.data.reuse.short_name}} to use the following Cruise Control features:

- Generating optimization proposals from multiple optimization goals.
- Rebalancing a Kafka cluster based on an optimization proposal.

**Note:** {{site.data.reuse.short_name}} does not support other Cruise Control features.

<!-- Copied from Strmzi -->

Cruise Control can be used to dynamically optimize the distribution of the partitions on your brokers so that resources are used more efficiently.

Cruise Control reduces the time and effort involved in running an efficient and balanced Kafka cluster.

A typical cluster can become unevenly loaded over time. Partitions that handle large amounts of message traffic might be unevenly distributed across the available brokers. To rebalance the cluster, administrators must monitor the load on brokers and manually reassign busy partitions to brokers with spare capacity.

Cruise Control automates the cluster rebalancing process. It constructs a workload model of resource utilization for the cluster based on CPU, disk, and network load, ​and generates optimization proposals (that you can approve or reject) for more balanced partition assignments. A set of configurable optimization goals is used to calculate these proposals.

When you approve an optimization proposal, Cruise Control applies it to your Kafka cluster. When the cluster rebalancing operation is complete, the broker pods are used more effectively and the Kafka cluster is more evenly balanced.

<!-- Copied from Strmzi -->

### Steps for rebalancing a cluster

Follow these steps to rebalance a cluster by using Cruise Control:

1. Ensure you have an {{site.data.reuse.short_name}} installation that has Cruise Control [enabled](../../installing/configuring/#enabling-and-configuring-cruise-control) in the `EventStreams` custom resource.
2. In your `EventStreams` custom resource, configure the optimization goals that are available for rebalancing, and set capacity limits for broker resources. You can use Cruise Control defaults or define your own goals and capacity limits, as described in [enabling and configuring Cruise Control](../../installing/configuring/#enabling-and-configuring-cruise-control).

   **Important:** The configuration settings in the `EventStreams` custom resource are used by all optimization proposals defined in the `KafkaRebalance` custom resource, and can constrain the possible proposals a user can make.

3. [Set up the optimization proposal](#setting-up-optimization) by using the `KafkaRebalance` custom resource.

   **Important:** Deploying Cruise Control allows for rebalancing a cluster based on the predefined constraints defined in the `KafkaRebalance` custom resource. If Cruise Control is not enabled, the `KafkaRebalance` custom resource has no effect on a cluster, and similarly, without a `KafkaRebalance` custom resource Cruise Control will make no changes to a cluster even if it is enabled.

4. Wait for an [optimization proposal](#receiving-an-optimization-proposal) to appear in the status of the `KafkaRebalance` custom resource.
5. [Accept the optimization proposal](#approving-an-optimization-proposal) in the `KafkaRebalance` custom resource by annotating it.
6. Check for the `KafkaRebalance` proposal to be finished processed.
7. Depending on the outcome of the `KafkaRebalance` proposal, perform the following steps:
   - If **`status.condtions[0].status` = Ready:** Cruise Control has successfully optimized the Kafka cluster and no further action is needed.
   - If **`status.condtions[0].status` = NotReady:** Cruise Control was unable to optimize the Kafka cluster and you need to [address the error](#dealing-with-rebalancing-errors)

## Setting up optimization

To rebalance a Kafka cluster, Cruise Control uses the [available](#configuring-cruise-control) optimization goals to generate optimization proposals, which you can approve or reject.

### Creating an optimization proposal

To define the [goals](#optimization-goals) to use when rebalancing the cluster, use the `KafkaRebalance` custom resource. The goals defined in the custom resource determine how the cluster will be optimized during the calculation of the `KafkaRebalance` proposal.

**Important:** The [hard goals](#hard-goals) that are configured in `spec.strimziOverrides.config["hard.goals"]` in the `EventStreams` custom resource must be satisfied, whereas the goals defined in the `KafkaRebalance` custom resource will be optimized if possible, but not at the cost of violating any of the hard goals.

To create a `KafkaRebalance` custom resource that creates a proposal that does not consider the hard goals set in `spec.strimziOverrides.cruiseControl.config["hard.goals"]` in the `EventStreams` custom resource, set `spec.skipHardGoalsCheck` to true in the `KafkaRebalance` custom resource.

Hard goals include settings that must be met by an optimization proposal and cannot be ignored. Other goals in the `KafkaRebalance` custom resource are optimized only if possible.

To create a `KafkaRebalance` custom resource for your {{site.data.reuse.short_name}} instance, add the `eventstreams.ibm.com/cluster=<instance-name>` label to `metadata.labels` in your `KafkaRebalance` custom resource as follows, where `<instance-name>` is the name of your {{site.data.reuse.short_name}} cluster.

```
# ...
metadata:
  # ...
  labels:
    eventstreams.ibm.com/cluster: <instance-name>
spec:
  # ...
  goals:
    - NetworkInboundCapacityGoal
    - NetworkOutboundCapacityGoal
  skipHardGoalCheck: true
```

To add a list of goals to your `KafkaRebalance` custom resource, add the subset of [defined goals](#optimization-goals) to the `spec.goals` property. The previous example has the `NetworkInboundCapacityGoal` and `NetworkOutboundCapacityGoal` goals added.

To configure a `KafkaRebalance` custom resource, use the {{site.data.reuse.openshift_short}} web console or the {{site.data.reuse.openshift_short}} CLI as follows.


#### Using the {{site.data.reuse.openshift_short}} web console

1. {{site.data.reuse.openshift_ui_login}}
2. From the navigation menu, click **Operators > Installed Operators**.
3. In the **Projects** dropdown list, select the project that contains the {{site.data.reuse.long_name}} instance.
4. Select the **{{site.data.reuse.long_name}} Operator** in the list of Installed Operators.
5. In the **Operator Details > Overview** page, find the **KafkaRebalance** tile in the list of **Provided APIs** and click **Create Instance**.
6. In the **Create KafkaRebalance** page, edit the provided YAML to set values for the following properties.
   - In the **metadata.labels** section, set the **eventstreams.ibm.com/cluster** property value to the name of your {{site.data.reuse.long_name}} instance that you want to rebalance.
   - Set the `metadata.name` property value to what you want to call the `KafkaRebalance` custom resource.
   - Set the `spec.goals` to provide a list of goals you want to optimize.
   - Set the `spec.skipHardGoalCheck` to provide true if you want to skip the hard goals.

   See the previous YAML snippet as an example.
7. Click **Create**.
8. The new `KafkaRebalance` custom resource is listed in the **Operator Details > KafkaRebalance** page.

#### Using the {{site.data.reuse.openshift_short}} CLI

1. {{site.data.reuse.openshift_cli_login}}
2. Run the following command to select the project that contains the existing {{site.data.reuse.short_name}} cluster:\\
   `oc project <project-name>`
3. Define a `KafkaRebalance` custom resource in a file. For example, the following YAML defines a `KafkaRebalance` custom resource that will rebalance the Kafka cluster associated with the {{site.data.reuse.long_name}} instance named `my-cluster` and will create a proposal to satisfy the `NetworkInboundCapacityGoal` goal.


   ```
   apiVersion: eventstreams.ibm.com/v1alpha1
   kind: KafkaRebalance
   metadata:
     labels:
       eventstreams.ibm.com/cluster: my-cluster
     name: my-test-kafka-rebalance
   spec:
     goals:
       - NetworkInboundCapacityGoal
   ```

   **Note:** The `KafkaRebalance` must have a label under `metadata.labels` with the key `eventstreams.ibm.com/cluster`, and the value must be set to the name of the {{site.data.reuse.long_name}} instance that you are rebalancing.



4. Run the following command to create the `KafkaRebalance` custom resource:\\
   `oc create -f <path-to-your-KafkaRebalance-file>`
5. Verify the `KafkaRebalance` custom resource has been created by running:\\
   `oc get kafkarebalances`\\
   Ensure the `KafkaRebalance` custom resource you are trying to create is listed.
6. To view the `KafkaRebalance` proposal by running:\\
   `oc get KafkaRebalance <KafkaRebalance-instance-name> -o yaml`

### Receiving an optimization proposal

After you have created the `KafkaRebalance` custom resource, Cruise Control creates an optimization proposal if it can, and will add the `ProposalReady` status to the `status.conditions` property and display an overview of the proposal in the `status.optimizationResult` field.

The following is an example of a successful proposal:

```
# ...
status:
  # ...
  conditions:
    - lastTransitionTime: '2020-07-07T08:36:09.193Z'
      status: ProposalReady
      type: State
  observedGeneration: 5
  optimizationResult:
    intraBrokerDataToMoveMB: 0
    onDemandBalancednessScoreBefore: 0
    recentWindows: 1
    dataToMoveMB: 3
    excludedTopics: []
    excludedBrokersForReplicaMove: []
    numReplicaMovements: 7
    onDemandBalancednessScoreAfter: 100
    numLeaderMovements: 0
    monitoredPartitionsPercentage: 100
    numIntraBrokerReplicaMovements: 0
    excludedBrokersForLeadership: []
  sessionId: 03974f67-b208-4133-9f54-305d268a1a22
```

For more information about optimization proposals, see the Strimzi [documentation](https://strimzi.io/docs/operators/master/full/using.html#con-optimization-proposals-str){:target="_blank"}.

### Refreshing an optimization proposal

A `KafkaRebalance` custom resource does not automatically refresh the optimization proposal, it requires a manual refresh to be triggered. This is to ensure that a proposal does not change without your permission, and also to ensure the proposal does not change before it is approved.

To refresh the optimization proposal, you will need to add `eventstreams.ibm.com/rebalance: refresh` to the `KafkaRebalance` custom resource as described in [adding an annotation](#adding-annotations-to-a-kafkarebalance-custom-resource).

If a valid optimization exists for the configuration and the goals specified, then the `KafkaRebalance` custom resource will get updated, and `status.optimizationResult` shows the updated proposal.

### Approving an optimization proposal

Cruise Control is used for generating and implementing Kafka rebalance proposals. The `KafkaRebalance` custom resource is the way a user interacts with Cruise Control via the operator. The operator has automated the process of generating a proposal request, but to approve the proposal a user needs to annotate their `KafkaRebalance` custom resource.

If the `KafkaRebalance` custom resource contains a rebalance proposal that you want to accept, then you will need to approve the proposal by adding the `eventstreams.ibm.com/rebalance: approve` annotation to your `KafkaRebalance` custom resource by [adding an annotation](#adding-annotations-to-a-kafkarebalance-custom-resource)

When approved, the `KafkaRebalance` custom resource is updated to show the status `Rebalancing` in `status.conditions`. This means that Cruise Control is currently rebalancing the Kafka cluster. The amount of time required for a rebalance depends on various factors such as the amount of data on a partition and the goals being accomplished. If the rebalance is successful, then the `KafkaRebalance` custom resource will have the status updated to `Ready` in the `status.conditions` field.

#### Dealing with rebalancing errors

If Cruise Control is unsuccessful in rebalancing the Kafka brokers, then the `KafkaRebalance` custom resource will be updated to show the `NotReady` status in the `status.conditions` field, and `status.conditions` will contain the error and how to remediate. After you have followed the guidance to fix the error, trigger a [KafkaRebalance refresh](#refreshing-an-optimization-proposal) and then [approve the KafkaRebalance proposal](#approving-an-optimization-proposal).

### Stopping an inflight optimization proposal

If you want to stop the process of rebalancing a Kafka cluster, you can add the `eventstreams.ibm.com/rebalance: stop` annotation by [adding an annotation](#adding-annotations-to-a-kafkarebalance-custom-resource).

**Note:** Cruise Control will not restore the state of the topics and partitions that existed before rebalancing. This means the state of the Kafka brokers might not be the same as before rebalancing started.

### Adding annotations to a `KafkaRebalance` custom resource

To add annotations to the `KafkaRebalance` custom resource, use the {{site.data.reuse.openshift_short}} web console or the {{site.data.reuse.openshift_short}} CLI as follows.

#### Using the {{site.data.reuse.openshift_short}} web console

1. {{site.data.reuse.openshift_ui_login}}
2. The new `KafkaRebalance` custom resource is listed in the **Operator Details > KafkaRebalance** page.
3. Click the name of the `KafkaRebalance` custom resource you want to edit.
4. Click the **YAML** tab.
5. Add the `eventstreams.ibm.com/rebalance` annotation to the `metadata.annotations` field.
```
# ...
metadata:
  # ...
  annotations:
    eventstreams.ibm.com/rebalance: <annotation-value>
```
6. Click **Save**.

#### Using the {{site.data.reuse.openshift_short}} CLI

1. {{site.data.reuse.openshift_cli_login}}
2. Run the following command to select the project that contains the existing `KafkaRebalance` custom resource:\\
   `oc project <project-name>`
3. Run the following command to see a list of all the `KafkaRebalance` custom resources:\\
   `oc get kafkarebalances`
4. Find the name of the `KafkaRebalance` custom resource you want to annotate.
5. Run the following command to view the YAML for your `KafkaRebalance` instance:\\
   `oc annotate kafkarebalances <rebalance-cr-name> <annotation-key>=<annotation-value>`

## Optimization goals

Optimization goals determine what the `KafkaRebalance` proposal chooses to optimize when rebalancing the Kafka cluster.

**Note:** The more goals you use, the harder it will be for Cruise Control to create an optimization proposal that will satisfy all of the goals. Consider creating a `KafkaRebalance` custom resource with fewer goals.

**Important:** Most goals might result in the moving of partitions across brokers. This might impact performance during the operation, and cause issues with connecting clients.

You can configure the following optimization goals. the goals are listed in **order of decreasing priority**.

### RackAwareGoal

Ensures that all replicas of each partition are assigned in a rack-aware manner. This means no more than one replica of each partition resides on the same rack.

Using it in a multi-zone environment ensures that partitions are spread across different zones. This will improve the availability of topic data.

### ReplicaCapacityGoal

Ensures that the maximum number of replicas per broker is under the specified maximum limit.

This goal does not ensure that the replicas are evenly distributed across brokers. It ensures that the total replicas on a single broker remains under a specified maximum limit.

For even distribution of replicas amongst brokers, see [ReplicaDistributionGoal](#replicadistributiongoal).

### DiskCapacityGoal

Ensures that disk space usage of each broker is below the threshold set in the `spec.strimziOverrides.cruiseControl.brokerCapacity.disk` property in the `EventStreams` custom resource.

Use this goal to optimize the distribution of partitions amongst brokers based on the disk usage of a partition. This might not lead to an even distribution of partitions amongst the brokers. For even distribution of disk space usage on brokers, see [DiskUsageDistributionGoal](#diskusagedistributiongoal).

### NetworkInboundCapacityGoal

Ensures that inbound network utilization of each broker is below the threshold set in the `spec.strimziOverrides.cruiseControl.brokerCapacity.inboundNetwork` property in the `EventStreams` custom resource.

This is mainly affected by the number of producers producing and the size of produced messages. Use this goal to rebalance the partitions to optimize the distribution of the partitions on the inbound network traffic. This might not result in the inbound network being evenly distributed amongst brokers, it only ensures that the inbound network of each broker is under a given threshold. For even distribution of inbound network traffic amongst brokers, see [NetworkInboundDistributionUsageGoal](#networkinboundusagedistributiongoal)

### NetworkOutboundCapacityGoal

Ensures that outbound network utilization of each broker is below a given threshold set in the `spec.strimziOverrides.cruiseControl.brokerCapacity.inboundNetwork` property in the `EventStreams` custom resource.

This is mainly affected by the number of consumers consuming and communication between the Kafka Brokers. Use this goal to rebalance the partitions to optimize the distribution of the partitions on the outbound network traffic. This might not result in the outbound network being evenly distributed amongst brokers, it only ensures that the outbound network of each broker is under a given threshold. For even distribution of outbound network traffic amongst brokers, see [NetworkOutboundDistributionUsageGoal](#networkoutboundusagedistributiongoal).

### ReplicaDistributionGoal

Attempts to make all the brokers in a cluster have a similar number of replicas.

Use this goal to ensure that the total number of partition replicas are distributed evenly amongst brokers. This does not mean that partitions will be optimally distributed for other metrics such as network traffic and disk usage, so it might still cause brokers to be unevenly loaded.

### PotentialNwOutGoal

Ensures that the potential network output (when all the replicas in the broker become leaders) on each of the broker do not exceed the broker’s network outbound bandwidth capacity.

This is mainly affected by the number of consumers consuming and the size of the consumed messages. Use this goal to rebalance the partitions to optimize the distribution of the partitions on the potential outbound network traffic. This will ensure that the partitions with the most outbound traffic are moved to the most idle brokers.

The difference between this goal and [NetworkOutboundCapacityGoal](#networkoutboundcapacitygoal) is that this goal will rebalance the cluster based on the worst-case network outbound usage around the outbound network capacity specified, and the `NetworkOutboundCapacityGoal` will rebalance the outbound network usage around the outbound network capacity specified.

### DiskUsageDistributionGoal

Attempts to keep the disk space usage variance among brokers within a certain range relative to the average disk utilization.

Use this goal to optimize the distribution of partitions amongst brokers to ensure that the disk utilization amongst brokers are similar.

### NetworkInboundUsageDistributionGoal

Attempts to keep the inbound network utilization variance among brokers within a certain range relative to the average inbound network utilization.

This is mainly affected by the number of producers producing and the size of produced messages. Use this goal to rebalance the partitions to optimize the distribution of the partitions on the inbound network traffic. This will ensure that the partitions with the most inbound traffic are moved to the most idle brokers and the inbound network traffic amongst brokers are similar.

### NetworkOutboundUsageDistributionGoal

Attempts to keep the outbound network utilization variance among brokers within a certain range relative to the average outbound network utilization.

This is mainly affected by the number of consumers consuming and the size of the consumed messages. Use this goal to rebalance the partitions to optimize the distribution of the partitions on the outbound network traffic. This will ensure that the partitions with the most outbound traffic are moved to the most idle brokers and the outbound network traffic amongst brokers are similar.

### CpuUsageDistributionGoal

Attempts to keep the CPU usage variance among brokers within a certain range relative to the average CPU utilization.

Use this goal to rebalance the partitions to optimize the distribution of the partitions on the CPU usage of brokers. This will ensure that the CPU usage of brokers are similar.

### LeaderReplicaDistributionGoal

Attempts to make all the brokers in a cluster have a similar number of leader replicas.

Use this goal to ensure the total number of partitions leaders are similar amongst brokers.

### LeaderBytesInDistributionGoal

Attempts to equalize the leader bytes in rate on each host.

This goal may not result in an even distribution of replicas across brokers as it is optimizing the leader bytes on each broker.

### TopicReplicaDistributionGoal

Attempts to maintain an even distribution of any topic's partitions across the entire cluster.

Use this goal to ensure that the total number of partition replicas are distributed evenly amongst brokers. This does not mean that partitions will be optimally distributed for other metrics such as network traffic and disk usage, so might cause brokers to be unevenly loaded. This might also cause a partition on a topic to be present on a subset of the total brokers.

### PreferredLeaderElectionGoal

Simply moves the leaders to the first replica of each partition.

Cruise Control does not try to optimize the distribution of replicas. Before using this goal, check the state of the partitions to see where the leaders will end up to ensure the required outcome.

### IntraBrokerDiskCapacityGoal

Ensures that disk space usage of each disk is below a given threshold.

Use this goal to rebalance the distribution of the partitions on disk space usage under a given threshold. This may not result in the disk space usage being evenly distributed amongst brokers, it only ensures that the disk space usage of each broker is under a given threshold.

For even distribution of disk space usage amongst brokers, see [IntraBrokerDiskUsageDistributionGoal](#intrabrokerdiskusagedistributiongoal).

### IntraBrokerDiskUsageDistributionGoal

Attempts to keep the disk space usage variance among disks within a certain range relative to the average broker disk utilization.

Use this goal to rebalance the distribution of the partitions on disk space usage. This goal will ensure that the disk space usage amongst brokers are similar.
