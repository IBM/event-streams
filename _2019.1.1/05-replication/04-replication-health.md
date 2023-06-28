---
title: "Monitoring and managing geo-replication"
excerpt: "Check the status of your geo-replication."
categories: georeplication
slug: health
layout: redirects
toc: true
---
When you have geo-replication set up, you can monitor and manage your geo-replication, such as checking the status of your geo-replicators, pausing and resuming the copying of data for each topic, removing replicated topics from destination clusters, and so on.

## From a destination cluster

You can check the status of your geo-replication and manage geo-replicators (such as pause and resume) on your destination cluster.

You can view the following information for geo-replication on a destination cluster:

* The total number of origin clusters that have topics being replicated to the destination cluster you are logged into.
* The total number of topics being geo-replicated to the destination cluster you are logged into.
* Information about each origin cluster that has geo-replication set up on the destination cluster you are logged into:
    - The cluster name that includes the helm release name.
    - The health of the geo-replication for that origin cluster: **CREATING**, **PAUSED**, **STOPPING**, **ASSIGNING**, **OFFLINE**, and **ERROR**.
    - Number of topics replicated from each origin cluster.

**Tip:** As your cluster can be used as a destination for more than one origin cluster and their replicated topics, this information is useful to understand the status of all geo-replicators running on the cluster.

### Using the UI

To view this information on the destination cluster by using the UI:
1. Log in to your destination {{site.data.reuse.long_name}} cluster as an administrator.
2. Click the **Topics** tab and then click **Geo-replication**.
3. See details in the **Origin locations** section.

To manage geo-replication on the destination cluster by using the UI:
1. Log in to your destination {{site.data.reuse.long_name}} cluster as an administrator.
2. Click the **Topics** tab and then click **Geo-replication**.
3. Locate the name of the origin cluster for which you want to manage geo-replication for, and choose from one of the following options:
    - ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Pause running replicators**: To pause geo-replication and suspend copying of data from the origin cluster.
    - ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Resume paused replicators**: To resume geo-replication from the origin cluster.
    - ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Restart failed replicators**: To restart geo-replication from the origin cluster for geo-replicators that experienced problems.
    - ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Stop replication**: To stop geo-replication from the origin cluster.\\
      **Important:** Stopping replication also removes the origin cluster from the list.

**Note**: You cannot perform these actions on the destination cluster by using the CLI.

## From an origin cluster

On the origin cluster, you can check the status of all of your destination clusters, and drill down into more detail about each destination.

You can also manage geo-replicators (such as pause and resume), and remove entire destination clusters as a target for geo-replication. You can also add topics to geo-replicate.

You can view the following high-level information for geo-replication on an origin cluster:

* The name of each destination cluster.
* The total number of topics being geo-replicated to all destination clusters from the origin cluster you are logged into.
* The total number of workers running for the destination cluster you are geo-replicating topics to.

You can view more detailed information about each destination cluster after they are set up and running like:

* The topics that are being geo-replicated to the destination cluster.
* The health status of the geo-replication on each destination cluster: **RUNNING**, **RESUME**, **RESUMING**, **PAUSING**, **REMOVING**, and **ERROR**. When the status is **ERROR**, the cause of the problem is also provided to aid resolution.

### Using the UI

To view this information on the origin cluster by using the UI:
1. Log in to your origin {{site.data.reuse.long_name}} cluster as an administrator.
2. Click the **Topics** tab and then click **Geo-replication**.
3. See the section **Destination locations**.

To manage geo-replication on the origin cluster by using the UI:
1. Log in to your origin {{site.data.reuse.long_name}} cluster as an administrator.
2. Click the **Topics** tab and then click **Geo-replication**.
3. Locate the name of the destination cluster for which you want to manage geo-replication, and choose from one of the following options:
    - ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Pause running replicator**: To pause a geo-replicator and suspend copying of data to the destination cluster.
    - **Resume** button: To resume a geo-replicator for the destination cluster.
    - ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Restart failed replicator**: To restart a geo-replicator that experienced problems.
    - ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Remove replicator**: To remove a geo-replicator from the destination cluster.

You can take the same actions for all of the geo-replicators in a destination cluster using the ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options** menu in the top right when browsing  destination cluster details (for example, pausing all geo-replicators or removing the whole cluster as a destination).

### Using the CLI

To view this information on the origin cluster by using the CLI:
1. Go to your origin cluster. {{site.data.reuse.icp_cli_login}}
2. Run the following command to start the {{site.data.reuse.long_name}} CLI: `cloudctl es init`
3. Retrieve destination cluster IDs by using the following command:\\
   `cloudctl es geo-clusters`
4. Retrieve information about a destination cluster by running the following command and copying the required destination cluster ID from the previous step:\\
   `cloudctl es geo-cluster --destination <destination-cluster-id>`\\
   For example:\\
   `cloudctl es geo-cluster --destination siliconvalley_es_byl6x`\\
   The command returns the following information:
   ```
   Details of destination cluster siliconvalley_es_byl6x
   Cluster ID               Cluster name    REST API URL                 Skip SSL validation?
   destination_byl6x        destination     https://9.30.119.223:31764   true

   Geo-replicator details
   Name                               Status    Origin bootstrap servers   Origin topic   Destination topic
   topic1__to__origin_topic1_evzoo    RUNNING   192.0.2.24:32237           topic1         origin_topic1
   topic2__to__topic2_vdpr0           PAUSED    192.0.2.24:32237           topic2         topic2
   topic3__to__topic3_9jc71           ERROR     192.0.2.24:32237           topic3         topic3
   topic4__to__topic4_nk87o           PENDING   192.0.2.24:32237           topic4         topic4
   ```

To manage geo-replication on the origin cluster by using the CLI:
1. Go to your origin cluster. {{site.data.reuse.icp_cli_login}}
2. Run the following command to start the {{site.data.reuse.long_name}} CLI: `cloudctl es init`
3. Run the following commands as required:
  - `cloudctl es geo-replicator-pause --destination <destination-cluster-id> --name <replicator-name>`
  - `cloudctl es geo-replicator-resume --destination <destination-cluster-id> --name <replicator-name>`
  - `cloudctl es geo-replicator-restart --destination <destination-cluster-id> --name <replicator-name>`
  - `cloudctl es geo-replicator-delete --destination <destination-cluster-id> --name <replicator-name>`
  - You can also remove a cluster as a destination using the following command:\\
     `cloudctl es geo-cluster-remove --destination <destination-cluster-id>`\\
     **Note:** If you are unable to remove a destination cluster due to technical issues, you can use the `--force` option with the `geo-cluster-remove` command to remove the cluster.

{{site.data.reuse.cli_options_short}}

## Restarting a geo-replicator with Error status

Running geo-replicators constantly consume from origin clusters and produce to destination clusters. If the geo-replicator receives an error from Kafka that prevents it from continuing to produce or consume, such as an authentication error or all brokers being unavailable, it will stop replicating and report a status of **Error**.

To restart a geo-replicator that has an **Error** status from the UI:
1. Log in to your origin {{site.data.reuse.long_name}} cluster as an administrator.
2. Click the **Topics** tab and then click **Geo-replication**.
3. Locate the name of the destination cluster for the geo-replicator that has an **Error** status.
4. Locate the reason for the **Error** status under the entry for the geo-replicator.
5. Either fix the reported problem with the system or verify that the problem is no longer present.
6. Select ![More options icon](../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Restart failed replicator** to restart the geo-replicator.
