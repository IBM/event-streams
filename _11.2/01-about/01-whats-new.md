---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 11.2.x.

## Release 11.2.0

### Support for other Kubernetes platforms

In addition to the existing support for the {{site.data.reuse.openshift}}, {{site.data.reuse.short_name}} version 11.2.0 introduces support for [installing](../../installing/installing-on-kubernetes/) on other Kubernetes platforms that support the Red Hat Universal Base Images (UBI) containers.

### {{site.data.reuse.icpfs}} is optional on {{site.data.reuse.openshift}}

{{site.data.reuse.short_name}} 11.2.0 introduces support to run on {{site.data.reuse.openshift}} without requiring {{site.data.reuse.icpfs}}.

### Support for `StrimziPodSets`

In {{site.data.reuse.short_name}} 11.2.0 and later, `StatefulSets` are replaced by `StrimziPodSets` to manage Kafka and Zookeeper related pods.

### Support for JMXTrans removed

{{site.data.reuse.short_name}} release 11.2.0 and later do not support JMXTrans. For more information, see [Strimzi GitHub issue 7692](https://github.com/strimzi/strimzi-kafka-operator/issues/7692){:target="_blank"}.

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.2.0 contains security and bug fixes.

