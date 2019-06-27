---
title: "Pre-requisites"
excerpt: "Pre-requisites for installing IBM Event Streams."
categories: installing
slug: prerequisites
toc: true
---

Ensure your environment meets the following prerequisites before installing {{site.data.reuse.long_name}}.

## Container environment

{{site.data.reuse.long_name}} 2019.2.1 is supported on the following platforms and systems:

| Container platform | Systems
|--------------------|-----------------------|-------------|--------------------
|  {{site.data.reuse.icp}} 3.1.2 and 3.2.0 |  - Linux® 64-bit (x86_64) systems <br/>- Linux on IBM® Z systems
|  {{site.data.reuse.openshift}} 3.11 with {{site.data.reuse.icp}} 3.2.0   |  Linux® 64-bit (x86_64) systems |
|  {{site.data.reuse.openshift}} 3.10 with {{site.data.reuse.icp}} 3.1.2 |  Linux® 64-bit (x86_64) systems
|  Amazon Web Services (AWS) with {{site.data.reuse.icp}} 3.1.2 |  Linux® 64-bit (x86_64) systems
|  Microsoft Azure with {{site.data.reuse.icp}} 3.1.2 |  Linux® 64-bit (x86_64) systems

**Important:** {{site.data.reuse.icp}} 3.2.0 requires a fix for issue 26931. Contact {{site.data.reuse.icp}} [support](https://www.ibm.com/mysupport/s/){:target="_blank"} for the required fix.

{{site.data.reuse.short_name}} 2019.2.1 has Helm chart version 1.3.0 and includes Kafka version 2.2.0. For an overview of supported component and platform versions, see the [support matrix](../../support/#support-matrix).

Ensure you have the following set up for your {{site.data.reuse.icp}} environment:
  * Install [{{site.data.reuse.icp}}](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/install.html){:target="_blank"}.\\
    **Important:** In high throughput environments, ensure you configure your {{site.data.reuse.icp}} cluster to include an external load balancer and an internal network. These configuration options help take full advantage of {{site.data.reuse.short_name}} scaling and Kafka settings, and avoid potential performance bottlenecks. For more information, see the [performance planning topic](../capacity-planning).\\
    **Note:** {{site.data.reuse.long_name}} includes entitlement to {{site.data.reuse.icp_foundation}} which you can download from IBM Passport Advantage.
  * If you are installing {{site.data.reuse.short_name}} on the {{site.data.reuse.openshift_short}}, ensure you have the right version of OpenShift installed and integrated with the right version of {{site.data.reuse.icp}}. See previous table for supported versions. For example,  [install](https://docs.openshift.com/container-platform/3.11/getting_started/install_openshift.html){:target="_blank"} OpenShift 3.11, and [integrate](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/supported_environments/openshift/overview.html){:target="_blank"} it with {{site.data.reuse.icp}} 3.2.0.
  * If you are installing {{site.data.reuse.short_name}} on an {{site.data.reuse.icp}} cluster [deployed on Amazon Web Services (AWS)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/supported_environments/aws/overview.html){:target="_blank"}, ensure your proxy address uses [lowercase characters](../installing/#before-you-begin).
  * If you are installing {{site.data.reuse.short_name}} on an {{site.data.reuse.icp}} cluster [deployed on Microsoft Azure](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/supported_environments/azure_overview.html){:target="_blank"}, ensure you first register a Service Principal (an application in the Azure Active Directory). For information about creating a Service Principal, see the [terraform documentation](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html){:target="_blank"}.
  * Install the [Kubernetes command line tool](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/cfc_cli.html){:target="_blank"}, and configure access to your cluster.
  * If you are installing {{site.data.reuse.short_name}} on the {{site.data.reuse.openshift_short}}, ensure you also install the [{{site.data.reuse.openshift_short}} CLI](https://docs.openshift.com/container-platform/3.10/cli_reference/get_started_cli.html){:target="_blank"}.
  * Install the [{{site.data.reuse.icp}} Command Line Interface (CLI)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/install_cli.html){:target="_blank"}.
  * Install the [Helm CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/app_center/create_helm_cli.html){:target="_blank"} required for your version of {{site.data.reuse.icp}}, and add the {{site.data.reuse.icp}} [internal Helm repository](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/app_center/add_int_helm_repo_to_cli.html){:target="_blank"} called `local-charts` to the Helm CLI as an external repository.
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

| Pods                   | Number of replicas | Minimum total CPU | Minimum total memory (Gi) |
| --------------------- | ------------------ | ----------------- | ------------------------- |
| Kafka pod      | 3*                 | 2.2*                | 4.7*                      |
| Event Streams core pods | 12 if no persistence enabled  | 13 if no persistence enabled   | 10 if no persistence enabled   |
| &nbsp;            |  13 if persistence enabled  |  14 if persistence enabled  |  10.5 if persistence enabled|
| Message indexing pods  | 3  | 1.5  | 4.1  |
| Geo-replication pod  | 0*                  | 0.9 per replica  | 2.5 per replica

**Important:** You can configure the settings marked with an asterisk (*).

**Note:** Before installing {{site.data.reuse.long_name}} (not {{site.data.reuse.ce_short}}), consider the number of Kafka replicas and geo-replicator nodes you plan to use. Each Kafka replica and geo-replicator node is a separate chargeable unit.

{{site.data.reuse.geo-rep_note}}

### Kafka pod

| Container         | CPU per container  |  Memory per container (Gi)
| ------------------|--------------------|---------------------------
| Kafka             | 1*                 | 2*
| Metrics reporter  | 0.4                | 1.5*
| Metrics proxy     | 0.5                | 1
| Healthcheck       | 0.2                | 0.1
| TLS proxy         | 0.1                | 0.1

### ZooKeeper pod

| Container         | CPU per container  |  Memory per container (Gi)
| ------------------|--------------------|---------------------------
| ZooKeeper         | 0.1*               | 0.75*
| TLS proxy         | 0.1                | 0.1

### Geo-replicator pod

| Container         | CPU per container     |  Memory per container (Gi)
| ------------------|-----------------------|---------------------------
| Replicator        | 0.5                     | 1
| Metrics reporter  | 0.4                   | 1.5

### Administration UI pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|------------------------|---------------------------
| UI         | 1                      | 1
| Redis      | 0.1                    | 0.1

### Administration server pod

| Container  | CPU per container     |  Memory per container (Gi)
| -----------|-----------------------|---------------------------
| Rest       | 0.5                   | 1
| Codegen    | 0.2                   | 0.3
| TLS proxy  | 0.1                   | 0.1

### REST producer server pod

| Container     | CPU per container  |  Memory per container (Gi)
| --------------|--------------------|---------------------------
| Rest-producer | 0.5                | 1

### REST proxy pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Rest-proxy | 0.5                | 0.25

### Collector pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Collector  | 0.1                | 0.05
| TLS proxy  | 0.1                | 0.1

### Network proxy pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Proxy      | 1                  | 0.1

### Access controller pod

| Container          | CPU per container  |  Memory per container (Gi)
| -------------------|--------------------|---------------------------
| Access controller  | 0.1                | 0.25
| Redis              | 0.1                | 0.1

### Index manager pod

| Container     | CPU per container  |  Memory per container (Gi)
| --------------|--------------------|---------------------------
| Index manager | 0.2                | 0.1
| TLS proxy     | 0.1                | 0.1

### Elasticsearch pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Elastic    | 1                  | 4
| TLS proxy  | 0.1                | 0.1


### Schema Registry pod

| Container  | CPU per container  |  Memory per container (Gi)
| -----------|--------------------|---------------------------
| Schema Registry | 0.5           | 0.25
| Avro service    | 0.5           |  0.25 |


## PodSecurityPolicy requirements

To install the {{site.data.reuse.short_name}} chart, you must have the `ibm-restricted-psp` [PodSecurityPolicy](https://ibm.biz/cpkspec-psp){:target="_blank"} selected for the target namespace.

You can define the PodSecurityPolicy when creating the [namespace](../installing/#create-a-namespace) for your installation.

{{site.data.reuse.short_name}} applies network policies to control the traffic within the namespace where it is deployed, limiting the traffic to that required by {{site.data.reuse.short_name}}. For more information about the network policies and the traffic they permit, see [network policies](../../security/network-policies/).

For more information about PodSecurityPolicy definitions, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/security.html){:target="_blank"}.

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

Ensure you stay current with the installation of CD update packages, as described in [the continuous delivery life cycle policy](https://www.ibm.com/support/docview.wss?uid=ibm10718163){:target="_blank"}. Product defect fixes and security updates are only available for the two most current CD update packages.

{{site.data.reuse.long_name}} offers support for Apache Kafka, and will work with the Apache Kafka open source community to produce open source fixes. Where appropriate, IBM can provide an interim fix for the temporary resolution of Apache Kafka issues.
