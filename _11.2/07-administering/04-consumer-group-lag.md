---
title: "Monitoring Kafka consumer group lag"
excerpt: "Understand the health of your Kafka consumer clients through monitoring heuristics such as lag."
categories: administering
slug: consumer-lag
layout: redirects
toc: true
---

You can monitor the consumer lag for Kafka clients connecting to {{site.data.reuse.long_name}}. This information is available through both the {{site.data.reuse.short_name}} UI and CLI.

## Consumer lag

Each partition will have a consumer within a consumer group with information relating to its consumption as follows:

- **Client ID** and **Consumer ID**: each partition will have exactly one consumer in the consumer group, identifiable by a **Client ID** and **Consumer ID**.
- **Current offset**: the last committed offset of the consumer.
- **Log end offset**: the highest offset of the partition.
- **Offset lag**: the difference between the current consumer offset and the highest offset, which shows how far behind the consumer is.

### Using the {{site.data.reuse.short_name}} UI

To access the consumer groups side panel in the {{site.data.reuse.short_name}} UI, do the following:

1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click **Topics** in the primary navigation.
3. Locate your topic using the **Name** column and click the row for the topic.
4. Click the **Consumer groups** tab.
5. The **Consumer groups** dashboard will display all consumer groups for the selected topic.
   Click the consumer group of interest from the **Consumer group ID** column.
   The consumer group side panel should now be displayed on screen.

This side panel will display a table containing [consumer group information](#consumer-lag) for each partition of the topic.

### Using the {{site.data.reuse.short_name}} CLI

{{site.data.reuse.openshift_only_note}}

To access information about a consumer group in the {{site.data.reuse.short_name}} CLI, do the following:

1. {{site.data.reuse.es_cli_init_111}}
2. To list all consumer groups on a cluster, run:\\
   `cloudctl es groups`
3. To list information about a consumer group, run:\\
   `cloudctl es group --group <consumer-group-id>`\\
   where `<consumer-group-id>` is the name of the consumer group of interest.

The CLI will print a table containing [consumer group information](#consumer-lag) for each partition of the topic.

The following example shows the information the command returns for a consumer group called `my-consumer`:

```
$ cloudctl es group --group my-consumer
>
Details for consumer group my-consumer
Group ID            State
my-consumer         Stable

Topic      Partition   Current offset   End offset   Offset lag   Client        Consumer        Host
my-topic   2           999              1001         2            some-client   some-consumer   some-host
my-topic   0           1000             1001         1            some-client   some-consumer   some-host
my-topic   1           1000             1000         0            some-client   some-consumer   some-host
OK
```

To view other Kafka-related metrics, consider configuring a [Kafka Exporter](../../installing/configuring/#configuring-the-kafka-exporter).

For information on how to monitor the general health of a particular topic, see [monitoring topic health](../topic-health).
