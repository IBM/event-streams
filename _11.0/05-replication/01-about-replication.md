---
title: "About geo-replication"
excerpt: "Learn about setting up geo-replication for your clusters."
categories: georeplication
slug: about
layout: redirects
toc: true
---

You can deploy multiple instances of {{site.data.reuse.long_name}} and use the included geo-replication feature to synchronize data between your clusters that are typically located in different geographical locations. The geo-replication feature creates copies of your selected topics to help with disaster recovery.

Geo-replication can help with various service availability scenarios, for example:
* Supporting your disaster recovery plans: you can set up geo-replication to support your disaster recovery architecture, enabling the switching to other clusters if your primary ones experience a problem.
* Making mission-critical data safe: you might have mission-critical data that your applications depend on to provide services. Using the geo-replication feature, you can back up your topics to several destinations to ensure their safety and availability.
* Migrating data: you can ensure your topic data can be moved to another deployment, for example, when switching from a test to a production environment.


## How it works

The Kafka cluster where you have the topics that you want to make copies of is called the "origin cluster".

The Kafka cluster where you want to copy the selected topics to is called the "destination cluster".

So, one cluster is the origin where you want to copy the data from, while the other cluster is the destination where you want to copy the data to.

**Important:** If you are using geo-replication for purposes of availability in the event of a data center outage or disaster, you must ensure that the origin cluster and destination cluster are installed on different systems that are isolated from each other. This ensures that any issues with the origin cluster do not affect the destination cluster.

Any of your {{site.data.reuse.long_name}} clusters can become a destination for geo-replication. At the same time, the origin cluster can also be a destination for topics from other sources.

Geo-replication not only copies the messages of a topic, but also copies the topic configuration, the topic's metadata, its partitions, and even preserves the timestamps from the origin topic.

After geo-replication starts, the topics are kept in sync. If you add a new partition to the origin topic, the geo-replicator adds a partition to the copy of the topic on the destination cluster.

You can set up geo-replication by using the {{site.data.reuse.long_name}} UI or CLI.

## What to replicate

What topics you choose to replicate and how depend on the topic data, whether it is critical to your operations, and how you want to use it.

For example, you might have transaction data for your customers in topics. Such information is critical to your operations to run reliably, so you want to ensure they have back-up copies to switch to when needed. For such critical data, you might consider setting up several copies to ensure availability. One way to do this is to set up geo-replication of 5 topics to one destination cluster, and the next 5 to another destination cluster, assuming you have 10 topics to replicate. Alternatively, you can replicate the same topics to two different destination clusters.

Another example would be storing of website analytics information, such as where users clicked and how many times they did so. Such information is likely to be less important than maintaining availability for your operations, and you might choose not to replicate such topics, or only replicate them to one destination cluster.

When replication is set up and working, you can switch your applications to use another cluster when needed.
