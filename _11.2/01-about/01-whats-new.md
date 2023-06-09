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

In addition to the existing support for the {{site.data.reuse.openshift}}, {{site.data.reuse.short_name}} version 11.2.0 introduces [support]({{ 'support/#support-matrix' | relative_url }}) for [installing](../../installing/installing-on-kubernetes/) on other Kubernetes platforms that support the Red Hat Universal Base Images (UBI) containers.

### {{site.data.reuse.icpfs}} is optional on {{site.data.reuse.openshift}}

{{site.data.reuse.short_name}} 11.2.0 introduces support to run on {{site.data.reuse.openshift}} without requiring {{site.data.reuse.icpfs}}.

### Requirement for setting license ID 

{{site.data.reuse.short_name}} 11.2.0 introduces the requirement to set a license ID (`spec.license.license`) that must be set correctly when [creating an instance]({{ 'installpagedivert' | relative_url }}) of {{site.data.reuse.short_name}}. For more information, see [planning](../installing/planning#license-usage).

### Support for `StrimziPodSets`

In {{site.data.reuse.short_name}} 11.2.0 and later, `StatefulSets` are replaced by `StrimziPodSets` to manage Kafka and Zookeeper related pods.

### Support for JMXTrans removed

{{site.data.reuse.short_name}} release 11.2.0 and later do not support JMXTrans, as the JMXTrans tool is no longer maintained. For more information, see the [Strimzi proposal](https://github.com/strimzi/proposals/blob/main/043-deprecate-and-remove-jmxtrans.md){:target="_blank"} about deprecating JMXTrans.

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.2.0 contains security and bug fixes.

### CASE bundle version is 3.2.0

The CASE bundle version of {{site.data.reuse.short_name}} release 11.2.0 is aligned to the operator version: 3.2.0.
