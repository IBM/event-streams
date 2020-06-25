---
title: "Using the schema API"
excerpt: "Using the schema API."
categories: schemas
slug: schema-api
toc: true
---

{{site.data.reuse.short_name}} provides a Java library to enable Kafka applications to serialize and deserialize messages using schemas stored in your {{site.data.reuse.short_name}} schema registry. Using the schema registry serdes library API, schema versions are automatically downloaded from your schema registry, checked to see if they are in a disabled or deprecated state, and cached. The schemas are used to serialize messages produced to Kafka and deserialize messages consumed from Kafka.

Schemas downloaded by the schema registry serdes library API are cached in memory with a 10 minute expiration period. This means that if a schema is deprecated or disabled, it might take 10 minutes before consuming or producing applications will see the change. To change the expiration period, set the `SchemaRegistryConfig.PROPERTY_SCHEMA_CACHE_REFRESH_RATE` configuration property to a new milliseconds value.

For more details, including code snippets that use the schema registry serdes API, see [setting Java applications to use schemas](../setting-java-apps).

For full details of the {{site.data.reuse.short_name}} schema registry serdes API, see the [Schema API Javadoc](../../schema-api/){:target="_blank"}.
