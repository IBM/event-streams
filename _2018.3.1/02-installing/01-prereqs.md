---
title: "Pre-requisites"
excerpt: "Pre-requisites for installing IBM Event Streams."
categories: installing
slug: prerequisites
toc: true
---

Ensure your environment meets the following prerequisites before installing {{site.data.reuse.long_name}}.

## {{site.data.reuse.icp}} environment

{{site.data.reuse.short_name}} version | Container platform | Systems
----------------------|--------------------|-----------------------|-------------|--------------------
![Event Streams 2018.3.1 icon](../../../images/2018.3.1.svg "Event Streams 2018.3.1.") | {{site.data.reuse.icp}} 3.1.1 and 3.1.2  | - Linux® 64-bit (x86_64) systems <br/>- Linux on IBM® Z systems
  | {{site.data.reuse.icp}} 3.1.0  | - Linux® 64-bit (x86_64) systems
![Event Streams 2018.3.0 icon](../../../images/2018.3.0.svg "Event Streams 2018.3.0.") | {{site.data.reuse.icp}} 3.1.0  | - Linux® 64-bit (x86_64) systems

![Event Streams 2018.3.1 icon](../../../images/2018.3.1.svg "Event Streams 2018.3.1.") has Helm chart version 1.1.0 and includes Kafka version 2.0.1.

![Event Streams 2018.3.0 icon](../../../images/2018.3.0.svg "Event Streams 2018.3.0.") has Helm chart version 1.0.0 and includes Kafka version 2.0.

For an overview of supported component and platform versions, see the [support matrix](../../../support/#support-matrix).

Ensure you have the following set up for your {{site.data.reuse.icp}} environment:
  * Install [{{site.data.reuse.icp}}](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/install.html). \\
    **Note:** {{site.data.reuse.long_name}} includes entitlement to {{site.data.reuse.icp_foundation}} which you can download from IBM Passport Advantage.
  * Install the [Kubernetes command line tool](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/cfc_cli.html), and configure access to your cluster.
  * Install the [{{site.data.reuse.icp}} Command Line Interface (CLI)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/install_cli.html).
  * Install the [Helm CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/app_center/create_helm_cli.html) required for your version of {{site.data.reuse.icp}}, and add the {{site.data.reuse.icp}} [internal Helm repository](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/app_center/add_int_helm_repo_to_cli.html) called `local-charts` to the Helm CLI as an external repository.
  * For message indexing capabilities (enabled by default), ensure you set the `vm.max_map_count` property to at least `262144` on all {{site.data.reuse.icp}} nodes in your cluster (not only the master node). Run the following commands on each node: \\
    `sudo sysctl -w vm.max_map_count=262144`\\
    `echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf`\\
    **Important:** This property might have already been updated by other workloads to be higher than the minimum required.

## Hardware requirements

The Helm chart for {{site.data.reuse.long_name}} specifies default values for the CPU and memory usage of the Apache Kafka brokers and Apache ZooKeeper servers. While {{site.data.reuse.long_name}} can run successfully if lower memory and CPU values are specified, these defaults are the minimum values tested.

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
| Proxy      | unlimited             | unlimited

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

To install the {{site.data.reuse.short_name}} chart, you must have the `ibm-restricted-psp` [PodSecurityPolicy](https://ibm.biz/cpkspec-psp) selected for the target namespace.

You can define the PodSecurityPolicy when creating the [namespace](../installing/#create-a-namespace) for your installation.

For more information about PodSecurityPolicy definitions, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/security.html).

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
*   Microsoft Edge version 44.17763.1.0 (Microsoft EdgeHTML 18.17763) or later
*   Safari version 11.1 or later

## {{site.data.reuse.long_name}} CLI

The {{site.data.reuse.long_name}} command line interface (CLI) is supported on the following systems:

*   Windows 10 or later
*   Linux® Ubuntu 16.04 or later
*   macOS 10.13 (High Sierra) or later

## Clients

<!--
{{site.data.reuse.long_name}} is supported for use with clients running Apache Kafka version 2.0 or later.
-->

The Apache Kafka Java client shipped with {{site.data.reuse.long_name}} is supported for use with the following Java versions:

*   IBM Java 8
*   Oracle Java 8

You can use other Kafka version 2.0 or later clients when connecting to {{site.data.reuse.short_name}}, but in such cases IBM can only provide support for server-side issues, and not for the clients themselves.

{{site.data.reuse.short_name}} is designed for use with clients based on the `librdkafka` implementation of the Apache Kafka protocol.

## Continuous Delivery (CD) support model

{{site.data.reuse.long_name}} uses the continuous delivery (CD) support model.

Ensure you stay current with the installation of CD update packages, as described in [the continuous delivery life cycle policy](https://www.ibm.com/support/docview.wss?uid=ibm10718163). Product defect fixes and security updates are only available for the two most current CD update packages.

{{site.data.reuse.long_name}} offers support for Apache Kafka, and will work with the Apache Kafka open source community to produce open source fixes. Where appropriate, IBM can provide an interim fix for the temporary resolution of Apache Kafka issues.
