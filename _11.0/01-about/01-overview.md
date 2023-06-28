---
title: "Introduction"
excerpt: "IBM Event Streams is an event-streaming platform based on the open-source Apache Kafka® project."
categories: about
slug: overview
layout: redirects
toc: true
---



{{site.data.reuse.long_name}} is an event-streaming platform based on the [Apache Kafka®](https://kafka.apache.org/){:target="_blank"} project and incorporates the open-source [Strimzi](https://strimzi.io){:target="_blank"} technology.

- {{site.data.reuse.short_name}} version 11.0.4 includes Kafka release 3.2.0, and supports the use of all Kafka interfaces.
- {{site.data.reuse.short_name}} version 11.0.3 includes Kafka release 3.2.0, and supports the use of all Kafka interfaces.
- {{site.data.reuse.short_name}} version 11.0.2 includes Kafka release 3.2.0, and supports the use of all Kafka interfaces.
- {{site.data.reuse.short_name}} version 11.0.1 includes Kafka release 3.1.0, and supports the use of all Kafka interfaces.
- {{site.data.reuse.short_name}} version 11.0.0 includes Kafka release 3.0.0, and supports the use of all Kafka interfaces.

{{site.data.reuse.long_name}} uses Strimzi to deploy Apache Kafka in a resilient and manageable way, and provides a range of additional capabilities to extend the core functionality.

{{site.data.reuse.long_name}} features include:

- Apache Kafka deployed by Strimzi that distributes Kafka brokers across the nodes of a {{site.data.reuse.openshift}} cluster, creating a highly-available and resilient deployment.

- An administrative user interface (UI) focused on providing essential features for managing production clusters, in addition to enabling developers to get started with Apache Kafka. The {{site.data.reuse.short_name}} UI facilitates topic lifecycle control, message filtering and browsing, client metric analysis, schema and geo-replication management, connection details and credentials generation, and a range of tools, including a sample starter and producer application.

- A command-line interface (CLI) to enable manual and scripted cluster management. For example, you can use the {{site.data.reuse.short_name}} CLI to inspect brokers, manage topics, deploy schemas, and manage geo-replication.

- Geo-replication of topics between clusters to enable disaster recovery.

- A REST API for producing messages to {{site.data.reuse.short_name}} topics, expanding event source possibilities.

- A schema registry to support the definition and enforcement of message formats between producers and consumers. {{site.data.reuse.short_name}} includes the open-source [Apicurio Registry](https://www.apicur.io/registry/docs/apicurio-registry/2.2.x/index.html){:target="_blank"} for managing schemas.

- Health check information to help identify issues with your clusters and brokers.

- Secure by default production cluster templates with authentication, authorization and encryption included, and optional configurations to simplify proof of concept or lite development environments.

- Granular security configuration through Kafka access control lists to configure authorization and quotas for connecting applications.


## Operators

Kubernetes [Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/){:target="_blank"} are designed to simplify the deployment and maintenance of complex applications. They do this by packaging up and abstracting away domain-specific knowledge of how to deploy, configure and operate the application and its component parts. An Operator can then extend Kubernetes by providing new Kubernetes constructs to support these abstractions, simplifying the initial deployment and subsequent lifecycle management of the application.

Strimzi uses Operators in this manner to facilitate the deployment of Kafka clusters. {{site.data.reuse.short_name}} builds on top of Strimzi to deploy not only the Kafka components but also the additional features outlined earlier. A new Kubernetes resource `EventStreams` is provided (in Kubernetes referred to as a "kind"), to allow the definition of a complete deployment that brings together the components provided by Strimzi and {{site.data.reuse.short_name}}. This information is defined in a standard YAML document and deployed in a single operation.


## Operators provided by {{site.data.reuse.short_name}}

The following diagram shows the operators involved in an {{site.data.reuse.short_name}} deployment along with the resources they manage. {{site.data.reuse.short_name}} builds on the Strimzi core, and adds additional components to extend the base capabilities.

![EventStreams Operator diagram.]({{ 'images' | relative_url }}/operator_structure.png "Diagram that shows the operators involved in an {{site.data.reuse.short_name}} deployment.")

### The EventStreams Cluster Operator

The Strimzi Cluster Operator manages the deployment of core components within the Kafka cluster such as Kafka and ZooKeeper nodes.

The EventStreams Cluster Operator extends the Strimzi Cluster Operator to provision the additional components provided by  {{site.data.reuse.short_name}} alongside these core components. A new custom resource Type called `EventStreams` is provided to manage this overall deployment.

### The Entity Operator

Kafka provides authentication and authorization through Users and Access Control Lists. These define the operations that users can perform on specific resources within the cluster.

The User operator provides a new custom resource type called `KafkaUser` to manage these Kafka users and associated Access Control Lists and is a mandatory component of an {{site.data.reuse.short_name}} deployment.

Kafka topics are a resource within the cluster to which a series of records can be produced.

The _optional_ Topic operator provides a new custom resource type called `KafkaTopic` to manage these Kafka topics. By default, the Topic operator is not part of the {{site.data.reuse.short_name}} cluster. Instead, to create and manage Kafka topics, use the {{site.data.reuse.short_name}} UI, CLI and REST API provided mechanisms.

If there is a need to have Kafka topics represented as Kubernetes resources, the _optional_ Topic operator can be included in the EventStreams definition, and will then be deployed as a container alongside the User operator within the Entity operator Pod.
