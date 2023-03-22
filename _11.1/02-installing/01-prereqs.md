---
title: "Prerequisites"
excerpt: "Prerequisites for installing IBM Event Streams."
categories: installing
slug: prerequisites
toc: true
---



Ensure your environment meets the following prerequisites before installing {{site.data.reuse.long_name}}.

## Container environment

{{site.data.reuse.long_name}} 11.1.x is supported on the {{site.data.reuse.openshift}}.
- Version 11.1.5 is installed by the {{site.data.reuse.short_name}} operator version 3.1.5, and includes Kafka version 3.4.0.
- Version 11.1.4 is installed by the {{site.data.reuse.short_name}} operator version 3.1.4, and includes Kafka version 3.3.1.
- Version 11.1.3 is installed by the {{site.data.reuse.short_name}} operator version 3.1.3, and includes Kafka version 3.2.3.
- Version 11.1.2 is installed by the {{site.data.reuse.short_name}} operator version 3.1.2, and includes Kafka version 3.2.3.
- Version 11.1.1 is installed by the {{site.data.reuse.short_name}} operator version 3.1.1, and includes Kafka version 3.2.3.
- Version 11.1.0 is installed by the {{site.data.reuse.short_name}} operator version 3.1.0, and includes Kafka version 3.2.3.

For an overview of supported component and platform versions, see the [support matrix]({{ 'support/#support-matrix' | relative_url }}).

Ensure you have the following set up for your environment:

- A supported version of {{site.data.reuse.openshift_short}} [installed](https://docs.openshift.com/container-platform/4.12/installing/index.html#installation-overview_ocp-installation-overview){:target="_blank"}. See the [support matrix]({{ 'support/#support-matrix' | relative_url }}) for supported versions.
- The {{site.data.reuse.openshift_short}} CLI [installed](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html){:target="_blank"}.
- The IBM Cloud Pak CLI (`cloudctl`) [installed](https://github.com/IBM/cloud-pak-cli/blob/master/README.md){:target="_blank"}.
- A supported version of the {{site.data.reuse.icpfs}} [installed](#ibm-cloud-pak-foundational-services){:target="_blank"}.

## Hardware requirements

Ensure your hardware can accommodate the [resource requirements](#resource-requirements) for your planned deployment.

Kubernetes manages the allocation of containers within your cluster. This allows resources to be available for other {{site.data.reuse.short_name}} components which might be required to reside on the same node.

For production systems, it is recommended to have {{site.data.reuse.short_name}} configured with at least 3 Kafka brokers, and to have one worker node for each Kafka broker. This requires a minimum of 3 worker nodes available for use by {{site.data.reuse.short_name}}. Ensure each worker node runs on a separate physical server. See the guidance about [Kafka high availability](../planning/#kafka-high-availability) for more information.

## {{site.data.reuse.icpfs}}

Ensure you have installed a supported version of {{site.data.reuse.icpfs}} before installing {{site.data.reuse.short_name}}, as described in the [foundational services documentation](https://www.ibm.com/docs/en/cpfs?topic=installer){:target="_blank"}. {{site.data.reuse.short_name}} supports {{site.data.reuse.fs}} version 3.19.0 or later 3.x releases.

{{site.data.reuse.short_name}} supports both the Continuous Delivery (CD) and the Long Term Service Release (LTSR) version of foundational services (for more information, see [release types](https://www.ibm.com/docs/en/cpfs?topic=about-release-types){:target="_blank"}). This provides more flexibility for compatibility with other Cloud Pak components (for more information, see [deploying with other Cloud Paks on the same cluster](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.4?topic=requirements-deploying-other-cloud-paks-same-cluster){:target="_blank"}.

<!---**Important:** Before installing {{site.data.reuse.icpfs}}, ensure you meet the [prerequisites](https://www.ibm.com/docs/en/cpfs?topic=operator-hardware-requirements-recommendations-foundational-services){:target="_blank"} for installing {{site.data.reuse.fs}}, and review the steps for [preparing to install](https://www.ibm.com/docs/en/cpfs?topic=operator-preparing-install-foundational-services){:target="_blank"}.--->

 By default, the `starterset` profile is requested for new installations. If you are preparing for a production deployment, ensure you set a more suitable profile, for example, the [medium profile](https://www.ibm.com/docs/en/cpfs?topic=services-hardware-requirements-medium-profile){:target="_blank"} as described in [setting the hardware profile](https://www.ibm.com/docs/en/cpfs?topic=319-installing-foundational-services-by-using-console#profile){:target="_blank"}.

**Note:** If you are installing {{site.data.reuse.short_name}} in an existing {{site.data.reuse.cp4i}} deployment, the required {{site.data.reuse.fs}} might already be installed due to other capabilities, and the dependencies required by {{site.data.reuse.short_name}} might already be satisfied with a profile other than the default `starterset`.

If you plan to install other {{site.data.reuse.cp4i}} capabilities, ensure you meet the resource requirements for the whole profile. If you only want to deploy  {{site.data.reuse.short_name}} on the cluster, you can calculate more granular sizing requirements based on the following {{site.data.reuse.fs}} components that {{site.data.reuse.short_name}} uses:
- Catalog UI
- Certificate Manager
- Common Web UI
- IAM
- Ingress NGINX
- Installer
- Management ingress
- Mongo DB
- Platform API

## Resource requirements

{{site.data.reuse.short_name}} resource requirements depend on several factors. The following sections provide guidance about minimum requirements for a starter deployment, and options for initial production configurations.

Installing {{site.data.reuse.short_name}} has two phases:

1. Install the {{site.data.reuse.short_name}} operator. The operator will then be available to install and manage your {{site.data.reuse.short_name}} instances.
2. Install one or more instances of {{site.data.reuse.short_name}} by applying configured custom resources. Sample configurations for development and production use cases are provided to get you started.

Minimum resource requirements are as follows, and are based on the total of requests set for the deployment. You will require more resources to accommodate the limit settings (see more about "requests" and "limits" later in this section).
Always ensure you have sufficient resources in your environment to deploy the {{site.data.reuse.short_name}} operator together with a development or a production {{site.data.reuse.short_name}} instance.

| Deployment                                          | CPU (cores) | Memory (Gi) | VPCs (see [licensing](../planning/#licensing)) |
| --------------------------------------------------- | ----------- | ----------- | ---- |
| [Operator](#operator-requirements)                  | 0.2         | 1.0         | N/A  |
| [Development](../planning/#sample-deployments) | 2.4         | 5.4         | 0.5  |
| [Production](../planning/#sample-deployments)   | 2.8         | 5.9         | 3.0  |

**Note:** {{site.data.reuse.short_name}} provides sample configurations to help you get started with deployments. The resource requirements for these specific samples are detailed in the [planning](../planning/#sample-deployments) section. If you do not have an {{site.data.reuse.short_name}} installation on your system yet, always ensure you include the resource requirements for the operator together with the intended {{site.data.reuse.short_name}} instance requirements (development or production).

**Important:** Licensing is based on the number of Virtual Processing Cores (VPCs) used by your {{site.data.reuse.short_name}} instance. See [licensing considerations](../planning/#licensing) for more information. For a production installation of {{site.data.reuse.short_name}}, the ratio is 1 license required for every 1 VPC being used. For a non-production installation of {{site.data.reuse.short_name}}, the ratio is 1 license required for every 2 VPCs being used.

{{site.data.reuse.short_name}} is a [Kubernetes operator-based](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/){:target="_blank"} release and uses custom resources to define your {{site.data.reuse.short_name}} configurations.
The {{site.data.reuse.short_name}} operator uses the declared required state of your {{site.data.reuse.short_name}} in the custom resources to deploy and manage the entire lifecycle of your {{site.data.reuse.short_name}} instances. Custom resources are presented as YAML configuration documents that define instances of the `EventStreams` custom resource type.

The provided samples define typical configuration settings for your {{site.data.reuse.short_name}} instance, including broker configurations, security settings, and default values for resources such as CPU and memory defined as "request" and "limit" settings. [Requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/){:target="_blank"} are Kubernetes concepts for controlling resource types such as CPU and memory.

- Requests set the minimum requirements a container requires to be scheduled. If your system does not have the required request value, then the services will not start up.
- Limits set the value beyond which a container cannot consume the resource. It is the upper limit within your system for the service. Containers that exceed a CPU resource limit are throttled, and containers that exceed a memory resource limit are terminated by the system.

Ensure you have sufficient CPU capacity and physical memory in your environment to service these requirements. Your {{site.data.reuse.short_name}} instance can be dynamically updated later through the configuration options provided in the custom resource.

### Operator requirements

The {{site.data.reuse.short_name}} operator requires the following minimum resource requirements. Ensure you always include sufficient CPU capacity and physical memory in your environment to service the operator requirements.

| CPU request (cores) | CPU limit (cores) | Memory request (Gi) | Memory limit (Gi) |
| ------------------- | ----------------- | ------------------- | ----------------- |
| 0.2                 | 1.0               | 1.0                 | 1.0               |


#### Cluster-scoped permissions required

The {{site.data.reuse.short_name}} operator requires the following cluster-scoped permissions:

- **Permission to list nodes in the cluster**: When the {{site.data.reuse.short_name}} operator is deploying a Kafka cluster that spans [multiple availability zones](../planning/#multiple-availability-zones), it needs to label the pods with zone information. The permission to list nodes in the cluster is required to retrieve the information for these labels.
- **Permission to manage admission webhooks**: The {{site.data.reuse.short_name}} operator uses admission webhooks to provide immediate validation and feedback about the creation and modification of {{site.data.reuse.short_name}} instances. The permission to manage webhooks is required for the operator to register these actions.
- **Permission to manage ConsoleYAMLSamples**: ConsoleYAMLSamples are used to provide samples for {{site.data.reuse.short_name}} resources in the {{site.data.reuse.openshift_short}} web console. The permission to manage ConsoleYAMLSamples is required for the operator to register the setting up of samples.
- **Permission to view ConfigMaps**: {{site.data.reuse.short_name}} uses authentication services from {{site.data.reuse.icpfs}}. The status of these services is maintained in ConfigMaps, so the permission to view the contents of the ConfigMaps allows {{site.data.reuse.short_name}} to monitor the availability of the {{site.data.reuse.fs}} dependencies.
- **Permission to list specific CustomResourceDefinitions**: This allows {{site.data.reuse.short_name}} to identify whether other optional dependencies have been installed into the cluster.
- **Permission to list ClusterRoles and ClusterRoleBindings**: The {{site.data.reuse.short_name}} operator uses ClusterRoles created by the Operator Lifecycle Manager (OLM) as parents for supporting resources that the {{site.data.reuse.short_name}} operator creates. This is needed so that the supporting resources are correctly cleaned up when {{site.data.reuse.short_name}} is uninstalled. The permission to list ClusterRoles is required to allow the operator to identify the appropriate cluster role to use for this purpose.

### Adding {{site.data.reuse.short_name}} geo-replication to a deployment

The {{site.data.reuse.short_name}} [geo-replicator](../../georeplication/about/) allows messages sent to a topic on one {{site.data.reuse.short_name}} cluster to be automatically replicated to another {{site.data.reuse.short_name}} cluster. This capability ensures messages are available on a separate system to form part of a disaster recovery plan.

To use this feature, ensure you have the following additional resources available. The following table shows the prerequisites for each geo-replicator node.

| CPU request (cores) | CPU limit (cores) | Memory request (Gi) | Memory limit (Gi) | VPCs (see [licensing](../planning/#licensing)) |
| ------------------- | ----------------- | ------------------- | ----------------- | ---- |
| 1.0                 | 2.0               | 2.0                 | 2.0               | 1.0  |

For instructions about installing geo-replication, see [configuring](../configuring/#setting-geo-replication-nodes).


## Red Hat OpenShift Security Context Constraints

{{site.data.reuse.short_name}} requires a [Security Context Constraint (SCC)](https://docs.openshift.com/container-platform/4.12/authentication/managing-security-context-constraints.html){:target="_blank"} to be bound to the target namespace prior to installation.

By default, {{site.data.reuse.short_name}} uses the default `restricted` SCC that comes with the {{site.data.reuse.openshift_short}}.

If you use a custom SCC (for example, one that is more restrictive), or have an operator that updates the default SCC, the changes might interfere with the functioning of your {{site.data.reuse.short_name}} deployment. To resolve any issues, apply the SCC provided by {{site.data.reuse.short_name}} as described in [troubleshooting](../../troubleshooting/default-scc-issues).

## Network requirements

{{site.data.reuse.long_name}} is supported for use with IPv4 networks only.

## Data storage requirements

If you want to set up [persistent storage](../planning/#planning-for-persistent-storage), {{site.data.reuse.short_name}} requires block storage configured to use the XFS or ext4 file system. The use of file storage (for example, NFS) is not recommended.

For example, you can use one of the following systems:

- Red Hat OpenShift Data Foundation (previously OpenShift Container Storage) version 4.2 or later (block storage only)
- IBM Cloud Block storage
- IBM Storage Suite for IBM Cloud Paks: block storage from IBM Spectrum Virtualize, FlashSystem, or DS8K
- Portworx Storage version 2.5.5 or later
- Kubernetes local volumes
- Amazon Elastic Block Store (EBS)
- Rook Ceph

## {{site.data.reuse.long_name}} UI

The {{site.data.reuse.long_name}} user interface (UI) is supported on the following web browsers:

- Google Chrome version 65 or later
- Mozilla Firefox version 59 or later
- Safari version 11.1 or later

## {{site.data.reuse.long_name}} CLI

The {{site.data.reuse.long_name}} command-line interface (CLI) is supported on the following systems:

- Windows 10 or later
- Linux® Ubuntu 16.04 or later
- macOS 10.13 (High Sierra) or later

See the post-installation tasks for information about [installing the CLI](../post-installation/#installing-the-event-streams-command-line-interface).


## Kafka clients

The Apache Kafka Java client included with {{site.data.reuse.long_name}} is supported for use with the following Java versions:

- IBM Java 8 or later
- Oracle Java 8 or later

You can also use other Kafka version 2.0 or later clients when connecting to {{site.data.reuse.short_name}}. If you encounter client-side issues, IBM can assist you to resolve those issues (see our [support policy]({{ 'support/#support-policy' | relative_url }}){:target="_blank"}).

{{site.data.reuse.short_name}} is designed for use with clients based on the `librdkafka` [implementation](https://github.com/edenhill/librdkafka){:target="_blank"} of the Apache Kafka protocol.
