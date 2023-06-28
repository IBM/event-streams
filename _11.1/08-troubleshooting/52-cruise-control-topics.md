---
title: "KafkaRebalance custom resource remains in PendingProposal state"
excerpt: "KafkaRebalance custom resource remains in PendingProposal state due to incorrect Cruise Control topic configuration."
categories: troubleshooting
slug: kafkarebalance-pendingproposal
layout: redirects
toc: true
---

## Symptoms

A `KafkaRebalance` custom resource remains in the `PendingProposal` state, does not move to the `ProposalReady` state, and does not populate the `status.optimizationResult` property. The Cruise Control pod logs contain the following error:
```
2023-04-13 10:55:09 ERROR KafkaCruiseControlRequestHandler:88 - Error processing POST request '/rebalance' due to: 
'com.linkedin.kafka.cruisecontrol.exception.KafkaCruiseControlException: com.linkedin.cruisecontrol.exception.NotEnoughValidWindowsException: 
There is no window available in range [-1, 1681383309158] (index [1, -1]). Window index (current: 0, oldest: 0).'.
java.util.concurrent.ExecutionException: com.linkedin.kafka.cruisecontrol.exception.KafkaCruiseControlException: 
com.linkedin.cruisecontrol.exception.NotEnoughValidWindowsException: 
There is no window available in range [-1, 1681383309158] (index [1, -1]). Window index (current: 0, oldest: 0).
at java.util.concurrent.CompletableFuture.reportGet(CompletableFuture.java:396) ~[?:?]
Caused by: com.linkedin.kafka.cruisecontrol.exception.KafkaCruiseControlException: com.linkedin.cruisecontrol.exception.NotEnoughValidWindowsException:
There is no window available in range [-1, 1681383309158] (index [1, -1]). Window index (current: 0, oldest: 0).

```

## Causes

Cruise Control uses Kafka topics to store and process the metrics used to generate the optimization proposal. This error occurs because the default Cruise Control topic names are incorrectly set by the {{site.data.reuse.short_name}} operator.

## Resolving the problem

To set the correct topic names to be used by Cruise Control, add the following configuration to the `spec.strimziOverrides.cruiseControl.config` field in the `EventStreams` custom resource:

```
spec:
  strimziOverrides:
    cruiseControl:
      config:
        metric.reporter.topic: "eventstreams.cruisecontrol.metrics"
        broker.metric.sample.store.topic: "eventstreams.cruisecontrol.modeltrainingsamples"
        partition.metric.sample.store.topic: "eventstreams.cruisecontrol.partitionmetricsamples"
```

