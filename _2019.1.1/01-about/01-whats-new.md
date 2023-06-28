---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
layout: redirects
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 2019.1.1.


## Support for {{site.data.reuse.openshift}}

{{site.data.reuse.short_name}} 2019.1.1 is [supported](../../installing/prerequisites/#container-environment) on {{site.data.reuse.openshift}} 3.9 and 3.10.

## Support for {{site.data.reuse.icp}} version 3.1.2

In addition to {{site.data.reuse.icp}} 3.1.1, {{site.data.reuse.short_name}} 2019.1.1 is also [supported](../../installing/prerequisites/#container-environment) on {{site.data.reuse.icp}} 3.1.2.

## New REST interface for sending event data to {{site.data.reuse.short_name}}

{{site.data.reuse.short_name}} provides a [producer API](../../connecting/rest-api/) to help connect your existing systems to your {{site.data.reuse.short_name}} Kafka cluster, and produce messages to {{site.data.reuse.short_name}} over a secure HTTP endpoint.

## Connect external monitoring tools to {{site.data.reuse.short_name}}

You can use third-party monitoring tools to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster. Find out more about monitoring with [external tools](../../administering/external-monitoring/).

## New Producer dashboard

A new dashboard has been added to help monitor the health of your topics. The [**Producer** dashboard](../../administering/topic-health/) provides information about producer activity for a selected topic.

## Kafka version upgraded to 2.1.1

{{site.data.reuse.short_name}} 2019.1.1 uses the Kafka 2.1.1 release. If you are upgrading from a previous version of {{site.data.reuse.short_name}}, follow the [post-upgrade tasks](../../installing/upgrading/#post-upgrade-tasks) to upgrade your Kafka version.

## Default resource requirements have changed.

See the updated tables for the {{site.data.reuse.short_name}} [resource requirements](../../installing/prerequisites/#helm-resource-requirements).
