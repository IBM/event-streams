---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 10.1.0.

## Apicurio Registry

{{site.data.reuse.short_name}} version 10.1.0 includes the open-source [Apicurio Registry](https://www.apicur.io/registry/docs/apicurio-registry/index.html){:target="_blank"} for managing [schemas](../../schemas/overview/).

The {{site.data.reuse.short_name}} schema registry provided in earlier versions is deprecated in version 10.1.0 and later. If you are upgrading to {{site.data.reuse.short_name}} version 10.1.0 from an earlier version, you can [migrate](../../installing/migrating-to-apicurio/) to the Apicurio Registry from the deprecated schema registry.

## Support for Linux on IBM Z

In addition to Linux® 64-bit (x86_64) systems, {{site.data.reuse.short_name}} 10.1.0 is also [supported]({{ 'support/#support-matrix' | relative_url }}) on Linux on IBM® Z systems.

## Kafka version upgraded to 2.6.0

{{site.data.reuse.short_name}} version 10.1.0 includes Kafka release 2.6.0, and supports the use of all Kafka interfaces.

## Default resource requirements have changed

The minimum footprint for {{site.data.reuse.short_name}} has been reduced. See the updated tables for the [resource requirements](../../installing/prerequisites/#resource-requirements).

## Support for Cruise Control

{{site.data.reuse.short_name}} supports the deployment and use of [Cruise Control](https://strimzi.io/docs/operators/master/using.html#cruise-control-concepts-str){:target="_blank"}.
Use Cruise Control to optimize your Kafka brokers by rebalancing the Kafka cluster based on a set of defined goals.
[Find out more](../../administering/cruise-control/) about Cruise Control with {{site.data.reuse.short_name}}.
