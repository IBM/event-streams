---
title: "Planning for geo-replication"
permalink: /georeplication/planning/
excerpt: "Plan geo-replication for your clusters."
last_modified_at:
toc: true
---

Consider the following when planning for geo-replication:
- If you want to use the CLI to set up geo-replication, ensure you have the [{{site.data.reuse.long_name}} CLI installed](../../installing/post-installation/#installing-the-cli).
-	[Prepare your destination cluster](#preparing-destination-clusters) by setting the number of geo-replication workers.
- [Identify the topics](../about/#what-to-replicate) you want to create copies of. This depends on the data stored in the topics, its use, and how critical it is to your operations.
-	Decide whether you want to include message history in the geo-replication, or only copy messages from the time of setting up geo-replication. By default, the message history is included in geo-replication. The amount of history is determined by the message retention option set when the topics were created on the origin cluster.
-	Decide whether the replicated topics on the destination cluster should have the same name as their corresponding topics on the origin cluster, or if a prefix should be added to the topic name. The prefix is the release name of the origin cluster. By default, the replicated topics on the destination cluster have the same name.

## Preparing destination clusters

Before you can set up geo-replication and start replicating topics, you must configure the number of geo-replication workers in the destination cluster.

The number of workers depend on the number of topics you want to replicate, and the throughput of the produced messages. You can use the same approach to determine the number as used when [setting the number of brokers](../../installing/planning/#sizing-considerations) for your installation.

For example, you can create a small number of workers at the time of installation. You can then increase the number later if you find that your geo-replication performance is not able to keep up with making copies of all the selected topics as required. Alternatively, you can start with a high number of workers, and then decrease the number if you find that the workers underperform.

**Important:** For high availability reasons, ensure you have at least 2 workers in case one of the workers encounters problems.

You can configure the number of workers at the time of installing {{site.data.reuse.long_name}}, or you can modify an existing installation, even if you already have geo-replication set up and running on that installation.

### Configuring a new installation

If you are installing a new {{site.data.reuse.long_name}} instance for use as a destination cluster, you can specify the number of workers when configuring the installation.

To configure the number of workers at the time of installation, use the UI or the CLI as follows.

#### Using the UI

You have the option to specify the number of workers during the installation process on the [**Configure** page](../../installing/configuring/#setting-geo-replication-nodes). Go to the **Geo-replication** section and specify the number of workers in the **Geo-replicator workers** field.

#### Using the CLI

You have the option to specify the number of workers during the installation process by adding the `--set replicator.replicas=<number-of-workers>` to your `helm install` command.

### Configuring an existing installation

If you decide to use an existing {{site.data.reuse.long_name}} instance as a destination cluster, or want to change the number of workers on an existing instance used as a destination cluster for scaling purposes, you can modify the number of workers by using the UI or CLI as follows.

#### Using the UI (not recommended)

To modify the number of workers by using the UI:
1. {{site.data.reuse.icp_ui_login}} This is where your destination cluster is installed.
2. From the navigation menu, click **Workloads > Helm Releases**.
3. Locate the release name of your existing {{site.data.reuse.long_name}} cluster in the **NAME** column.
4. Click the release name and then click **Upgrade**.
5. Click **All parameters** in order to access all the release-related paramaters
6. Go to the **Geo-replication settings** section and modify the **Geo-replicator workers** field to the required number of workers.
7. Click **Upgrade**.

#### Using the CLI

To modify the number of workers by using the CLI:
1. {{site.data.reuse.icp_cli_login}}
2. Use the following helm command to modify the number of workers:\\
   `helm upgrade --reuse-values --set replicator.replicas=<number-of-workers> <release_name> ibm-eventstreams-prod --tls`\\
   For example:\\
   `helm upgrade --reuse-values --set replicator.replicas=4 destination ibm-eventstreams-prod --tls`
