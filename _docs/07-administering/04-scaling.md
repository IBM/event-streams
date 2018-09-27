---
title: "Scaling"
permalink: /administering/scaling/
excerpt: "Scaling"
last_modified_at: 
toc: true
---

You can modify the capacity of your {{site.data.reuse.long_name}} system in a number of ways. See the following sections for details about the different methods, and their impact on your installation.

You can start with the [default installation parameters](../../installing/installing/) when deploying {{site.data.reuse.long_name}}, and test the system with a workload that is representative of your requirements. For this purpose, {{site.data.reuse.long_name}} provides a [workload generator application](../../getting-started/testing-loads/) to test message loads.

If this testing shows that your system does not have the capacity needed for the workload, whether this results in excessive lag or delays, or more extreme errors such as `OutOfMemory` errors, then you can incrementally make the increases detailed in the following sections, re-testing after each change to identify a configuration that meets your specific requirements.

## Increase the number of Kafka brokers in the cluster

To set this at the time of installation, you can use the `--set kafka.brokers=<NUMBER>` option in your `helm install` command if using the CLI, or enter the number in the **Kafka brokers** field of the **Configure** page if using the UI.

To modify the number of Kafka brokers for an existing {{site.data.reuse.long_name}} installation, use the following command:

`helm upgrade --reuse-values --set kafka.brokers=<NUMBER> <release_name> ibm-eventstreams-prod --tls`

## Increase the CPU limit available to each Kafka broker

To set this at the time of installation, you can use the `--set kafka.resources.limits.cpu=<LIMIT> --set kafka.resources.requests.cpu=<LIMIT>` options in your `helm install` command if using the CLI, or enter the values in the **CPU request for Kafka brokers** and **CPU limit for Kafka brokers** fields of the **Configure** page if using the UI.

To modify this for an existing {{site.data.reuse.long_name}} installation, use the following command:

`helm upgrade --reuse-values --set kafka.resources.limits.cpu=<LIMIT> --set kafka.resources.requests.cpu=<LIMIT> <release_name> ibm-eventstreams-prod --tls`

A description of the syntax for these values can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

## Increase the amount of memory available to each Kafka broker

To set this at the time of installation, you can use the `--set kafka.resources.limits.memory=<LIMIT> --set kafka.resources.requests.memory=<LIMIT> --set kafka.jvmHeapSize=<HEAPSIZE>` options in your `helm install` command if using the CLI, or enter the values into the **Memory request for Kafka brokers**, **Memory limit for Kafka brokers**, and **Heap size for Kafka broker JVM** fields of the **Configure** page if using the UI.

The first two `LIMIT` values apply to the containers that the Kafka brokers run in. The third `HEAPSIZE` value is used by the JVM running the Kafka broker. Set this to be less than the memory available to the container overall. Ensure you set the heap size to approximately 75% of the memory limit for the containers.

**Note:** The syntax for these values is different.
The syntax for the container memory limits can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory).
The heap size can be specified in megabytes (m) or gigabytes (g). For example: `2g` sets a maximum heap size of 2GB.

To modify this for an existing {{site.data.reuse.long_name}} installation, use the following command:

`helm upgrade --reuse-values --set kafka.resources.limits.memory=<LIMIT> --set kafka.resources.requests.memory=<LIMIT> --set kafka.jvmHeapSize=<HEAPSIZE> <release_name> ibm-eventstreams-prod --tls`

## Increase the memory available to supporting systems

If you have significantly increased the memory available to Kafka brokers, you will likely need to make a similar increase in the memory available to the other components that support the Kafka brokers.

Ensure you consider the following two components.

The **metrics reporter** component captures the monitoring statistics for cluster, broker, and topic activity. The memory requirements for this component will increase with the number of topic partitions in the cluster, and the throughput on those topics.

To set this at the time of installation, you can use the following options:\\
`--set kafka.metricsReporterResources.limits.memory=<LIMIT>`\\
`--set kafka.metricsReporterResources.requests.memory=<LIMIT>`\\
`--set kafka.metricsReporterJvmHeapSize=<HEAPSIZE>`

The first two `LIMIT` values apply to the containers that the metrics reporters run in. The third `HEAPSIZE` value is used by the JVM running the metrics reporter. Set this to be less than the memory available to the container overall. Ensure you set the heap size to approximately 75% of the memory limit for the containers.

**Note:** The syntax for these values is different.
The syntax for the container memory limits can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory).

The heap size can be specified in megabytes (m) or gigabytes (g). For example: `2g` sets a maximum heap size of 2GB.

The **message indexer** indexes the messages on topics to allow them to be searched in the {{site.data.reuse.long_name}} UI. The memory requirements for this component will increase with the cluster message throughput.

To set this at the time of installation, you can use the `--set messageIndexing.resources.limits.memory=<LIMIT>` option in your `helm install` command if using the CLI, or enter the values into the **Memory limits for Index Manager nodes** fields of the **Configure** page if using the UI.

The syntax for the container memory limits can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory).

To modify this for an existing {{site.data.reuse.long_name}} installation, use the following command:

`helm upgrade --reuse-values  --set kafka.metricsReporterResources.limits.memory=<LIMIT> --set kafka.metricsReporterResources.requests.memory=<LIMIT> --set kafka.metricsReporterJvmHeapSize=<HEAPSIZE>  --set messageIndexing.resources.limits.memory=<LIMIT>  <release_name> ibm-eventstreams-prod --tls`


## Custom JVM tuning for Kafka brokers


If you have specific requirements, you might need to further tune the JVMs running the Kafka brokers, such as modifying the garbage collection policies.

**Note:** Take care when modifying these settings as changes can have an impact on the functioning of the product.

To provide custom JVM parameters at the time of installation, you can use `--set kafka.heapOpts=<JVMOPTIONS>` option in your `helm install` command.

To modify this for an existing {{site.data.reuse.long_name}} installation, use the following command:

`helm upgrade --reuse-values --set kafka.heapOpts=<JVMOPTIONS> <release_name> ibm-eventstreams-prod --tls`

## Use a faster storage class for PVCs used by Kafka brokers

The speed of the storage available to Kafka brokers will impact performance.

Set this at the time of installation with the `--set kafka.persistence.dataPVC.storageClassName=<STORAGE_CLASS>` option in your `helm install` command if using the CLI, or by entering the desired storage class into the **Storage class name** field of the **Kafka persistent storage settings** section of the **Configure** page if using the UI.


For more information about available storage classes, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/create_storage_class.html).

## Increase the disk space available to each Kafka broker

The Kafka brokers will require sufficient storage to meet the retention requirements for all of the topics in the cluster. Disk space requirements grow with longer retention periods or sizes, and more topic partitions.

Set this at the time of installation with the `--set kafka.persistence.dataPVC.size=<SIZE>` option in your `helm install` command if using the CLI, or by entering the desired persistence size into the **Size** field of the **Kafka persistent storage settings** section of the **Configure** page if using the UI.
