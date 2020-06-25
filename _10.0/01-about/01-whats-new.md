---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 10.0.0.

## Operator-based release

The [Kubernetes operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/){:target="_blank"} replaces Helm as the method for installing and managing {{site.data.reuse.short_name}}. The {{site.data.reuse.short_name}} operator uses custom resources to manage the required components. The operator can deploy instances of {{site.data.reuse.short_name}} as required, and manage the lifecycle of each instance, including configuration changes and upgrades.

[Find out more](../overview) about {{site.data.reuse.short_name}} and operators.

## New security model

{{site.data.reuse.short_name}} version 10.0 introduces changes to the way security works. The main changes are as follows:

- Support for SCRAM-SHA-512 and Mutual TLS security mechanisms when [connecting Kafka clients](../../getting-started/connecting/#securing-the-connection) to the {{site.data.reuse.short_name}} Cluster.
- Support for [Kafka Access Control Lists](../../security/managing-access/#assigning-access-to-applications) for permissions to Kafka resources.
- Support for insecure cluster installation, for proof of concept or development environments.
- Support for [multiple REST endpoints](../../installing/configuring/#rest-services-access) with configurable security definitions.

## Kafka Connect framework hosted by {{site.data.reuse.short_name}}

The {{site.data.reuse.short_name}} operator now deploys and manages Kafka Connect clusters using the `KafkaConnectS2I` and `KafkaConnector` custom resources.

The `KafkaConnectS2I` custom resource enables users to install new connectors without needing to run local Docker builds. The `KafkaConnector` custom resource provides a Kubernetes-native way to start, pause and stop connectors and tasks.

For more information, see the documentation on creating [Kafka Connect clusters](../../connecting/setting-up-connectors).

## Additional tested connectors

The [connector catalog](../../connectors/){:target="_blank"} now includes additional connectors that are commercially supported for customers with a support entitlement for {{site.data.reuse.cp4i}}:

 - An Elasticsearch sink connector that subscribes to one or more Kafka topics and writes the records to Elasticsearch.
 - Debezium's PostgreSQL source connector that can monitor the row-level changes in the schemas of a PostgreSQL database and record them in separate Kafka topics.
 - Debezium's MySQL source connector that can monitor all of the row-level changes in the databases on a MySQL server or HA MySQL cluster and record them in Kafka topics.

## Geo-replication now uses MirrorMaker2

Kafka Mirror Maker 2 provides the implementation for geo-replication in {{site.data.reuse.long_name}} 10.0.0.

[Find out more](../../georeplication/about/) about {{site.data.reuse.short_name}} geo-replication.

## Support for {{site.data.reuse.openshift}} 4.4

{{site.data.reuse.long_name}} 10.0.0 introduces support for {{site.data.reuse.openshift}} 4.4.

## Kafka version upgraded to 2.5.0

{{site.data.reuse.short_name}} version 10.0.0 includes Kafka release 2.5.0, and supports the use of all Kafka interfaces.

## Default resource requirements have changed

The minimum footprint for {{site.data.reuse.short_name}} has been reduced. See the updated tables for the [resource requirements](../../installing/prerequisites/#resource-requirements).

## Technology Preview features

Technology Preview features are available to evaluate potential upcoming features. Such features are intended for testing purposes only and not for production use. IBM does not support these features, but might help with any issues raised against them. IBM welcomes [feedback](../../support) on Technology Preview features to improve them. As the features are still under development, functions and interfaces can change, and it might not be possible to upgrade when updated versions become available.

IBM offers no guarantee that Technology Preview features will be part of upcoming releases and as such become fully supported.

{{site.data.reuse.short_name}} version 10.0.0 includes [Cruise Control for Apache Kafka](https://github.com/linkedin/cruise-control){:target="_blank"} as a Technology Preview feature.
