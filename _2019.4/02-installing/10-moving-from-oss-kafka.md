---
title: "Migrating from open-source Apache Kafka to Event Streams"
excerpt: "Learn about the steps required to move from an open-source Kafka implementation to using Event Streams."
categories: installing
slug: moving-from-oss-kafka
layout: redirects
toc: true
---

If you are using open-source Apache Kafka as your event-streaming platform, you can move to {{site.data.reuse.long_name}} and [benefit](../../about/overview/) from its features and enterprise-level support. The main difference is that {{site.data.reuse.short_name}} requires connections to be secured.

## Prerequisites

Ensure you have an {{site.data.reuse.short_name}} deployment available. See the instructions for installing on [{{site.data.reuse.icp}}](../../installing/installing/), or the instructions for installing on [{{site.data.reuse.openshift_short}}](../../installing/installing-openshift).

For many of the tasks, you can use the [Kafka console tools](https://kafka.apache.org/quickstart){:target="_blank"}. Many of the console tools work with {{site.data.reuse.short_name}}, as described in the [using console tools](../../getting-started/using-kafka-console-tools/) topic.

## Re-create your topics in {{site.data.reuse.short_name}}

In {{site.data.reuse.short_name}}, re-create your existing topics from your open-source Kafka cluster.

To list your existing topics and configurations, run the following Kafka console tool:

`./kafka-topics.sh --bootstrap-server <host>:<port> --describe`

A list of all your topics is displayed. Re-create each topic in {{site.data.reuse.short_name}} by using the UI or the CLI.

### Using the UI

1. {{site.data.reuse.es_ui_login}}
2. Click **Topics** in the primary navigation.
3. Follow the instructions to create the topic. Ensure you set the same partition and replica settings, as well as any other non-default settings, as you have set for the existing topic in your open source Kafka instance.
4. Repeat for each topic you have in your open source Kafka instance.

### Using the CLI

1. {{site.data.reuse.icp_cli_login321}}
2. Run the following command to initialize the {{site.data.reuse.short_name}} CLI on the destination cluster:

   `cloudctl es init`

3. Run the following command to create a topic:

   `cloudctl es topic-create --name <topic_name> --partitions <number_of_partitions> --replication-factor <number_of_replicas>`

    Ensure you set the same partition and replica settings, as well as any other non-default settings, as you have set for the existing topic in your open source Kafka instance.
4. Repeat for each topic you have in your open-source Kafka cluster.

## Change producer configuration

Change the configuration for applications that produce messages to your open-source Kafka cluster to connect to {{site.data.reuse.short_name}} instead as described in [securing the connections](../../getting-started/client/#securing-the-connection).

If you are using the Kafka console tools, see the instructions for the example console producer in [using the console tools](../../getting-started/using-kafka-console-tools/#using-the-console-tools-with-ibm-event-streams) to change where the messages are produced to.

## Change consumer configuration

Change the configuration for applications that consume messages from your open-source Kafka cluster to connect to {{site.data.reuse.short_name}} instead as described in [securing the connections](../../getting-started/client/#securing-the-connection).

If you are using the Kafka console tools, see the instructions for the example console consumer in [using the console tools](../../getting-started/using-kafka-console-tools/#using-the-console-tools-with-ibm-event-streams) to change where messages are consumed from.
