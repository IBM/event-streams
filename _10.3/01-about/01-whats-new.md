---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
layout: redirects
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 10.3.x.

## Release 10.3.1

### Move to IBM Container Registry 

All images for {{site.data.reuse.short_name}}, including the latest 10.3.1 release, are available in the [IBM Cloud Container Registry](https://icr.io). Images for earlier releases than 10.3.1 are also available in the [Docker Container Registry](https://docker.io).

### Support for {{site.data.reuse.openshift}} 4.8

{{site.data.reuse.short_name}} 10.3.1 introduces support for {{site.data.reuse.openshift}} 4.8.

### Kafka version upgraded to 2.6.2

{{site.data.reuse.short_name}} version 10.3.1 includes Kafka release 2.5.2, and supports the use of all Kafka interfaces.

### Documentation: Highlighting differences between versions

Any difference in features or behavior introduced by {{site.data.reuse.short_name}} 10.3.1 compared to 10.3.0 or earlier is highlighted in this documentation by using the following graphic: ![Event Streams 10.3.1 icon]({{ 'images' | relative_url }}/10.3.1.svg "In Event Streams 10.3.1.")

## Release 10.3.0

### Reduced footprint of lightweight sample

The lightweight without security [sample](../../installing/planning/#development-deployments) does not request the following {{site.data.reuse.icpfs}} by default:
- IAM
- Monitoring Exporters
- Monitoring Grafana
- Monitoring Prometheus Ext

This reduces the minimum resources required for {{site.data.reuse.fs}}.

### Support for {{site.data.reuse.openshift}} 4.6.8 and later

{{site.data.reuse.short_name}} version 10.3.0 introduces support for {{site.data.reuse.openshift}} version 4.6.8 and later.
