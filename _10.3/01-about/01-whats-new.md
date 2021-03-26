---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 10.3.0.

## Reduced footprint of lightweight sample

The lightweight without security [sample](../../installing/planning/#development-deployments) does not request the following {{site.data.reuse.icpfs}} by default:
- IAM
- Monitoring Exporters
- Monitoring Grafana
- Monitoring Prometheus Ext

This reduces the minimum resources required for {{site.data.reuse.fs}}.

## Support for {{site.data.reuse.openshift}} 4.6.8 and later

{{site.data.reuse.short_name}} version 10.3.0 introduces support for {{site.data.reuse.openshift}} version 4.6.8 and later.

## Deprecation of Event Streams

The Event Streams component in IBM Cloud Pak for Integration 2021.1.1 and later has been deprecated. Event Streams will continue to be supported but will no longer be enhanced (see [announcement](https://www-01.ibm.com/common/ssi/ShowDoc.wss?docURL=/common/ssi/rep_ca/2/877/ENUSZP21-0082/index.html){:target="_blank"}). For self-managed software solutions that require Apache Kafka, IBM recommends the Confluent Platform available as an add-on for Cloud Pak for Integration.

This deprecation does not apply to the managed service of [{{site.data.reuse.long_name}} on IBM Cloud](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-getting_started#getting_started){:target="_blank"}.
