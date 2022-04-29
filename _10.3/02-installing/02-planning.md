---
title: "Planning your installation"
excerpt: "Planning your installation of Event Streams."
categories: installing
slug: planning
toc: true
---

Consider the following when planning your installation of {{site.data.reuse.short_name}}.

Decide the purpose of your deployment, for example, whether you want to try a starter deployment for testing purposes, or start setting up a production deployment.

- Use the [sample deployments](#sample-deployments) as a starting point if you need something to base your deployment on.
- Size your planned deployment by considering potential throughput, the number of producers and consumers, Kafka performance tuning, and other aspects. For more details, see the [performance considerations](../capacity-planning) section.
- For production use, and whenever you want your data to be saved in the event of a restart, set up [persistent storage](#planning-for-persistent-storage).
- Consider the options for [securing](#planning-for-security) your deployment.
- Plan for [resilience](#planning-for-resilience) by understanding Kafka high availability and how to support it, set up multiple availability zones for added resilience, and consider geo-replication to help with your disaster recovery planning.
- Consider setting up [logging](#planning-for-log-management) for your deployment to help troubleshoot any potential issues.

## Sample deployments

A number of sample configurations are provided when [installing](../installing) {{site.data.reuse.short_name}} on which you can base your deployment. These range from smaller deployments for non-production development or general experimentation to large scale clusters ready to handle a production workload.

 - [Development deployments](#development-deployments)
 - [Production deployments](#production-deployments)

The sample configurations are available in the {{site.data.reuse.openshift_short}} web console as explained in [installing](../installing/#installing-an-instance-by-using-the-web-console), or on [GitHub](http://ibm.biz/es-cr-samples){:target="_blank"}, from where you can download and extract the resources for your {{site.data.reuse.short_name}} version, then go to `/cr-examples/eventstreams` to access the samples.

### Development deployments

If you want to try {{site.data.reuse.short_name}}, use one of the development samples when configuring your instance. Installing with these settings is suitable for a starter deployment intended for testing purposes and trying out {{site.data.reuse.short_name}}. It is not suitable for production environments. For samples appropriate for production use, see [production deployments](#production-deployments)

The following development samples are available:
- [Lightweight without security](#example-deployment-lightweight-without-security)
- [Development](#example-deployment-development)

#### Example deployment: **Lightweight without security**

Overview: A non-production deployment suitable for basic development, and test activities. For environments where minimum resource requirements, persistent storage, access control and encryption are not required.

**Note:** By default, this sample does not request the following [{{site.data.reuse.icpfs}}](../prerequisites/#operator-requirements), reducing the required minimum resources:
- IAM
- Monitoring Exporters
- Monitoring Grafana
- Monitoring Prometheus Ext



This example provides a starter deployment that can be used if you simply want to try {{site.data.reuse.short_name}} with a minimum resource footprint. It installs an {{site.data.reuse.short_name}} instance with the following characteristics:
- A small single broker Kafka cluster and a single node ZooKeeper.
- As there is only 1 broker, no message replication takes place between brokers, and the system topics (message offset and transaction state) are configured accordingly for this.
- There is no encryption internally between containers.
- External connections use TLS encryption, but no authentication to keep the configuration to a minimum, making it easy to experiment with the platform.

Resource requirements for this deployment:

| CPU request (cores) | CPU limit (cores) | Memory request (Gi) | Memory limit (Gi) | VPCs (see [licensing](#licensing))|
| ------------------- | ----------------- | ------------------- | ----------------- | ---- |
| 2.4                 | 8.2               | 5.4                 | 8.2               | 0.5  |

Ensure you have sufficient CPU capacity and physical memory in your environment to service at least the resource **request** values. The resource **limit** values constrain the amount of resource the {{site.data.reuse.short_name}} instance is able to consume.

{{site.data.reuse.sample_select_note}}

**Important:** This deployment is not suitable for a production system even if storage configuration is applied. This is due to the number of Kafka and ZooKeeper nodes not being appropriate for data persistence and high availability. For a production system, at least three Kafka brokers and ZooKeeper nodes are required for an instance, see [production](#production-deployments) sample deployments later for alternatives.

In addition, this deployment installs a single ZooKeeper node with ephemeral storage. If the ZooKeeper pod is restarted, either during normal operation or as part of an upgrade, all messages and all topics will be lost and both ZooKeeper and Kafka pods will move to an error state. To recover the cluster, restart the Kafka pod by deleting it.

#### Example deployment: **Development**

Overview: A non-production deployment for experimenting with {{site.data.reuse.short_name}} configured for high availability, authentication, and no persistent storage. Suitable for basic development and testing activities.

This example provides a starter deployment that can be used if you want to try {{site.data.reuse.short_name}} with a minimum resource footprint. It installs an {{site.data.reuse.short_name}} instance with the following settings:
- 3 Kafka brokers and 3 ZooKeeper nodes.
- Internally, TLS encryption is used between containers.
- External connections use TLS encryption and SCRAM SHA 512 authentication.

Resource requirements for this deployment:

| CPU request (cores) | CPU limit (cores) | Memory request (Gi) | Memory limit (Gi) | VPCs (see [licensing](#licensing))|
| ------------------- | ----------------- | ------------------- | ----------------- | ---- |
| 2.8                 | 12.2              | 5.9                 | 14.2              | 1.5  |

Ensure you have sufficient CPU capacity and physical memory in your environment to service at least the resource **request** values. The resource **limit** values constrain the amount of resource the {{site.data.reuse.short_name}} instance is able to consume.

{{site.data.reuse.sample_select_note}}

### Production deployments

To start setting up a production instance, use one of the following samples.

- [Minimal production](#example-deployment-minimal-production)
- [Production 3 brokers](#example-deployment-production-3-brokers)
- [Production 6 brokers](#example-deployment-production-6-brokers)
- [Production 9 brokers](#example-deployment-production-9-brokers)

**Important:** For a production setup, the sample configuration values are for guidance only, and you might need to change them. Ensure you set your resource values as required to cope with the intended usage, and also consider important configuration options for your environment and {{site.data.reuse.short_name}} requirements as described in the rest of this planning section.

#### Example deployment: **Minimal production**

Overview: A minimal production deployment for {{site.data.reuse.short_name}}.

This example provides the smallest possible production deployment that can be configured for {{site.data.reuse.short_name}}. It installs an {{site.data.reuse.short_name}} instance with the following settings:
- 3 Kafka brokers and 3 ZooKeeper nodes.
- Internally, TLS encryption is used between containers.
- External connections use TLS encryption and SCRAM SHA 512 authentication.
- Kafka tuning settings consistent with 3 brokers are applied as follows:

```
num.replica.fetchers: 3
num.io.threads: 24
num.network.threads: 9
log.cleaner.threads: 6
```

If a storage solution has been configured, the following characteristics make this a production-ready deployment:

- Messages are replicated between brokers to ensure that no single broker is a point of failure. If a broker restarts, producers and consumers of messages will not experience any loss of service.
- The number of threads made available for replicating messages between brokers, is increased to 3 from the default 1. This helps to prevent bottlenecks when replicating messages between brokers, which might otherwise prevent the Kafka brokers from being fully utilized.
- The number of threads made available for processing requests is increased to 24 from the default 8, and the number of threads made available for managing network traffic is increased to 9 from the default 3. This helps prevent bottlenecks for producers or consumers, which might otherwise prevent the Kafka brokers from being fully utilized.
- The number of threads made available for cleaning the Kafka log is increased to 6 from the default 1. This helps to ensure that records that have exceeded their retention period are removed from the log in a timely manner, and prevents them from accumulating in a heavily loaded system.

Resource requirements for this deployment:

| CPU request (cores) | CPU limit (cores) | Memory request (Gi) | Memory limit (Gi) | VPCs (see [licensing](#licensing))|
| ------------------- | ----------------- | ------------------- | ----------------- | ---- |
| 2.8                 | 12.2              | 5.9                 | 14.2              | 3.0  |

{{site.data.reuse.sample_select_note}}

{{site.data.reuse.prod_persistence_note}}

#### Example deployment: **Production 3 brokers**

Overview: A small production deployment for {{site.data.reuse.short_name}}.

This example installs a production-ready {{site.data.reuse.short_name}} instance similar to the [**Minimal production**](#example-deployment-minimal-production) setup, but with added resource requirements:
- 3 Kafka brokers and 3 ZooKeeper nodes.
- Internally, TLS encryption is used between containers.
- External connections use TLS encryption and SCRAM SHA 512 authentication.
- The memory and CPU requests and limits for the Kafka brokers are increased compared to the **Minimal production** sample described previously to give them the bandwidth to process a larger number of messages.

Resource requirements for this deployment:

| CPU request (cores) | CPU limit (cores) | Memory request (Gi) | Memory limit (Gi) | VPCs (see [licensing](#licensing))|
| ------------------- | ----------------- | ------------------- | ----------------- | ---- |
| 14.5                | 21.2              | 29.3                | 31.9              | 12.0 |

Ensure you have sufficient CPU capacity and physical memory in your environment to service at least the resource **request** values. The resource **limit** values constrain the amount of resource the {{site.data.reuse.short_name}} instance is able to consume.

{{site.data.reuse.sample_select_note}}

{{site.data.reuse.prod_persistence_note}}

#### Example deployment: **Production 6 brokers**

Overview: A medium sized production deployment for {{site.data.reuse.short_name}}.

This sample configuration is similar to the [**Production 3 brokers**](#example-deployment-production-3-brokers) sample described earlier, but with an increase in the following settings:
- Uses 6 brokers rather than 3 to allow for additional message capacity.
- The resource settings for the individual brokers are the same, but the number of threads made available for replicating messages between brokers is increased to 6 to cater for the additional brokers to manage.

Resource requirements for this deployment:

| CPU request (cores) | CPU limit (cores) | Memory request (Gi) | Memory limit (Gi) | VPCs (see [licensing](#licensing))|
| ------------------- | ----------------- | ------------------- | ----------------- | ---- |
| 26.5                | 33.2              | 53.0                | 55.6              | 24.0 |

Ensure you have sufficient CPU capacity and physical memory in your environment to service at least the resource **request** values. The resource **limit** values constrain the amount of resource the {{site.data.reuse.short_name}} instance is able to consume.

**Important:** This sample is not provided in the {{site.data.reuse.openshift_short}} web console and can only be obtained through [GitHub](http://ibm.biz/es-cr-samples){:target="_blank"} (download and extract the resources for your {{site.data.reuse.short_name}} version, then go to `/cr-examples/eventstreams` to access the samples).

{{site.data.reuse.sample_select_note}}

{{site.data.reuse.prod_persistence_note}}


#### Example deployment: **Production 9 brokers**

Overview: A large production deployment for {{site.data.reuse.short_name}}.

This sample configuration is similar to the [**Production 6 brokers**](#example-deployment-production-6-brokers) sample described earlier, but with an increase in the following settings:
- Uses 9 Brokers rather than 6 to allow for additional message capacity.
- The resource settings for the individual brokers are the same, but the number of threads made available for replicating messages between brokers is increased to 9 to cater for the additional brokers to manage.

Resource requirements for this deployment:

| CPU request (cores) | CPU limit (cores) | Memory request (Gi) | Memory limit (Gi) | VPCs (see [licensing](#licensing))|
| ------------------- | ----------------- | ------------------- | ----------------- | ---- |
| 38.5                | 45.2              | 76.7                | 79.3              | 36.0 |

Ensure you have sufficient CPU capacity and physical memory in your environment to service at least the resource **request** values. The resource **limit** values constrain the amount of resource the {{site.data.reuse.short_name}} instance is able to consume.

**Important:** This sample is not provided in the {{site.data.reuse.openshift_short}} web console and can only be obtained through [GitHub](http://ibm.biz/es-cr-samples){:target="_blank"} (download and extract the resources for your {{site.data.reuse.short_name}} version, then go to `/cr-examples/eventstreams` to access the samples).

{{site.data.reuse.sample_select_note}}

{{site.data.reuse.prod_persistence_note}}

## Planning for persistent storage

If you plan to have persistent volumes, [consider the disk space](../capacity-planning/#disk-space-for-persistent-volumes) required for storage.

Both Kafka and ZooKeeper rely on fast write access to disks. Use separate dedicated disks for storing Kafka and ZooKeeper data. For more information, see the disks and filesystems guidance in the [Kafka documentation](https://kafka.apache.org/documentation/#diskandfs){:target="_blank"}, and the deployment guidance in the [ZooKeeper documentation](https://zookeeper.apache.org/doc/r3.5.7/zookeeperAdmin.html#sc_designing){:target="_blank"}.

If persistence is enabled, each Kafka broker and ZooKeeper server requires one physical volume each. The number of Kafka brokers and ZooKeeper servers depends on your setup (for example, see the provided samples described in [resource requirements](../prerequisites/#resource-requirements)).

You either need to create a [persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#static){:target="_blank"} for each physical volume, or specify a storage class that supports [dynamic provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#dynamic){:target="_blank"}. Each component can use a different storage class to control how physical volumes are allocated.

See the {{site.data.reuse.openshift_short}} [documentation](https://docs.openshift.com/container-platform/4.6/storage/understanding-persistent-storage.html){:target="_blank"} for information about creating persistent volumes and creating a storage class that supports dynamic provisioning. For both, you must have the Cluster Administrator role.

- If these persistent volumes are to be created manually, this must be done by the system administrator before installing {{site.data.reuse.long_name}}. These will then be claimed from a central pool when the {{site.data.reuse.long_name}} instance is deployed. The installation will then claim the required number of persistent volumes from this pool.
- If these persistent volumes are to be created automatically, ensure a [dynamic provisioner](https://docs.openshift.com/container-platform/4.6/storage/dynamic-provisioning.html){:target="_blank"} is configured for the storage class you want to use. See [data storage requirements](../prerequisites/#data-storage-requirements) for information about storage systems supported by {{site.data.reuse.short_name}}.

**Important:** When creating persistent volumes for each component, ensure the correct **Access mode** is set for the volumes as described in the following table.

| Component       | Access mode                      |
| --------------- | -------------------------------- |
| Kafka           | `ReadWriteOnce`                  |
| ZooKeeper       | `ReadWriteOnce`                  |

To use persistent storage, [configure the storage properties](../configuring/#enabling-persistent-storage) in your `EventStreams` custom resource.

## Planning for security

{{site.data.reuse.short_name}} has highly configurable security options that range from the fully secured default configuration to no security for basic development and testing.

The main security vectors to consider are:

- Kafka listeners
- Pod-to-Pod communication
- UI access
- REST endpoints (REST Producer, Admin API, Apicurio Registry)

Secure instances of {{site.data.reuse.short_name}} will make use of TLS to protect network traffic. Certificates will be generated by default, or you can [use custom certificates](../configuring/#using-your-own-certificates).

**Note:** If you want to use custom certificates, ensure you configure them before installing {{site.data.reuse.short_name}}.

### {{site.data.reuse.short_name}} UI Access

As explained in the [Managing access](../../security/managing-access) section, the {{site.data.reuse.icpfs}} Identity and Access Management (IAM) is used to bind a role to an identity. By default, the secure {{site.data.reuse.short_name}} instance will require an `Administrator` or higher role to authorize access. To setup LDAP (Lightweight Directory Access Protocol), assign roles to LDAP users, and create teams, see the instructions about [configuring LDAP connections](https://www.ibm.com/support/knowledgecenter/SSHKN6/iam/3.x.x/configure_ldap.html){:target="_blank"}.

Whilst it is highly recommended to always configure {{site.data.reuse.short_name}} with security enabled, it is also possible to configure the {{site.data.reuse.short_name}} UI to not require a login, which can be useful for proof of concept (PoC) environments. For details, see [configuring {{site.data.reuse.short_name}} UI access](../configuring/#configuring-ui-security).

### REST endpoint security

Review the security and configuration settings of your development and test environments.
The REST endpoints of {{site.data.reuse.short_name}} have a number of configuration capabilities. See [configuring access](../configuring/#rest-services-access) for details.

### Securing communication between pods

By default, Pod-to-Pod encryption is enabled. You can [configure encryption between pods](../configuring/#configuring-encryption-between-pods) when configuring your {{site.data.reuse.short_name}} installation.

### Kafka listeners

{{site.data.reuse.short_name}} has both internal and external configurable Kafka listeners. Optionally, each Kafka listener can be [secured with TLS or SCRAM](../configuring/#kafka-access).

## Planning for resilience

If you are looking for a more resilient setup, or want plan for disaster recovery, consider setting up multiple availability zones and creating geo-replication clusters. Also, set up your environment to support Kafka's inherent high availability design.

### Kafka high availability

Kafka is designed for high availability and fault tolerance.

To reduce the impact of {{site.data.reuse.short_name}} Kafka broker failures, configure your installation with at least three brokers and spread them across several {{site.data.reuse.openshift}} [worker nodes](https://docs.openshift.com/container-platform/4.6/machine_management/adding-rhel-compute.html){:target="_blank"} by ensuring you have at least as many worker nodes as brokers. For example, for 3 Kafka brokers, ensure you have at least 3 worker nodes running on separate physical servers.

Kafka ensures that topic-partition replicas are spread across available brokers up to the replication factor specified. Usually, all of the replicas will be in-sync, meaning that they are all fully up-to-date, although some replicas can temporarily be out-of-sync, for example, when a broker has just been restarted.

The replication factor controls how many replicas there are, and the minimum in-sync configuration controls how many of the replicas need to be in-sync for applications to produce and consume messages with no loss of function. For example, a typical configuration has a replication factor of 3 and minimum in-sync replicas set to 2. This configuration can tolerate 1 out-of-sync replica, or 1 worker node or broker outage with no loss of function, and 2 out-of-sync replicas, or 2 worker node or broker outages with loss of function but no loss of data.

The combination of brokers spread across nodes together with the replication feature make a single {{site.data.reuse.short_name}} cluster highly available.

### Multiple availability zones

To add further resilience to your {{site.data.reuse.short_name}} cluster, you can split your servers across multiple data centers or zones, so that even if one zone experiences a failure, you still have a working system.

[Multizone support](https://kubernetes.io/docs/setup/best-practices/multiple-zones/){:target="_blank"} provides the option to run a single Kubernetes cluster in multiple availability zones within the same region. Multizone clusters are clusters of either physical or virtual servers that are spread over different locations to achieve greater resiliency. If one location is shut down for any reason, the rest of the cluster is unaffected.

**Note:** For {{site.data.reuse.short_name}} to work effectively within a multizone cluster, the network latency between zones must not be greater than 20 ms for Kafka to replicate data to the other brokers.

Typically, high availability requires a minimum of 3 zones (sites or data centers) to ensure a quorum with high availability for components, such as Kafka and ZooKeeper. Without the third zone, you might end up with a third quorum member in a zone that already has a member of the quorum, consequently if that zone goes down, the majority of the quorum is lost and loss of function is inevitable.

{{site.data.reuse.openshift_short}} requires a minimum of 3 zones for high availability topologies and {{site.data.reuse.short_name}} supports that model. This is different from the traditional primary and backup site configuration, and is a move to support the quorum-based application paradigm.

With [zone awareness](https://kubernetes.io/docs/setup/best-practices/multiple-zones/#pods-are-spread-across-zones), Kubernetes automatically distributes pods in a replication controller across different zones. For workload-critical components, for example Kafka, ZooKeeper and REST Producer, set the number of replicas of each component to at least match the number of zones. This provides at least one replica of each component in each zone, so in the event of loss of a zone the service will continue using the other working zones.

For information about how to prepare multiple zones, see [preparing for multizone clusters](../preparing-multizone).

<!-- **COMMENT:** _The terminology to use based on some research is: "multizone", "multiple availability zones", zone aware (n), zone-aware (adj), non-zone aware (n), and non-zone-aware (adj)._ -->

### Geo-replication

Consider configuring [geo-replication](../../georeplication/about/) to aid your disaster recovery and resilience planning.

You can deploy multiple instances of {{site.data.reuse.long_name}} and use the included geo-replication feature to synchronize data between your clusters. Geo-replication helps maintain service availability.

No additional preparation is needed on the origin cluster, {{site.data.reuse.long_name}} as geo-replication runs on the destination cluster.

[Prepare your destination cluster](../configuring/#setting-geo-replication-nodes) by setting the number of geo-replication worker nodes during installation.

Geo-replication is based on [MirrorMaker 2.0](https://strimzi.io/blog/2020/03/30/introducing-mirrormaker2/){:target="_blank"}, which uses Kafka Connect, enabling interoperability with other Kafka distributions.

Use geo-replication to replicate data between {{site.data.reuse.short_name}} clusters.  Use MirrorMaker2 to move data between Event Streams clusters and other Kafka clusters.

### Cruise Control

Cruise Control is an open-source system for optimizing your Kafka cluster by monitoring cluster workload, rebalancing a cluster based on predefined constraints, and detecting and fixing anomalies.
You can set up {{site.data.reuse.short_name}} to use the following Cruise Control features:

- Generating optimization proposals from multiple optimization goals.
- Rebalancing a Kafka cluster based on an optimization proposal.

**Note:** {{site.data.reuse.short_name}} does not support other Cruise Control features.

[Enable Cruise Control](../configuring/#enabling-and-configuring-cruise-control) for {{site.data.reuse.short_name}} and configure optimization goals for your cluster.

**Note:** Cruise Control stores data in Kafka topics. It does not have its own persistent storage configuration. Consider using persistent storage for your Kafka topics when using Cruise Control.

## Planning for log management

{{site.data.reuse.short_name}} uses the [cluster logging](https://docs.openshift.com/container-platform/4.6/logging/cluster-logging.html){:target="_blank"} provided by the {{site.data.reuse.openshift_short}} to collect, store, and visualize logs. The cluster logging components are based upon Elasticsearch, Fluentd, and Kibana (EFK).

You can use this EFK stack logging capability in your environment to help resolve problems with your deployment and aid general troubleshooting.

You can use log data to investigate any problems affecting your [system health](../../administering/deployment-health/).

## Kafka static configuration properties

You can set [Kafka broker configuration](https://strimzi.io/docs/operators/0.19.0/using.html#ref-kafka-broker-configuration-deployment-configuration-kafka){:target="_blank"} settings in your `EventStreams` custom resource under the property `spec.strimziOverrides.kafka`. These settings will override the default Kafka configuration defined by {{site.data.reuse.short_name}}.

You can also use this configuration property to modify read-only Kafka broker settings for an existing {{site.data.reuse.long_name}} installation. Read-only parameters are defined by Kafka as settings that require a broker restart. Find out more about the [Kafka configuration options and how to modify them](../../administering/modifying-installation/#modifying-kafka-broker-configuration-settings) for an existing installation.

## Connecting clients

By default, Kafka client applications connect to cluster using the Kafka bootstrap route address. Find out more about [connecting external clients](../configuring/#configuring-access) to your installation.

## Monitoring Kafka clusters

{{site.data.reuse.long_name}} uses the {{site.data.reuse.icpfs}} monitoring service to provide you with information about the health of your {{site.data.reuse.short_name}} Kafka clusters. You can view data for the last 1 hour, 1 day, 1 week, or 1 month in the metrics charts.

**Important:** By default, the metrics data used to provide monitoring information is only stored for a day. Modify the [time period](https://www.ibm.com/support/knowledgecenter/SSHKN6/monitoring/1.x.x/monitoring_service.html#promlogs){:target="_blank"} for metric retention to be able to view monitoring data for longer time periods, such as 1 week or 1 month.

For more information about keeping an eye on the health of your Kafka cluster, see the [monitoring Kafka](../../administering/cluster-health/) topic.

## Licensing

### Licensing considerations

Licensing is based on a Virtual Processing Cores (VPC) metric. To use {{site.data.reuse.short_name}} you must have a license for all of the virtual cores that are available to all of the following {{site.data.reuse.short_name}} components:
- Kafka brokers
- Geo-Replicator nodes
- MirrorMaker2 nodes
- Kafka Connect nodes hosted by {{site.data.reuse.short_name}}

All other container types are pre-requisite components that are supported as part of {{site.data.reuse.short_name}}, and do not require additional licenses.

If you are using one of the samples provided, see the [sample deployments section](#sample-deployments) for information about the number of VPCs required. The number of VPCs indicate the licenses required.

**Note:** For a production installation of {{site.data.reuse.short_name}}, the ratio is 1 license required for every 1 VPC being used. For a non-production installation of {{site.data.reuse.short_name}}, the ratio is 1 license required for every 2 VPCs being used.

To flag an installation of {{site.data.reuse.short_name}} as production or non-production, set the `spec.license.use` correctly during installation. See [license usage](#license-usage) for more information about selecting the correct value.

If you add more Kafka replicas, geo-replicator nodes, MirrorMaker2 nodes, or Kafka Connect nodes, each one is an additional, separate chargeable unit. See [license usage](#license-usage) to learn how you can find out more about the number of virtual cores used by your deployment.

### License usage

The license usage of {{site.data.reuse.long_name}} is collected by the {{site.data.reuse.icpfs}} License Service which is automatically deployed with {{site.data.reuse.long_name}}. This provides the service that tracks the licensed containers and their resource usage based on the product use.

When [creating an instance](../installing/#install-an-event-streams-instance) of {{site.data.reuse.short_name}}, ensure that you select the correct value for `spec.license.use` in the custom resource. This value is used for metering purposes and could result in inaccurate charging and auditing if set incorrectly. Select one of the following values based on the purpose of your deployment:

- **CloudPakForIntegrationNonProduction** for non-production deployments suitable for basic development and test activities.
- **CloudPakForIntegrationProduction** for production deployments.

The [sample deployments](#sample-deployments) provided by {{site.data.reuse.short_name}} have the correct value set by default based on the sample deployment purposes.

The license usage information can be viewed by [obtaining an API token](https://www.ibm.com/support/knowledgecenter/SSHKN6/license-service/1.x.x/token.html) that is required to make the API calls to retrieve license usage data, and then accessing provided [APIs](https://www.ibm.com/support/knowledgecenter/SSHKN6/license-service/1.x.x/APIs.html) for retrieving the license usage data.

There are 3 APIs that can be viewed:
1. **Snapshot (last 30 days)** This provides audit level information in a .zip file and is a superset of the other reports.
2. **Products report (last 30 days)** This shows the VPC usage for all products that are deployed in {{site.data.reuse.cp4i}}, for example:
```
[{"name":"{{site.data.reuse.cp4i}}","id":"c8b82d189e7545f0892db9ef2731b90d","metricPeakDate":"2020-06-10","metricQuantity":3,"metricName":"VIRTUAL_PROCESSOR_CORE"}]
```
In this example, the `metricQuantity` is 3 indicating that the peak VPC usage is 3.
3. **Bundled products report (last 30 days)** This shows the breakdown of bundled products that are included in IBM Cloud Paks that are deployed on a cluster with the highest VPC usage within the requested period. For {{site.data.reuse.short_name}} this shows the peak number of VPCs in use, the conversion ratio and the number of licenses used. For example:
```
[{"productName":"IBM Event Streams for Non Production","productId":"<product_id>","cloudpakId":"<cloudpak_id>","cloudpakVersion":"2020.2.1","metricName":"VIRTUAL_PROCESSOR_CORE","metricPeakDate":"2020-06-10","metricMeasuredQuantity":6,"metricConversion":"2:1","metricConvertedQuantity":3}]
```
In this example, the `productName` shows the license metrics for a `IBM Event Streams for Non Production` deployment. The `metricMeasuredQuantity` is 6 VPCs, the `metricConversion` is 2:1 and `metricConvertedQuantity` is 3 VPCs so the license usage is 3.

**Note:** The `metricMeasuredQuantity` is the peak number of VPCs used over the timeframe. If an {{site.data.reuse.short_name}} instance is deleted and a new instance installed, then the quantity will be the maximum used at any one time.

The following examples show the number of licenses required for specific installations:

### Example 1 - Non-production 3 brokers
This example is for an {{site.data.reuse.short_name}} installation configured with 3 Kafka brokers, no Mirror Maker or Kafka Connect containers. In this example installation, each Kafka container requires 2 VPCs so in total 6 VPCs are being used. For non-production deployment the metrics conversion ratio is 2:1, therefore 3 licenses are required.

### Example 2 - Production 3 brokers
This example is for an {{site.data.reuse.short_name}} installation configured with 3 Kafka brokers, no Mirror Maker or Kafka Connect containers. In this example installation, each Kafka container requires 4 VPCs so in total 12 VPCs are being used. For production deployment the metrics conversion ratio is 1:1, therefore 12 licenses are required.

### Example 3 - Production 6 brokers with Geo-Replication
This example is for an {{site.data.reuse.short_name}} installation configured with 6 Kafka brokers, 1 Mirror Maker container and no Kafka Connect containers. In this example installation, each Kafka container requires 4 VPCs and each Mirror Maker container requires 1 VPC, so in total 25 VPCs are being used. For production deployment the metrics conversion ratio is 1:1, therefore 25 licenses are required.

### Example 4 - Production 9 brokers with Geo-Replication and Kafka-Connect
This example is for an {{site.data.reuse.short_name}} installation configured with 9 Kafka brokers, 1 Mirror Maker and 1 Kafka Connect container. In this example installation, each Kafka container requires 4 VPCs, each Mirror Maker container requires 1 VPC and each Kafka-Connect container requires 1 VPC, so in total 38 VPCs are being used. For production deployment the metrics conversion ratio is 1:1, therefore 38 licenses are required.

If there are multiple production or non-production installations in a cluster then the API will show the total peak VPC usage for all production or non-production instances in that cluster. For example if you have 2 production instances of {{site.data.reuse.long_name}} where each instance has 3 Kafka brokers that each use 2 VPS, then the total peak usage is 12 VPCs which converts to 12 licenses.

If there are production and non-production {{site.data.reuse.long_name}} instances installed in the cluster, then the `metricConvertedQuantity` under `IBM Event Streams` and `IBM Event Streams for Non Production` will need to be added to determine the total license usage. For example:
```
[{"productName":"IBM Event Streams for Non Production","productId":"<product_id>","cloudpakId":"<cloudpak_id>","cloudpakVersion":"2020.2.1","metricName":"VIRTUAL_PROCESSOR_CORE","metricPeakDate":"2020-06-10","metricMeasuredQuantity":6,"metricConversion":"2:1","metricConvertedQuantity":3},{"productName":"IBM Event Streams","productId":"<product_id>","cloudpakId":"<cloudpak_id>","cloudpakVersion":"2020.2.1","metricName":"VIRTUAL_PROCESSOR_CORE","metricPeakDate":"2020-06-11","metricMeasuredQuantity":8,"metricConversion":"1:1","metricConvertedQuantity":8}]
```
In this example there are {{site.data.reuse.short_name}} installations for non-production and for production. The non-production usage is 6 VPCs which converts to 3 licenses. The production usage is 8 VPCs which converts to 8 licenses. Therefore the total license usage is 11.
