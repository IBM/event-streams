---
title: "Unable to find Kafka Exporter metrics in Prometheus"
excerpt: "Kafka Exporter metrics are not available in Prometheus"
categories: troubleshooting
slug: kafkaexporter-error
toc: true
---

## Symptoms

After enabling the Kafka Exporter in `EventStreams` custom resource, the corresponding metrics that it provides are not available in Prometheus. 

## Causes

Prometheus is unable to receive metrics from Kafka Exporter.

## Resolving the problem

[Upgrade](../../installing/upgrading/) your {{site.data.reuse.short_name}} instance to version 11.1.6 or later to resolve the issue.
