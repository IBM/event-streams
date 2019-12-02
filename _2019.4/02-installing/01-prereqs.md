---
title: "Pre-requisites"
excerpt: "Pre-requisites for installing IBM Event Streams."
categories: installing
slug: prerequisites
toc: true
---

Ensure your environment meets the following prerequisites before installing {{site.data.reuse.long_name}}.

## Container environment

{{site.data.reuse.long_name}} 2019.4.1 is supported on the following platforms and systems:

| Container platform | Systems
|--------------------|-----------------------|-------------|--------------------
| {{site.data.reuse.openshift}} 3.11 with IBM cloud foundational services 3.2.1* | - Linux® 64-bit (x86_64) systems <br> - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS) |
| {{site.data.reuse.icp}} 3.2.1 | - Linux® 64-bit (x86_64) systems <br/>- Linux on IBM® z13 or later systems <br> - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS) |

*Provided by {{site.data.reuse.icp}}

{{site.data.reuse.short_name}} 2019.4.1 has Helm chart version 1.4.0 and includes Kafka version 2.3.0. For an overview of supported component and platform versions, see the [support matrix](../../support/#support-matrix).

Ensure you have the following set up for your environment:

  * If you are installing {{site.data.reuse.short_name}} on the {{site.data.reuse.openshift_short}}, ensure you have the right version of OpenShift installed and integrated with the right version of {{site.data.reuse.icp}}. See previous table for supported versions. For example,  [install](https://docs.openshift.com/container-platform/3.11/getting_started/install_openshift.html){:target="_blank"} OpenShift 3.11, and [integrate](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/supported_environments/openshift/overview.html){:target="_blank"} it with {{site.data.reuse.icp}} 3.2.1.
  * Install and configure [{{site.data.reuse.icp}}](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/installing/install.html){:target="_blank"}.\\
    **Important:** In high throughput environments, ensure you configure your {{site.data.reuse.icp}} cluster to include an external load balancer and an internal network. These configuration options help take full advantage of {{site.data.reuse.short_name}} scaling and Kafka settings, and avoid potential performance bottlenecks. For more information, see the [performance planning topic](../capacity-planning).

    **Note:** {{site.data.reuse.long_name}} includes entitlement to {{site.data.reuse.icp_foundation}} which you can download from IBM Passport Advantage.
  * If you are installing {{site.data.reuse.short_name}} on an {{site.data.reuse.icp}} cluster [deployed on Amazon Web Services (AWS)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/supported_environments/aws/overview.html){:target="_blank"}, ensure your proxy address uses [lowercase characters](../installing/#before-you-begin).
  * If you are installing {{site.data.reuse.short_name}} on an {{site.data.reuse.icp}} cluster [deployed on Microsoft Azure](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/supported_environments/azure_overview.html){:target="_blank"}, ensure you first register a Service Principal (an application in the Azure Active Directory). For information about creating a Service Principal, see the [terraform documentation](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html){:target="_blank"}.
  * Install the [Kubernetes command line tool](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_cluster/cfc_cli.html){:target="_blank"}, and configure access to your cluster.
  * If you are installing {{site.data.reuse.short_name}} on the {{site.data.reuse.openshift_short}}, ensure you also install the [{{site.data.reuse.openshift_short}} CLI](https://docs.openshift.com/container-platform/3.11/cli_reference/get_started_cli.html){:target="_blank"}.
  * Install the [{{site.data.reuse.icp}} Command Line Interface (CLI)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_cluster/install_cli.html){:target="_blank"}.
  * Install the [Helm CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/app_center/create_helm_cli.html){:target="_blank"} required for your version of {{site.data.reuse.icp}}, and add the {{site.data.reuse.icp}} [internal Helm repository](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/app_center/add_int_helm_repo_to_cli.html){:target="_blank"} called `local-charts` to the Helm CLI as an external repository.
  * For message indexing capabilities (enabled by default), ensure you set the `vm.max_map_count` property to at least `262144` on all {{site.data.reuse.icp}} nodes in your cluster (not only the master node). Run the following commands on each node: \\
    `sudo sysctl -w vm.max_map_count=262144`\\
    `echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf`

    **Important:** This property might have already been updated by other workloads to be higher than the minimum required.

## Hardware requirements

The Helm chart for {{site.data.reuse.long_name}} specifies default values for the CPU and memory usage of the Apache Kafka brokers and Apache ZooKeeper servers.

See the [following table](#helm-resource-requirements) for memory requirements of each Helm chart component. Ensure you have sufficient physical memory to service these requirements.

Kubernetes manages the allocation of containers within your cluster. This allows resources to be available for other {{site.data.reuse.long_name}} components which might be required to reside on the same node.

Ensure you have one {{site.data.reuse.icp}} worker node per Kafka broker, and a minimum of 3 worker nodes available for use by {{site.data.reuse.long_name}}. Ensure each worker node runs on a separate physical server. See the guidance about [Kafka high availability](../planning/#kafka-high-availability) for more information.


## Helm resource requirements

The {{site.data.reuse.short_name}} Helm chart has the following resource requirements based on resource request and limit settings. Requests and limits are Kubernetes concepts for controlling resource types such as CPU and memory.

- Requests set the minimum requirements a container requires to be scheduled. If your system does not have the required request value, then your services will not start up.
- Limits set the value beyond which a container cannot consume the resource. It is the upper limit within your system for the service.

For more information about resource requests and limits, see the Kubernetes [documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/){:target="_blank"}.

The following table lists the aggregate resource requirements of the {{site.data.reuse.short_name}} Helm chart. The table includes totals for both request and limit values of all pods and their containers. Each container in a pod has its own request and limit values, but as pods run as a group, these values need to be added together to understand the total requirements for a pod.

The table includes information about requirements for the following deployment options:
- The requirements are different depending on whether you require [persistent storage](../planning/#persistent-storage) or not.
- If you plan to set up a [multizone cluster](../planning/#multizone-support), certain pod resource requirements will be on a per zone basis.

For details about the requirements for each container within individual pods and any zone implications, see the individual tables in the sections following the summary table.

These are the minimum requirements for an {{site.data.reuse.short_name}} installation, and will be used unless you change them when [configuring](../configuring) your installation. They are based on the default resource request and limit settings of the chart. Installing with these settings is suitable for a starter deployment intended for testing purposes and trying out {{site.data.reuse.short_name}}.

For a production setup, ensure you set higher values, and also consider important configuration options for {{site.data.reuse.icp}} such as setting up a load balancer and an internal network. For more information about planning for a production setup, including requirements for a baseline production environment, see the [performance planning topic](../capacity-planning).

| Pod group             | Configurable replicas | Total CPU request per pod group (cores)| Total CPU limit per pod group (cores)| Total memory request per pod group (Gi)| Total memory limit per pod group (Gi)|
| --------------------- | --------------------- | --------------------------|-------------------------|---------------------------|--------------------|
| [Kafka](#kafka-group)      | 3*               | 8.6* (3.2 per zone) | 10.4* (3.8 per zone) | 14.3*  (4.8 per zone)  | 14.3* (4.8 per zone)
| [Event Streams core](#event-streams-core-group) <br>- Not persistent | | 5.1 | 12.4  | 6  | 7.4
| [Event Streams core](#event-streams-core-group) <br>- Not persistent <br>- Multizone   | | 3.3 + 1.4 per zone | 7.1 + 4.9 per zone  | 4 + 1.6 per zone  | 4.5 + 2.6 per zone
| [Event Streams core](#event-streams-core-group) <br> - Persistent     | | 6.1 | 13.4  | 6.5  | 7.9
| [Event Streams core](#event-streams-core-group) <br> - Persistent <br> - Multizone  | | 4.3 + 1.4 per zone | 8.1 + 4.9 per zone | 4.5 + 1.6 per zone | 5 + 2.6 per zone
| [Message indexing](#message-indexing-group)  |   | 1.5                | 2.5                   | 4.4                       | 8.4
| [Geo-replication](#geo-replicator-group)  | 0*   | 0.9 per replica    | 1.6 per replica       | 2.5 per replica           | 2.5 per replica
| **TOTAL not persistent**  |         | **15.2**       | **24.3**      | **21.8**    | **23.2** |
| **TOTAL persistent**      |         | **16.2**       | **26.3**      | **25.2**    | **30.6** |
| **TOTAL 3 zones and persistent**|   | **19.6**       | **36.7**      | **28.1**    | **35.6** |

**Important:** The settings marked with an asterisk (*) are configurable. The values in the table are the default minimum values.

Before installing {{site.data.reuse.long_name}} (not {{site.data.reuse.ce_short}}), consider the number of Kafka replicas and geo-replicator nodes you plan to use. Each Kafka replica and geo-replicator node is a separate chargeable unit.

{{site.data.reuse.geo-rep_note}} The geo-replication numbers are included in the previous table as an indication to show per replica requirements, but not included in the **TOTAL** rows.

### Kafka group

The following pods and their containers are part of this group.

**Important:** The settings marked with an asterisk (*) are configurable. The values in the table are the default minimum values.

#### Kafka pod

Number of replicas: 3*

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Kafka             |   1*                              | 1*                              | 2*                                 | 2*
| Metrics reporter  |  0.4                              | 0.6                             | 1.5                                | 1.5
| Metrics proxy     |  0.5                              | 0.5                             | 1                                  | 1
| Healthcheck       |  0.2                              | 0.2                             | 0.1                                | 0.1
| TLS proxy         |  0.1                              | 0.5                             | 0.1                                | 0.1

#### Network proxy pod

Number of replicas: 2 by default, otherwise 1 per zone

| Container  | CPU request per container (cores) |  CPU limit per container (cores) | Memory request per container (Gi) | Memory limit per container (Gi)
| -----------|-----------------------------------|----------------------------------|-----------------------------------|--------------------------------
| Proxy      |         1                         |  1                               | 0.1                               | 0.1

### Event Streams core group

The following pods and their containers are part of this group.

**Important:** The settings marked with an asterisk (*) are configurable. The values in the table are the default minimum values.

#### ZooKeeper pod

Number of replicas: 3

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| ZooKeeper         | 0.1*                              | 0.1*                            | 0.75                               | 1
| TLS proxy         | 0.1                               | 0.1                             | 0.1                                | 0.1

#### Administration UI pod

Number of replicas: 1

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| UI                | 1                                 | 1                               | 1                                  | 1
| Redis             | 0.1                               | 0.1                             | 0.1                                | 0.1

#### Administration server pod

Number of replicas: 1

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Rest              | 0.5                               | 4                               | 1                                  | 1
| Codegen           | 0.2                               | 0.5                             | 0.3                                | 0.5
| TLS proxy         | 0.1                               | 0.1                             | 0.1                                | 0.1

#### REST producer server pod

Number of replicas: 1 per zone

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Rest-producer     | 0.5                               | 4                               | 1                                  | 2

#### REST proxy pod

Number of replicas: 1 per zone

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Rest-proxy        | 0.5                               | 0.5                             | 0.25                               | 0.25

#### Collector pod

Number of replicas: 1

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Collector         | 0.1                               | 0.1                             | 0.05                               | 0.05
| TLS proxy         | 0.1                               | 0.1                             | 0.1                                | 0.1


#### Access controller pod

Number of replicas: 2 by default, otherwise 1 per zone

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Access controller | 0.3                               | 0.3                             | 0.25                               | 0.25
| Redis             | 0.1                               | 0.1                             | 0.1                                | 0.1

#### Schema Registry pod

Number of replicas:
- 1 without persistence
- 2 with persistence enabled

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Schema Registry   | 0.5                               | 0.5                             | 0.25                               | 0.25
| Avro service      | 0.5                               | 0.5                             | 0.25                               | 0.25

### Message indexing group

The following pods and their containers are part of this group.

#### Index manager pod

Number of replicas: 1

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Index manager     | 0.2                               | 0.2                             | 0.1                                | 0.1
| TLS proxy         | 0.1                               | 0.1                             | 0.1                                | 0.1

#### Elasticsearch pod

Number of replicas: 2

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Elastic           | 0.5*                              | 1*                              | 2*                                 | 4*
| TLS proxy         | 0.1                               | 0.1                             | 0.1                                | 0.1

### Geo-replicator group

This group only contains the geo-replicator pod.

Number of replicas: 0*

**Note:** This means there is no geo-replication enabled by default. The values in the following table are the default minimum values for 1 replica.

| Container         | CPU request per container (cores) | CPU limit per container (cores) |  Memory request per container (Gi) | Memory limit per container (Gi)
| ------------------|-----------------------------------|---------------------------------|------------------------------------|--------------------------------
| Replicator        | 0.5                               | 1                               | 1                                  | 1
| Metrics reporter  | 0.4                               | 0.6                             | 1.5                                | 1.5


## PodSecurityPolicy requirements

To install the {{site.data.reuse.short_name}} chart, you must have the `ibm-restricted-psp` [PodSecurityPolicy](https://ibm.biz/cpkspec-psp){:target="_blank"} selected for the target namespace.

You can define the PodSecurityPolicy when creating the [namespace](../installing/#create-a-namespace) for your installation.

{{site.data.reuse.short_name}} applies network policies to control the traffic within the namespace where it is deployed, limiting the traffic to that required by {{site.data.reuse.short_name}}. For more information about the network policies and the traffic they permit, see [network policies](../../security/network-policies/).

For more information about PodSecurityPolicy definitions, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_cluster/security.html){:target="_blank"}.

**Note:** The PodSecurityPolicy requirements do not apply to the {{site.data.reuse.openshift}}.

## Red Hat OpenShift SecurityContextConstraints Requirements

If you  are installing on the {{site.data.reuse.openshift_short}}, the {{site.data.reuse.short_name}} chart requires a custom SecurityContextConstraints to be bound to the target namespace prior to installation. The custom SecurityContextConstraints controls the permissions and capabilities required to deploy this chart.

You can enable this custom SecurityContextConstraints resource using the supplied pre-installation [setup script](../installing-openshift/#run-the-setup-script).

## Network requirements

{{site.data.reuse.long_name}} is supported for use with IPv4 networks only.

## File systems for storage

If you want to set up [persistent storage](../planning/#persistent-storage), you must have physical volumes available, backed by one of the following file systems:
- [NFS](https://kubernetes.io/docs/concepts/storage/volumes/#nfs){:target="_blank"} version 4
- [GlusterFS](https://kubernetes.io/docs/concepts/storage/volumes/#glusterfs){:target="_blank"} version 3.10.1
- [IBM Spectrum Scale](https://www.ibm.com/support/knowledgecenter/en/STXKQY_5.0.3/com.ibm.spectrum.scale.v5r03.doc/bl1ins_intro.htm){:target="_blank"} version 5.0.3.0
- [Kubernetes local volumes](https://kubernetes.io/docs/concepts/storage/volumes/#local){:target="_blank"}
- [Amazon Elastic Block Store (EBS)](https://kubernetes.io/docs/concepts/storage/volumes/#awselasticblockstore){:target="_blank"}

## {{site.data.reuse.long_name}} user interface

The {{site.data.reuse.long_name}} user interface (UI) is supported on the following web browsers:

*   Google Chrome version 65 or later
*   Mozilla Firefox version 59 or later
*   Safari version 11.1 or later

## {{site.data.reuse.long_name}} CLI

The {{site.data.reuse.long_name}} command line interface (CLI) is supported on the following systems:

*   Windows 10 or later
*   Linux® Ubuntu 16.04 or later
*   macOS 10.13 (High Sierra) or later

## Clients

The Apache Kafka Java client included with {{site.data.reuse.long_name}} is supported for use with the following Java versions:

*   IBM Java 8
*   Oracle Java 8

You can also use other Kafka version 2.0 or later clients when connecting to {{site.data.reuse.short_name}}. If you encounter client-side issues, IBM can assist you to resolve those issues (see our [support policy](../../support#support-policy)).

{{site.data.reuse.short_name}} is designed for use with clients based on the `librdkafka` implementation of the Apache Kafka protocol.
