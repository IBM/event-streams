---
title: "Kafka exporter is not deployed"
excerpt: "When enabling the Kafka exporter the resource is not deployed"
categories: troubleshooting
slug: kafka-exporter-not-deployed
toc: true
---

## Symptoms
When enabling the Kafka exporter (`strimziOverrides.kafkaExporter`), the instance of {{site.data.reuse.short_name}} enters a failed state and the operator logs show failure to reconcile due to a `NullPointerException`. The Kafka exporter is not deployed.

## Causes
The exception is thrown because the operator is accessing incorrect resources when configuring the Kafka exporter.

## Resolving the problem

Contact [IBM Support]({{ 'support' | relative_url }}) to request a fix, and include issue number [ES-151](https://github.com/IBM/event-streams/issues/151){:target="_blank"} in your correspondence.

<!--
When the issue is resolved, update this section to include:
"Resolved in Event Streams x.y.z"
-->
