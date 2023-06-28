---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
layout: redirects
toc: true
---

## Releases 2019.2.2 and 2019.2.3

{{site.data.reuse.long_name}} 2019.2.2 and 2019.2.3 introduce support for the [{{site.data.reuse.cp4i}}](https://www.ibm.com/support/knowledgecenter/SSGT7J_19.3/welcome.html){:target="_blank"} solution. For information about installing {{site.data.reuse.short_name}} as a capability, see the {{site.data.reuse.cp4i}} [documentation](https://www.ibm.com/support/knowledgecenter/SSGT7J_19.3/install/install_event_streams.html){:target="_blank"}.

**Important:** {{site.data.reuse.short_name}} 2019.2.2 and 2019.2.3 are only available as part of the {{site.data.reuse.cp4i}} solution. {{site.data.reuse.short_name}} 2019.2.2 and 2019.2.3 have the same features as the 2019.2.1 release.

## Release 2019.2.1

Find out what is new in {{site.data.reuse.long_name}} version 2019.2.1.

### Schemas and schema registry

{{site.data.reuse.short_name}} now supports [schemas](../../schemas/overview/) to define the structure of message data, and provides an {{site.data.reuse.short_name}} schema registry to manage schemas.

### Connector catalog

{{site.data.reuse.short_name}} includes a [connector catalog](../../../connectors/){:target="_blank"} listing all connectors that have been verified with {{site.data.reuse.short_name}}, including  community-provided connectors and connectors supported by IBM.

### Enhanced support for Kafka Connect

{{site.data.reuse.short_name}} now provides enhanced support for [Kafka Connect](../../connecting/connectors/) to help integrate external systems with your {{site.data.reuse.short_name}} instance.

### TLS encryption for inter-pod communication

You now have the option to encrypt inter-pod communication by using [TLS](../../installing/planning/#securing-communication-between-pods) to enhance security.

### Red Hat Universal Base Image (UBI)

All {{site.data.reuse.long_name}} images are now based on [Red Hat Universal Base Image (UBI) 8](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image){:target="_blank"}.

### Support for IBM Z has changed
Red Hat Universal Base Image (UBI) 8 runs on z13 or later IBM mainframe systems.

### Kafka version upgraded to 2.2.0

{{site.data.reuse.short_name}} version 2019.2.1 includes Kafka release 2.2.0, and supports the use of all Kafka interfaces.

### {{site.data.reuse.ce_long}} available on {{site.data.reuse.openshift}}

You can now [install](../../installing/trying-out/) {{site.data.reuse.ce_long}} on the {{site.data.reuse.openshift}}.

### Support for {{site.data.reuse.icp}} version 3.2.0

In addition to {{site.data.reuse.icp}} 3.1.2, {{site.data.reuse.short_name}} 2019.2.1 is also [supported](../../installing/prerequisites/#container-environment) on {{site.data.reuse.icp}} 3.2.0.

### Default resource requirements have changed.

See the updated tables for the {{site.data.reuse.short_name}} [resource requirements](../../installing/prerequisites/#helm-resource-requirements).
