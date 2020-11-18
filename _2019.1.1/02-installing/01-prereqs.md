---
title: "Pre-requisites"
excerpt: "Pre-requisites for installing IBM Event Streams."
categories: installing
slug: prerequisites
toc: true
---

Ensure your environment meets the following prerequisites before installing {{site.data.reuse.long_name}}.

## Container environment

{{site.data.reuse.long_name}} 2019.1.1 is supported on the following platforms and systems:

| Container platform | Systems
|--------------------|-----------------------|-------------|--------------------
| {{site.data.reuse.openshift}} 3.9 and 3.10 with IBM cloud foundational services 3.1.2*   |  - Linux® 64-bit (x86_64) systems <br> - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS) |
| {{site.data.reuse.icp}} 3.1.1, 3.1.2, and 3.2.0.1907 (or later [fix pack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/patching_cluster.html){:target="_blank"}) |  - Linux® 64-bit (x86_64) systems <br/>- Linux on IBM® Z systems
| {{site.data.reuse.icp}} 3.1.2     | - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS)  |

*Provided by {{site.data.reuse.icp}}

{{site.data.reuse.short_name}} 2019.1.1 has Helm chart version 1.2.0 and includes Kafka version 2.1.1. For an overview of supported component and platform versions, see the [support matrix]({{ 'support/#support-matrix' | relative_url }}).

Ensure you have the following set up for your environment:
  * If you are installing {{site.data.reuse.short_name}} on the {{site.data.reuse.openshift_short}}, ensure you have OpenShift [installed](https://docs.openshift.com/container-platform/3.10/getting_started/install_openshift.html){:target="_blank"}, and also ensure you [install and integrate](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/supported_environments/openshift/overview.html){:target="_blank"} {{site.data.reuse.icp}} version 3.1.2.\\
     **Note:** {{site.data.reuse.ce_long}} is not supported on {{site.data.reuse.openshift}}.
 * Install and configure [{{site.data.reuse.icp}}](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/installing/install.html){:target="_blank"}.\\
     **Important:** In high throughput environments, ensure you [configure an external load balancer](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/installing/set_loadbalancer.html){:target="_blank"} for your {{site.data.reuse.icp}} cluster to take full advantage of {{site.data.reuse.short_name}} [scaling](../../administering/scaling/), and avoid potential bottlenecks.\\
     **Note:** {{site.data.reuse.long_name}} includes entitlement to {{site.data.reuse.icp_foundation}} which you can download from IBM Passport Advantage.
  * If you are installing {{site.data.reuse.short_name}} on an {{site.data.reuse.icp}} cluster [deployed on Amazon Web Services (AWS)](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/supported_environments/aws/overview.html){:target="_blank"}, ensure your proxy address uses [lowercase characters](../installing/#before-you-begin).
  * Install the [Kubernetes command line tool](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/cfc_cli.html){:target="_blank"}, and configure access to your cluster.
  * If you are installing {{site.data.reuse.short_name}} on the {{site.data.reuse.openshift_short}}, ensure you also install the [{{site.data.reuse.openshift_short}} CLI](https://docs.openshift.com/container-platform/3.10/cli_reference/get_started_cli.html){:target="_blank"}.
  * Install the [{{site.data.reuse.icp}} Command Line Interface (CLI)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/install_cli.html){:target="_blank"}.
  * Install the [Helm CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/app_center/create_helm_cli.html){:target="_blank"} required for your version of {{site.data.reuse.icp}}, and add the {{site.data.reuse.icp}} [internal Helm repository](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/app_center/add_int_helm_repo_to_cli.html){:target="_blank"} called `local-charts` to the Helm CLI as an external repository.
  * For message indexing capabilities (enabled by default), ensure you set the `vm.max_map_count` property to at least `262144` on all {{site.data.reuse.icp}} nodes in your cluster (not only the master node). Run the following commands on each node: \\
    `sudo sysctl -w vm.max_map_count=262144`\\
    `echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf`\\
    **Important:** This property might have already been updated by other workloads to be higher than the minimum required.

## Hardware requirements

The Helm chart for {{site.data.reuse.long_name}} specifies default values for the CPU and memory usage of the Apache Kafka brokers and Apache ZooKeeper servers.

See the [following table](#helm-resource-requirements) for memory requirements of each Helm chart component. Ensure you have sufficient physical memory to service these requirements.

Kubernetes manages the allocation of containers within your cluster. This allows resources to be available for other {{site.data.reuse.long_name}} components which might be required to reside on the same node.

Ensure you have one {{site.data.reuse.icp}} worker node per Kafka broker, and a minimum of 3 worker nodes available for use by {{site.data.reuse.long_name}}.

## Helm resource requirements

The following table lists the resource requirements of the {{site.data.reuse.long_name}} Helm chart. For details about the requirements for each pod and their containers, see the tables in the following sections.

| Pod                   | Number of replicas  | Total CPU per pod  | Total memory per pod (Gi)
| ----------------------|---------------------|--------------------|--------------------------
| Kafka                 | 3*                  | 1*                 | 3.5*
| ZooKeeper             | 3                   | 0.1*               | 1*
| Geo-replicator        | 0*                  | 1 per replica      | 1 per replica
| Administration UI     | 1                   | 1                  | 1
| Administration server | 1                   | 4.5                | 2.5
| REST producer server  | 1                   | 4                  | 2
| REST proxy            | 1                   | unlimited          | unlimited
| Collector             | 1                   | 1                  | 1
| Network proxy         | 2                   | unlimited          | unlimited
| Access controller     | 1                   | 0.1                | 0.25
| Index manager         | 1                   | unlimited          | unlimited
| Elasticsearch         | 2                   | unlimited          | 4

**Important:** You can configure the settings marked with an asterisk (*).

**Note:** Before installing {{site.data.reuse.long_name}} (not {{site.data.reuse.ce_short}}), consider the number of Kafka replicas and geo-replicator nodes you plan to use. Each Kafka replica and geo-replicator node is a separate chargeable unit.

The CPU and memory limits for some components are not limited by the chart, so they inherit the resource limits for the namespace that the chart is being installed into. If there are no resource limits set for the namespace, the containers run with unbounded CPU and memory limits.

{{site.data.reuse.geo-rep_note}}

### Kafka pod

| Container         | CPU per container  |  Memory per container (Gi)
| ------------------|--------------------|---------------------------
| Kafka             | 1*                 | 2*
| Metrics reporter  | unlimited          | 1.5*
| Metrics proxy     | unlimited          | unlimited
| Healthcheck       | unlimited          | unlimited

### ZooKeeper pod

| Container         | CPU per container  |  Memory per container (Gi)
| ------------------|--------------------|---------------------------
| ZooKeeper         | 0.1*               | 1*

### Geo-replicator pod

| Container         | CPU per container     |  Memory per container (Gi)
| ------------------|-----------------------|---------------------------
| Replicator        | 1                     | 1
| Metrics reporter  | unlimited             | unlimited

### Administration UI pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|------------------------|---------------------------
| UI         | 1                      | 1
| Redis      | unlimited              | unlimited
| Proxy      | unlimited              | unlimited

### Administration server pod

| Container  | CPU per container     |  Memory per container (Gi)
| -----------|-----------------------|---------------------------
| Rest       | 4                     | 2
| Codegen    | 0.5                   | 0.5

### REST producer server pod

| Container     | CPU per container  |  Memory per container (Gi)
| --------------|--------------------|---------------------------
| Rest-producer | 4                  | 2

### REST proxy pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Rest-proxy | unlimited          | unlimited

### Collector pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Collector  | unlimited          | unlimited

### Network proxy pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Proxy      | unlimited          | unlimited

### Access controller pod

| Container          | CPU per container  |  Memory per container (Gi)
| -------------------|--------------------|---------------------------
| Access controller  | 0.1                | 0.25
| Redis              | unlimited          | unlimited

### Index manager pod

| Container     | CPU per container  |  Memory per container (Gi)
| --------------|--------------------|---------------------------
| Index manager | unlimited          | unlimited

### Elasticsearch pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Elastic    | unlimited          | 4

## PodSecurityPolicy requirements

To install the {{site.data.reuse.short_name}} chart, you must have the `ibm-restricted-psp` [PodSecurityPolicy](https://ibm.biz/cpkspec-psp){:target="_blank"} selected for the target namespace.

You can define the PodSecurityPolicy when creating the [namespace](../installing/#create-a-namespace) for your installation.

{{site.data.reuse.short_name}} applies network policies to control the traffic within the namespace where it is deployed, limiting the traffic to that required by {{site.data.reuse.short_name}}. For more information about the network policies and the traffic they permit, see [network policies](../../security/network-policies/).

For more information about PodSecurityPolicy definitions, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/security.html){:target="_blank"}.

**Note:** The PodSecurityPolicy requirements do not apply to the {{site.data.reuse.openshift}}.

## Red Hat OpenShift SecurityContextConstraints Requirements

If you  are installing on the {{site.data.reuse.openshift_short}}, the {{site.data.reuse.short_name}} chart requires a custom SecurityContextConstraints to be bound to the target namespace prior to installation. The custom SecurityContextConstraints controls the permissions and capabilities required to deploy this chart.

You can enable this custom SecurityContextConstraints resource using the supplied pre-installation [setup script](../installing-openshift/#run-the-setup-script).

## Network requirements

{{site.data.reuse.long_name}} is supported for use with IPv4 networks only.

## File systems for storage

If you want to set up [persistent storage](../planning/#persistent-storage), you must have physical volumes available, backed by one of the following file systems:
- NFS version 4
- GlusterFS version 3.10.1

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

You can also use other Kafka version 2.0 or later clients when connecting to {{site.data.reuse.short_name}}. If you encounter client-side issues, IBM can assist you to resolve those issues (see our [support policy](../../../support#support-policy)).

{{site.data.reuse.short_name}} is designed for use with clients based on the `librdkafka` implementation of the Apache Kafka protocol.
