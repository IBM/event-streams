---
title: "Migrating existing applications to the Event Streams schema registry"
excerpt: "Read about how you can migrate to using the Event Streams schema registry."
categories: schemas
slug: migrating
toc: true
---

If you are using the Confluent Platform schema registry, {{site.data.reuse.short_name}} provides a migration path for moving your Kafka consumers and producers over to use the Apicurio Registry in {{site.data.reuse.short_name}}.

{{site.data.reuse.apicurio_note}}

## Migrating schemas to Apicurio Registry in {{site.data.reuse.short_name}}

To migrate schemas, you can use schema auto-registration in your Kafka producer, or you can manually migrate schemas by downloading the schema definitions from the Confluent Platform schema registry and adding them to the Apicurio Registry in {{site.data.reuse.short_name}}.

### Migrating schemas with auto-registration

When using auto-registration, the schema will be automatically uploaded to the Apicurio Registry in {{site.data.reuse.short_name}}, and named with the subject ID (which is based on the subject name strategy in use) and a random suffix.

Auto-registration is enabled by default in the Confluent Platform schema registry client library. To disable it, set the `auto.register.schemas` property to `false`.

**Note:** To auto-register schemas in the Apicurio Registry in {{site.data.reuse.short_name}}, you need credentials that have producer permissions and permission to create schemas. You can generate credentials by using the {{site.data.reuse.short_name}} [UI](../../security/managing-access/#creating-a-kafkauser-in-the-event-streams-ui) or [CLI](../../security/managing-access/#creating-a-kafkauser-in-the-event-streams-cli).

### Migrating schemas manually

To manually migrate the schemas, download the schema definitions from the Confluent Platform schema registry, and add them to the Apicurio Registry in {{site.data.reuse.short_name}}. When manually adding schemas to the Apicurio Registry in {{site.data.reuse.short_name}}, the provided schema name must match the subject ID used by the Confluent Platform schema registry subject name strategy.

If you are using the default `TopicNameStrategy`, the schema name must be `<TOPIC_NAME>-<'value'|'key'>`

If you are using the `RecordNameStrategy`, the schema name must be `<SCHEMA_DEFINITION_NAMESPACE>.<SCHEMA_DEFINITION_NAME>`

For example, if you are using the default `TopicNameStrategy` as your subject name strategy, and you are serializing your data into the message value and producing to the **MyTopic** topic, then the schema name you must provide when adding the schema in the UI must be `MyTopic-value`

For example, if you are using the `RecordNameStrategy` as your subject name strategy, and the schema definition file begins with the following, then the schema name you must provide when adding the schema in the UI must be `org.example.Book`:

```
{
    "type": "record",
    "name": "Book",
    "namespace": "org.example",
    "fields": [
...
```

If you are using the CLI, run the following command when adding the schema:

`cloudctl es schema-add --create --name org.example.Book --version 1.0.0 --file /path/to/Book.avsc`


## Migrating a Kafka producer application

To migrate a Kafka producer application that uses the Confluent Platform schema registry, secure the connection from your application to {{site.data.reuse.short_name}}, and add additional properties to enable the Confluent Platform schema registry client library to interact with the Apicurio Registry in {{site.data.reuse.short_name}}.

1. Configure your producer application to [secure the connection](../../getting-started/connecting/#securing-the-connection) between the producer and {{site.data.reuse.short_name}}.
2. Retrieve the full URL for the {{site.data.reuse.short_name}} [API endpoint](../../connecting/rest-api/#prerequisites), including the host name and port number by using the following command:\\
  `cloudctl es init`
3. Ensure you add the following schema properties to your Kafka producers:

   Property name        |  Property value
   ---------------------|----------------
    `schema.registry.url` |  `https://<host name>:<API port>`
    `basic.auth.credentials.source` |  `SASL_INHERIT`

   You can also use the following code snippet for Java applications:

   ```
   props.put(AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, "https://<host name>:<API port>/apis/ccompat/v6");
   props.put(AbstractKafkaSchemaSerDeConfig.BASIC_AUTH_CREDENTIALS_SOURCE, "SASL_INHERIT");
   ```

4. Set the Java SSL truststore JVM properties to allow the Confluent Platform schema registry client library to make HTTPS calls to the the Apicurio Registry in {{site.data.reuse.short_name}}. For example:


   ```
   export KAFKA_OPTS="-Djavax.net.ssl.trustStore=/path/to/es-cert.jks \ 
      -Djavax.net.ssl.trustStorePassword=password"
   ```

## Migrating a Kafka consumer application

To migrate a Kafka consumer application that uses the Confluent Platform schema registry, secure the connection from your application to {{site.data.reuse.short_name}}, and add additional properties to enable the Confluent Platform schema registry client library to interact with the Apicurio Registry in {{site.data.reuse.short_name}}.

1. Configure your consumer application to [secure the connection](../../getting-started/connecting/#securing-the-connection) between the consumer and {{site.data.reuse.short_name}}.
2. Retrieve the full URL for the {{site.data.reuse.short_name}} [API endpoint](../../connecting/rest-api/#prerequisites), including the host name and port number by using the following command:\\
  `cloudctl es init`
3. Ensure you add the following schema properties to your Kafka producers:

   Property name        |  Property value
   ---------------------|----------------
    `schema.registry.url` |  `https://<schema_registry_endpoint>/apis/ccompat/v6`
    `basic.auth.credentials.source` |  `SASL_INHERIT`

   You can also use the following code snippet for Java applications:

   ```
   props.put(AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, "https://<schema_registry_endpoint>/apis/ccompat/v6");
   props.put(AbstractKafkaSchemaSerDeConfig.BASIC_AUTH_CREDENTIALS_SOURCE, "SASL_INHERIT");
   ```

4. Set the Java SSL truststore JVM properties to allow the Confluent Platform schema registry client library to make HTTPS calls to the Apicurio Registry in {{site.data.reuse.short_name}}. For example:


   ```
   export KAFKA_OPTS="-Djavax.net.ssl.trustStore=/path/to/es-cert.jks \ 
       -Djavax.net.ssl.trustStorePassword=password"
   ```
