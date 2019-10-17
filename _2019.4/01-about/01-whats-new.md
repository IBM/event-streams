---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 2019.4.1.

### Support for multiple availability zones

{{site.data.reuse.short_name}} now supports running a single cluster that spans [multiple zones](../../installing/planning/#multizone-support).

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
