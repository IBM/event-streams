---
title: "Setting up geo-replication"
excerpt: "Set up geo-replication for your clusters."
categories: georeplication
slug: setting-up
layout: redirects
toc: true
---

You can set up geo-replication using the {{site.data.reuse.long_name}} UI or CLI. You can then switch your applications to use another cluster when needed.

Ensure you [plan for geo-replication](../planning/) before setting it up.

## Defining destination clusters

To be able to replicate topics, you must define destination clusters. The process involves logging in to your intended destination cluster and copying its connection details to the clipboard. You then log in to the origin cluster and use the connection details to point to the intended destination cluster and define it as a possible target for your geo-replication.

### Using the UI

1. Log in to your destination {{site.data.reuse.long_name}} cluster as an administrator.
2. Click **Topics** in the primary navigation and then click **Geo-replication**.
3. Click the **Origin locations** tab, and click **Generate connection information for this cluster**.
4. Copy the connection information to the clipboard. This information is what you need to specify the cluster as a destination for replication when you log in to your origin cluster.\\
    **Note:** This information includes the security credentials for your destination cluster, which is then used by your origin cluster to authenticate with the destination.
5. Log in to your origin {{site.data.reuse.long_name}} cluster as an administrator.
6. Click **Topics** in the primary navigation and then click **Geo-replication**.
7. Click **Add destination cluster** on the **Destination location** tab.
8. Paste the information you copied in step 4, wait for the validation of your payload to complete and click **Connect cluster**.\\
   The cluster is added as a destination to where you can replicate topics to.\\
   {{site.data.reuse.replicator_origin_list}}

Alternatively, you can also use the following steps:

1. Log in to your destination {{site.data.reuse.long_name}} cluster as an administrator.
2. Click **Connect to this cluster** on the right, and then go to the **Geo-replication** tab.
3. Click the **I want this cluster to be able to receive topics from another cluster** tile.
4. Copy the connection information to the clipboard. This information is what you need to specify the cluster as a destination for replication when you log in to your origin cluster.\\
    **Note:** This step includes the security credentials for your destination cluster which is then used by your origin cluster to authenticate.
5. Log in to your origin {{site.data.reuse.long_name}} cluster as an administrator.
6. Click **Connect to this cluster** on the right, and then go to the **Geo-replication** tab.
7. Click **I want to replicate topics from this cluster to another cluster**.
8. Paste the information you copied in step 4, wait for the validation of your payload to complete and click **Connect cluster**.\\
   The cluster is added as a destination to where you can replicate topics to.\\
   {{site.data.reuse.replicator_origin_list}}


### Using the CLI

{{site.data.reuse.openshift_only_note}}

1. Go to your destination cluster. {{site.data.reuse.cp_cli_login}}
2. {{site.data.reuse.es_cli_init}}
3. Run the following command to display the connection details for your destination cluster:\\
   `cloudctl es geo-cluster-connect`\\
    The command returns a base64 encoded string consisting of the API URL and the security credentials required for creating a destination cluster that should be used to configure geo-replication using the CLI.  If the connection details are to be used to configure geo-replication using the UI, add the `--json` option to return a JSON-formatted string.
4. Go to your origin cluster. {{site.data.reuse.cp_cli_login}}
5. {{site.data.reuse.es_cli_init}}
6. Run the following command to add the cluster as a destination to where you can replicate your topics to:\\
   `cloudctl es geo-cluster-add  --cluster-connect <base64-encoded-string-from-step-3>`


## Specifying what and where to replicate

To select the topics you want to replicate and set the destination cluster to replicate to, use the following steps.

### Using the UI

1. Log in to your origin {{site.data.reuse.long_name}} cluster as an administrator.
2. Click **Topics** in the primary navigation and then click **Geo-replication**.
3. Choose a destination cluster to replicate to by clicking the name of the cluster from the **Destination locations** list.
4. Choose the topics you want to replicate by selecting the checkbox next to each, and click **Geo-replicate to destination**.\\
   **Tip:** You can also click the ![Add topic to geo-replication icon]({{ 'images' | relative_url }}/add_to_georeplication_icon.png "Add to geo-replication icon that is displayed in each topic row.") icon in the topic's row to add it to the destination cluster. The icon turns into a **Remove** button, and the topic is added to the list of topics that are geo-replicated to the destination cluster.

   **Note:** A prefix of the origin cluster name will be added to the name of the new replicated topic that is created on the destination cluster, resulting in replicated topics named such as `<origin-cluster>.<topic-name>`.

   Message history is included in geo-replication. This means all available message data for the topic is copied. The amount of history is determined by the message retention options set when the topics were created on the origin cluster.
5. Click **Create** to create a geo-replicator for the selected topics on the chosen destination cluster. Geo-replication starts automatically when the geo-replicator for the selected topics is set up successfully.\\
   **Note:** After clicking **Create**, it might take up to 5 to 10 minutes before geo-replication becomes active.

For each topic that has geo-replication set up, a visual indicator is shown in the topic's row. If topics are being replicated from the cluster you are logged in to, the **Geo-replication** column displays the number of clusters the topic is being replicated to. Clicking the column for the topic expands the row to show details about the geo-replication for the topic. You can then click **View** to see more details about the geo-replicated topic in the side panel:\\
  ![Geo-replication for topic on origin]({{ 'images' | relative_url }}/georeplication_onorigin_detail_201941.png "Screen capture showing geo-replication detail after expanding row by clicking icon for topics that have geo-replication set up from the cluster you are logged into.")

### Using the CLI

{{site.data.reuse.openshift_only_note}}

To set up replication by using the CLI:

1. Go to your origin cluster. {{site.data.reuse.cp_cli_login}}
2. {{site.data.reuse.es_cli_init}}
3. Choose a destination cluster to replicate to by listing all available destination clusters, making the ID of the clusters available to select and copy: `cloudctl es geo-clusters`
4. Choose the topics you want to replicate by listing your topics, making their names available to select and copy: `cloudctl es topics`
5. Specify the destination cluster to replicate to, and set the topics you want to replicate. Use the required destination cluster ID and topic names retrieved in the previous steps. List each topic you want to replicate by using a comma-separated list without spaces in between:\\
   `cloudctl es geo-replicator-create --destination <cluster-ID-from-step-3> --topics <comma-separated-list-of-topic-names-from-step-4>`\\
   Geo-replication starts automatically when the geo-replicator for the selected topics is set up successfully.

**Note:** A prefix of the origin cluster name will be added to the name of the new replicated topic that is created on the destination cluster, resulting in replicated topics named such as `<origin-cluster>.<topic-name>`.

Message history is included in geo-replication. This means all available message data for the topic is copied. The amount of history is determined by the message retention option set when the topics were created on the origin cluster.

## Considerations

{{site.data.reuse.long_name}} geo-replication uses Kafka's MirrorMaker 2.0 to replicate data from the origin cluster to the destination cluster.

### Replication Factor

{{site.data.reuse.long_name}} sets the number of replicas of geo-replicated topics to 3, or if there are fewer brokers available then to the number of brokers in the destination cluster.

If a different number of replicas are required on the destination topic, edit the value of the sourceConnector configuration property replication.factor on the MirrorMaker2 instance that is created by {{site.data.reuse.short_name}} for the geo-replication pairing. The change will apply to all new topics created by the geo-replicator on the destination cluster after the changes is made. It will not be applied to topics already configured for geo-replication.

### Topic configuration

MirrorMaker 2.0 has a list of topic properties that are not copied from the source cluster topic:

* `follower.replication.throttled.replicas`
* `leader.replication.throttled.replicas`
* `message.timestamp.difference.max.ms`
* `message.timestamp.type`
* `unclean.leader.election.enable`
* `min.insync.replicas`

It is not possible to override the value of these properties using MirrorMaker 2.0 configuration, instead the values are taken from the settings of the destination cluster.

To query the current values set on the destination cluster:

{{site.data.reuse.openshift_only_note}}

1. Go to your destination cluster. {{site.data.reuse.cp_cli_login}}
2. {{site.data.reuse.es_cli_init}}
3. List the broker configuration by using `cloudctl es broker 0`
4. Update the [broker configuration](../../installing/configuring/#applying-kafka-broker-configuration-settings) to set these properties to the values if required before configuring geo-replication.
