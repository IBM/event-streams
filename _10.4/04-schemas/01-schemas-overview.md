---
title: "Schemas overview"
excerpt: "Learn about schemas and the schema registry, and understand how schemas can help manage your data more efficiently."
categories: schemas
slug: overview
toc: true
---

Apache Kafka can handle any data, but it does not validate the information in the messages. However, efficient handling of data often requires that it includes specific information in a certain format. Using schemas, you can define the structure of the data in a message, ensuring that both producers and consumers use the correct structure.

Schemas help producers create data that conforms to a predefined structure, defining the fields that need to be present together with the type of each field. This definition then helps consumers parse that data and interpret it correctly. {{site.data.reuse.short_name}} supports schemas and includes a schema registry for using and managing schemas.

It is common for all of the messages on a topic to use the same schema. The key and value of a message can each be described by a schema.

![Schemas: key and value of a message diagram.]({{ 'images' | relative_url }}/Schema_Basics_1.svg "Diagram representing how a schema can help define a structure for the key and value pairs of a message.")

<!-- A schema defines the structure of the data in a message. After the structure is described in a schema, it makes it much easier to ensure that producers and consumers use the correct structure.-->

## Schema registry

Schemas are stored in internal Kafka topics by the [Apicurio Registry](https://www.apicur.io/registry/docs/apicurio-registry/1.3.3.Final/index.html){:target="_blank"}, an open-source schema registry. In addition to storing a versioned history of schemas, Apicurio Registry provides an interface for retrieving them. Each {{site.data.reuse.short_name}} cluster has its own instance of Apicurio Registry providing schema registry functionality.

Your producers and consumers validate the data against the specified schema stored in the schema registry. This is in addition to going through Kafka brokers. The schemas do not need to be transferred in the messages this way, meaning the messages are smaller than without using a schema registry.

![Schema architecture diagram.]({{ 'images' | relative_url }}/Schema_registry_arch.png "Diagram showing a schema registry architecture. A producer is sending messages and a consumer is reading messages, while both are retrieving the schema from the schema registry.")

If you are migrating to use {{site.data.reuse.short_name}} as your Kafka solution, and have been using a schema registry from a different provider, you can [migrate](../migrating/) to using {{site.data.reuse.short_name}} and the Apicurio Registry.

The {{site.data.reuse.short_name}} schema registry provided in earlier versions is deprecated in version 10.1.0 and later. If you are upgrading to {{site.data.reuse.short_name}} version 10.2.0 or later from an earlier version, you can [migrate](../../installing/migrating-to-apicurio/) to the Apicurio Registry from the deprecated schema registry.

<!--The schema registry is used to hold the schemas. Each Event Streams cluster has its own schema registry.	It provides interfaces for storing and retrieving schemas. In most situations, the interfaces are used behind the scenes.-->

## Apache Avro data format

Schemas are defined using [Apache Avro](https://avro.apache.org/){:target="_blank"}, an open-source data serialization technology commonly used with Apache Kafka. It provides an efficient data encoding format, either by using the compact binary format or a more verbose, but human-readable [JSON](https://www.json.org){:target="_blank"} format.

The schema registry in {{site.data.reuse.short_name}} uses Apache Avro data formats. When messages are sent in the Avro format, they contain the data and the unique identifier for the schema used. The identifier specifies which schema in the registry is to be used for the message.

Avro has support for a wide range of data types, including primitive types (`null`, `boolean`, `integer`, `long`, `float`, `double`, `bytes`, and `string`) and complex types (`record`, `enum`, `array`, `map`, `union`, and `fixed`).

Learn more about how you can [create schemas](../creating) in {{site.data.reuse.short_name}}.

![Schemas: Avro format.]({{ 'images' | relative_url }}/Schema_Basics_3.svg "Diagram showing a representation of a message sent in Avro format.")

<!-- Apache Avro is an open-source data serialization technology. The schema registry uses Apache Avro data formats.	Apache Avro is commonly used with Apache Kafka. It provides an efficient data encoding format, either using the compact binary format or a more verbose but human-readable JSON format.-->

## Serialization and deserialization

A producing application uses a serializer to produce messages conforming to a specific schema. As mentioned earlier, the message contains the data in Avro format, together with the schema identifier.

A consuming application then uses a deserializer to consume messages that have been serialized using the same schema. When a consumer reads a message sent in Avro format, the deserializer finds the identifier of the schema in the message, and retrieves the schema from the schema registry to deserialize the data.

This process provides an efficient way of ensuring that data in messages conform to the required structure.

Serializers and deserializers that automatically retrieve the schemas from the schema registry as required are provided by {{site.data.reuse.long_name}}. If you need to use schemas in an environment for which serializers or deserializers are not provided, you can [use the command line or UI](../setting-nonjava-apps/#retrieving-the-schema-definition-from-the-schema-registry) directly to retrieve the schemas.

![Schemas: Serializer and deserializer.]({{ 'images' | relative_url }}/Schema_Basics_4.svg "Diagram showing a representation of where a serializer and a deserializer fits into the Event Streams architecture.")

<!-- A producing application uses a serializer to produce messages conforming to a schema. A consuming application uses a deserializer to consume messages that have been serialized using a schema._

_Serializers and deserializers that automatically retrieve the schemas from the schema registry as required are provided or generated by IBM Event Streams. If you need to use schemas in an environment for which serializers or deserializers are not provided, you can call the schema registry API directly to retrieve the schemas._-->

## Versions and compatibility

Whenever you add a schema, and any subsequent versions of the same schema, Apicurio Registry validates the format automatically and warns of any issues. You can evolve your schemas over time to accommodate changing requirements. You simply create a new version of an existing schema, and the registry ensures that the new version is compatible with the existing version, meaning that producers and consumers using the existing version are not broken by the new version.

When you create a new version of the schema, you simply add it to the registry and version it. You can then set your producers and consumers that use the schema to start using the new version. Until they do, both producers and consumers are warned that a new version of the schema is available.

![Schemas: versions.]({{ 'images' | relative_url }}/Schema_Basics_5.svg "Diagram showing a representation of schema versions.")

## Lifecycle

When a new version is used, you can deprecate the previous version. Deprecating means that producing and consuming applications still using the deprecated version are warned that a new version is available to upgrade to. When you upgrade your producers to use the new version, you can disable the older version so it can no longer be used, or you can remove it entirely from the schema registry.

You can use the {{site.data.reuse.short_name}} UI or CLI to [manage the lifecycle](../manage-lifecycle/) of schemas, including registering, versioning, and deprecating.

![Schemas: Avro format.]({{ 'images' | relative_url }}/Schema_Basics_6.svg "Diagram showing a representation of schema lifecycle stages.")

<!-- _Sometimes, the schema for a topic needs to change to accommodate new requirements. This can be achieved by creating a new version of the existing schema. The schema registry ensures that the new version is compatible with the existing version, meaning that producers and consumers using the existing version will not be broken by the new version._

_When a new version of a schema begins to be used, it is best to deprecate the previous version. This simply means that producing applications using the deprecated version are warned that they should upgrade. When a deprecated schema is no longer being used, it can be disabled so it can no longer be used, or even removed entirely from the schema registry._ -->

## How to get started with schemas

1. [Create schemas](../creating/#creating-schemas)
2. [Add schemas](../creating/#adding-schemas-to-the-registry) to schema registry
3. Set your [Java](../setting-java-apps/) or [non-Java](../setting-nonjava-apps/) applications to use schemas
4. Manage schema [lifecycle](../manage-lifecycle/)
