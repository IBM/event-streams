---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 11.1.x.

## Release 11.1.3

{{site.data.reuse.short_name}} release 11.1.3 contains security and bug fixes.

## Release 11.1.2

{{site.data.reuse.short_name}} release 11.1.2 contains security and bug fixes.

## Release 11.1.1

### Expanded feature support when using SCRAM authentication

Support for the following features is now available when using SCRAM authentication:

- If enabled, users can delete topics in the UI with the **Topic Delete** button in the overflow menu.
- The geo-replication feature is available for all users.

For more information, see [managing access to the UI with SCRAM](../../security/managing-access/#managing-access-to-the-ui-with-scram).

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.1.1 contains security and bug fixes.

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

{{site.data.reuse.short_name}} version 11.1.0 introduces support for SCRAM authentication access to the {{site.data.reuse.short_name}} UI (for more information, see [configuring UI security](../../installing/configuring/#configuring-ui-security)). Kafka users that have been configured to use SCRAM-SHA-512 authentication can log in to the UI and access components based on the ACL permissions of the user.

**Note:** The following features are not available in this release of {{site.data.reuse.short_name}} when using SCRAM authentication:
- Metrics information and dashboards
- Geo-replication
- {{site.data.reuse.short_name}} CLI

### Security and bug fixes

{{site.data.reuse.short_name}} release 11.1.0 contains security and bug fixes.
