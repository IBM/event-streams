---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 11.0.0.

## Support for {{site.data.reuse.openshift}} 4.10

{{site.data.reuse.short_name}} 11.0.0 introduces support for {{site.data.reuse.openshift}} 4.10.

## Kafka version upgraded to 3.0.0

{{site.data.reuse.short_name}} version 11.0.0 includes Kafka release 3.0.0, and supports the use of all Kafka interfaces.

## Apicurio version upgraded to 2.2.0

{{site.data.reuse.short_name}} 11.0.0 includes Apicurio Registry version 2.2.0 for [managing schemas](../../schemas/overview/#schema-registry).

## Support for Kafka Bridge

With [Kafka Bridge](../../connecting/kafka-bridge/), you can connect client applications to your {{site.data.reuse.short_name}} cluster over HTTP.

## Support for OAuth

Open Authorization (OAuth) is an open standard for authorization that allows client applications secure delegated access to specified resources. OAuth works over HTTPS and uses access tokens for authorization rather than credentials.


You can [configure OAuth](../../installing/configuring/#enabling-oauth) for {{site.data.reuse.short_name}} to grant access to your Kafka cluster and resources.

## Kafka Proxy added for producer metrics

In {{site.data.reuse.long_name}} version 11.0.0 and later, a Kafka Proxy handles gathering metrics from producing applications. The information is displayed in the [**Producers** dashboard](../../administering/topic-health/). The proxy is optional and is not enabled by default. To enable producer metrics gathering and have the information displayed in the dashboard, [enable the Kafka Proxy](../../installing/configuring/#enabling-collection-of-producer-metrics).

