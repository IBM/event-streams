---
title: "Partition leadership"
excerpt: "Each partition has one server in the cluster that acts as the partition's leader and other servers that act as the followers."
categories: about
slug: partition-leadership
toc: false
---

Each partition has one server in the cluster that acts as the partition's leader and other servers that act as the followers. All produce and consume requests for the partition are handled by the leader. The followers replicate the partition data from the leader with the aim of keeping up with the leader. If a follower is keeping up with the leader of a partition, the follower\'s replica is in-sync.

When a message is sent to the partition leader, that message is not immediately available to consumers. The leader appends the record for the message to the partition, assigning it the next offset number for that partition. After all the followers for the in-sync replicas have replicated the record and acknowledged that they\'ve written the record to their replicas, the record is now *committed*. The message is available for consumers.

If the leader for a partition fails, one of the followers with an in-sync replica automatically takes over as the partition\'s leader. In practice, every server is the leader for some partitions and the follower for others. The leadership of partitions is dynamic and changes as servers come and go.

Applications do not need to take specific actions to handle the change in the leadership of a partition. The Kafka client library automatically reconnects to the new leader, although you will see increased latency while the cluster settles.

To learn more, see the following information:

-   [Producing messages](../producing-messages)
-   [Consuming messages](../consuming-messages)
-   [Apache Kafka documentation](http://kafka.apache.org/documentation.html){:target="_blank"}
