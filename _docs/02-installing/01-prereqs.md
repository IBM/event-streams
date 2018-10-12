---
title: "Pre-requisites"
permalink: /installing/prerequisites/
excerpt: "Pre-requisites for installing IBM Event Streams."
last_modified_at:
toc: true
---

Ensure your environment meets the following prerequisites before installing {{site.data.reuse.long_name}} version 2018.3.0.

## {{site.data.reuse.icp}} environment

{{site.data.reuse.long_name}} is supported on {{site.data.reuse.icp}} version 3.1.0 running on Linux® 64-bit (x86_64) systems.

Ensure you have the following set up for your {{site.data.reuse.icp}} environment:
  * Install [{{site.data.reuse.icp}} version 3.1.0](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/installing/installing.html).\\
    **Note:** {{site.data.reuse.long_name}} includes entitlement for {{site.data.reuse.icp_foundation}} which you can [download](../downloading) from IBM Passport Advantage.
  * Install the [Kubernetes command line tool](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/cfc_cli.html), and configure access to your cluster.
  * Install the [{{site.data.reuse.icp}} Command Line Interface](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_cluster/install_cli.html).
  * Install the [Helm Command Line Interface](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/app_center/create_helm_cli.html) version 2.7.3 or later, and add the {{site.data.reuse.icp}} [internal Helm repository](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/app_center/add_int_helm_repo_to_cli.html) called `local-charts` to the Helm CLI as an external repository.
  * For message indexing capabilities (enabled by default), ensure you set the `vm.max_map_count` property to at least `262144` on all {{site.data.reuse.icp}} nodes in your cluster (not only the master node). Run the following commands on each node: \\
    `sudo sysctl -w vm.max_map_count=262144`\\
    `echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf`\\
    **Important:** This property might have already been updated by other workloads to be higher than the minimum required.\\

## Hardware requirements

The Helm chart for {{site.data.reuse.long_name}} specifies default values for the CPU and memory usage of the Apache Kafka brokers and Apache ZooKeeper servers. While {{site.data.reuse.long_name}} can run successfully if lower memory and CPU values are specified, these defaults are the minimum values tested.

See the [following table](#helm-resource-requirements) for memory requirements of each Helm chart component. Ensure you have sufficient physical memory to service these requirements.

Kubernetes manages the allocation of containers within your cluster. This allows resources to be available for other {{site.data.reuse.long_name}} components which might be required to reside on the same node.

Ensure you have one {{site.data.reuse.icp}} worker node per Kafka broker, and a minimum of 3 worker nodes available for use by {{site.data.reuse.long_name}}.

## Helm resource requirements

The {{site.data.reuse.long_name}} Helm chart has the following resource requirements:

Component  | Number of replicas  | CPU/container  | Memory/container (Gi)
--|---|---|--
Kafka  | 3*  | 1*  | 2*
ZooKeeper  | 3  | 0.1*  | 0.25*
Administration UI  | 1  | 1  | 1
Administration server  | 1  | 1  | 2
Network proxy  | 2  | unlimited  | unlimited
Access controller  | 1  | 0.1  | 0.25
Index manager  | 1  | unlimited  | unlimited
Elasticsearch  | 2  | unlimited  | 2
Geo-replicator  | 0*  | 1  | 1

You can configure the settings marked with an asterisk (*).

**Note:** Before installing {{site.data.reuse.long_name}} (not {{site.data.reuse.ce_short}}), consider the number of Kafka replicas and geo-replicator nodes you plan to use. Each Kafka replica and geo-replicator node is a separate chargeable unit.

The CPU and memory limits for some components are not limited by the chart, so they inherit the resource limits for the namespace that the chart is being installed into. If there are no resource limits set for the namespace, the containers run with unbounded CPU and memory limits.

## PodSecurityPolicy requirements

If you apply Pod Security Policies to the namespace where {{site.data.reuse.long_name}} is installed, ensure you allow the following capabilities. If any of the following capabilities are blocked, {{site.data.reuse.long_name}} will not start or operate correctly.

- Access to the following volume types:
  - configMapName
  - emptyDir
  - persistentVolumeClaim
  - projected
- fsGroup support for the following group IDs:
  - 1000
  - 1001
- runAsUser support for the following user IDs:
  - 1000
  - 1001
  - 65534
- readOnlyRootFilesystem must be `false`
- Retain default settings for the following capabilities:
  - SELinux
  - AppArmor
  - seccomp
  - sysctl

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
*   Microsoft Edge version 16 or later
*   Safari version 11.1 or later

## {{site.data.reuse.long_name}} command line interface

The {{site.data.reuse.long_name}} command line interface (CLI) is supported on the following systems:

*   Windows 10 or later
*   Linux® Ubuntu 16.04 or later
*   macOS 10.13 (High Sierra) or later

## Clients

{{site.data.reuse.long_name}} is supported for use with clients running Apache Kafka version 2.0 or later.

The Kafka Java client shipped with {{site.data.reuse.long_name}} is supported for use with the following Java versions:

*   IBM Java 8
*   Oracle Java 8
