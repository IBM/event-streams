---
title: "Preparing for multizone clusters"
excerpt: "Prepare for installing your Event Streams on multizone clusters."
categories: installing
slug: preparing-multizone
layout: redirects
toc: true
---

{{site.data.reuse.short_name}} supports [multiple availability zones](../planning/#multizone-support) for your clusters. Multizone clusters add resilience to your  {{site.data.reuse.short_name}} installation.

For guidance about handling outages in a multizone setup, see [managing a multizone setup](../../administering/managing-multizone/).

## Installing as Team Administrator

If you are installing as a Team Administrator, a Cluster Administrator first must download and run the Cluster Role setup script as follows.

   1. {{site.data.reuse.icp_cli_login321}}
   2. Download the files from [GitHub](https://github.com/IBM/charts/tree/master/stable/ibm-eventstreams-dev/ibm_cloud_pak/pak_extensions/pre-install){:target="_blank"}.
   3. Change to the location where you downloaded the files, and run the setup script as follows:

       `./node-cluster-role.sh <namespace> <release-name>`

       Where `<namespace>` is the namespace you created for your {{site.data.reuse.short_name}} installation earlier and `<release_name>` is the name of the release the Team Admin is planning on installing as.

       This script sets the required Cluster Role and Cluster Rolebinding for the Team Administrator role.

   4. Ensure you clear the **Generate cluster roles** checkbox when [configuring](../configuring/#installing-into-a-multizone-cluster) your {{site.data.reuse.short_name}} installation.

## Checking if your cluster is zone aware

To determine if your cluster is zone aware, run the following command as Cluster Administrator:

`kubectl get nodes --show-labels`

- If your cluster is zone aware, the following label is displayed as a result: `failure-domain.beta.kubernetes.io/zone`\\
   The value of the label will be the zone the node is in, for example, `us-west1`. If your cluster is zone aware and you want to use multiple availability zones, specify the number of zones when [configuring](../configuring/#installing-into-a-multizone-cluster) your installation. Your zones are automatically set up during installation.
- If your cluster is not zone aware, the zone label mentioned earlier is not displayed. In such cases, prepare your clusters as described in [setting up non-zone-aware clusters](#setting-up-non-zone-aware-clusters).

## Setting up non-zone-aware clusters

If your Kubernetes cluster is not zone aware, you can still set up multiple availability zones as follows.

1. Label the nodes in your cluster with `failure-domain.beta.kubernetes.io/zone`, and set the value to a value of your choice. Run the following command to label your nodes, for example, to allocate a node to `es-zone-1`:

   `kubectl label node <node-name> failure-domain.beta.kubernetes.io/zone=es-zone-1`

   You will need to provide these labels in the [**Zone labels**](../configuring/#global-install-settings) field when installing {{site.data.reuse.short_name}}. This is required to distribute the resources equally across the zones in a similar way to a zone-aware cluster by setting the node affinity rules on the resources.

2. Distribute the 3 ZooKeeper pods across the zones by dedicating a node in each zone to a ZooKeeper pod. You do this by adding a label to the selected node in each zone as follows:

   `kubectl label node <node-name> node-role.kubernetes.io/zk=true`

3. Distribute the Kafka broker pods as evenly as possible across the zones by dedicating a node in each zone to a Kafka pod. You do this by adding a label to the selected node in each zone as follows:

   `kubectl label node <node-name> node-role.kubernetes.io/kafka=true`

   **Note:** You need to do this for each Kafka broker. For example, if you have 3 brokers and 3 availability zones, then label 1 node in each zone; if you have 6 brokers and 3 availability zones, then label 2 nodes in each zone.

4. Set up the availability zones when configuring your {{site.data.reuse.short_name}} installation as described in [configuring](../configuring/#installing-into-a-multizone-cluster).
