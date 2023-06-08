---
title: "Trying out Event Streams"
excerpt: "Install a basic deployment to try out IBM Event Streams."
categories: installing
slug: trying-out
toc: true
---

To try out {{site.data.reuse.short_name}}, you have the following options:

- Create a subscription for a fully managed Kafka service on [IBM Cloud](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-getting-started){:target="_blank"}.
- [Install {{site.data.reuse.long_name}}]({{ 'installpagedivert' | relative_url }}) on a Kubernetes cluster for development purposes or for production use, and benefit from both the support of IBM and the open-source community.

  {{site.data.reuse.short_name}} comes with a host of useful features such as a user interface (UI) to help you get started with Kafka and help operate a production cluster, geo-replication of topics between clusters, a schema registry to enforce correct and consistent message formats, a connector catalog, and more.



- Use [Strimzi](https://strimzi.io){:target="_blank"} if you want to install your own basic Kafka cluster on Kubernetes for testing and proof-of-concept purposes.

   As {{site.data.reuse.short_name}} is based on Strimzi, you can easily move your deployment to {{site.data.reuse.short_name}} later, and keep your existing configurations and preferences from the Strimzi setup. Moving to {{site.data.reuse.short_name}} adds the benefit of full enterprise-level support from IBM.
