---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
layout: redirects
toc: true
---

## Release 2019.4.6

{{site.data.reuse.short_name}} 2019.4.6 contains security and bug fixes.
## Release 2019.4.5

{{site.data.reuse.short_name}} 2019.4.5 contains security and bug fixes.

## Release 2019.4.4

{{site.data.reuse.short_name}} 2019.4.4 contains security and bug fixes.

For more information about the bugs fixed in 2019.4.4, see the [issues page](https://github.com/IBM/event-streams/issues?utf8=%E2%9C%93&q=is:issue+label:bug+label:2019.4.4){:target="_blank"}.

## Release 2019.4.3

{{site.data.reuse.short_name}} 2019.4.3 contains security and bug fixes.

For more information about the bugs fixed in 2019.4.3, see the [issues page](https://github.com/IBM/event-streams/issues?utf8=%E2%9C%93&q=is:issue+label:bug+label:2019.4.3){:target="_blank"}.

## Release 2019.4.2

Find out what is new in {{site.data.reuse.long_name}} version 2019.4.2.

### Support for {{site.data.reuse.openshift}} 4.3

{{site.data.reuse.short_name}} 2019.4.2 introduces support for {{site.data.reuse.openshift}} 4.3.

{{site.data.reuse.openshift_short}} 4.2 is also supported in this version, continuing the support introduced as part of {{site.data.reuse.short_name}} 2019.4.1 in {{site.data.reuse.cp4i}}.

### Kafka version upgraded to 2.3.1

{{site.data.reuse.short_name}} version 2019.4.2 includes Kafka release 2.3.1, and supports the use of all Kafka interfaces.

### Documentation: Highlighting differences between versions

Any difference in features or behavior introduced by {{site.data.reuse.short_name}} 2019.4.2 compared to 2019.4.1 is highlighted in this documentation using the following graphic: ![Event Streams 2019.4.2 icon](../../../images/2019.4.2.svg "In Event Streams 2019.4.2.")

### {{site.data.reuse.ce_short}} is deprecated

The {{site.data.reuse.ce_long}} has been removed from version 2019.4.2.

{{site.data.reuse.ce_deprecated}}


## Release 2019.4.1

Find out what is new in {{site.data.reuse.long_name}} version 2019.4.1.

### Support for {{site.data.reuse.openshift}} 4.2

{{site.data.reuse.long_name}} 2019.4.1 installed in [{{site.data.reuse.cp4i}}](https://www.ibm.com/support/knowledgecenter/SSGT7J_19.4/welcome.html){:target="_blank"} 2019.4.1 introduces support for {{site.data.reuse.openshift}} 4.2.

### Support for multiple availability zones

{{site.data.reuse.short_name}} now supports running a single cluster that spans [multiple zones]({{ 'support' | relative_url }}).

### Support for SSL client authentication when using the REST producer

In addition to using HTTP authorization, you can now use the {{site.data.reuse.short_name}} REST producer API with [SSL client authentication](../../connecting/rest-api/).

This means you can provide the required API key with each REST call by embedding it into an SSL client certificate. This is useful when you are using third-party software where you cannot control the HTTP headers sent, or systems such as CICS events over HTTP.

### Changing certificates for existing deployments

{{site.data.reuse.short_name}} 2019.4.1 now supports updating your external and internal [certificates](../../security/updating-certificates/) for an existing deployment.

### Kafka version upgraded to 2.3.0

{{site.data.reuse.short_name}} version 2019.4.1 includes Kafka release 2.3.0, and supports the use of all Kafka interfaces.

### Support for {{site.data.reuse.openshift}} routes

{{site.data.reuse.short_name}} now supports using {{site.data.reuse.openshift_short}} [routes](https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html){:target="_blank"}.

If you are using the {{site.data.reuse.openshift_short}} and have upgraded to {{site.data.reuse.short_name}} version 2019.4.1, you can [switch](../../installing/upgrading/#switch-to-routes) to using OpenShift routes.

### Support for {{site.data.reuse.icp}} version 3.2.1

{{site.data.reuse.short_name}} 2019.4.1 is [supported](../../installing/prerequisites/#container-environment) on {{site.data.reuse.icp}} 3.2.1.

### Default resource requirements have changed

See the updated tables for the {{site.data.reuse.short_name}} [resource requirements](../../installing/prerequisites/#helm-resource-requirements).

### Deprecated features

The simulated topic has been removed from the UI in {{site.data.reuse.short_name}} version 2019.4.1 and later.
