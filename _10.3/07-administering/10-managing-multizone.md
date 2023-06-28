---
title: "Managing a multizone setup"
excerpt: "Find out more about managing multizone clusters, including what to do in the event of a failure."
categories: administering
slug: managing-multizone
layout: redirects
toc: true
---

If you have set up your {{site.data.reuse.short_name}} installation to use [multiple availability zones](../../installing/preparing-multizone/), follow the guidance here if one of your nodes containing Kafka or ZooKeeper experiences problems.

## Topic configuration

Only create Kafka topics where the minimum in-sync replicas configuration can be met in the event of a zone failure. This requires considering the minimum in-sync replicas value in relation to the replication factor set for the topic, and the number of availability zones being used for spreading out your Kafka brokers.

For example, if you have 3 availability zones and 6 Kafka brokers, losing a zone means the loss of 2 brokers. In the event of such a zone failure, the following topic configurations will guarantee that you can continue to produce to and consume from your topics:

- If the replication factor is set to 6, then the suggested minimum in-sync replica is 4.
- If the replication factor is set to 5, then the suggested minimum in-sync replica is 3.

## Updating an existing installation

If you are updating an existing installation, for example, adding a new Kafka broker node or replacing a failing node that contains a Kafka broker, you can [label another node](../../installing/preparing-multizone/#zone-awareness) with the zone label. When the new node label is applied, Kubernetes will then be able to schedule a Kafka broker to run on that node.
