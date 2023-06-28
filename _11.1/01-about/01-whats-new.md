---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
layout: redirects
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 11.1.x.

## Release 11.1.6

### Migration to latest Apicurio Registry

{{site.data.reuse.short_name}} 11.1.6 includes support for Apicurio Registry 2.4.1. Ensure all applications connecting to {{site.data.reuse.short_name}} that use the schema registry are using Apicurio client libraries version 2.4.1 or later, then [migrate to the latest Apicurio](../../troubleshooting/upgrade-apicurio/).

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.1.6 contains security and bug fixes.

### Documentation: Highlighting differences between versions

Any difference in features or behavior introduced by {{site.data.reuse.short_name}} 11.1.6 compared to 11.1.5 or earlier is highlighted in this documentation by using the following graphic: ![Event Streams 11.1.6 icon]({{ 'images' | relative_url }}/11.1.6.svg "In Event Streams 11.1.6")

## Release 11.1.5

### Kafka version upgraded to 3.4.0

{{site.data.reuse.short_name}} version 11.1.5 includes Kafka release 3.4.0, and supports the use of all Kafka interfaces.

### Support for {{site.data.reuse.short_name}} CLI when using SCRAM authentication

{{site.data.reuse.short_name}} version 11.1.5 and later supports [SCRAM authentication access](../../installing/configuring/#configuring-ui-and-cli-security) to the {{site.data.reuse.short_name}} CLI.

Kafka users that have been configured to use SCRAM-SHA-512 authentication can log in to the {{site.data.reuse.short_name}} CLI and run commands based on the ACL permissions of the user. For more information, see [managing access to the UI and CLI with SCRAM](../../security/managing-access/#managing-access-to-the-ui-and-cli-with-scram).

### JmxTrans is deprecated

Support for JmxTrans in {{site.data.reuse.short_name}} version 11.1.5 and later is deprecated. For more information, see [Strimzi GitHub issue 7693](https://github.com/strimzi/strimzi-kafka-operator/issues/7693){:target="_blank"}.

### Support for OpenTelemetry with IBM Instana

{{site.data.reuse.short_name}} 11.1.5 introduces support for [OpenTelemetry with IBM Instana](../../administering/tracing/#opentelemetry-tracing-with-instana) to provide real-time insights into the performance and behavior of your event-driven applications.

**Note:** In {{site.data.reuse.cp4i}} 2022.4.1 and later, the integration tracing capability with the Operations Dashboard is deprecated. For more information, see the {{site.data.reuse.cp4i}} [documentation](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.4?topic=capabilities-integration-tracing-deployment){:target="_blank"}.


### Technology Preview features

Technology Preview features are available to evaluate potential upcoming features. Such features are intended for testing purposes only and not for production use. IBM does not support these features, but might help with any issues raised against them. IBM welcomes feedback on Technology Preview features to improve them. As the features are still under development, functions and interfaces can change, and it might not be possible to upgrade when updated versions become available.

IBM offers no guarantee that Technology Preview features will be part of upcoming releases and as such become fully supported.

{{site.data.reuse.short_name}} version 11.1.5 includes [Apache Kafka Raft (KRaft)](https://cwiki.apache.org/confluence/display/KAFKA/KIP-500%3A+Replace+ZooKeeper+with+a+Self-Managed+Metadata+Quorum){:target="_blank"} as a Technology Preview feature.
KRaft replaces ZooKeeper for managing metadata, moving the overall handling of metadata into Kafka itself.

Find out more about [enabling KRaft and its limitations](../../installing/installing/#technology-preview-feature-kraft) for {{site.data.reuse.short_name}}.

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.1.5 contains security and bug fixes.

### Documentation: Highlighting differences between versions

Any difference in features or behavior introduced by {{site.data.reuse.short_name}} 11.1.5 compared to 11.1.4 or earlier is highlighted in this documentation by using the following graphic: ![Event Streams 11.1.5 icon]({{ 'images' | relative_url }}/11.1.5.svg "In Event Streams 11.1.5")



## Release 11.1.4

### Apicurio: set applications to use latest client libraries

Support for Apicurio client libraries version 2.3.x and earlier is deprecated. Ensure all applications connecting to {{site.data.reuse.short_name}} that use the schema registry are using Apicurio client libraries version 2.4.1 or later.

### Kafka version upgraded to 3.3.1

{{site.data.reuse.short_name}} version 11.1.4 includes Kafka release 3.3.1, and supports the use of all Kafka interfaces.

### Support for {{site.data.reuse.openshift}} 4.12

{{site.data.reuse.short_name}} 11.1.4 introduces support for {{site.data.reuse.openshift}} 4.12.

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.1.4 contains security and bug fixes.

## Release 11.1.3

### Support for {{site.data.reuse.openshift}} 4.12

{{site.data.reuse.short_name}} 11.1.3 includes support for {{site.data.reuse.openshift}} 4.12.

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.1.3 contains security and bug fixes.

## Release 11.1.2

{{site.data.reuse.short_name}} release 11.1.2 contains security and bug fixes.

## Release 11.1.1

### Expanded feature support when using SCRAM authentication

Support for the following features is now available when using SCRAM authentication:

- If enabled, users can delete topics in the UI with the **Topic Delete** button in the overflow menu.
- The geo-replication feature is available for all users.

For more information, see [managing access to the UI with SCRAM](../../security/managing-access/#managing-access-to-the-ui-and-cli-with-scram).

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.1.1 contains security and bug fixes.

### Documentation: Highlighting differences between versions

Any difference in features or behavior introduced by {{site.data.reuse.short_name}} 11.1.1 compared to 11.1.0 or earlier is highlighted in this documentation by using the following graphic: ![Event Streams 11.1.1 icon]({{ 'images' | relative_url }}/11.1.1.svg "In Event Streams 11.1.1")

## Release 11.1.0

### Kafka version upgraded to 3.2.3

{{site.data.reuse.short_name}} version 11.1.0 includes Kafka release 3.2.3, and supports the use of all Kafka interfaces.

### Apicurio version updated to 2.3.1

{{site.data.reuse.short_name}} 11.1.0 includes Apicurio Registry version 2.3.1 for [managing schemas](../../schemas/overview/#schema-registry).

### Foundational services a prerequisite for flexibility

{{site.data.reuse.icpfs}} is now a prerequisite. {{site.data.reuse.short_name}} supports {{site.data.reuse.fs}} version 3.19.0 or later 3.x releases, providing support for both the Continuous Delivery (CD) and the Long Term Service Release (LTSR) version of {{site.data.reuse.fs}} (for more information, see the [prerequisites](../../installing/prerequisites/#ibm-cloud-pak-foundational-services)).

### Simplified installation and upgrade process

{{site.data.reuse.short_name}} 11.1.0 introduces automatic [upgrade](../../installing/upgrading) of {{site.data.reuse.short_name}} instances. The {{site.data.reuse.short_name}} operator deploys and manages only a single version of the {{site.data.reuse.short_name}} instance. When upgrading {{site.data.reuse.short_name}}, the operator upgrades instances to the version supported by the operator, so you no longer have to upgrade the instances separately.

### Support for SCRAM authentication

{{site.data.reuse.short_name}} version 11.1.0 introduces support for SCRAM authentication access to the {{site.data.reuse.short_name}} UI (for more information, see [configuring UI and CLI security](../../installing/configuring/#configuring-ui-and-cli-security)). Kafka users that have been configured to use SCRAM-SHA-512 authentication can log in to the UI and access components based on the ACL permissions of the user.

**Note:** The following features are not available in this release of {{site.data.reuse.short_name}} when using SCRAM authentication:
- Metrics information and dashboards
- Geo-replication
- {{site.data.reuse.short_name}} CLI

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.1.0 contains security and bug fixes.
