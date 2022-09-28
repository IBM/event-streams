---
title: "Scaling"
excerpt: "Modify the capacity of your system by scaling it."
categories: administering
slug: scaling
toc: true
---

You can modify the capacity of your {{site.data.reuse.long_name}} system in a number of ways. See the following sections for details about the different methods, and their impact on your installation.

The [pre-requisite](../../installing/prerequisites/) guidance gives various examples of different production configurations on which you can base your deployment. To verify it meets your requirements, you should test the system with a workload that is representative of the expected throughput. For this purpose, {{site.data.reuse.long_name}} provides a [workload generator application](../../getting-started/testing-loads/) to test different message loads.

If this testing shows that your system does not have the capacity needed for the workload, whether this results in excessive lag or delays, or more extreme errors such as `OutOfMemory` errors, then you can incrementally make the increases detailed in the following sections, re-testing after each change to identify a configuration that meets your specific requirements.

A [performance report](../../pdfs/Performance Report 2019.4.1 v1.0.pdf){:target="_blank"} based on example case studies is also available to provide guidance for setting these values.

**Note:** Although the testing for the report was based on Apache Kafka version 2.3.0, the performance numbers are broadly applicable to current versions of Kafka as well.

## Modifying the settings

These settings are defined in the `EventStreams` custom resource under the `spec.strimziOverrides` property. For more information on modifying these settings see [modifying installation](../modifying-installation).

## Increase the number of Kafka brokers in the cluster

The number of Kafka brokers is defined in the `EventStreams` custom resource in the `spec.strimziOverrides.kafka.replicas` property. For example to configure {{site.data.reuse.short_name}} to use 6 Kafka brokers:

```
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      # ...
      replicas: 6
```


## Increase the CPU request or limit settings for the Kafka brokers

The CPU settings for the Kafka brokers are defined in the `EventStreams` custom resource in the `requests` and `limits` properties under `spec.strimziOverrides.kafka.resources`. For example to configure {{site.data.reuse.short_name}} Kafka brokers to have a CPU request set to 2 CPUs and limit set to 4 CPUs:

```
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      # ...
      resources:
        requests:
          cpu: 2000m
        limits:
          cpu: 4000m
```

A description of the syntax for these values can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu){:target="_blank"}.


## Increase the memory request or limit settings for the Kafka brokers and ZooKeeper nodes

The memory settings for the Kafka brokers are defined in the `EventStreams` custom resource in the `requests` and `limits` properties under `spec.strimziOverrides.kafka.resources`.

The memory settings for the ZooKeeper nodes are defined in the `EventStreams` custom resource in the `requests` and `limits` properties under `spec.strimziOverrides.zookeeper.resources`.

For example to configure {{site.data.reuse.short_name}} Kafka brokers and ZooKeeper nodes to have a memory request set to `4GB` and limit set to `8GB`:

```
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      # ...
      resources:
        requests:
          memory: 4096Mi
        limits:
          memory: 8096Mi
    zookeeper:
      # ...
      resources:
        requests:
          memory: 4096Mi
        limits:
          memory: 8096Mi
```
The syntax for these values can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory){:target="_blank"}.



## Modifying the resources available to supporting components

The resource settings for each supporting component are defined in the `EventStreams` custom resource in their corresponding component key the `requests` and `limits` properties under `spec.<component>.resources`.
For example, to configure the Apicurio Registry to have a memory request set to `4GB` and limit set to `8GB`:

```
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  # ...
  apicurioRegistry:
    # ...
    resources:
      requests:
        memory: 4096Mi
      limits:
        memory: 8096Mi
```

The syntax for these values can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory){:target="_blank"}.


## Modifying the JVM settings for Kafka brokers

If you have specific requirements, you can modify the JVM settings for the Kafka brokers.

**Note:** Take care when modifying these settings as changes can have an impact on the functioning of the product.

**Note:** Only a [selected subset](https://strimzi.io/docs/operators/0.30.0/configuring.html#con-common-configuration-jvm-reference){:target="_blank"} of the available JVM options can be configured.

JVM settings for the Kafka brokers are defined in the `EventStreams` custom resource in the `spec.strimziOverrides.kafka.jvmOptions` propety. For example:

```
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      # ...
      jvmOptions:
        -Xms: 4096m
        -Xmx: 4096m
```


## Increase the disk space available to each Kafka broker

The Kafka brokers need sufficient storage to meet the retention requirements for all of the topics in the cluster. Disk space requirements grow with longer retention periods for messages, increased message sizes and additional topic partitions.

The amount of storage made available to Kafka brokers is defined at the time of installation in the `EventStreams` custom resource in the `spec.strimziOverrides.kafka.storage.size` property. For example:

```
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      # ...
      storage:
        # ...
        size: 100Gi
```
