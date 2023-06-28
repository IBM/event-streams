---
title: "What's new"
excerpt: "Find out what is new in IBM Event Streams."
categories: about
slug: whats-new
layout: redirects
toc: true
---

Find out what is new in {{site.data.reuse.long_name}} version 10.5.

## Kafka version upgraded to 2.8.1

{{site.data.reuse.short_name}} version 10.5.0 includes Kafka release 2.8.1, and supports the use of all Kafka interfaces.

## Support for IBM Power Systems

Adding to the existing support for Linux® 64-bit (x86_64) systems and Linux on IBM® Z systems (s390x), {{site.data.reuse.short_name}} 10.5.0 introduces [support]({{ 'support/#support-matrix' | relative_url }}) for Linux on IBM Power Systems (ppc64le).

## {{site.data.reuse.short_name}} uses the Apicurio Registry for schemas

The previous schema registry in {{site.data.reuse.short_name}} was deprecated in version 10.1.0 and is not an available option for schemas in {{site.data.reuse.short_name}} version 10.5.0 and later. Use the open-source [Apicurio Registry](https://www.apicur.io/registry/docs/apicurio-registry/1.3.3.Final/index.html){:target="_blank"} included in {{site.data.reuse.short_name}} version 10.1.0 and later to manage schemas.

If you are upgrading to {{site.data.reuse.short_name}} version 10.5.0 from an earlier version and you are using the deprecated registry option previously used for schemas, you can [migrate](../../installing/migrating-to-apicurio/) to the Apicurio Registry.

## {{site.data.reuse.short_name}} schema registry `serdes` library deprecated

The {{site.data.reuse.short_name}} schema registry `serdes` library provided in earlier versions is deprecated in version 10.5.0. Use the open-source [Apicurio Registry](https://www.apicur.io/registry/docs/apicurio-registry/1.3.3.Final/index.html){:target="_blank"} `serdes` library to serialize and deserialize messages based on schemas stored in the Apicurio Registry.
